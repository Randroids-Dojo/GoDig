extends CPUParticles2D
## Jackpot burst particle effect for rare ore discoveries.
##
## Creates a dramatic explosion of particles when player discovers
## rare/epic/legendary ores. Particles burst outward in all directions
## with gold/colored sparkles based on the ore's rarity tier.

## Rarity tier definitions
enum Tier { RARE, EPIC, LEGENDARY }

## Color schemes per rarity tier
const TIER_COLORS := {
	Tier.RARE: Color(0.3, 0.6, 1.0, 1.0),       # Blue sparkles
	Tier.EPIC: Color(0.85, 0.4, 1.0, 1.0),      # Purple sparkles
	Tier.LEGENDARY: Color(1.0, 0.85, 0.2, 1.0)  # Gold sparkles
}

## Particle counts per tier (more = more exciting)
const TIER_AMOUNTS := {
	Tier.RARE: 16,
	Tier.EPIC: 24,
	Tier.LEGENDARY: 36
}

## Lifetimes per tier
const TIER_LIFETIMES := {
	Tier.RARE: 0.6,
	Tier.EPIC: 0.8,
	Tier.LEGENDARY: 1.0
}

var _in_pool: bool = true


func _ready() -> void:
	emitting = false
	one_shot = true
	explosiveness = 1.0

	# Default to rare tier settings
	amount = TIER_AMOUNTS[Tier.RARE]
	lifetime = TIER_LIFETIMES[Tier.RARE]

	# Radial burst in all directions
	direction = Vector2(0, 0)
	spread = 180.0  # Full circle
	initial_velocity_min = 150.0
	initial_velocity_max = 300.0
	gravity = Vector2(0, 100)  # Light gravity for floaty feel
	scale_amount_min = 4.0
	scale_amount_max = 8.0

	# Fade out
	color_ramp = _create_sparkle_gradient()


func _create_sparkle_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.add_point(0.0, Color(1.0, 1.0, 1.0, 1.0))
	gradient.add_point(0.3, Color(1.0, 1.0, 0.9, 1.0))
	gradient.add_point(0.7, Color(1.0, 0.95, 0.8, 0.8))
	gradient.add_point(1.0, Color(1.0, 0.9, 0.7, 0.0))  # Fade to transparent
	return gradient


## Burst particles at screen position for the given rarity tier
## tier: 0=rare, 1=epic, 2=legendary (or use Tier enum values)
func burst_at_screen(screen_pos: Vector2, tier: int = 0, ore_color: Color = Color.WHITE) -> void:
	global_position = screen_pos
	visible = true
	_in_pool = false

	# Configure based on tier
	_configure_for_tier(tier, ore_color)

	emitting = true

	# Return to pool after particles finish
	await get_tree().create_timer(lifetime + 0.2).timeout
	_return_to_pool()


func _configure_for_tier(tier: int, ore_color: Color) -> void:
	## Configure particle behavior based on rarity tier.
	## Higher tiers = more particles, longer lifetime, more dramatic.

	# Clamp tier to valid range
	tier = clampi(tier, 0, 2)

	# Get tier settings
	var tier_color: Color = TIER_COLORS.get(tier, TIER_COLORS[Tier.RARE])
	amount = TIER_AMOUNTS.get(tier, TIER_AMOUNTS[Tier.RARE])
	lifetime = TIER_LIFETIMES.get(tier, TIER_LIFETIMES[Tier.RARE])

	# Blend tier color with ore color for unique effect per ore type
	color = tier_color.lerp(ore_color, 0.3)

	# Adjust velocity and spread based on tier
	match tier:
		Tier.RARE:
			initial_velocity_min = 150.0
			initial_velocity_max = 280.0
			scale_amount_min = 4.0
			scale_amount_max = 7.0
		Tier.EPIC:
			initial_velocity_min = 180.0
			initial_velocity_max = 350.0
			scale_amount_min = 5.0
			scale_amount_max = 9.0
		Tier.LEGENDARY:
			initial_velocity_min = 200.0
			initial_velocity_max = 420.0
			scale_amount_min = 6.0
			scale_amount_max = 12.0


func _return_to_pool() -> void:
	visible = false
	emitting = false
	_in_pool = true


## Check if this particle instance is available in the pool
func is_available() -> bool:
	return _in_pool
