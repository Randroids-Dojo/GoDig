class_name ToolData extends Resource
## Resource class for tool definitions.
## Each tool tier (pickaxe, drill, etc.) is a .tres file using this class.
## Tools define mining damage and speed, affecting how fast blocks break.
## Includes audio/visual identity settings for distinct tier feel.

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

## Maximum durability (0 = infinite durability)
@export var max_durability: int = 0

## Repair cost multiplier (cost = base_damage * multiplier)
@export var repair_cost_multiplier: float = 1.0

## Whether this tool can break (false = indestructible)
@export var can_break: bool = false

## ============================================
## AUDIO/VISUAL IDENTITY
## Each tier should be immediately recognizable
## ============================================

@export_group("Sound Identity")
## Base pitch modifier for mining sounds (1.0 = normal)
## Lower tiers = duller, higher tiers = brighter/sharper
@export var sound_pitch: float = 1.0

## Sound "character" - affects which base sound variant is used
## 0=wood (dull thunk), 1=metal (tink), 2=sharp (clang), 3=rich (ring), 4=crystal (chime)
@export_enum("wood", "metal", "sharp", "rich", "crystal") var sound_character: int = 0

## Volume boost for block break (higher tiers have more satisfying break sound)
@export_range(0.0, 3.0) var break_volume_boost: float = 0.0

@export_group("Particle Identity")
## Particle color tint (for sparks/debris)
@export var particle_color: Color = Color.WHITE

## Particle scale multiplier (bigger = more impactful)
@export_range(0.5, 2.0) var particle_scale: float = 1.0

## Whether tool creates spark particles (metallic tools)
@export var creates_sparks: bool = false

## Glow effect intensity (0 = none, 1 = full)
@export_range(0.0, 1.0) var glow_intensity: float = 0.0


## Get effective damage considering durability (future use)
func get_effective_damage(current_durability: int) -> float:
	if max_durability == 0:
		return damage  # Infinite durability

	# Damage reduction when worn (below 25% durability)
	var durability_ratio := float(current_durability) / float(max_durability)
	if durability_ratio < 0.25:
		return damage * (0.5 + durability_ratio * 2.0)  # 50-100% damage
	return damage


## Check if tool is broken
func is_broken(current_durability: int) -> bool:
	return max_durability > 0 and current_durability <= 0


## Calculate repair cost
func get_repair_cost(current_durability: int) -> int:
	if max_durability == 0:
		return 0  # Can't repair infinite durability tools

	var missing_durability := max_durability - current_durability
	var base_cost := int(float(missing_durability) * repair_cost_multiplier)
	return maxi(1, base_cost)
