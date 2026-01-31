extends Node
## PlayerData - Tracks player equipment and progression stats.
##
## Manages equipped tool, boots, helmet and max depth reached. Emits signals when equipment changes.
## Used by shop to determine available upgrades and by player for mining damage.

# Preload to ensure classes are available before autoload initialization
const ToolDataClass = preload("res://resources/tools/tool_data.gd")
const EquipmentDataClass = preload("res://resources/equipment/equipment_data.gd")

signal tool_changed(tool)  # ToolData
signal equipment_changed(slot: int, equipment)  # EquipmentData or null
signal max_depth_updated(depth: int)
signal tool_durability_changed(current: int, max_val: int)
signal tool_broken()

## Currently equipped tool ID (default: starter pickaxe)
var equipped_tool_id: String = "rusty_pickaxe"

## Maximum depth the player has ever reached (in grid rows)
var max_depth_reached: int = 0

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


## Get the currently equipped tool resource
func get_equipped_tool() -> ToolDataClass:
	if DataRegistry == null:
		return null
	return DataRegistry.get_tool(equipped_tool_id)


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

	equipped_tool_id = tool_id
	tool_changed.emit(tool_data)
	print("[PlayerData] Equipped: %s (Damage: %.1f)" % [tool_data.display_name, tool_data.damage])
	return true


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
	tool_durabilities.clear()
	warehouse_level = 0
	gadgets_owned.clear()
	consumables_owned.clear()
	unlocked_boots.clear()
	unlocked_helmets.clear()
	elevator_depths.clear()
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
		"tool_durabilities": tool_durabilities.duplicate(),
		"warehouse_level": warehouse_level,
		"gadgets_owned": gadgets_owned.duplicate(),
		"consumables_owned": consumables_owned.duplicate(),
		"unlocked_boots": unlocked_boots.duplicate(),
		"unlocked_helmets": unlocked_helmets.duplicate(),
		"elevator_depths": elevator_depths.duplicate(),
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	equipped_tool_id = data.get("equipped_tool_id", "rusty_pickaxe")
	equipped_boots_id = data.get("equipped_boots_id", "")
	equipped_helmet_id = data.get("equipped_helmet_id", "")
	equipped_accessory_id = data.get("equipped_accessory_id", "")
	max_depth_reached = data.get("max_depth_reached", 0)
	tool_durabilities = data.get("tool_durabilities", {}).duplicate()
	warehouse_level = data.get("warehouse_level", 0)
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

	tool_changed.emit(get_equipped_tool())
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.BOOTS, get_equipped_boots())
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.HELMET, get_equipped_helmet())
	equipment_changed.emit(EquipmentDataClass.EquipmentSlot.ACCESSORY, get_equipped_accessory())
	max_depth_updated.emit(max_depth_reached)
	print("[PlayerData] Loaded - Tool: %s, Boots: %s, Accessory: %s, Max Depth: %d, Warehouse Lvl: %d" % [equipped_tool_id, equipped_boots_id, equipped_accessory_id, max_depth_reached, warehouse_level])
