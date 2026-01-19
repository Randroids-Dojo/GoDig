class_name LayerData extends Resource
## Resource class for underground layer definitions.
## Each layer has unique visual identity and hardness affecting mining.

## Unique identifier for this layer type
@export var id: String = ""

## Display name shown to the player
@export var display_name: String = ""

## Minimum depth (in grid rows) where this layer starts
@export var min_depth: int = 0

## Maximum depth (in grid rows) where this layer ends
@export var max_depth: int = 50

## Base hardness value - affects hits needed to break blocks
@export var base_hardness: float = 10.0

## Primary color for this layer's blocks
@export var color_primary: Color = Color.BROWN

## Accent color for visual variation
@export var color_accent: Color = Color.TAN

## TileSet atlas coordinates for this layer's tile (if using TileMap)
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO


## Get hardness with variance based on position for deterministic randomness
func get_hardness_at(grid_pos: Vector2i) -> float:
	# Use position as seed for deterministic variance
	var seed_value := grid_pos.x * 1000 + grid_pos.y
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var variance := rng.randf_range(0.9, 1.1)
	return base_hardness * variance


## Check if a given depth is in this layer's transition zone
func is_transition_zone(depth: int) -> bool:
	const TRANSITION_RANGE := 10
	return depth >= max_depth - TRANSITION_RANGE and depth < max_depth
