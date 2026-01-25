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
	WAREHOUSE,         ## Extra storage
}

signal player_entered(shop_type: ShopType)
signal player_exited(shop_type: ShopType)

## The type of shop this building represents
@export var shop_type: ShopType = ShopType.GENERAL_STORE

## Display name for this shop (shown on label)
@export var shop_name: String = "Shop"

@onready var interaction_area: Area2D = $InteractionArea
@onready var label: Label = $Label

var player_nearby: bool = false

func _ready() -> void:
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	if label and shop_name:
		label.text = shop_name

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
	return "unknown"
