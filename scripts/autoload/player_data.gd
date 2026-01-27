extends Node
## PlayerData - Tracks player equipment and progression stats.
##
## Manages equipped tool and max depth reached. Emits signals when equipment changes.
## Used by shop to determine available upgrades and by player for mining damage.

# Preload to ensure ToolData class is available before autoload initialization
const ToolDataClass = preload("res://resources/tools/tool_data.gd")

signal tool_changed(tool)  # ToolData
signal max_depth_updated(depth: int)
signal tool_durability_changed(current: int, max_val: int)
signal tool_broken()

## Currently equipped tool ID (default: starter pickaxe)
var equipped_tool_id: String = "rusty_pickaxe"

## Maximum depth the player has ever reached (in grid rows)
var max_depth_reached: int = 0

## Tool durability tracking (per-tool dictionary)
var tool_durabilities: Dictionary = {}  # tool_id -> current_durability


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
	max_depth_reached = 0
	tool_durabilities.clear()
	tool_changed.emit(get_equipped_tool())
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


## Get save data for persistence
func get_save_data() -> Dictionary:
	return {
		"equipped_tool_id": equipped_tool_id,
		"max_depth_reached": max_depth_reached,
		"tool_durabilities": tool_durabilities.duplicate(),
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	equipped_tool_id = data.get("equipped_tool_id", "rusty_pickaxe")
	max_depth_reached = data.get("max_depth_reached", 0)
	tool_durabilities = data.get("tool_durabilities", {}).duplicate()
	tool_changed.emit(get_equipped_tool())
	max_depth_updated.emit(max_depth_reached)
	print("[PlayerData] Loaded - Tool: %s, Max Depth: %d" % [equipped_tool_id, max_depth_reached])
