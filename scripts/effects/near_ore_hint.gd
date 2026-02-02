extends CPUParticles2D
## Near-ore hint visual effect.
##
## Creates a subtle, infrequent shimmer effect on blocks adjacent to ore veins.
## Much dimmer and less frequent than ore sparkles to feel like a "getting warmer" hint
## rather than a direct indicator.

const BLOCK_SIZE := 128

## Base interval between hints (much longer than ore sparkles)
var _base_interval: float = 8.0
var _hint_timer: float = 0.0
var _current_interval: float = 8.0

## Hint color - subtle earth tone
var hint_color: Color = Color(0.8, 0.75, 0.6, 0.5)

## Depth factor - hints become subtler as player learns (deeper = less obvious)
var depth_factor: float = 1.0


func _ready() -> void:
	# Configure particle behavior for subtle hint effect
	emitting = false
	one_shot = true
	explosiveness = 1.0
	amount = 1  # Single particle - very subtle
	lifetime = 0.6

	# Gentle upward drift
	direction = Vector2(0, -1)
	spread = 45.0
	initial_velocity_min = 10.0
	initial_velocity_max = 20.0
	gravity = Vector2(0, 0)  # No gravity

	# Very small particles
	scale_amount_min = 1.0
	scale_amount_max = 2.0

	# Subtle fade
	color_ramp = _create_hint_gradient()

	# Position in center of block
	position = Vector2(BLOCK_SIZE / 2, BLOCK_SIZE / 2)

	# Randomize initial timer heavily so hints appear sporadically
	_hint_timer = randf() * _current_interval * 1.5


func _process(delta: float) -> void:
	# Skip hint processing if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		return

	_hint_timer += delta
	if _hint_timer >= _current_interval:
		_hint_timer = 0.0
		_do_hint()
		# Randomize next interval heavily
		_current_interval = _get_random_interval()


func _create_hint_gradient() -> Gradient:
	var gradient := Gradient.new()
	# Start very subtle, fade to transparent
	gradient.add_point(0.0, Color(1, 1, 1, 0.4))
	gradient.add_point(0.5, Color(1, 1, 1, 0.2))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	return gradient


func _do_hint() -> void:
	## Trigger a subtle hint glint
	# Apply depth factor - deeper hints are dimmer
	var dim_factor := 0.3 + (0.7 * depth_factor)
	color = hint_color.darkened(1.0 - dim_factor)
	emitting = true


func _get_random_interval() -> float:
	## Get random interval - infrequent and variable to feel natural
	## Ranges from 6-12 seconds, adjusted by depth factor
	var base := randf_range(6.0, 12.0)
	# Deeper = less frequent (hints become optional skill)
	return base / depth_factor


func configure(p_depth_factor: float = 1.0) -> void:
	## Configure hint based on depth.
	## p_depth_factor: 1.0 = surface (most obvious), 0.3 = very deep (subtle)
	depth_factor = clampf(p_depth_factor, 0.3, 1.0)
	_current_interval = _get_random_interval()
	# Heavy randomization for staggered hints
	_hint_timer = randf() * _current_interval * 2.0
