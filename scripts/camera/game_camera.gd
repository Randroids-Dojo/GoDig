extends Camera2D
## Camera that follows the player with optional screen shake.
## Should be a child of the player node for automatic following.

# Offset from player origin
# X=64 centers on player sprite (player is 128px wide)
# Y=200 looks ahead below the player
const PLAYER_CENTER_X := 64.0
const LOOK_AHEAD_Y := 200.0

# Screen shake state
var _shake_intensity: float = 0.0
var _shake_decay: float = 10.0  # How fast shake fades
var _base_offset: Vector2


func _ready() -> void:
	# Position camera relative to player
	# X centers on player sprite, Y looks below
	position = Vector2(PLAYER_CENTER_X, PLAYER_CENTER_X + LOOK_AHEAD_Y)
	_base_offset = offset
	make_current()


func _process(delta: float) -> void:
	if _shake_intensity > 0.01:
		# Apply random offset within shake intensity range
		offset = _base_offset + Vector2(
			randf_range(-_shake_intensity, _shake_intensity),
			randf_range(-_shake_intensity, _shake_intensity)
		)
		# Decay shake intensity over time
		_shake_intensity = lerpf(_shake_intensity, 0.0, _shake_decay * delta)
	elif offset != _base_offset:
		# Return to base offset when shake is done
		offset = _base_offset


## Trigger camera shake with the given intensity (pixels)
func shake(intensity: float) -> void:
	# Skip if reduced motion is enabled (accessibility)
	if SettingsManager and SettingsManager.reduced_motion:
		return

	# Use the higher of current and new intensity (don't reduce mid-shake)
	_shake_intensity = maxf(_shake_intensity, intensity)
