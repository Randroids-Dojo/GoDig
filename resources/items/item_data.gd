class_name ItemData extends Resource
## Resource class for item definitions.
## Each item type (ore, gem, artifact, etc.) is a .tres file using this class.

## Unique identifier for this item type
@export var id: String = ""

## Display name shown to the player
@export var display_name: String = ""

## Icon texture for UI display
@export var icon: Texture2D

## Item category: ore, gem, artifact, consumable
@export var category: String = "ore"

## Maximum stack size in a single inventory slot
@export var max_stack: int = 99

## Base value when selling to shop
@export var sell_value: int = 1

## Rarity tier: common, uncommon, rare, epic, legendary
@export var rarity: String = "common"

## Optional: Minimum depth where this item spawns
@export var min_depth: int = 0

## Optional: Description text for item details
@export var description: String = ""
