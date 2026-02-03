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

## Primary color for this layer's blocks (most common)
@export var color_primary: Color = Color.BROWN

## Secondary color for visual variety (less common)
@export var color_secondary: Color = Color.TAN

## Accent color for highlights and transitions
@export var color_accent: Color = Color.TAN

## Background/shadow color for depth
@export var color_shadow: Color = Color.DIM_GRAY

## Highlight color for special blocks
@export var color_highlight: Color = Color.WHITE

## Ore tint color - applied to ores in this layer for cohesion
@export var color_ore_tint: Color = Color.WHITE

## TileSet atlas coordinates for this layer's tile (if using TileMap)
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO

## Enable infinite depth scaling (hardness increases with depth)
@export var infinite_scaling: bool = false

## Hardness increase per 100 blocks of depth (when infinite_scaling is true)
@export var hardness_per_100_depth: float = 10.0

## Maximum hardness cap (0 = no cap)
@export var max_hardness: float = 0.0

## Heat damage per second (0 = no heat damage)
@export var heat_damage: float = 0.0

## Heat damage scaling per 100 blocks of depth (for infinite layers)
@export var heat_damage_per_100_depth: float = 0.0


## Get hardness with variance based on position for deterministic randomness
## Supports infinite depth scaling for endless layers
func get_hardness_at(grid_pos: Vector2i) -> float:
	# Use position as seed for deterministic variance
	var seed_value := grid_pos.x * 1000 + grid_pos.y
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var variance := rng.randf_range(0.9, 1.1)

	var hardness := base_hardness

	# Apply infinite depth scaling if enabled
	if infinite_scaling:
		var depth_into_layer := grid_pos.y - min_depth
		if depth_into_layer > 0:
			# Increase hardness logarithmically to prevent extreme values
			var depth_factor := log(1.0 + float(depth_into_layer) / 100.0) * hardness_per_100_depth
			hardness += depth_factor

			# Apply cap if set
			if max_hardness > 0 and hardness > max_hardness:
				hardness = max_hardness

	return hardness * variance


## Check if a given depth is in this layer's transition zone
func is_transition_zone(depth: int) -> bool:
	const TRANSITION_RANGE := 10
	return depth >= max_depth - TRANSITION_RANGE and depth < max_depth


## Get heat damage at a specific depth
## Returns damage per second (0 = no heat damage)
func get_heat_damage_at(depth: int) -> float:
	if heat_damage == 0.0 and heat_damage_per_100_depth == 0.0:
		return 0.0

	var damage := heat_damage

	# Apply depth scaling if enabled
	if heat_damage_per_100_depth > 0.0:
		var depth_into_layer := depth - min_depth
		if depth_into_layer > 0:
			damage += (float(depth_into_layer) / 100.0) * heat_damage_per_100_depth

	return damage


## Get a color for a block at grid position with deterministic variation.
## Uses the full palette for natural-looking terrain.
## Weights: primary (60%), secondary (25%), accent (15%)
func get_color_at(grid_pos: Vector2i) -> Color:
	var seed_value := grid_pos.x * 1000 + grid_pos.y
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var roll := rng.randf()

	if roll < 0.60:
		return color_primary
	elif roll < 0.85:
		return color_secondary
	else:
		return color_accent


## Get the full palette as an array for external systems
func get_palette() -> Array[Color]:
	return [
		color_primary,
		color_secondary,
		color_accent,
		color_shadow,
		color_highlight,
		color_ore_tint,
	]


## Get the saturation level of this layer's palette (0.0 to 1.0)
## Useful for UI elements that need to match layer feel
func get_saturation_level() -> float:
	return color_primary.s
