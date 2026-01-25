extends Node2D
## Surface area scene controller
##
## Manages the above-ground hub area where the player spawns, returns to sell
## resources, and interacts with shops. This is a safe zone where no digging
## is possible.
##
## Building Slot System: The surface has predefined slots where buildings can
## be placed/unlocked. Each slot has a position and unlock requirement.

const BLOCK_SIZE := 128

## Building slot configuration: position_x, unlock_depth, shop_type
const BUILDING_SLOTS := [
	{"x": -256, "unlock_depth": 0, "type": "general_store", "name": "General Store"},
	{"x": 256, "unlock_depth": 50, "type": "blacksmith", "name": "Blacksmith"},
	{"x": 512, "unlock_depth": 100, "type": "supply_store", "name": "Supply Store"},
	{"x": -512, "unlock_depth": 200, "type": "equipment_shop", "name": "Equipment"},
	{"x": 768, "unlock_depth": 300, "type": "gem_appraiser", "name": "Appraiser"},
	{"x": -768, "unlock_depth": 500, "type": "warehouse", "name": "Warehouse"},
]

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var sky: ColorRect = $Sky
@onready var ground: ColorRect = $Ground
@onready var shop_building: Node2D = $ShopBuilding if has_node("ShopBuilding") else null
@onready var mine_entrance: Node2D = $MineEntrance if has_node("MineEntrance") else null

## All shop buildings on the surface (keyed by slot index)
var shop_buildings: Dictionary = {}

func _ready() -> void:
	_setup_surface_visuals()
	if shop_building:
		shop_buildings[0] = shop_building

func _setup_surface_visuals() -> void:
	## Position surface elements based on SURFACE_ROW constant
	var surface_y := GameManager.SURFACE_ROW * BLOCK_SIZE

	# Sky extends from top to just above ground
	sky.position.y = 0
	sky.size.y = surface_y - BLOCK_SIZE

	# Ground strip sits just above where dirt starts
	ground.position.y = surface_y - BLOCK_SIZE
	ground.size.y = BLOCK_SIZE

func get_spawn_position() -> Vector2:
	## Returns the world position where the player should spawn
	return spawn_point.global_position

func get_shop_position() -> Vector2:
	## Returns the world position of the shop building
	if shop_building:
		return shop_building.global_position
	return Vector2.ZERO

func get_mine_entrance_position() -> Vector2:
	## Returns the world position of the mine entrance
	if mine_entrance:
		return mine_entrance.global_position
	return Vector2.ZERO


# ============================================
# BUILDING SLOT SYSTEM
# ============================================

func get_building_slots() -> Array:
	## Get all building slot configurations
	return BUILDING_SLOTS


func get_unlocked_slots(max_depth_reached: int) -> Array:
	## Get building slots that are unlocked based on player's max depth
	var unlocked := []
	for i in range(BUILDING_SLOTS.size()):
		var slot = BUILDING_SLOTS[i]
		if slot.unlock_depth <= max_depth_reached:
			unlocked.append({"index": i, "config": slot})
	return unlocked


func is_slot_unlocked(slot_index: int, max_depth_reached: int) -> bool:
	## Check if a specific slot is unlocked
	if slot_index < 0 or slot_index >= BUILDING_SLOTS.size():
		return false
	return BUILDING_SLOTS[slot_index].unlock_depth <= max_depth_reached


func get_slot_position(slot_index: int) -> Vector2:
	## Get world position for a building slot
	if slot_index < 0 or slot_index >= BUILDING_SLOTS.size():
		return Vector2.ZERO

	var slot = BUILDING_SLOTS[slot_index]
	var surface_y := (GameManager.SURFACE_ROW - 1) * BLOCK_SIZE
	return Vector2(slot.x, surface_y)


func get_all_shop_buildings() -> Array:
	## Get all active shop buildings
	return shop_buildings.values()


func get_building_count() -> int:
	## Get number of active buildings
	return shop_buildings.size()
