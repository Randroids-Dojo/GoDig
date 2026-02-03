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

# ============================================
# VISUAL IDENTITY SYSTEM (Dead Cells/Terraria-inspired)
# ============================================

## Signature visual element that defines this layer's identity
## Examples: "roots", "crystals", "lava_veins", "fossils", "thorns"
@export var signature_element: String = ""

## Description of the layer's visual theme (for UI/tooltips)
@export var visual_description: String = ""

## Atmospheric particle effect type for this layer
## Examples: "dust", "spores", "embers", "snowflakes", "void_particles"
@export_enum("none", "dust", "spores", "embers", "snowflakes", "void_particles", "drip", "crystal_sparkle") var atmosphere_particles: String = "none"

## Ambient sound ID for this layer (connects to SoundManager)
@export var ambient_sound: String = ""

## Fog/mist intensity (0.0 = none, 1.0 = thick fog)
@export_range(0.0, 1.0, 0.05) var fog_intensity: float = 0.0

## Fog color (if fog_intensity > 0)
@export var fog_color: Color = Color(0.5, 0.5, 0.5, 0.5)

## Chance for special decorative blocks (0.0-1.0)
## Decorative blocks use signature_element for visuals
@export_range(0.0, 0.3, 0.01) var decoration_chance: float = 0.05

## Array of signature ore IDs that primarily appear in this layer
## Used for "layer identity" - players associate these ores with this layer
@export var signature_ores: PackedStringArray = []

## Whether this layer has environmental storytelling elements
## (ancient ruins, fossils, lost equipment, etc.)
@export var has_lore_elements: bool = false

## Light emission from layer environment (0.0 = none, affects visibility)
## Crystal caves and magma zones emit some ambient light
@export_range(0.0, 0.5, 0.05) var ambient_light_emission: float = 0.0

## Movement speed modifier (1.0 = normal, <1.0 = slowed)
@export_range(0.5, 1.5, 0.05) var movement_modifier: float = 1.0

## Background parallax style for this layer
@export_enum("none", "earthy", "rocky", "crystalline", "magmatic", "void") var background_style: String = "none"

# ============================================
# EUREKA MECHANIC SYSTEM
# Each layer introduces a unique mechanic that creates 'aha' moments
# ============================================

## The eureka mechanic type for this layer
## Each mechanic teaches players something new about the game
@export_enum("none", "basic_dig", "ore_shimmer", "crumbling_blocks", "cave_sense", "pressure_cracks", "crystal_resonance", "loose_blocks", "heat_weaken", "void_sight", "reality_tears") var eureka_mechanic: String = "none"

## Display name for the eureka mechanic (shown when first encountered)
@export var eureka_name: String = ""

## Description of how the mechanic works (tutorial hint)
@export var eureka_description: String = ""

## Icon identifier for the eureka mechanic UI
@export var eureka_icon: String = ""

## Chance for eureka mechanic to trigger (0.0 to 1.0)
## Some mechanics are always active, others are probabilistic
@export_range(0.0, 1.0, 0.01) var eureka_trigger_chance: float = 1.0

## Parameter 1 for the eureka mechanic (meaning depends on mechanic type)
## crumbling_blocks: delay in seconds before block falls
## pressure_cracks: chain break radius
## crystal_resonance: weakness multiplier
## loose_blocks: fall speed
## heat_weaken: damage bonus per heat tick
## void_sight: reveal radius
## reality_tears: jackpot multiplier
@export var eureka_param_1: float = 0.0

## Parameter 2 for the eureka mechanic (optional secondary parameter)
@export var eureka_param_2: float = 0.0


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


## Check if this layer has a distinct visual identity
func has_visual_identity() -> bool:
	return not signature_element.is_empty()


## Check if a given ore ID is a signature ore for this layer
func is_signature_ore(ore_id: String) -> bool:
	return signature_ores.has(ore_id)


## Get atmospheric effect intensity based on depth into layer
func get_atmosphere_intensity_at(depth: int) -> float:
	if atmosphere_particles == "none":
		return 0.0

	var depth_into_layer := depth - min_depth
	if depth_into_layer < 0:
		return 0.0

	# Ramp up intensity over first 50 blocks, then stay at max
	var ramp := minf(float(depth_into_layer) / 50.0, 1.0)
	return ramp


## Check if position should have a decorative element
## Uses deterministic RNG based on position
func should_have_decoration(grid_pos: Vector2i) -> bool:
	if decoration_chance <= 0.0:
		return false

	var seed_value := grid_pos.x * 1337 + grid_pos.y * 7919
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng.randf() < decoration_chance


## Get the visibility modifier for this layer (considering ambient light emission)
## Returns 0.0-1.0 where 1.0 is fully visible
func get_visibility_modifier() -> float:
	# Base visibility from ambient light emission
	return ambient_light_emission


## Get a description string for UI display
func get_identity_description() -> String:
	if visual_description.is_empty():
		return "A %s layer." % display_name.to_lower()
	return visual_description


# ============================================
# EUREKA MECHANIC HELPERS
# ============================================

## Check if this layer has an eureka mechanic
func has_eureka_mechanic() -> bool:
	return eureka_mechanic != "none" and not eureka_mechanic.is_empty()


## Check if the eureka mechanic should trigger (based on probability)
func should_trigger_eureka(rng: RandomNumberGenerator = null) -> bool:
	if not has_eureka_mechanic():
		return false
	if eureka_trigger_chance >= 1.0:
		return true
	if rng != null:
		return rng.randf() < eureka_trigger_chance
	return randf() < eureka_trigger_chance


## Get eureka mechanic display info for UI
func get_eureka_display_info() -> Dictionary:
	if not has_eureka_mechanic():
		return {}
	return {
		"mechanic": eureka_mechanic,
		"name": eureka_name,
		"description": eureka_description,
		"icon": eureka_icon,
	}
