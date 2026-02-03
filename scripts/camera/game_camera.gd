extends Camera2D
## Camera that follows the player with optional screen shake.
## Should be a child of the player node for automatic following.
## Also manages depth-based lighting via CanvasModulate.

# Offset from player origin
# X=64 centers on player sprite (player is 128px wide)
# Y=200 looks ahead below the player
const PLAYER_CENTER_X := 64.0
const LOOK_AHEAD_Y := 200.0

# Screen shake state
var _shake_intensity: float = 0.0
var _shake_decay: float = 10.0  # How fast shake fades
var _base_offset: Vector2

# Lighting modulation
var _ambient_modulate: CanvasModulate = null


func _ready() -> void:
	# Position camera relative to player
	# X centers on player sprite, Y looks below
	position = Vector2(PLAYER_CENTER_X, PLAYER_CENTER_X + LOOK_AHEAD_Y)
	_base_offset = offset
	make_current()

	# Create CanvasModulate for depth-based lighting
	_setup_ambient_lighting()


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

	# Apply screen shake intensity setting
	var adjusted_intensity := intensity
	if SettingsManager:
		adjusted_intensity *= SettingsManager.screen_shake_intensity
		# Also apply juice level shake multiplier
		adjusted_intensity *= SettingsManager.get_shake_multiplier()

	# Skip if intensity is too low
	if adjusted_intensity < 0.1:
		return

	# Use the higher of current and new intensity (don't reduce mid-shake)
	_shake_intensity = maxf(_shake_intensity, adjusted_intensity)


## Setup CanvasModulate for depth-based ambient lighting
func _setup_ambient_lighting() -> void:
	# Create CanvasModulate as sibling of camera (in Main scene)
	# We need to find the Main node and add it there
	var main_node := _find_main_node()
	if main_node == null:
		push_warning("[GameCamera] Could not find Main node for ambient lighting")
		return

	# Check if CanvasModulate already exists
	if main_node.has_node("AmbientModulate"):
		_ambient_modulate = main_node.get_node("AmbientModulate")
	else:
		_ambient_modulate = CanvasModulate.new()
		_ambient_modulate.name = "AmbientModulate"
		_ambient_modulate.color = Color.WHITE
		main_node.add_child(_ambient_modulate)

	# Register with LightingManager
	if LightingManager:
		LightingManager.register_canvas_modulate(_ambient_modulate)


## Find the Main scene node (root of game scene)
func _find_main_node() -> Node:
	# Walk up to find the Main node
	var current := get_parent()
	while current != null:
		if current.name == "Main":
			return current
		current = current.get_parent()

	# Fallback: try to get from scene tree
	var root := get_tree().root
	if root.has_node("Main"):
		return root.get_node("Main")

	return null
