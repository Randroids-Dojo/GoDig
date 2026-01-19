class_name OreData extends Resource
## Resource class for ore type definitions.
##
## Each ore type (coal, copper, iron, etc.) is a .tres file using this class.
## Used by OreGenerator for placement logic and by inventory/shop for values.

## Unique identifier (coal, copper, iron, etc.)
@export var id: String = ""

## Display name shown to player
@export var display_name: String = ""

## Icon texture for inventory/shop UI
@export var icon: Texture2D

## Color for tinting or UI borders
@export var color: Color = Color.WHITE

## TileSet atlas coordinates for this ore block
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO


## Generation parameters
@export_group("Generation")

## Minimum depth (grid rows from surface) where this ore can spawn
@export var min_depth: int = 0

## Maximum depth (-1 for no limit)
@export var max_depth: int = -1

## Noise threshold (0.0-1.0, higher = rarer). 0.75 common, 0.95+ rare
@export_range(0.0, 1.0) var spawn_threshold: float = 0.75

## Noise frequency (controls cluster spread). Lower = bigger clusters
@export_range(0.01, 0.5) var noise_frequency: float = 0.05

## Minimum vein size in blocks
@export var vein_size_min: int = 2

## Maximum vein size in blocks
@export var vein_size_max: int = 6


## Economy parameters
@export_group("Economy")

## Base sell value in coins
@export var sell_value: int = 1

## Maximum stack size in inventory
@export var max_stack: int = 99

## Rarity tier (1-8, affects border colors in UI)
@export_range(1, 8) var tier: int = 1

## Rarity name: common, uncommon, rare, epic, legendary
@export_enum("common", "uncommon", "rare", "epic", "legendary") var rarity: String = "common"


## Mining parameters
@export_group("Mining")

## Hardness (hits to break with base pickaxe)
@export var hardness: int = 2

## Minimum tool tier required to mine (0 = any)
@export var required_tool_tier: int = 0


## Check if this ore can spawn at the given depth
func can_spawn_at_depth(depth: int) -> bool:
	if depth < min_depth:
		return false
	if max_depth == -1:
		return true
	return depth <= max_depth


## Get a random vein size within the configured range
func get_random_vein_size(rng: RandomNumberGenerator = null) -> int:
	if rng == null:
		return randi_range(vein_size_min, vein_size_max)
	return rng.randi_range(vein_size_min, vein_size_max)
