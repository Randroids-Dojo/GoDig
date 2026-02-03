extends Node2D
## Physical shop building on the surface
##
## Represents a shop where the player can interact for various services.
## Different shop types: general_store, supply_store, blacksmith, equipment_shop, etc.
## When the player is near the building, they can interact with it.

## Available shop types
enum ShopType {
	GENERAL_STORE,     ## Sell resources for coins
	SUPPLY_STORE,      ## Buy basic supplies (ladders, ropes, etc.)
	BLACKSMITH,        ## Tool upgrades and repairs
	EQUIPMENT_SHOP,    ## Gear and equipment
	GEM_APPRAISER,     ## Sell gems at better rates
	WAREHOUSE,         ## Extra storage capacity
	GADGET_SHOP,       ## Utility items (teleport scrolls, etc.)
	ELEVATOR,          ## Fast travel system
	REST_STATION,      ## Underground convenience shop (v1.1)
	RESEARCH_LAB,      ## Sidegrades and playstyle customization (v1.2)
}

signal player_entered(shop_type: ShopType)
signal player_exited(shop_type: ShopType)

## The type of shop this building represents
@export var shop_type: ShopType = ShopType.GENERAL_STORE

## Display name for this shop (shown on label)
@export var shop_name: String = "Shop"

@onready var interaction_area: Area2D = $InteractionArea
@onready var label: Label = $Label
@onready var building_sprite: Sprite2D = $BuildingSprite

## Preloaded building sprite textures for each shop type
const BUILDING_SPRITES = {
	ShopType.GENERAL_STORE: preload("res://resources/sprites/buildings/general_store.png"),
	ShopType.SUPPLY_STORE: preload("res://resources/sprites/buildings/supply_store.png"),
	ShopType.BLACKSMITH: preload("res://resources/sprites/buildings/blacksmith.png"),
	ShopType.EQUIPMENT_SHOP: preload("res://resources/sprites/buildings/equipment_shop.png"),
	ShopType.GEM_APPRAISER: preload("res://resources/sprites/buildings/gem_appraiser.png"),
	ShopType.WAREHOUSE: preload("res://resources/sprites/buildings/warehouse.png"),
	ShopType.GADGET_SHOP: preload("res://resources/sprites/buildings/gadget_shop.png"),
	ShopType.ELEVATOR: preload("res://resources/sprites/buildings/elevator.png"),
	ShopType.REST_STATION: preload("res://resources/sprites/buildings/rest_station.png"),
	ShopType.RESEARCH_LAB: preload("res://resources/sprites/buildings/research_lab.png"),
}

var player_nearby: bool = false

func _ready() -> void:
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	if label and shop_name:
		label.text = shop_name
	_update_building_sprite()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_nearby = true
		player_entered.emit(shop_type)
		if label:
			label.modulate = Color(1, 1, 0.5)  # Highlight when player is near

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_nearby = false
		player_exited.emit(shop_type)
		if label:
			label.modulate = Color.WHITE

func is_player_nearby() -> bool:
	return player_nearby

func get_shop_type() -> ShopType:
	return shop_type

func get_shop_type_name() -> String:
	match shop_type:
		ShopType.GENERAL_STORE:
			return "general_store"
		ShopType.SUPPLY_STORE:
			return "supply_store"
		ShopType.BLACKSMITH:
			return "blacksmith"
		ShopType.EQUIPMENT_SHOP:
			return "equipment_shop"
		ShopType.GEM_APPRAISER:
			return "gem_appraiser"
		ShopType.WAREHOUSE:
			return "warehouse"
		ShopType.GADGET_SHOP:
			return "gadget_shop"
		ShopType.ELEVATOR:
			return "elevator"
		ShopType.REST_STATION:
			return "rest_station"
		ShopType.RESEARCH_LAB:
			return "research_lab"
	return "unknown"


func _update_building_sprite() -> void:
	## Updates the building sprite based on the current shop_type.
	## Called during _ready and can be called when shop_type changes in editor.
	if not building_sprite:
		return

	if BUILDING_SPRITES.has(shop_type):
		building_sprite.texture = BUILDING_SPRITES[shop_type]


func set_shop_type(new_type: ShopType) -> void:
	## Sets the shop type and updates the building sprite accordingly.
	shop_type = new_type
	_update_building_sprite()
