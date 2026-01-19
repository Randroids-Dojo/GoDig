class_name ToolData extends Resource
## Resource class for tool definitions.
## Each tool tier (pickaxe, drill, etc.) is a .tres file using this class.
## Tools define mining damage and speed, affecting how fast blocks break.

## Unique identifier for this tool
@export var id: String = ""

## Display name shown to the player
@export var display_name: String = ""

## Damage dealt per hit (compared against block hardness)
@export var damage: float = 10.0

## Speed multiplier for mining (1.0 = normal)
@export var speed_multiplier: float = 1.0

## Cost in coins to purchase this tool
@export var cost: int = 0

## Minimum depth player must reach before tool is available in shop
@export var unlock_depth: int = 0

## Tier number (1 = starter, higher = better)
@export var tier: int = 1

## Icon texture for UI display
@export var icon: Texture2D

## Optional sprite for player holding (v1.0)
@export var sprite: Texture2D

## Optional description text
@export var description: String = ""
