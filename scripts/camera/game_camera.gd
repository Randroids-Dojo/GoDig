extends Camera2D
## Camera that follows the player with optional screen shake.
## Should be a child of the player node for automatic following.
## Also manages depth-based lighting via CanvasModulate and fog overlay.

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

# Depth fog overlay
var _fog_overlay: ColorRect = null
var _fog_canvas_layer: CanvasLayer = null


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

	# Setup depth fog overlay for atmospheric effect
	_setup_fog_overlay(main_node)


## Setup fog overlay for depth-based atmospheric fog
func _setup_fog_overlay(main_node: Node) -> void:
	# Create a CanvasLayer for the fog (renders above game but below UI)
	if main_node.has_node("FogLayer"):
		_fog_canvas_layer = main_node.get_node("FogLayer")
		_fog_overlay = _fog_canvas_layer.get_node_or_null("FogOverlay")
	else:
		_fog_canvas_layer = CanvasLayer.new()
		_fog_canvas_layer.name = "FogLayer"
		_fog_canvas_layer.layer = 50  # Above game world, below UI (UI is typically 100+)
		main_node.add_child(_fog_canvas_layer)

		# Create the fog ColorRect
		_fog_overlay = ColorRect.new()
		_fog_overlay.name = "FogOverlay"
		_fog_overlay.color = Color(0.5, 0.5, 0.5, 0.0)  # Start transparent
		_fog_overlay.visible = false  # Start hidden (surface has no fog)

		# Make it cover the full screen
		_fog_overlay.anchors_preset = Control.PRESET_FULL_RECT
		_fog_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

		# Use multiply blend mode for atmospheric fog effect
		_fog_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block input

		_fog_canvas_layer.add_child(_fog_overlay)

	# Register with LightingManager
	if LightingManager and _fog_overlay:
		LightingManager.register_fog_overlay(_fog_overlay)


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
