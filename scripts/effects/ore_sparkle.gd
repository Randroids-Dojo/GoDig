extends CPUParticles2D
## Ore sparkle visual effect.
##
## Creates a subtle shimmer effect on ore blocks to hint at valuable resources.
## Sparkle frequency increases with ore rarity.

const BLOCK_SIZE := 128

## Base interval between sparkles (modified by rarity)
var _base_interval: float = 3.0
var _sparkle_timer: float = 0.0
var _current_interval: float = 3.0

## Ore color for the sparkle
var ore_color: Color = Color.WHITE

## Rarity level (0-4, higher = more frequent sparkles)
var rarity: int = 0


func _ready() -> void:
	# Configure particle behavior for sparkle effect
	emitting = false
	one_shot = true
	explosiveness = 1.0
	amount = 3
	lifetime = 0.5

	# Sparkle floats upward gently
	direction = Vector2(0, -1)
	spread = 30.0
	initial_velocity_min = 20.0
	initial_velocity_max = 40.0
	gravity = Vector2(0, 0)  # No gravity - float away

	# Small sparkle particles
	scale_amount_min = 2.0
	scale_amount_max = 4.0

	# Fade out
	color_ramp = _create_sparkle_gradient()

	# Position in center of block
	position = Vector2(BLOCK_SIZE / 2, BLOCK_SIZE / 2)

	# Randomize initial timer so not all blocks sparkle at once
	_sparkle_timer = randf() * _current_interval


func _process(delta: float) -> void:
	# Skip sparkle processing if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		return

	_sparkle_timer += delta
	if _sparkle_timer >= _current_interval:
		_sparkle_timer = 0.0
		_do_sparkle()
		# Randomize next interval
		_current_interval = _get_random_interval()


func _create_sparkle_gradient() -> Gradient:
	var gradient := Gradient.new()
	# Start bright, fade to transparent
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(0.3, Color(1, 1, 1, 0.8))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	return gradient


func _do_sparkle() -> void:
	## Trigger a sparkle burst
	# Set color based on ore color (brighter)
	var brightness_boost := 0.1 + (rarity * 0.1)
	color = ore_color.lightened(brightness_boost)
	emitting = true


func _get_random_interval() -> float:
	## Get random interval based on rarity
	## Higher rarity = more frequent sparkles
	match rarity:
		0:  # Common
			return randf_range(3.0, 5.0)
		1:  # Uncommon
			return randf_range(2.0, 4.0)
		2:  # Rare
			return randf_range(1.5, 3.0)
		3:  # Epic
			return randf_range(1.0, 2.0)
		_:  # Legendary or higher
			return randf_range(0.5, 1.5)


func configure(p_ore_color: Color, p_rarity: int) -> void:
	## Configure sparkle for a specific ore
	ore_color = p_ore_color
	rarity = p_rarity
	_current_interval = _get_random_interval()
	# Reset timer with some randomization
	_sparkle_timer = randf() * _current_interval
