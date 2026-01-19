extends Node
## PlayerData - Tracks player equipment and progression stats.
##
## Manages equipped tool and max depth reached. Emits signals when equipment changes.
## Used by shop to determine available upgrades and by player for mining damage.

signal tool_changed(tool)  # ToolData
signal max_depth_updated(depth: int)

## Currently equipped tool ID (default: starter pickaxe)
var equipped_tool_id: String = "rusty_pickaxe"

## Maximum depth the player has ever reached (in grid rows)
var max_depth_reached: int = 0


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
func get_equipped_tool():
	## Returns ToolData or null
	return DataRegistry.get_tool(equipped_tool_id)


## Get the effective damage of the equipped tool
func get_tool_damage() -> float:
	var tool = get_equipped_tool()
	if tool == null:
		return 10.0  # Default damage
	return tool.damage * tool.speed_multiplier


## Equip a new tool by ID
func equip_tool(tool_id: String) -> bool:
	var tool = DataRegistry.get_tool(tool_id)
	if tool == null:
		push_warning("[PlayerData] Cannot equip unknown tool: %s" % tool_id)
		return false

	equipped_tool_id = tool_id
	tool_changed.emit(tool)
	print("[PlayerData] Equipped: %s (Damage: %.1f)" % [tool.display_name, tool.damage])
	return true


## Check if a tool can be purchased (depth requirement and not already owned)
func can_unlock_tool(tool) -> bool:
	## tool: ToolData or null
	if tool == null:
		return false
	# Check depth requirement
	if tool.unlock_depth > max_depth_reached:
		return false
	# Check if better than current tool (can only upgrade, not downgrade)
	var current = get_equipped_tool()
	if current != null and tool.tier <= current.tier:
		return false
	return true


## Get the next available tool upgrade (null if at max tier)
func get_next_tool_upgrade():
	## Returns ToolData or null
	var current = get_equipped_tool()
	if current == null:
		return DataRegistry.get_tool("rusty_pickaxe")

	var next_tier: int = current.tier + 1
	var all_tools = DataRegistry.get_all_tools()

	for tool in all_tools:
		if tool.tier == next_tier:
			return tool

	return null


## Reset player data (for new game)
func reset() -> void:
	equipped_tool_id = "rusty_pickaxe"
	max_depth_reached = 0
	tool_changed.emit(get_equipped_tool())
	max_depth_updated.emit(max_depth_reached)
	print("[PlayerData] Reset to defaults")


## Get save data for persistence
func get_save_data() -> Dictionary:
	return {
		"equipped_tool_id": equipped_tool_id,
		"max_depth_reached": max_depth_reached,
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	equipped_tool_id = data.get("equipped_tool_id", "rusty_pickaxe")
	max_depth_reached = data.get("max_depth_reached", 0)
	tool_changed.emit(get_equipped_tool())
	max_depth_updated.emit(max_depth_reached)
	print("[PlayerData] Loaded - Tool: %s, Max Depth: %d" % [equipped_tool_id, max_depth_reached])
