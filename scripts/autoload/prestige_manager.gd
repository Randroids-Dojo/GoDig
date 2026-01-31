extends Node
## PrestigeManager - Handles the prestige/rebirth system.
##
## Players can reset their progress in exchange for prestige points that
## provide permanent bonuses. Prestige is available after reaching a minimum depth.

signal prestige_available(points_to_gain: int)
signal prestige_completed(new_total_points: int, bonuses: Dictionary)
signal prestige_points_changed(new_total: int)

## Minimum depth required to prestige
const MIN_PRESTIGE_DEPTH := 500

## Points earned per 100 meters of depth reached
const POINTS_PER_100_DEPTH := 1

## Bonus depth points for achieving milestones
const MILESTONE_BONUS_POINTS := {
	500: 1,   # Reaching 500m grants +1 extra point
	750: 2,   # 750m grants +2 extra
	1000: 3,  # 1000m grants +3 extra
	1500: 5,  # 1500m grants +5 extra
	2000: 10, # 2000m grants +10 extra
}

## Prestige bonuses per point spent
const BONUS_TYPES := {
	"mining_speed": {"name": "Mining Speed", "per_point": 0.05, "max_points": 20},        # +5% per point, max 100%
	"coin_bonus": {"name": "Coin Bonus", "per_point": 0.02, "max_points": 25},            # +2% per point, max 50%
	"fall_resistance": {"name": "Fall Resistance", "per_point": 0.03, "max_points": 10},  # +3% per point, max 30%
	"starting_coins": {"name": "Starting Coins", "per_point": 50, "max_points": 20},      # +50 coins per point, max 1000
	"inventory_bonus": {"name": "Inventory Slots", "per_point": 1, "max_points": 5},      # +1 slot per point, max 5
}

## Current prestige level (number of times prestiged)
var prestige_level: int = 0

## Total accumulated prestige points
var total_prestige_points: int = 0

## Available (unspent) prestige points
var available_points: int = 0

## Points allocated to each bonus type
var allocated_points: Dictionary = {
	"mining_speed": 0,
	"coin_bonus": 0,
	"fall_resistance": 0,
	"starting_coins": 0,
	"inventory_bonus": 0,
}

## Highest depth reached in current run (tracked for prestige calculation)
var current_run_max_depth: int = 0


func _ready() -> void:
	# Connect to depth updates
	call_deferred("_connect_signals")
	print("[PrestigeManager] Ready")


func _connect_signals() -> void:
	if GameManager and GameManager.has_signal("max_depth_updated"):
		GameManager.max_depth_updated.connect(_on_max_depth_updated)


func _on_max_depth_updated(depth: int) -> void:
	if depth > current_run_max_depth:
		current_run_max_depth = depth
		if can_prestige():
			prestige_available.emit(calculate_prestige_points())


## Check if player can prestige
func can_prestige() -> bool:
	return current_run_max_depth >= MIN_PRESTIGE_DEPTH


## Calculate how many prestige points would be earned from current run
func calculate_prestige_points() -> int:
	if current_run_max_depth < MIN_PRESTIGE_DEPTH:
		return 0

	# Base points from depth
	var points := int(current_run_max_depth / 100) * POINTS_PER_100_DEPTH

	# Bonus points from milestones
	for milestone in MILESTONE_BONUS_POINTS:
		if current_run_max_depth >= milestone:
			points += MILESTONE_BONUS_POINTS[milestone]

	return points


## Execute prestige - reset progress and gain points
func do_prestige() -> Dictionary:
	if not can_prestige():
		push_warning("[PrestigeManager] Cannot prestige - minimum depth not reached")
		return {}

	var points_earned := calculate_prestige_points()

	# Increment prestige level
	prestige_level += 1

	# Add earned points
	total_prestige_points += points_earned
	available_points += points_earned

	prestige_points_changed.emit(total_prestige_points)

	# Reset game progress (keeping prestige bonuses)
	_reset_progress()

	var result := {
		"points_earned": points_earned,
		"total_points": total_prestige_points,
		"prestige_level": prestige_level,
		"bonuses": get_active_bonuses(),
	}

	prestige_completed.emit(total_prestige_points, get_active_bonuses())
	print("[PrestigeManager] Prestige #%d completed! Earned %d points (total: %d)" % [
		prestige_level, points_earned, total_prestige_points
	])

	# Save immediately
	if SaveManager:
		SaveManager.save_game(true)

	return result


## Reset progress for prestige (keeps prestige bonuses)
func _reset_progress() -> void:
	current_run_max_depth = 0

	# Reset game state through managers
	if GameManager:
		# Start with bonus coins from prestige
		var starting_coins := get_bonus_value("starting_coins")
		GameManager.set_coins(starting_coins)
		GameManager.current_depth = 0
		GameManager.reset_milestones()
		GameManager.reset_tutorial()

	if InventoryManager:
		InventoryManager.clear_all()
		# Apply inventory bonus
		var bonus_slots := int(get_bonus_value("inventory_bonus"))
		InventoryManager.max_slots = 8 + bonus_slots

	if PlayerData:
		PlayerData.reset()

	if PlayerStats:
		# Keep lifetime stats but reset session stats
		PlayerStats.reset_session_stats()


## Allocate points to a bonus type
func allocate_point(bonus_type: String) -> bool:
	if not BONUS_TYPES.has(bonus_type):
		push_warning("[PrestigeManager] Unknown bonus type: %s" % bonus_type)
		return false

	if available_points <= 0:
		push_warning("[PrestigeManager] No available points to allocate")
		return false

	var max_points: int = BONUS_TYPES[bonus_type]["max_points"]
	if allocated_points[bonus_type] >= max_points:
		push_warning("[PrestigeManager] Bonus %s already at max level" % bonus_type)
		return false

	allocated_points[bonus_type] += 1
	available_points -= 1

	prestige_points_changed.emit(total_prestige_points)
	print("[PrestigeManager] Allocated point to %s (now %d/%d)" % [
		bonus_type, allocated_points[bonus_type], max_points
	])

	return true


## Get the current value of a bonus
func get_bonus_value(bonus_type: String) -> float:
	if not BONUS_TYPES.has(bonus_type):
		return 0.0

	var points_allocated: int = allocated_points.get(bonus_type, 0)
	var per_point: float = BONUS_TYPES[bonus_type]["per_point"]

	return points_allocated * per_point


## Get all active bonuses as a dictionary
func get_active_bonuses() -> Dictionary:
	var bonuses := {}
	for bonus_type in BONUS_TYPES:
		var value := get_bonus_value(bonus_type)
		if value > 0:
			bonuses[bonus_type] = value
	return bonuses


## Get mining speed multiplier (1.0 + bonus)
func get_mining_speed_multiplier() -> float:
	return 1.0 + get_bonus_value("mining_speed")


## Get coin bonus multiplier (1.0 + bonus)
func get_coin_multiplier() -> float:
	return 1.0 + get_bonus_value("coin_bonus")


## Get fall damage resistance (0.0 - 1.0)
func get_fall_resistance() -> float:
	return get_bonus_value("fall_resistance")


## Get bonus starting coins
func get_starting_coins() -> int:
	return int(get_bonus_value("starting_coins"))


## Get bonus inventory slots
func get_bonus_inventory_slots() -> int:
	return int(get_bonus_value("inventory_bonus"))


## Get prestige level
func get_prestige_level() -> int:
	return prestige_level


## Get available (unspent) points
func get_available_points() -> int:
	return available_points


## Get total prestige points earned (all time)
func get_total_points() -> int:
	return total_prestige_points


## Get points allocated to a specific bonus
func get_allocated_points(bonus_type: String) -> int:
	return allocated_points.get(bonus_type, 0)


## Get max points for a bonus type
func get_max_points(bonus_type: String) -> int:
	if BONUS_TYPES.has(bonus_type):
		return BONUS_TYPES[bonus_type]["max_points"]
	return 0


## Reset for new game (keeps prestige progress)
func reset_run() -> void:
	current_run_max_depth = 0


## Full reset (for starting completely fresh)
func reset() -> void:
	prestige_level = 0
	total_prestige_points = 0
	available_points = 0
	current_run_max_depth = 0
	for bonus_type in allocated_points:
		allocated_points[bonus_type] = 0


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	return {
		"prestige_level": prestige_level,
		"total_prestige_points": total_prestige_points,
		"available_points": available_points,
		"allocated_points": allocated_points.duplicate(),
		"current_run_max_depth": current_run_max_depth,
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	prestige_level = data.get("prestige_level", 0)
	total_prestige_points = data.get("total_prestige_points", 0)
	available_points = data.get("available_points", 0)
	current_run_max_depth = data.get("current_run_max_depth", 0)

	# Load allocated points
	var saved_allocated = data.get("allocated_points", {})
	for bonus_type in allocated_points:
		allocated_points[bonus_type] = saved_allocated.get(bonus_type, 0)

	print("[PrestigeManager] Loaded - Level: %d, Total Points: %d, Available: %d" % [
		prestige_level, total_prestige_points, available_points
	])
