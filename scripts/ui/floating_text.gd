extends Control
## FloatingText - Animated text for pickup feedback.
##
## Shows item pickup text that rises and fades out.
## Used by test_level to provide visual feedback on ore collection.

@onready var label: Label = $Label


## Display floating text with animation
func show_pickup(text: String, color: Color, screen_pos: Vector2) -> void:
	label.text = text
	label.modulate = color

	# Position at the given screen coordinates
	global_position = screen_pos

	# Center the label on the position
	label.position.x = -label.size.x / 2.0
	label.position.y = -label.size.y / 2.0

	# Start visible and slightly scaled up for pop effect
	modulate.a = 1.0
	scale = Vector2(1.3, 1.3)

	# Skip fancy animations if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.8)
		tween.chain().tween_callback(queue_free)
		return

	# Animate: bounce in, rise up and fade out
	var tween := create_tween()
	tween.set_parallel(true)

	# Bounce scale down (pop effect)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Rise 80 pixels over 1 second
	tween.tween_property(self, "global_position:y", global_position.y - 80.0, 1.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# Fade out starting at 0.3s
	tween.tween_property(self, "modulate:a", 0.0, 0.7) \
		.set_delay(0.3)

	# Free the node after animation completes
	tween.chain().tween_callback(queue_free)
