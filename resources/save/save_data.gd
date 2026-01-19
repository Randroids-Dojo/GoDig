class_name SaveData extends Resource
## Resource class for storing player save data.
##
## Contains all persistent player state that needs to survive between sessions:
## player position, inventory, economy, progression, and world seed.
## Chunk modifications are stored separately in binary files.

## Current save format version for migration support
const CURRENT_VERSION := 1

## Save file metadata
@export var save_version: int = CURRENT_VERSION
@export var last_save_time: int = 0
@export var total_playtime: float = 0.0
@export var save_slot_name: String = ""

## Player position and state
@export var player_grid_position: Vector2i = Vector2i(2, 6)  # Start above surface
@export var current_depth: int = 0

## Economy
@export var coins: int = 0
@export var lifetime_coins: int = 0

## Inventory - Dictionary[String item_id, int quantity]
@export var inventory: Dictionary = {}
@export var max_slots: int = 8
@export var equipped_tool: String = "rusty_pickaxe"

## Progression tracking
@export var max_depth_reached: int = 0
@export var tools_unlocked: Array[String] = ["rusty_pickaxe"]
@export var achievements: Array[String] = []
@export var buildings_unlocked: Array[String] = []

## World generation seed
@export var world_seed: int = 0

## Statistics
@export var blocks_mined: int = 0
@export var ores_collected: int = 0
@export var deaths: int = 0


## Create a new save with default starting state
static func create_new(slot_name: String = ""):
	var save = (load("res://resources/save/save_data.gd") as GDScript).new()
	save.save_slot_name = slot_name
	save.world_seed = randi()
	save.last_save_time = int(Time.get_unix_time_from_system())
	save.equipped_tool = "rusty_pickaxe"
	save.tools_unlocked = ["rusty_pickaxe"]
	return save


## Update playtime based on elapsed time since last update
func update_playtime(delta: float) -> void:
	total_playtime += delta


## Record that a new depth milestone was reached
func update_max_depth(depth: int) -> void:
	if depth > max_depth_reached:
		max_depth_reached = depth


## Add coins and track lifetime total
func add_coins_stat(amount: int) -> void:
	coins += amount
	lifetime_coins += amount


## Increment blocks mined counter
func increment_blocks_mined() -> void:
	blocks_mined += 1


## Increment ores collected counter
func increment_ores_collected() -> void:
	ores_collected += 1


## Increment death counter
func increment_deaths() -> void:
	deaths += 1


## Check if an achievement is unlocked
func has_achievement(achievement_id: String) -> bool:
	return achievement_id in achievements


## Unlock an achievement
func unlock_achievement(achievement_id: String) -> bool:
	if has_achievement(achievement_id):
		return false
	achievements.append(achievement_id)
	return true


## Check if a tool is unlocked
func has_tool(tool_id: String) -> bool:
	return tool_id in tools_unlocked


## Unlock a tool
func unlock_tool(tool_id: String) -> bool:
	if has_tool(tool_id):
		return false
	tools_unlocked.append(tool_id)
	return true


## Check if a building is unlocked
func has_building(building_id: String) -> bool:
	return building_id in buildings_unlocked


## Unlock a building
func unlock_building(building_id: String) -> bool:
	if has_building(building_id):
		return false
	buildings_unlocked.append(building_id)
	return true


## Get a summary string for save slot display
func get_summary() -> String:
	var time_str := Time.get_datetime_string_from_unix_time(last_save_time, false)
	return "Depth: %d | Coins: $%d | %s" % [max_depth_reached, coins, time_str]
