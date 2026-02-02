extends Control
## FloatingText - Animated text for pickup feedback.
##
## Shows item pickup text that rises and fades out.
## Used by test_level to provide visual feedback on ore collection.

signal animation_finished

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


## Display achievement notification with longer duration and no rise animation
func show_achievement(text: String, color: Color, screen_pos: Vector2) -> void:
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", 18)

	# Position at the given screen coordinates
	global_position = screen_pos

	# Center the label on the position
	await get_tree().process_frame  # Wait for label to calculate size
	label.position.x = -label.size.x / 2.0
	label.position.y = -label.size.y / 2.0

	# Start visible with slight scale
	modulate.a = 0.0
	scale = Vector2(1.2, 1.2)

	# Skip fancy animations if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		modulate.a = 1.0
		scale = Vector2.ONE
		await get_tree().create_timer(2.0).timeout
		animation_finished.emit()
		queue_free()
		return

	# Animate: fade in, hold, fade out (total ~3 seconds)
	var tween := create_tween()

	# Fade in and scale down
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Hold for 2 seconds
	tween.chain().tween_interval(2.0)

	# Fade out
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.5)

	# Signal and free
	tween.chain().tween_callback(func():
		animation_finished.emit()
		queue_free()
	)


## Ore rarity tiers for celebration scaling
enum OreRarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

## Display ore discovery celebration with animation intensity based on rarity
## rarity: 0=common, 1=uncommon, 2=rare, 3=epic, 4=legendary
func show_ore_discovery(text: String, color: Color, screen_pos: Vector2, rarity: int = 0) -> void:
	label.text = text
	label.modulate = color

	# Position at the given screen coordinates
	global_position = screen_pos

	# Center the label on the position
	label.position.x = -label.size.x / 2.0
	label.position.y = -label.size.y / 2.0

	# Scale parameters based on rarity
	var start_scale: float
	var end_scale: float
	var bounce_scale: float
	var rise_distance: float
	var duration: float
	var font_size: int

	match rarity:
		OreRarity.COMMON:
			# Subtle - barely noticeable but satisfying
			start_scale = 1.1
			end_scale = 1.0
			bounce_scale = 1.05
			rise_distance = 60.0
			duration = 0.8
			font_size = 14
		OreRarity.UNCOMMON:
			# Moderate - player notices
			start_scale = 1.2
			end_scale = 1.0
			bounce_scale = 1.1
			rise_distance = 70.0
			duration = 0.9
			font_size = 15
		OreRarity.RARE:
			# Exciting - player feels rewarded
			start_scale = 1.4
			end_scale = 1.0
			bounce_scale = 1.2
			rise_distance = 80.0
			duration = 1.0
			font_size = 17
		OreRarity.EPIC:
			# Big celebration
			start_scale = 1.6
			end_scale = 1.0
			bounce_scale = 1.3
			rise_distance = 100.0
			duration = 1.2
			font_size = 19
		_:  # LEGENDARY or higher
			# Jackpot feeling!
			start_scale = 1.8
			end_scale = 1.1
			bounce_scale = 1.4
			rise_distance = 120.0
			duration = 1.5
			font_size = 22

	label.add_theme_font_size_override("font_size", font_size)

	# Start visible and scaled up
	modulate.a = 1.0
	scale = Vector2(start_scale, start_scale)

	# Skip fancy animations if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		scale = Vector2.ONE
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 0.0, duration * 0.8)
		tween.chain().tween_callback(queue_free)
		return

	# Animate with rarity-appropriate intensity
	var tween := create_tween()
	tween.set_parallel(true)

	# Bounce scale down with overshoot (more dramatic for rarer)
	tween.tween_property(self, "scale", Vector2(end_scale, end_scale), 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Secondary bounce for rare+ items
	if rarity >= OreRarity.RARE:
		tween.chain().tween_property(self, "scale", Vector2(bounce_scale, bounce_scale), 0.15) \
			.set_ease(Tween.EASE_OUT)
		tween.chain().tween_property(self, "scale", Vector2(end_scale, end_scale), 0.1)

	# Rise and fade
	tween.tween_property(self, "global_position:y", global_position.y - rise_distance, duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# Fade out - delayed more for rarer items so player can appreciate
	var fade_delay := 0.2 + (rarity * 0.1)
	tween.tween_property(self, "modulate:a", 0.0, duration - fade_delay) \
		.set_delay(fade_delay)

	# Free the node after animation completes
	tween.chain().tween_callback(queue_free)
