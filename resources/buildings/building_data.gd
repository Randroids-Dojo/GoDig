class_name BuildingData extends Resource
## Resource class for building definitions.
## Each building on the surface is defined by a .tres file using this class.

## Unique identifier for this building
@export var id: String = ""

## Display name shown to the player
@export var display_name: String = ""

## Description of what the building does
@export var description: String = ""

## Icon texture for UI display
@export var icon: Texture2D

## Minimum depth required to unlock this building (0 = available from start)
@export var unlock_depth: int = 0

## Position slot on the surface (for building placement)
@export var surface_slot: int = 0

## Path to the building's scene file
@export var scene_path: String = ""

## Whether this is a shop-type building that opens a menu
@export var is_shop: bool = false

## Shop category (for shop-type buildings): "tools", "equipment", "supplies", "gems"
@export var shop_category: String = ""
