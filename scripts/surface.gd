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

## Parallax background components
var parallax_bg: ParallaxBackground = null
var cloud_layer: ParallaxLayer = null
var mountain_layer: ParallaxLayer = null

func _ready() -> void:
	_setup_parallax_background()
	_setup_surface_visuals()
	if shop_building:
		shop_buildings[0] = shop_building

func _setup_parallax_background() -> void:
	## Create parallax background layers for visual depth
	parallax_bg = ParallaxBackground.new()
	parallax_bg.name = "ParallaxBackground"
	# Insert at the beginning so it's behind other elements
	add_child(parallax_bg)
	move_child(parallax_bg, 0)

	var surface_y := GameManager.SURFACE_ROW * BLOCK_SIZE

	# Mountain layer (slowest parallax, furthest away)
	mountain_layer = ParallaxLayer.new()
	mountain_layer.name = "MountainLayer"
	mountain_layer.motion_scale = Vector2(0.3, 0.15)
	mountain_layer.motion_offset = Vector2(0, -200)
	parallax_bg.add_child(mountain_layer)

	# Create mountain silhouette
	var mountains := ColorRect.new()
	mountains.name = "Mountains"
	mountains.color = Color(0.35, 0.45, 0.55, 0.6)  # Distant blue-gray
	mountains.position = Vector2(-5000, surface_y - 400)
	mountains.size = Vector2(10000, 300)
	mountain_layer.add_child(mountains)

	# Add some mountain "peaks" using multiple rects
	_create_mountain_peaks(mountain_layer, surface_y)

	# Cloud layer (moderate parallax)
	cloud_layer = ParallaxLayer.new()
	cloud_layer.name = "CloudLayer"
	cloud_layer.motion_scale = Vector2(0.1, 0.05)
	cloud_layer.motion_offset = Vector2(0, -350)
	parallax_bg.add_child(cloud_layer)

	# Create cloud shapes
	_create_clouds(cloud_layer, surface_y)


func _create_mountain_peaks(layer: ParallaxLayer, surface_y: float) -> void:
	## Create procedural mountain peak shapes
	var peak_positions := [-3000.0, -1500.0, -500.0, 800.0, 2000.0, 3500.0]
	var peak_heights := [180.0, 220.0, 160.0, 200.0, 240.0, 170.0]

	for i in range(peak_positions.size()):
		var peak := ColorRect.new()
		peak.name = "Peak%d" % i
		peak.color = Color(0.3, 0.4, 0.5, 0.7)  # Slightly darker than base
		peak.position = Vector2(peak_positions[i], surface_y - 300 - peak_heights[i])
		peak.size = Vector2(400, peak_heights[i])
		peak.rotation = 0  # Could add slight rotation for variety
		layer.add_child(peak)


func _create_clouds(layer: ParallaxLayer, surface_y: float) -> void:
	## Create procedural cloud shapes
	var cloud_positions := [
		Vector2(-2000, surface_y - 600),
		Vector2(-500, surface_y - 550),
		Vector2(1000, surface_y - 580),
		Vector2(2500, surface_y - 520),
		Vector2(-3500, surface_y - 540),
		Vector2(4000, surface_y - 570),
	]

	var cloud_sizes := [
		Vector2(300, 60),
		Vector2(200, 50),
		Vector2(350, 70),
		Vector2(250, 55),
		Vector2(280, 65),
		Vector2(320, 58),
	]

	for i in range(cloud_positions.size()):
		var cloud := ColorRect.new()
		cloud.name = "Cloud%d" % i
		cloud.color = Color(1.0, 1.0, 1.0, 0.7)  # White, semi-transparent
		cloud.position = cloud_positions[i]
		cloud.size = cloud_sizes[i]
		layer.add_child(cloud)

		# Add a smaller puff on top
		var puff := ColorRect.new()
		puff.name = "Puff%d" % i
		puff.color = Color(1.0, 1.0, 1.0, 0.6)
		puff.position = cloud_positions[i] + Vector2(cloud_sizes[i].x * 0.3, -cloud_sizes[i].y * 0.5)
		puff.size = cloud_sizes[i] * 0.6
		layer.add_child(puff)


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
