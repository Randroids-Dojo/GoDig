extends Node
## FrustrationTracker - Tracks player frustrations to recommend relevant upgrades.
##
## Records frustration events (inventory full, tool issues, deaths) and maps them
## to upgrade recommendations. The shop uses this to highlight "ah, that's what I needed!"
## upgrades that solve problems the player just experienced.

signal frustration_recorded(frustration_type: String, context: Dictionary)
signal recommended_upgrade_changed(upgrade_type: String)

# ============================================
# FRUSTRATION TYPES
# ============================================

enum FrustrationType {
	NONE,
	INVENTORY_FULL,       # Tried to pick up items but inventory was full
	SLOW_MINING,          # Took many hits to break a block (trip count based)
	TOOL_BROKEN,          # Tool durability ran out
	HARD_BLOCK,           # Encountered a block that requires higher tier tool
	DEATH_FALL,           # Died from falling
	DEATH_OTHER,          # Other death cause
	LADDER_SHORTAGE,      # Ran out of ladders during descent
	DEEP_DIVE_TEDIOUS,    # Long return trips to surface (depth-based)
}

## Frustration -> Recommended upgrade mapping
## Each frustration maps to an upgrade type that solves it
const FRUSTRATION_TO_UPGRADE := {
	FrustrationType.INVENTORY_FULL: "backpack",
	FrustrationType.SLOW_MINING: "pickaxe",
	FrustrationType.TOOL_BROKEN: "pickaxe",
	FrustrationType.HARD_BLOCK: "pickaxe",
	FrustrationType.DEATH_FALL: "boots",       # Fall damage reduction
	FrustrationType.DEATH_OTHER: "helmet",     # General survival
	FrustrationType.LADDER_SHORTAGE: "supplies", # Ladder bundle
	FrustrationType.DEEP_DIVE_TEDIOUS: "elevator", # Fast travel
}

## Human-readable descriptions for frustrations
const FRUSTRATION_DESCRIPTIONS := {
	FrustrationType.INVENTORY_FULL: "Your inventory was full!",
	FrustrationType.SLOW_MINING: "Mining felt slow...",
	FrustrationType.TOOL_BROKEN: "Your pickaxe broke!",
	FrustrationType.HARD_BLOCK: "You couldn't mine that block.",
	FrustrationType.DEATH_FALL: "You fell too far!",
	FrustrationType.DEATH_OTHER: "You died underground.",
	FrustrationType.LADDER_SHORTAGE: "You ran out of ladders!",
	FrustrationType.DEEP_DIVE_TEDIOUS: "Long way back to surface...",
}

# ============================================
# STATE
# ============================================

## Recent frustration events (type -> { timestamp, count, context })
var _recent_frustrations: Dictionary = {}

## Most recent frustration (highest priority for shop recommendation)
var _current_frustration: FrustrationType = FrustrationType.NONE

## Frustration decay time (frustrations become less relevant after this)
const FRUSTRATION_DECAY_SECONDS := 300.0  # 5 minutes

## Trip count for slow mining detection
var _trip_count: int = 0

## Depth tracking for tedious return detection
var _last_surface_depth: int = 0

## Blocks mined tracking (for slow mining detection)
var _blocks_mined_this_trip: int = 0
var _total_hits_this_trip: int = 0


func _ready() -> void:
	call_deferred("_connect_signals")
	print("[FrustrationTracker] Ready")


func _connect_signals() -> void:
	## Connect to relevant game signals to track frustrations

	# Inventory full
	if InventoryManager != null:
		InventoryManager.inventory_full.connect(_on_inventory_full)

	# Tool broken
	if PlayerData != null:
		PlayerData.tool_broken.connect(_on_tool_broken)

	# Depth tracking for tedious return detection
	if GameManager != null:
		GameManager.depth_updated.connect(_on_depth_updated)

	print("[FrustrationTracker] Connected to game signals")


# ============================================
# FRUSTRATION RECORDING
# ============================================

## Record a frustration event
func record_frustration(type: FrustrationType, context: Dictionary = {}) -> void:
	if type == FrustrationType.NONE:
		return

	var now := Time.get_unix_time_from_system()

	if _recent_frustrations.has(type):
		_recent_frustrations[type].timestamp = now
		_recent_frustrations[type].count += 1
		_recent_frustrations[type].context = context
	else:
		_recent_frustrations[type] = {
			"timestamp": now,
			"count": 1,
			"context": context,
		}

	# Update current frustration (most recent takes priority)
	_current_frustration = type

	# Emit signals
	var type_name: String = FrustrationType.keys()[type]
	frustration_recorded.emit(type_name, context)
	recommended_upgrade_changed.emit(get_recommended_upgrade())

	# Analytics tracking
	if AnalyticsManager != null:
		AnalyticsManager.log_event("frustration", {
			"type": type_name,
			"count": _recent_frustrations[type].count,
			"context": context,
		})

	print("[FrustrationTracker] Recorded frustration: %s (count: %d)" % [
		type_name, _recent_frustrations[type].count
	])


## Record death with cause
func record_death(cause: String, depth: int) -> void:
	var type := FrustrationType.DEATH_OTHER
	if cause == "fall":
		type = FrustrationType.DEATH_FALL

	record_frustration(type, {"cause": cause, "depth": depth})


## Record when player encounters a block too hard for their tool
func record_hard_block(block_tier: int, tool_tier: int) -> void:
	record_frustration(FrustrationType.HARD_BLOCK, {
		"block_tier": block_tier,
		"tool_tier": tool_tier,
	})


## Record when player runs out of ladders mid-dive
func record_ladder_shortage(depth: int, ladders_used: int) -> void:
	record_frustration(FrustrationType.LADDER_SHORTAGE, {
		"depth": depth,
		"ladders_used": ladders_used,
	})


## Track a mining hit (for slow mining detection)
func track_mining_hit() -> void:
	_total_hits_this_trip += 1


## Track a block mined (for slow mining detection)
func track_block_mined() -> void:
	_blocks_mined_this_trip += 1


## Called when player returns to surface - evaluate the trip
func evaluate_trip() -> void:
	# Check for slow mining (average hits per block > 3)
	if _blocks_mined_this_trip > 5:
		var avg_hits: float = float(_total_hits_this_trip) / float(_blocks_mined_this_trip)
		if avg_hits > 3.0:
			record_frustration(FrustrationType.SLOW_MINING, {
				"avg_hits": avg_hits,
				"blocks_mined": _blocks_mined_this_trip,
			})

	# Increment trip count
	_trip_count += 1

	# Check for tedious deep dives (depth > 100, multiple trips)
	if _last_surface_depth > 100 and _trip_count >= 3:
		record_frustration(FrustrationType.DEEP_DIVE_TEDIOUS, {
			"depth": _last_surface_depth,
			"trip_count": _trip_count,
		})

	# Reset trip tracking
	_blocks_mined_this_trip = 0
	_total_hits_this_trip = 0


## Clear old frustrations (call periodically or on new session)
func decay_frustrations() -> void:
	var now := Time.get_unix_time_from_system()
	var to_remove: Array[FrustrationType] = []

	for type: FrustrationType in _recent_frustrations:
		var data: Dictionary = _recent_frustrations[type]
		if now - data.timestamp > FRUSTRATION_DECAY_SECONDS:
			to_remove.append(type)

	for type in to_remove:
		_recent_frustrations.erase(type)

	# Update current frustration if it was removed
	if _current_frustration in to_remove:
		_current_frustration = _get_highest_priority_frustration()


# ============================================
# RECOMMENDATIONS
# ============================================

## Get the recommended upgrade type based on recent frustrations
func get_recommended_upgrade() -> String:
	if _current_frustration == FrustrationType.NONE:
		return ""

	if not FRUSTRATION_TO_UPGRADE.has(_current_frustration):
		return ""

	return FRUSTRATION_TO_UPGRADE[_current_frustration]


## Get description of current frustration (for shop UI)
func get_frustration_description() -> String:
	if _current_frustration == FrustrationType.NONE:
		return ""

	if not FRUSTRATION_DESCRIPTIONS.has(_current_frustration):
		return ""

	return FRUSTRATION_DESCRIPTIONS[_current_frustration]


## Check if a specific upgrade type is recommended
func is_upgrade_recommended(upgrade_type: String) -> bool:
	return get_recommended_upgrade() == upgrade_type


## Get frustration count for a type (for analytics/debugging)
func get_frustration_count(type: FrustrationType) -> int:
	if _recent_frustrations.has(type):
		return _recent_frustrations[type].count
	return 0


## Get all recent frustrations (for shop to show multiple recommendations)
func get_all_recent_frustrations() -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for type: FrustrationType in _recent_frustrations:
		var data: Dictionary = _recent_frustrations[type]
		var upgrade: String = FRUSTRATION_TO_UPGRADE.get(type, "")
		var description: String = FRUSTRATION_DESCRIPTIONS.get(type, "")

		result.append({
			"type": type,
			"type_name": FrustrationType.keys()[type],
			"upgrade": upgrade,
			"description": description,
			"count": data.count,
			"timestamp": data.timestamp,
		})

	# Sort by timestamp (most recent first)
	result.sort_custom(func(a, b): return a.timestamp > b.timestamp)

	return result


## Clear current frustration (call after player purchases recommended upgrade)
func clear_frustration(type: FrustrationType = FrustrationType.NONE) -> void:
	if type == FrustrationType.NONE:
		# Clear all
		_recent_frustrations.clear()
		_current_frustration = FrustrationType.NONE
	else:
		_recent_frustrations.erase(type)
		if _current_frustration == type:
			_current_frustration = _get_highest_priority_frustration()

	recommended_upgrade_changed.emit(get_recommended_upgrade())


# ============================================
# SIGNAL HANDLERS
# ============================================

func _on_inventory_full() -> void:
	record_frustration(FrustrationType.INVENTORY_FULL, {
		"slots_used": InventoryManager.get_used_slots() if InventoryManager else 0,
		"max_slots": InventoryManager.get_total_slots() if InventoryManager else 0,
	})


func _on_tool_broken() -> void:
	var tool = PlayerData.get_equipped_tool() if PlayerData else null
	record_frustration(FrustrationType.TOOL_BROKEN, {
		"tool_id": tool.id if tool else "unknown",
		"tool_tier": tool.tier if tool else 0,
	})


func _on_depth_updated(depth: int) -> void:
	# Track max depth for this dive
	if depth > _last_surface_depth:
		_last_surface_depth = depth

	# Player returned to surface
	if depth == 0 and _last_surface_depth > 0:
		evaluate_trip()
		_last_surface_depth = 0


## Get highest priority frustration from recent ones
func _get_highest_priority_frustration() -> FrustrationType:
	if _recent_frustrations.is_empty():
		return FrustrationType.NONE

	# Priority order: INVENTORY_FULL > TOOL_BROKEN > HARD_BLOCK > others
	var priority_order: Array[FrustrationType] = [
		FrustrationType.INVENTORY_FULL,
		FrustrationType.TOOL_BROKEN,
		FrustrationType.HARD_BLOCK,
		FrustrationType.SLOW_MINING,
		FrustrationType.DEATH_FALL,
		FrustrationType.DEATH_OTHER,
		FrustrationType.LADDER_SHORTAGE,
		FrustrationType.DEEP_DIVE_TEDIOUS,
	]

	for type in priority_order:
		if _recent_frustrations.has(type):
			return type

	return FrustrationType.NONE


# ============================================
# RESET / SAVE/LOAD
# ============================================

## Reset tracker state (for new game)
func reset() -> void:
	_recent_frustrations.clear()
	_current_frustration = FrustrationType.NONE
	_trip_count = 0
	_last_surface_depth = 0
	_blocks_mined_this_trip = 0
	_total_hits_this_trip = 0
	print("[FrustrationTracker] Reset")


## Get save data
func get_save_data() -> Dictionary:
	return {
		"trip_count": _trip_count,
		# Don't save frustrations - they should be session-based
	}


## Load save data
func load_save_data(data: Dictionary) -> void:
	_trip_count = data.get("trip_count", 0)
