extends Node2D
## Surface area scene controller
##
## Manages the above-ground hub area where the player spawns, returns to sell
## resources, and interacts with shops. This is a safe zone where no digging
## is possible.

const BLOCK_SIZE := 128

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var sky: ColorRect = $Sky
@onready var ground: ColorRect = $Ground
@onready var shop_building: Node2D = $ShopBuilding if has_node("ShopBuilding") else null
@onready var mine_entrance: Node2D = $MineEntrance if has_node("MineEntrance") else null

func _ready() -> void:
	_setup_surface_visuals()

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
