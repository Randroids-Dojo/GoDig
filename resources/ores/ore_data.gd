class_name OreData extends ItemData
## Resource class for ore type definitions.
##
## Each ore type (coal, copper, iron, etc.) is a .tres file using this class.
## Extends ItemData so ores can be directly used in inventory/shop systems.
## Used by OreGenerator for placement logic and by inventory/shop for values.
##
## Inherited from ItemData: id, display_name, icon, category, max_stack,
##                          sell_value, rarity, min_depth, description

## Color for tinting or UI borders
@export var color: Color = Color.WHITE

## TileSet atlas coordinates for this ore block
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO


## Generation parameters (OreData-specific)
@export_group("Generation")

## Maximum depth (-1 for no limit). Note: min_depth is inherited from ItemData.
@export var max_depth: int = -1

## Noise threshold (0.0-1.0, higher = rarer). 0.75 common, 0.95+ rare
@export_range(0.0, 1.0) var spawn_threshold: float = 0.75

## Noise frequency (controls cluster spread). Lower = bigger clusters
@export_range(0.01, 0.5) var noise_frequency: float = 0.05

## Minimum vein size in blocks
@export var vein_size_min: int = 2

## Maximum vein size in blocks
@export var vein_size_max: int = 6


## Accessibility (OreData-specific)
@export_group("Accessibility")

## Symbol for colorblind mode (single character: C, I, G, S, etc.)
@export var colorblind_symbol: String = ""

## Pattern type for high-contrast colorblind mode (0-7 for different patterns)
@export_range(0, 7) var colorblind_pattern: int = 0


## Mining parameters (OreData-specific)
@export_group("Mining")

## Hardness (hits to break with base pickaxe)
@export var hardness: int = 2

## Minimum tool tier required to mine (0 = any)
@export var required_tool_tier: int = 0


## Audio parameters (OreData-specific)
@export_group("Audio")

## Custom discovery sound path (if empty, uses default ore_found sound)
## Different ore types can have distinct "sparkle" sounds for discovery moments
@export_file("*.wav") var discovery_sound: String = ""

## Base pitch for this ore's discovery sound (1.0 = normal, higher = brighter)
## Precious metals like gold should be higher pitched, coal lower
@export_range(0.7, 1.5) var discovery_pitch: float = 1.0

## Volume offset for this ore's discovery (-10 to +5 dB)
@export_range(-10.0, 5.0) var discovery_volume: float = 0.0


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
