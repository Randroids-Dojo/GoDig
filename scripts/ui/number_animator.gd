extends Node
## NumberAnimator - Reusable component for satisfying number animation.
##
## Provides pulse, flash, and floater effects when numbers increase.
## Attach to Labels or use static methods for one-shot effects.

class_name NumberAnimator

## Colors for different value types - reference UIColors for consistency
const COLOR_COINS := UIColors.GOLD
const COLOR_ORE := UIColors.GREEN
const COLOR_DEPTH := UIColors.BLUE
const COLOR_RECORD := UIColors.RECORD
const COLOR_LADDER := UIColors.LADDER

## Animation parameters
const PULSE_SCALE := 1.25
const PULSE_DURATION := 0.15
const SETTLE_DURATION := 0.2
const FLOATER_RISE := 40.0
const FLOATER_DURATION := 1.0

## Reference to the label being animated
var target_label: Label = null

## Cached values for change detection
var _last_value: int = 0
var _tween: Tween = null
var _floater_container: CanvasLayer = null


func _init(label: Label = null) -> void:
	target_label = label


## Set up the animator with a target label
func setup(label: Label) -> void:
	target_label = label
	if target_label:
		target_label.pivot_offset = target_label.size / 2


## Animate a value increase with pulse and optional floater
func animate_increase(new_value: int, old_value: int, color: Color, show_floater: bool = true) -> void:
	if target_label == null:
		return

	# Skip animations if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		return

	var delta := new_value - old_value
	if delta <= 0:
		return

	# Pulse animation
	_pulse_label(color)

	# Show floater if enabled
	if show_floater and delta > 0:
		_show_floater("+%d" % delta, color)


## Pulse the target label with scale and color flash
func _pulse_label(flash_color: Color) -> void:
	if target_label == null:
		return

	# Cancel existing animation
	if _tween and _tween.is_valid():
		_tween.kill()

	# Ensure pivot is centered for proper scaling
	target_label.pivot_offset = target_label.size / 2

	# Store original color
	var original_color: Color = target_label.get_theme_color("font_color") if target_label.has_theme_color_override("font_color") else Color.WHITE

	# Create pulse animation
	_tween = target_label.create_tween()
	_tween.set_parallel(true)

	# Scale up
	_tween.tween_property(target_label, "scale", Vector2(PULSE_SCALE, PULSE_SCALE), PULSE_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Flash color
	target_label.add_theme_color_override("font_color", flash_color)

	# Sequential: scale down and restore color
	_tween.chain().tween_property(target_label, "scale", Vector2(1.0, 1.0), SETTLE_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

	# Restore original color after flash
	_tween.chain().tween_callback(func():
		target_label.add_theme_color_override("font_color", original_color)
	).set_delay(0.0)


## Show a floater that rises from the label
func _show_floater(text: String, color: Color) -> void:
	if target_label == null:
		return

	# Find or create a container for floaters
	var root := target_label.get_tree().root
	if _floater_container == null:
		_floater_container = CanvasLayer.new()
		_floater_container.layer = 100  # Above most UI
		root.add_child(_floater_container)

	# Create the floater label
	var floater := Label.new()
	floater.text = text
	floater.add_theme_font_size_override("font_size", 14)
	floater.add_theme_color_override("font_color", color)
	floater.add_theme_constant_override("outline_size", 2)
	floater.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	floater.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Position above the target label
	var global_pos := target_label.global_position
	floater.global_position = global_pos + Vector2(target_label.size.x / 2 - 20, -10)

	_floater_container.add_child(floater)

	# Animate rise and fade
	var tween := floater.create_tween()
	tween.set_parallel(true)

	# Rise up
	tween.tween_property(floater, "global_position:y", floater.global_position.y - FLOATER_RISE, FLOATER_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# Fade out
	tween.tween_property(floater, "modulate:a", 0.0, FLOATER_DURATION * 0.6) \
		.set_delay(FLOATER_DURATION * 0.4)

	# Clean up
	tween.chain().tween_callback(floater.queue_free)


## Static method: Create a one-shot floater at a global position
static func show_floater_at(tree: SceneTree, text: String, global_pos: Vector2, color: Color) -> void:
	if SettingsManager and SettingsManager.reduced_motion:
		return

	var floater := Label.new()
	floater.text = text
	floater.add_theme_font_size_override("font_size", 16)
	floater.add_theme_color_override("font_color", color)
	floater.add_theme_constant_override("outline_size", 3)
	floater.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	floater.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	floater.global_position = global_pos

	# Add to a high canvas layer
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	tree.root.add_child(canvas)
	canvas.add_child(floater)

	# Animate
	var tween := floater.create_tween()
	tween.set_parallel(true)

	# Pop in
	floater.scale = Vector2(1.3, 1.3)
	tween.tween_property(floater, "scale", Vector2(1.0, 1.0), 0.15) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Rise
	tween.tween_property(floater, "global_position:y", global_pos.y - 50.0, 1.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# Fade
	tween.tween_property(floater, "modulate:a", 0.0, 0.6) \
		.set_delay(0.4)

	# Clean up canvas and floater
	tween.chain().tween_callback(func():
		canvas.queue_free()
	)


## Static method: Show a "+X" coin floater near the HUD coins display
static func show_coin_gain(tree: SceneTree, amount: int) -> void:
	if amount <= 0:
		return

	# Find HUD coins label for positioning
	var hud := tree.root.get_node_or_null("/root/Main/UI/HUD")
	if hud == null:
		return

	var coins_label: Label = hud.get_node_or_null("CoinsLabel")
	if coins_label == null:
		return

	var pos := coins_label.global_position + Vector2(coins_label.size.x + 10, 0)
	show_floater_at(tree, "+$%d" % amount, pos, COLOR_COINS)
