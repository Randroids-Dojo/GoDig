extends Control
## MilestoneNotification - Animated banner for depth milestone achievements.
##
## Shows a prominent center-screen notification when the player reaches
## significant depth milestones (10m, 25m, 50m, 100m, etc.).

@onready var label: Label = $Panel/Label
@onready var panel: PanelContainer = $Panel

## Animation state
var _tween: Tween = null


func _ready() -> void:
	# Start hidden
	modulate.a = 0.0
	visible = false


## Display milestone notification with slide-in animation
func show_milestone(depth: int) -> void:
	if label == null or panel == null:
		return

	# Format the milestone text
	label.text = "DEPTH MILESTONE: %dm!" % depth

	# Reset state
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)

	# Cancel any existing animation
	if _tween and _tween.is_valid():
		_tween.kill()

	# Skip fancy animations if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		modulate.a = 1.0
		scale = Vector2(1.0, 1.0)
		_tween = create_tween()
		_tween.tween_interval(2.0)
		_tween.tween_property(self, "modulate:a", 0.0, 0.3)
		_tween.tween_callback(_hide)
		return

	# Animated sequence: pop in, hold, fade out
	_tween = create_tween()
	_tween.set_parallel(true)

	# Scale pop effect (0.8 -> 1.1 -> 1.0)
	_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1) \
		.set_ease(Tween.EASE_IN_OUT)

	# Fade in quickly
	_tween.tween_property(self, "modulate:a", 1.0, 0.15) \
		.set_ease(Tween.EASE_OUT)

	# Sequential: hold for 2 seconds, then fade out
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.15) \
		.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1) \
		.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(2.0)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5) \
		.set_ease(Tween.EASE_IN)
	_tween.tween_callback(_hide)


## Display layer entry notification
func show_layer_entered(layer_name: String) -> void:
	if label == null or panel == null:
		return

	# Format the layer text
	label.text = "ENTERING: %s" % layer_name

	# Reset state
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)

	# Cancel any existing animation
	if _tween and _tween.is_valid():
		_tween.kill()

	# Skip fancy animations if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		modulate.a = 1.0
		scale = Vector2(1.0, 1.0)
		_tween = create_tween()
		_tween.tween_interval(2.0)
		_tween.tween_property(self, "modulate:a", 0.0, 0.3)
		_tween.tween_callback(_hide)
		return

	# Animated sequence
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.15) \
		.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1) \
		.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(1.5)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5) \
		.set_ease(Tween.EASE_IN)
	_tween.tween_callback(_hide)


func _hide() -> void:
	visible = false
