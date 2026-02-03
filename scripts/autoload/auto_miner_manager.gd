extends Node
## AutoMinerManager autoload singleton for passive ore generation.
##
## Manages the Auto-Miner Station building which generates passive income
## of basic ores over time. Unlocks at 1000m depth as a v1.1 feature.
##
## Design Goals:
## - Passive income supplements, not replaces, active mining
## - ~10% of active mining income at equivalent depth
## - Simple slot-based optimization puzzle (not complex conveyor systems)

signal auto_miner_unlocked
signal auto_miner_upgraded(level: int)
signal ore_generated(ore_id: String, amount: int)
signal collection_ready(ores: Dictionary)

## Unlock depth for the auto-miner station
const UNLOCK_DEPTH := 1000

## Base output per slot per hour (in ore units)
const BASE_OUTPUT_PER_HOUR := 10

## Time between ore generation ticks (in seconds)
const GENERATION_INTERVAL := 60.0  # Every minute

## Upgrade level configurations
const UPGRADE_LEVELS := {
	1: {"slots": 1, "output_mult": 1.0, "cost": 50000},
	2: {"slots": 2, "output_mult": 1.5, "cost": 150000},
	3: {"slots": 3, "output_mult": 2.0, "cost": 400000},
}

## Ore types unlocked by depth
const ORE_DEPTH_UNLOCKS := {
	0: ["coal", "copper_ore"],
	200: ["iron_ore", "tin_ore"],
	500: ["silver_ore", "gold_ore"],
	1000: ["ruby", "sapphire"],
}

## Whether the auto-miner is unlocked
var is_unlocked: bool = false

## Current upgrade level (1-3)
var current_level: int = 0

## Slot assignments: slot_index -> ore_id
var slot_assignments: Dictionary = {}

## Accumulated ore waiting to be collected
var pending_ores: Dictionary = {}

## Timer for ore generation
var _generation_timer: float = 0.0

## Last generation time for offline calculation
var _last_generation_time: int = 0


func _ready() -> void:
	print("[AutoMinerManager] Ready")


func _process(delta: float) -> void:
	if not is_unlocked or current_level <= 0:
		return

	_generation_timer += delta
	if _generation_timer >= GENERATION_INTERVAL:
		_generation_timer -= GENERATION_INTERVAL
		_generate_ores()


## Check if player has reached the unlock depth
func check_unlock(max_depth_reached: int) -> void:
	if is_unlocked:
		return

	if max_depth_reached >= UNLOCK_DEPTH:
		unlock()


## Unlock the auto-miner station
func unlock() -> void:
	if is_unlocked:
		return

	is_unlocked = true
	current_level = 1  # Start at level 1
	_last_generation_time = int(Time.get_unix_time_from_system())

	# Default slot assignment: first available ore
	_init_default_slots()

	auto_miner_unlocked.emit()
	print("[AutoMinerManager] Auto-Miner Station unlocked!")


## Initialize default slot assignments
func _init_default_slots() -> void:
	var available_ores := get_available_ores()
	var config = UPGRADE_LEVELS.get(current_level, {})
	var slots: int = config.get("slots", 1)

	slot_assignments.clear()
	for i in range(slots):
		if i < available_ores.size():
			slot_assignments[i] = available_ores[i]


## Get list of available ore types based on depth reached
func get_available_ores() -> Array:
	var available := []
	var max_depth := GameManager.max_depth_reached if GameManager else 0

	for depth_threshold in ORE_DEPTH_UNLOCKS:
		if max_depth >= depth_threshold:
			for ore_id in ORE_DEPTH_UNLOCKS[depth_threshold]:
				if ore_id not in available:
					available.append(ore_id)

	return available


## Generate ores for this tick
func _generate_ores() -> void:
	if current_level <= 0:
		return

	var config = UPGRADE_LEVELS.get(current_level, {})
	var output_mult: float = config.get("output_mult", 1.0)

	# Calculate output per slot per tick
	# BASE_OUTPUT_PER_HOUR / 60 minutes = output per minute
	var output_per_tick := BASE_OUTPUT_PER_HOUR / 60.0 * output_mult

	for slot_idx in slot_assignments:
		var ore_id: String = slot_assignments[slot_idx]
		if ore_id.is_empty():
			continue

		# Accumulate ore (fractional values accumulate over time)
		if ore_id not in pending_ores:
			pending_ores[ore_id] = 0.0
		pending_ores[ore_id] += output_per_tick

		# Track for stats
		var added_amount := int(output_per_tick)
		if added_amount > 0:
			ore_generated.emit(ore_id, added_amount)


## Collect accumulated ores (called when player returns to surface)
func collect_pending_ores() -> Dictionary:
	var collected := {}

	for ore_id in pending_ores:
		var amount := int(pending_ores[ore_id])
		if amount > 0:
			collected[ore_id] = amount
			# Add to inventory
			if InventoryManager and DataRegistry:
				var ore_item = DataRegistry.get_item(ore_id)
				if ore_item:
					InventoryManager.add_item(ore_item, amount)
			# Keep the fractional part
			pending_ores[ore_id] = pending_ores[ore_id] - amount

	if not collected.is_empty():
		collection_ready.emit(collected)
		print("[AutoMinerManager] Collected: %s" % str(collected))

	return collected


## Get pending ore count (for UI display)
func get_pending_count() -> int:
	var total := 0
	for ore_id in pending_ores:
		total += int(pending_ores[ore_id])
	return total


## Upgrade the auto-miner station
func upgrade() -> bool:
	var next_level := current_level + 1
	if next_level > UPGRADE_LEVELS.size():
		return false  # Max level reached

	var config = UPGRADE_LEVELS.get(next_level, {})
	var cost: int = config.get("cost", 0)

	if not GameManager.can_afford(cost):
		return false

	if not GameManager.spend_coins(cost):
		return false

	current_level = next_level
	auto_miner_upgraded.emit(current_level)

	# Add new slot with default assignment
	_update_slots_for_level()

	print("[AutoMinerManager] Upgraded to level %d" % current_level)
	return true


## Update slot assignments when upgrading
func _update_slots_for_level() -> void:
	var config = UPGRADE_LEVELS.get(current_level, {})
	var slots: int = config.get("slots", 1)
	var available_ores := get_available_ores()

	# Add new slots with default assignments
	for i in range(slots):
		if i not in slot_assignments:
			# Assign next available ore not already assigned
			for ore_id in available_ores:
				if ore_id not in slot_assignments.values():
					slot_assignments[i] = ore_id
					break


## Assign an ore type to a slot
func assign_slot(slot_index: int, ore_id: String) -> bool:
	var config = UPGRADE_LEVELS.get(current_level, {})
	var max_slots: int = config.get("slots", 1)

	if slot_index < 0 or slot_index >= max_slots:
		return false

	var available := get_available_ores()
	if ore_id not in available:
		return false

	slot_assignments[slot_index] = ore_id
	print("[AutoMinerManager] Slot %d assigned to %s" % [slot_index, ore_id])
	return true


## Get current slot assignments
func get_slot_assignments() -> Dictionary:
	return slot_assignments.duplicate()


## Get number of available slots
func get_slot_count() -> int:
	var config = UPGRADE_LEVELS.get(current_level, {})
	return config.get("slots", 0)


## Get current output per hour (total)
func get_output_per_hour() -> float:
	if current_level <= 0:
		return 0.0

	var config = UPGRADE_LEVELS.get(current_level, {})
	var slots: int = config.get("slots", 1)
	var output_mult: float = config.get("output_mult", 1.0)

	return BASE_OUTPUT_PER_HOUR * output_mult * slots


## Get upgrade cost for next level
func get_upgrade_cost() -> int:
	var next_level := current_level + 1
	if next_level > UPGRADE_LEVELS.size():
		return -1  # Max level

	var config = UPGRADE_LEVELS.get(next_level, {})
	return config.get("cost", 0)


## Check if max level reached
func is_max_level() -> bool:
	return current_level >= UPGRADE_LEVELS.size()


## Calculate offline ore generation
func calculate_offline_generation(seconds_offline: int) -> void:
	if not is_unlocked or current_level <= 0:
		return

	if seconds_offline <= 0:
		return

	# Cap offline generation at 4 hours
	var max_offline_seconds := 4 * 60 * 60
	var capped_seconds := mini(seconds_offline, max_offline_seconds)

	var config = UPGRADE_LEVELS.get(current_level, {})
	var output_mult: float = config.get("output_mult", 1.0)

	# Calculate total output for offline time
	var hours_offline := capped_seconds / 3600.0
	var output_per_slot := BASE_OUTPUT_PER_HOUR * output_mult * hours_offline

	for slot_idx in slot_assignments:
		var ore_id: String = slot_assignments[slot_idx]
		if ore_id.is_empty():
			continue

		if ore_id not in pending_ores:
			pending_ores[ore_id] = 0.0
		pending_ores[ore_id] += output_per_slot

	if capped_seconds > 0:
		print("[AutoMinerManager] Offline generation: %.1f hours worth of ores" % hours_offline)


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	return {
		"is_unlocked": is_unlocked,
		"current_level": current_level,
		"slot_assignments": slot_assignments.duplicate(),
		"pending_ores": pending_ores.duplicate(),
		"last_generation_time": int(Time.get_unix_time_from_system()),
	}


## Load save data
func load_save_data(data: Dictionary) -> void:
	is_unlocked = data.get("is_unlocked", false)
	current_level = data.get("current_level", 0)

	slot_assignments.clear()
	var saved_slots = data.get("slot_assignments", {})
	if saved_slots is Dictionary:
		for key in saved_slots:
			# Handle both string and int keys
			var slot_idx = int(key) if key is String else key
			slot_assignments[slot_idx] = saved_slots[key]

	pending_ores.clear()
	var saved_pending = data.get("pending_ores", {})
	if saved_pending is Dictionary:
		for key in saved_pending:
			pending_ores[key] = float(saved_pending[key])

	_last_generation_time = data.get("last_generation_time", 0)

	# Calculate offline generation if there was time away
	if _last_generation_time > 0:
		var current_time := int(Time.get_unix_time_from_system())
		var time_offline := current_time - _last_generation_time
		if time_offline > 60:  # At least 1 minute offline
			calculate_offline_generation(time_offline)


## Reset (for new game)
func reset() -> void:
	is_unlocked = false
	current_level = 0
	slot_assignments.clear()
	pending_ores.clear()
	_generation_timer = 0.0
	_last_generation_time = 0
