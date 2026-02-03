extends Node
## PlayerData - Tracks player equipment and progression stats.
##
## Manages equipped tool, boots, helmet and max depth reached. Emits signals when equipment changes.
## Used by shop to determine available upgrades and by player for mining damage.

# Preload to ensure classes are available before autoload initialization
const ToolDataClass = preload("res://resources/tools/tool_data.gd")
const EquipmentDataClass = preload("res://resources/equipment/equipment_data.gd")

signal tool_changed(tool)  # ToolData
signal tool_upgraded(old_tool, new_tool)  # Emitted when upgrading to a better tool
signal equipment_changed(slot: int, equipment)  # EquipmentData or null
signal max_depth_updated(depth: int)
signal tool_durability_changed(current: int, max_val: int)
signal tool_broken()

## Currently equipped tool ID (default: starter pickaxe)
var equipped_tool_id: String = "rusty_pickaxe"

## Maximum depth the player has ever reached (in grid rows)
var max_depth_reached: int = 0

## Maximum depth reached during current dive (resets on surface)
## Used for depth-based sell value multiplier
var current_dive_max_depth: int = 0

signal dive_depth_updated(depth: int)

## Tool durability tracking (per-tool dictionary)
var tool_durabilities: Dictionary = {}  # tool_id -> current_durability

## Currently equipped boots ID (empty = none)
var equipped_boots_id: String = ""

## Currently equipped helmet ID (empty = none)
var equipped_helmet_id: String = ""

## Currently equipped accessory ID (empty = none, includes drill)
var equipped_accessory_id: String = ""

## Warehouse upgrade level (0 = no upgrade)
var warehouse_level: int = 0

## Gadgets owned (gadget_id -> quantity)
var gadgets_owned: Dictionary = {}

## Consumables owned (consumable_id -> quantity) for items not in inventory
var consumables_owned: Dictionary = {}

## Unlocked boots IDs
var unlocked_boots: Array[String] = []

## Unlocked helmets IDs
var unlocked_helmets: Array[String] = []

## Elevator saved depths (for fast travel)
var elevator_depths: Array[int] = []

## Discovered ore types (for first-discovery bonus system)
var discovered_ores: Array[String] = []

## Passive income upgrade level (0 = no upgrade, max 3)
## Each level increases offline coin income multiplier
var passive_income_level: int = 0

## Passive income upgrade configurations
const PASSIVE_INCOME_UPGRADES := {
	1: {"multiplier": 1.5, "cost": 2000, "min_depth": 100, "name": "Apprentice Collector"},
	2: {"multiplier": 2.0, "cost": 8000, "min_depth": 300, "name": "Journeyman Collector"},
	3: {"multiplier": 3.0, "cost": 25000, "min_depth": 600, "name": "Master Collector"},
}

signal passive_income_upgraded(new_level: int, new_multiplier: float)

## Flag tracking if player just upgraded their tool (for first-dig celebration)
var just_upgraded_tool: bool = false

signal ore_type_discovered(ore_id: String)

## Unlocked sidegrade IDs (permanent unlocks)
var unlocked_sidegrades: Array[String] = []

## Active sidegrade IDs (currently equipped, can only have non-conflicting ones)
var active_sidegrades: Array[String] = []

## Second chance used this dive (resets on surface)
var second_chance_used: bool = false

signal sidegrade_unlocked(sidegrade_id: String)
signal sidegrade_activated(sidegrade_id: String)
signal sidegrade_deactivated(sidegrade_id: String)


func _ready() -> void:
	# Defer connection to allow other autoloads to initialize first
	call_deferred("_connect_signals")
	print("[PlayerData] Ready with tool: %s" % equipped_tool_id)


func _connect_signals() -> void:
	# Connect to GameManager depth updates
	if GameManager != null and GameManager.has_signal("depth_updated"):
		GameManager.depth_updated.connect(_on_depth_updated)


func _on_depth_updated(depth: int) -> void:
	## Track max depth reached for unlock purposes
	if depth > max_depth_reached:
		max_depth_reached = depth
		max_depth_updated.emit(max_depth_reached)

	## Track current dive max depth for sell multiplier
	## Reset when player returns to surface (depth 0)
	if depth == 0:
		if current_dive_max_depth > 0:
			print("[PlayerData] Dive complete! Max depth was %dm" % current_dive_max_depth)
		current_dive_max_depth = 0
		dive_depth_updated.emit(0)
	elif depth > current_dive_max_depth:
		current_dive_max_depth = depth
		dive_depth_updated.emit(current_dive_max_depth)


## Get the currently equipped tool resource
func get_equipped_tool() -> ToolDataClass:
	if DataRegistry == null:
		return null
	return DataRegistry.get_tool(equipped_tool_id)


## Current tool property (shorthand for get_equipped_tool)
## Used by effects systems for tool identity settings
var current_tool: ToolDataClass:
	get:
		return get_equipped_tool()


## Get the effective damage of the equipped tool
func get_tool_damage() -> float:
	var tool_data: ToolDataClass = get_equipped_tool()
	if tool_data == null:
		return 10.0  # Default damage
	return tool_data.damage


## Get the speed multiplier of the equipped tool (affects mining animation speed)
func get_tool_speed_multiplier() -> float:
	var tool_data: ToolDataClass = get_equipped_tool()
	if tool_data == null:
		return 1.0  # Default speed
	return tool_data.speed_multiplier


## Get the tier of the equipped tool (for ore gating)
func get_tool_tier() -> int:
	var tool_data: ToolDataClass = get_equipped_tool()
	if tool_data == null:
		return 0  # Default tier
	return tool_data.tier


## Equip a new tool by ID
func equip_tool(tool_id: String) -> bool:
	if DataRegistry == null:
		push_warning("[PlayerData] DataRegistry not available")
		return false
	var tool_data: ToolDataClass = DataRegistry.get_tool(tool_id)
	if tool_data == null:
		push_warning("[PlayerData] Cannot equip unknown tool: %s" % tool_id)
		return false

	# Get old tool for comparison (to detect upgrades)
	var old_tool: ToolDataClass = get_equipped_tool()
	var is_upgrade := old_tool != null and tool_data.tier > old_tool.tier

	equipped_tool_id = tool_id
	tool_changed.emit(tool_data)

	# If this is an upgrade, emit upgrade signal and set celebration flag
	if is_upgrade:
		just_upgraded_tool = true
		tool_upgraded.emit(old_tool, tool_data)
		print("[PlayerData] UPGRADED: %s -> %s (Damage: %.1f -> %.1f, Speed: %.2f -> %.2f)" % [
			old_tool.display_name, tool_data.display_name,
			old_tool.damage, tool_data.damage,
			old_tool.speed_multiplier, tool_data.speed_multiplier
		])
	else:
		print("[PlayerData] Equipped: %s (Damage: %.1f)" % [tool_data.display_name, tool_data.damage])
	return true


## Check and consume the just_upgraded flag (for first-dig celebration)
## Returns true if player just upgraded and this is their first action since
func consume_upgrade_celebration() -> bool:
	if just_upgraded_tool:
		just_upgraded_tool = false
		return true
	return false


## Check if a tool can be purchased (depth requirement and not already owned)
func can_unlock_tool(tool_data: ToolDataClass) -> bool:
	if tool_data == null:
		return false
	# Check depth requirement
	if tool_data.unlock_depth > max_depth_reached:
		return false
	# Check if better than current tool (can only upgrade, not downgrade)
	var current: ToolDataClass = get_equipped_tool()
	if current != null and tool_data.tier <= current.tier:
		return false
	return true


## Get the next available tool upgrade (null if at max tier)
func get_next_tool_upgrade() -> ToolDataClass:
	if DataRegistry == null:
		return null
	var current: ToolDataClass = get_equipped_tool()
	if current == null:
		return DataRegistry.get_tool("rusty_pickaxe")

	var next_tier: int = current.tier + 1
	var all_tools: Array = DataRegistry.get_all_tools()

	for tool_data: ToolDataClass in all_tools:
		if tool_data.tier == next_tier:
			return tool_data

	return null


## Reset player data (for new game)
func reset() -> void:
	equipped_tool_id = "rusty_pickaxe"
	equipped_boots_id = ""
	equipped_helmet_id = ""
	equipped_accessory_id = ""
	max_depth_reached = 0
	current_dive_max_depth = 0
	tool_durabilities.clear()
	warehouse_level = 0
	passive_income_level = 0
	gadgets_owned.clear()
	consumables_owned.clear()
	unlocked_boots.clear()
	unlocked_helmets.clear()
	elevator_depths.clear()
	discovered_ores.clear()
	unlocked_sidegrades.clear()
	active_sidegrades.clear()
	second_chance_used = false
	tool_changed.emit(get_equipped_tool())
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.BOOTS, null)
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.HELMET, null)
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.ACCESSORY, null)
	max_depth_updated.emit(max_depth_reached)
	print("[PlayerData] Reset to defaults")


# ============================================
# TOOL DURABILITY
# ============================================

## Get current durability of equipped tool
func get_tool_durability() -> int:
	var tool_data: ToolDataClass = get_equipped_tool()
	if tool_data == null:
		return 0

	# If tool has no durability system, return max
	if tool_data.max_durability == 0:
		return tool_data.max_durability  # 0 means infinite

	# Get stored durability, or initialize to max
	if not tool_durabilities.has(equipped_tool_id):
		tool_durabilities[equipped_tool_id] = tool_data.max_durability

	return tool_durabilities[equipped_tool_id]


## Use the tool (reduce durability by 1)
func use_tool() -> void:
	var tool_data: ToolDataClass = get_equipped_tool()
	if tool_data == null or tool_data.max_durability == 0:
		return  # No durability system

	# Initialize if needed
	if not tool_durabilities.has(equipped_tool_id):
		tool_durabilities[equipped_tool_id] = tool_data.max_durability

	# Reduce durability
	tool_durabilities[equipped_tool_id] -= 1
	var current: int = tool_durabilities[equipped_tool_id]

	tool_durability_changed.emit(current, tool_data.max_durability)

	# Check if broken
	if current <= 0:
		tool_broken.emit()
		print("[PlayerData] Tool broken: %s" % tool_data.display_name)


## Repair the equipped tool (full repair)
func repair_tool() -> int:
	var tool_data: ToolDataClass = get_equipped_tool()
	if tool_data == null or tool_data.max_durability == 0:
		return 0

	var current: int = get_tool_durability()
	var cost: int = tool_data.get_repair_cost(current)

	tool_durabilities[equipped_tool_id] = tool_data.max_durability
	tool_durability_changed.emit(tool_data.max_durability, tool_data.max_durability)

	print("[PlayerData] Tool repaired: %s" % tool_data.display_name)
	return cost


## Check if equipped tool is broken
func is_tool_broken() -> bool:
	var tool_data: ToolDataClass = get_equipped_tool()
	if tool_data == null or tool_data.max_durability == 0:
		return false
	return get_tool_durability() <= 0


## Get repair cost for equipped tool
func get_repair_cost() -> int:
	var tool_data: ToolDataClass = get_equipped_tool()
	if tool_data == null or tool_data.max_durability == 0:
		return 0
	return tool_data.get_repair_cost(get_tool_durability())


# ============================================
# EQUIPMENT (Boots, Helmets)
# ============================================

## Get the currently equipped boots
func get_equipped_boots() -> EquipmentDataClass:
	if DataRegistry == null or equipped_boots_id == "":
		return null
	return DataRegistry.get_equipment(equipped_boots_id)


## Get the currently equipped helmet
func get_equipped_helmet() -> EquipmentDataClass:
	if DataRegistry == null or equipped_helmet_id == "":
		return null
	return DataRegistry.get_equipment(equipped_helmet_id)


## Equip boots by ID
func equip_boots(boots_id: String) -> bool:
	if DataRegistry == null:
		push_warning("[PlayerData] DataRegistry not available")
		return false

	var boots = DataRegistry.get_equipment(boots_id)
	if boots == null:
		push_warning("[PlayerData] Cannot equip unknown boots: %s" % boots_id)
		return false

	if boots.slot != EquipmentDataClass.EquipmentSlot.BOOTS:
		push_warning("[PlayerData] Equipment %s is not boots" % boots_id)
		return false

	equipped_boots_id = boots_id
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.BOOTS, boots)
	print("[PlayerData] Equipped boots: %s (Fall reduction: %.0f%%)" % [boots.display_name, boots.fall_damage_reduction * 100])
	return true


## Equip helmet by ID
func equip_helmet(helmet_id: String) -> bool:
	if DataRegistry == null:
		push_warning("[PlayerData] DataRegistry not available")
		return false

	var helmet = DataRegistry.get_equipment(helmet_id)
	if helmet == null:
		push_warning("[PlayerData] Cannot equip unknown helmet: %s" % helmet_id)
		return false

	if helmet.slot != EquipmentDataClass.EquipmentSlot.HELMET:
		push_warning("[PlayerData] Equipment %s is not helmet" % helmet_id)
		return false

	equipped_helmet_id = helmet_id
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.HELMET, helmet)
	print("[PlayerData] Equipped helmet: %s" % helmet.display_name)
	return true


## Unequip boots
func unequip_boots() -> void:
	equipped_boots_id = ""
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.BOOTS, null)


## Unequip helmet
func unequip_helmet() -> void:
	equipped_helmet_id = ""
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.HELMET, null)


## Get depth-based sell value multiplier for current dive
## Formula: 1.0 + (dive_depth / 100)
## At 50m deep: 1.5x value, at 100m: 2x value
func get_depth_sell_multiplier() -> float:
	return 1.0 + (float(current_dive_max_depth) / 100.0)


## Get fall damage reduction from equipped boots (0.0 - 1.0)
func get_fall_damage_reduction() -> float:
	var boots = get_equipped_boots()
	if boots == null:
		return 0.0
	return boots.fall_damage_reduction


## Get fall threshold bonus from equipped boots (extra blocks before damage)
func get_fall_threshold_bonus() -> int:
	var boots = get_equipped_boots()
	if boots == null:
		return 0
	return boots.fall_threshold_bonus


## Get light radius bonus from equipped helmet
func get_light_radius_bonus() -> float:
	var helmet = get_equipped_helmet()
	if helmet == null:
		return 0.0
	return helmet.light_radius_bonus


## Get light intensity bonus from equipped helmet
func get_light_intensity_bonus() -> float:
	var helmet = get_equipped_helmet()
	if helmet == null:
		return 0.0
	return helmet.light_intensity_bonus


## Check if boots can be unlocked (depth requirement and tier check)
func can_unlock_boots(boots: EquipmentDataClass) -> bool:
	if boots == null:
		return false
	if boots.slot != EquipmentDataClass.EquipmentSlot.BOOTS:
		return false
	if boots.unlock_depth > max_depth_reached:
		return false
	var current = get_equipped_boots()
	if current != null and boots.tier <= current.tier:
		return false  # Already have equal or better
	return true


## Check if helmet can be unlocked (depth requirement and tier check)
func can_unlock_helmet(helmet: EquipmentDataClass) -> bool:
	if helmet == null:
		return false
	if helmet.slot != EquipmentDataClass.EquipmentSlot.HELMET:
		return false
	if helmet.unlock_depth > max_depth_reached:
		return false
	var current = get_equipped_helmet()
	if current != null and helmet.tier <= current.tier:
		return false  # Already have equal or better
	return true


## Get the next helmet upgrade available (null if at max tier or no helmets unlocked)
func get_next_helmet_upgrade() -> EquipmentDataClass:
	if DataRegistry == null:
		return null

	var current = get_equipped_helmet()
	var next_tier: int = 0 if current == null else current.tier + 1
	var all_helmets = DataRegistry.get_all_helmets()

	for helmet in all_helmets:
		if helmet.tier == next_tier:
			return helmet

	return null


## Get the currently equipped accessory (includes drill)
func get_equipped_accessory() -> EquipmentDataClass:
	if DataRegistry == null or equipped_accessory_id == "":
		return null
	return DataRegistry.get_equipment(equipped_accessory_id)


## Equip accessory by ID
func equip_accessory(accessory_id: String) -> bool:
	if DataRegistry == null:
		push_warning("[PlayerData] DataRegistry not available")
		return false

	var accessory = DataRegistry.get_equipment(accessory_id)
	if accessory == null:
		push_warning("[PlayerData] Cannot equip unknown accessory: %s" % accessory_id)
		return false

	if accessory.slot != EquipmentDataClass.EquipmentSlot.ACCESSORY:
		push_warning("[PlayerData] Equipment %s is not accessory" % accessory_id)
		return false

	equipped_accessory_id = accessory_id
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.ACCESSORY, accessory)
	print("[PlayerData] Equipped accessory: %s" % accessory.display_name)
	return true


## Unequip accessory
func unequip_accessory() -> void:
	equipped_accessory_id = ""
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.ACCESSORY, null)


## Check if player has the mining drill equipped
func has_drill() -> bool:
	return equipped_accessory_id == "mining_drill"


## Get mining speed bonus from equipped accessory
func get_mining_speed_bonus() -> float:
	var accessory = get_equipped_accessory()
	if accessory == null:
		return 1.0
	return accessory.mining_speed_bonus


# ============================================
# GADGETS AND CONSUMABLES
# ============================================

## Get gadget count by ID
func get_gadget_count(gadget_id: String) -> int:
	return gadgets_owned.get(gadget_id, 0)


## Add gadgets
func add_gadget(gadget_id: String, count: int = 1) -> void:
	if not gadgets_owned.has(gadget_id):
		gadgets_owned[gadget_id] = 0
	gadgets_owned[gadget_id] += count


## Use a gadget (returns true if successful)
func use_gadget(gadget_id: String) -> bool:
	if get_gadget_count(gadget_id) <= 0:
		return false
	gadgets_owned[gadget_id] -= 1
	return true


## Get consumable count by ID
func get_consumable_count(consumable_id: String) -> int:
	return consumables_owned.get(consumable_id, 0)


## Add consumables
func add_consumable(consumable_id: String, count: int = 1) -> void:
	if not consumables_owned.has(consumable_id):
		consumables_owned[consumable_id] = 0
	consumables_owned[consumable_id] += count


## Use a consumable (returns true if successful)
func use_consumable(consumable_id: String) -> bool:
	if get_consumable_count(consumable_id) <= 0:
		return false
	consumables_owned[consumable_id] -= 1
	return true


# ============================================
# EQUIPMENT OWNERSHIP
# ============================================

## Check if boots are unlocked
func has_boots(boots_id: String) -> bool:
	return boots_id in unlocked_boots


## Unlock boots
func unlock_boots(boots_id: String) -> void:
	if boots_id not in unlocked_boots:
		unlocked_boots.append(boots_id)


## Check if helmet is unlocked
func has_helmet(helmet_id: String) -> bool:
	return helmet_id in unlocked_helmets


## Unlock helmet
func unlock_helmet(helmet_id: String) -> void:
	if helmet_id not in unlocked_helmets:
		unlocked_helmets.append(helmet_id)


# ============================================
# PASSIVE INCOME UPGRADES
# ============================================

## Get current passive income multiplier based on upgrade level
func get_passive_income_multiplier() -> float:
	if passive_income_level <= 0:
		return 1.0
	var config = PASSIVE_INCOME_UPGRADES.get(passive_income_level, {})
	return config.get("multiplier", 1.0)


## Get next passive income upgrade info (null if maxed)
func get_next_passive_upgrade() -> Dictionary:
	var next_level := passive_income_level + 1
	if next_level > PASSIVE_INCOME_UPGRADES.size():
		return {}
	return PASSIVE_INCOME_UPGRADES.get(next_level, {})


## Check if player can afford and unlock the next passive income upgrade
func can_upgrade_passive_income() -> bool:
	var next := get_next_passive_upgrade()
	if next.is_empty():
		return false
	if max_depth_reached < next.get("min_depth", 0):
		return false
	return true


## Purchase the next passive income upgrade (does not check affordability)
func upgrade_passive_income() -> bool:
	if not can_upgrade_passive_income():
		return false

	var next := get_next_passive_upgrade()
	if next.is_empty():
		return false

	passive_income_level += 1
	var new_mult: float = next.get("multiplier", 1.0)
	passive_income_upgraded.emit(passive_income_level, new_mult)
	print("[PlayerData] Passive income upgraded to level %d (%.1fx multiplier)" % [passive_income_level, new_mult])
	return true


## Check if passive income is at max level
func is_passive_income_maxed() -> bool:
	return passive_income_level >= PASSIVE_INCOME_UPGRADES.size()


# ============================================
# ELEVATOR SYSTEM
# ============================================

## Add an elevator stop at a depth
func add_elevator_depth(depth: int) -> void:
	if depth not in elevator_depths:
		elevator_depths.append(depth)
		elevator_depths.sort()


## Check if elevator can travel to a depth
func can_elevator_to(depth: int) -> bool:
	return depth in elevator_depths


## Get all elevator stops
func get_elevator_stops() -> Array[int]:
	return elevator_depths.duplicate()


# ============================================
# ORE DISCOVERY TRACKING
# ============================================

## Check if an ore type has been discovered
func has_discovered_ore(ore_id: String) -> bool:
	return ore_id in discovered_ores


## Discover a new ore type - returns true if this was a first discovery
func discover_ore(ore_id: String) -> bool:
	if has_discovered_ore(ore_id):
		return false
	discovered_ores.append(ore_id)
	ore_type_discovered.emit(ore_id)
	print("[PlayerData] NEW ORE DISCOVERED: %s (Total discoveries: %d)" % [ore_id, discovered_ores.size()])
	return true


## Get all discovered ore types
func get_discovered_ores() -> Array[String]:
	return discovered_ores.duplicate()


## Get count of discovered ore types
func get_discovery_count() -> int:
	return discovered_ores.size()


# ============================================
# SIDEGRADE SYSTEM
# ============================================

## Check if a sidegrade is unlocked (permanently purchased)
func has_sidegrade(sidegrade_id: String) -> bool:
	return sidegrade_id in unlocked_sidegrades


## Check if a sidegrade is currently active
func is_sidegrade_active(sidegrade_id: String) -> bool:
	return sidegrade_id in active_sidegrades


## Unlock a sidegrade (permanent purchase)
func unlock_sidegrade(sidegrade_id: String) -> bool:
	if has_sidegrade(sidegrade_id):
		return false  # Already unlocked
	unlocked_sidegrades.append(sidegrade_id)
	sidegrade_unlocked.emit(sidegrade_id)
	print("[PlayerData] SIDEGRADE UNLOCKED: %s" % sidegrade_id)
	return true


## Activate a sidegrade (must be unlocked first)
## Returns false if sidegrade conflicts with currently active ones
func activate_sidegrade(sidegrade_id: String) -> bool:
	if not has_sidegrade(sidegrade_id):
		push_warning("[PlayerData] Cannot activate locked sidegrade: %s" % sidegrade_id)
		return false
	if is_sidegrade_active(sidegrade_id):
		return true  # Already active

	# Check for conflicts with currently active sidegrades
	if DataRegistry != null:
		for active_id in active_sidegrades:
			if DataRegistry.sidegrades_conflict(sidegrade_id, active_id):
				push_warning("[PlayerData] Sidegrade %s conflicts with active %s" % [sidegrade_id, active_id])
				return false

	active_sidegrades.append(sidegrade_id)
	sidegrade_activated.emit(sidegrade_id)
	print("[PlayerData] Sidegrade activated: %s" % sidegrade_id)
	return true


## Deactivate a sidegrade
func deactivate_sidegrade(sidegrade_id: String) -> void:
	if not is_sidegrade_active(sidegrade_id):
		return
	active_sidegrades.erase(sidegrade_id)
	sidegrade_deactivated.emit(sidegrade_id)
	print("[PlayerData] Sidegrade deactivated: %s" % sidegrade_id)


## Get all unlocked sidegrades
func get_unlocked_sidegrades() -> Array[String]:
	return unlocked_sidegrades.duplicate()


## Get all active sidegrades
func get_active_sidegrades() -> Array[String]:
	return active_sidegrades.duplicate()


## Calculate combined sidegrade modifiers
## Returns a dictionary with all accumulated bonuses/penalties
func get_sidegrade_modifiers() -> Dictionary:
	var modifiers := {
		"damage_multiplier": 1.0,
		"speed_multiplier": 1.0,
		"double_drop_chance": 0.0,
		"chain_mining_chance": 0.0,
		"speed_mining_mode": false,
		"wall_jump_enabled": false,
		"wall_slide_enabled": false,
		"ladder_slide_enabled": false,
		"extra_jumps": 0,
		"move_speed_multiplier": 1.0,
		"fall_damage_multiplier": 1.0,
		"auto_sell_junk": false,
		"auto_sell_threshold": 0,
		"auto_pickup_enabled": false,
		"auto_pickup_range": 0.0,
		"sell_value_multiplier": 1.0,
		"ore_detection_enabled": false,
		"ore_detection_range": 0.0,
		"path_hint_enabled": false,
		"auto_map_enabled": false,
		"light_radius_multiplier": 1.0,
		"emergency_teleport_charges": 0,
		"second_chance_enabled": false,
		"idle_regen_rate": 0.0,
		"max_hp_multiplier": 1.0,
	}

	if DataRegistry == null:
		return modifiers

	for sg_id in active_sidegrades:
		var sg = DataRegistry.get_sidegrade(sg_id)
		if sg == null:
			continue

		# Multiplicative modifiers
		modifiers.damage_multiplier *= sg.damage_multiplier
		modifiers.speed_multiplier *= sg.speed_multiplier
		modifiers.move_speed_multiplier *= sg.move_speed_multiplier
		modifiers.fall_damage_multiplier *= sg.fall_damage_multiplier
		modifiers.sell_value_multiplier *= sg.sell_value_multiplier
		modifiers.light_radius_multiplier *= sg.light_radius_multiplier
		modifiers.max_hp_multiplier *= sg.max_hp_multiplier

		# Additive modifiers
		modifiers.double_drop_chance += sg.double_drop_chance
		modifiers.chain_mining_chance += sg.chain_mining_chance
		modifiers.extra_jumps += sg.extra_jumps
		modifiers.auto_pickup_range = maxf(modifiers.auto_pickup_range, sg.auto_pickup_range)
		modifiers.auto_sell_threshold = maxi(modifiers.auto_sell_threshold, sg.auto_sell_threshold)
		modifiers.ore_detection_range = maxf(modifiers.ore_detection_range, sg.ore_detection_range)
		modifiers.idle_regen_rate += sg.idle_regen_rate
		modifiers.emergency_teleport_charges += sg.emergency_teleport_charges

		# Boolean modifiers (OR)
		modifiers.speed_mining_mode = modifiers.speed_mining_mode or sg.speed_mining_mode
		modifiers.wall_jump_enabled = modifiers.wall_jump_enabled or sg.wall_jump_enabled
		modifiers.wall_slide_enabled = modifiers.wall_slide_enabled or sg.wall_slide_enabled
		modifiers.ladder_slide_enabled = modifiers.ladder_slide_enabled or sg.ladder_slide_enabled
		modifiers.auto_sell_junk = modifiers.auto_sell_junk or sg.auto_sell_junk
		modifiers.auto_pickup_enabled = modifiers.auto_pickup_enabled or sg.auto_pickup_enabled
		modifiers.ore_detection_enabled = modifiers.ore_detection_enabled or sg.ore_detection_enabled
		modifiers.path_hint_enabled = modifiers.path_hint_enabled or sg.path_hint_enabled
		modifiers.auto_map_enabled = modifiers.auto_map_enabled or sg.auto_map_enabled
		modifiers.second_chance_enabled = modifiers.second_chance_enabled or sg.second_chance_enabled

	return modifiers


## Reset dive-specific sidegrade states (called when returning to surface)
func reset_dive_sidegrade_states() -> void:
	second_chance_used = false


## Use second chance (returns true if available and consumed)
func use_second_chance() -> bool:
	var mods := get_sidegrade_modifiers()
	if not mods.second_chance_enabled:
		return false
	if second_chance_used:
		return false
	second_chance_used = true
	print("[PlayerData] SECOND CHANCE USED - survive with 1 HP!")
	return true


# ============================================
# SAVE/LOAD
# ============================================

## Get save data for persistence
func get_save_data() -> Dictionary:
	return {
		"equipped_tool_id": equipped_tool_id,
		"equipped_boots_id": equipped_boots_id,
		"equipped_helmet_id": equipped_helmet_id,
		"equipped_accessory_id": equipped_accessory_id,
		"max_depth_reached": max_depth_reached,
		"current_dive_max_depth": current_dive_max_depth,
		"tool_durabilities": tool_durabilities.duplicate(),
		"warehouse_level": warehouse_level,
		"passive_income_level": passive_income_level,
		"gadgets_owned": gadgets_owned.duplicate(),
		"consumables_owned": consumables_owned.duplicate(),
		"unlocked_boots": unlocked_boots.duplicate(),
		"unlocked_helmets": unlocked_helmets.duplicate(),
		"elevator_depths": elevator_depths.duplicate(),
		"discovered_ores": discovered_ores.duplicate(),
		"unlocked_sidegrades": unlocked_sidegrades.duplicate(),
		"active_sidegrades": active_sidegrades.duplicate(),
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	equipped_tool_id = data.get("equipped_tool_id", "rusty_pickaxe")
	equipped_boots_id = data.get("equipped_boots_id", "")
	equipped_helmet_id = data.get("equipped_helmet_id", "")
	equipped_accessory_id = data.get("equipped_accessory_id", "")
	max_depth_reached = data.get("max_depth_reached", 0)
	current_dive_max_depth = data.get("current_dive_max_depth", 0)
	tool_durabilities = data.get("tool_durabilities", {}).duplicate()
	warehouse_level = data.get("warehouse_level", 0)
	passive_income_level = data.get("passive_income_level", 0)
	gadgets_owned = data.get("gadgets_owned", {}).duplicate()
	consumables_owned = data.get("consumables_owned", {}).duplicate()

	# Load unlocked equipment arrays
	unlocked_boots.clear()
	var saved_boots = data.get("unlocked_boots", [])
	for b in saved_boots:
		if b is String:
			unlocked_boots.append(b)

	unlocked_helmets.clear()
	var saved_helmets = data.get("unlocked_helmets", [])
	for h in saved_helmets:
		if h is String:
			unlocked_helmets.append(h)

	elevator_depths.clear()
	var saved_depths = data.get("elevator_depths", [])
	for d in saved_depths:
		if d is int:
			elevator_depths.append(d)

	discovered_ores.clear()
	var saved_ores = data.get("discovered_ores", [])
	for ore_id in saved_ores:
		if ore_id is String:
			discovered_ores.append(ore_id)

	unlocked_sidegrades.clear()
	var saved_sidegrades = data.get("unlocked_sidegrades", [])
	for sg_id in saved_sidegrades:
		if sg_id is String:
			unlocked_sidegrades.append(sg_id)

	active_sidegrades.clear()
	var saved_active = data.get("active_sidegrades", [])
	for sg_id in saved_active:
		if sg_id is String and sg_id in unlocked_sidegrades:
			active_sidegrades.append(sg_id)

	tool_changed.emit(get_equipped_tool())
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.BOOTS, get_equipped_boots())
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.HELMET, get_equipped_helmet())
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.ACCESSORY, get_equipped_accessory())
	max_depth_updated.emit(max_depth_reached)
	print("[PlayerData] Loaded - Tool: %s, Boots: %s, Accessory: %s, Max Depth: %d, Warehouse Lvl: %d, Discoveries: %d, Sidegrades: %d" % [equipped_tool_id, equipped_boots_id, equipped_accessory_id, max_depth_reached, warehouse_level, discovered_ores.size(), unlocked_sidegrades.size()])
