extends CanvasLayer
## Upgrade celebration effect for shop purchases.
##
## Creates a satisfying celebration when player purchases any upgrade:
## - Screen flash with gold tint
## - Particle burst effect
## - Stats comparison popup
## - Brief hitstop/slowmo effect
##
## First upgrade gets extra enhanced celebration (handled separately in shop.gd).

signal celebration_complete(upgrade_type: String)

## Upgrade types for different celebration variants
enum UpgradeType { TOOL, BACKPACK, WAREHOUSE, EQUIPMENT, GADGET }

## Colors per upgrade type
const TYPE_COLORS := {
	UpgradeType.TOOL: Color(1.0, 0.75, 0.2, 1.0),       # Gold for tools
	UpgradeType.BACKPACK: Color(0.6, 0.4, 0.2, 1.0),   # Brown for backpack
	UpgradeType.WAREHOUSE: Color(0.5, 0.5, 0.6, 1.0),  # Gray for warehouse
	UpgradeType.EQUIPMENT: Color(0.3, 0.7, 1.0, 1.0),  # Blue for equipment
	UpgradeType.GADGET: Color(0.8, 0.3, 1.0, 1.0),     # Purple for gadgets
}

## Flash intensity per upgrade type
const TYPE_FLASH_ALPHA := {
	UpgradeType.TOOL: 0.4,
	UpgradeType.BACKPACK: 0.25,
	UpgradeType.WAREHOUSE: 0.2,
	UpgradeType.EQUIPMENT: 0.3,
	UpgradeType.GADGET: 0.3,
}

## Particle counts per upgrade type
const TYPE_PARTICLE_AMOUNT := {
	UpgradeType.TOOL: 24,
	UpgradeType.BACKPACK: 16,
	UpgradeType.WAREHOUSE: 12,
	UpgradeType.EQUIPMENT: 20,
	UpgradeType.GADGET: 18,
}

@onready var flash_rect: ColorRect
@onready var particles: CPUParticles2D
@onready var stats_popup: Control

var _is_playing: bool = false


func _ready() -> void:
	layer = 80  # Above game, but below first-upgrade overlay (100)
	visible = false

	_setup_flash_rect()
	_setup_particles()
	_setup_stats_popup()


func _setup_flash_rect() -> void:
	## Create the screen flash effect
	flash_rect = ColorRect.new()
	flash_rect.name = "FlashRect"
	flash_rect.color = Color(1.0, 0.9, 0.5, 0.0)  # Start invisible
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(flash_rect)


func _setup_particles() -> void:
	## Create burst particle effect
	particles = CPUParticles2D.new()
	particles.name = "UpgradeParticles"
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 20
	particles.lifetime = 0.8

	# Radial burst upward
	particles.direction = Vector2(0, -1)
	particles.spread = 60.0
	particles.initial_velocity_min = 150.0
	particles.initial_velocity_max = 280.0
	particles.gravity = Vector2(0, 200)
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 8.0

	# Color gradient (fade out)
	var gradient := Gradient.new()
	gradient.add_point(0.0, Color(1.0, 1.0, 1.0, 1.0))
	gradient.add_point(0.4, Color(1.0, 0.95, 0.8, 1.0))
	gradient.add_point(0.8, Color(1.0, 0.9, 0.6, 0.6))
	gradient.add_point(1.0, Color(1.0, 0.85, 0.5, 0.0))
	particles.color_ramp = gradient

	add_child(particles)


func _setup_stats_popup() -> void:
	## Create the stats comparison popup container
	stats_popup = Control.new()
	stats_popup.name = "StatsPopup"
	stats_popup.set_anchors_preset(Control.PRESET_CENTER)
	stats_popup.visible = false
	add_child(stats_popup)


## Play the celebration effect for an upgrade purchase
## upgrade_type: Type of upgrade (TOOL, BACKPACK, etc.)
## old_value: Previous stat value (e.g., old damage)
## new_value: New stat value after upgrade
## stat_name: Name of the stat being compared (e.g., "Damage", "Slots")
## screen_pos: Screen position for particle effect (center of button pressed)
func celebrate(
	upgrade_type: int,
	old_value: float,
	new_value: float,
	stat_name: String,
	screen_pos: Vector2 = Vector2.ZERO
) -> void:
	if _is_playing:
		return

	_is_playing = true
	visible = true

	# Get settings for this upgrade type
	var flash_color: Color = TYPE_COLORS.get(upgrade_type, TYPE_COLORS[UpgradeType.TOOL])
	var flash_alpha: float = TYPE_FLASH_ALPHA.get(upgrade_type, 0.3)
	var particle_amount: int = TYPE_PARTICLE_AMOUNT.get(upgrade_type, 16)

	# Respect reduced motion setting
	var do_flash := true
	var do_particles := true
	if SettingsManager and SettingsManager.reduced_motion:
		do_flash = false
		do_particles = false

	# Play screen flash
	if do_flash and flash_rect:
		_play_flash(flash_color, flash_alpha)

	# Play particle burst
	if do_particles and particles:
		_play_particles(screen_pos, flash_color, particle_amount)

	# Show stats comparison popup
	_show_stats_comparison(old_value, new_value, stat_name, flash_color)

	# Apply brief hitstop effect (0.05s pause)
	_apply_hitstop(0.05)

	# Trigger camera shake via GameCamera
	_trigger_camera_shake(4.0)

	# Wait for effects to complete
	await get_tree().create_timer(1.2).timeout

	_cleanup()
	celebration_complete.emit(_upgrade_type_to_string(upgrade_type))


func _play_flash(color: Color, alpha: float) -> void:
	## Animate the screen flash
	flash_rect.color = Color(color.r, color.g, color.b, 0.0)

	var tween := create_tween()
	# Quick flash to peak (0.08s)
	tween.tween_property(flash_rect, "color:a", alpha, 0.08)
	# Slower fade out (0.25s)
	tween.tween_property(flash_rect, "color:a", 0.0, 0.25)


func _play_particles(pos: Vector2, color: Color, amount: int) -> void:
	## Burst particles at the given screen position
	if pos == Vector2.ZERO:
		# Default to center of screen
		var viewport := get_viewport()
		if viewport:
			pos = viewport.get_visible_rect().size / 2.0

	particles.position = pos
	particles.color = color
	particles.amount = amount
	particles.emitting = true


func _show_stats_comparison(old_val: float, new_val: float, stat_name: String, color: Color) -> void:
	## Show a brief popup comparing old vs new stats
	# Clear any existing children
	for child in stats_popup.get_children():
		child.queue_free()

	# Create popup panel
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(200, 0)
	stats_popup.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	# Stat name header
	var header := Label.new()
	header.text = stat_name
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(header)

	# Old -> New comparison
	var comparison := HBoxContainer.new()
	comparison.alignment = BoxContainer.ALIGNMENT_CENTER
	comparison.add_theme_constant_override("separation", 12)
	vbox.add_child(comparison)

	var old_label := Label.new()
	old_label.text = _format_stat_value(old_val)
	old_label.add_theme_font_size_override("font_size", 18)
	old_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	comparison.add_child(old_label)

	var arrow := Label.new()
	arrow.text = "->"
	arrow.add_theme_font_size_override("font_size", 18)
	arrow.add_theme_color_override("font_color", color)
	comparison.add_child(arrow)

	var new_label := Label.new()
	new_label.text = _format_stat_value(new_val)
	new_label.add_theme_font_size_override("font_size", 22)
	new_label.add_theme_color_override("font_color", color)
	comparison.add_child(new_label)

	# Percentage increase
	if old_val > 0:
		var increase := ((new_val / old_val) - 1.0) * 100.0
		var increase_label := Label.new()
		increase_label.text = "+%.0f%%" % increase
		increase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		increase_label.add_theme_font_size_override("font_size", 20)
		increase_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		vbox.add_child(increase_label)

	# Show and animate
	stats_popup.visible = true

	# Position at center after layout
	await get_tree().process_frame
	var viewport := get_viewport()
	if viewport:
		var viewport_size := viewport.get_visible_rect().size
		var panel_size := panel.size
		panel.position = Vector2(
			(viewport_size.x - panel_size.x) / 2.0 - stats_popup.global_position.x,
			(viewport_size.y - panel_size.y) / 2.0 - stats_popup.global_position.y - 50  # Slightly above center
		)

	# Animate entrance
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)
	panel.pivot_offset = panel.size / 2.0

	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.15)
	tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.15) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Hold for 0.6s then fade out
	await get_tree().create_timer(0.6).timeout

	var fade_tween := create_tween()
	fade_tween.tween_property(panel, "modulate:a", 0.0, 0.3)
	fade_tween.parallel().tween_property(panel, "position:y", panel.position.y - 30, 0.3)


func _format_stat_value(value: float) -> String:
	## Format a stat value for display
	if value == int(value):
		return "%d" % int(value)
	return "%.1f" % value


func _apply_hitstop(duration: float) -> void:
	## Brief pause effect for impact feel
	# Skip if reduced motion
	if SettingsManager and SettingsManager.reduced_motion:
		return

	Engine.time_scale = 0.1
	await get_tree().create_timer(duration * 0.1).timeout  # Timer runs in scaled time
	Engine.time_scale = 1.0


func _trigger_camera_shake(intensity: float) -> void:
	## Find the game camera and trigger shake
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_node("GameCamera"):
		var camera = player.get_node("GameCamera")
		if camera.has_method("shake"):
			camera.shake(intensity)


func _upgrade_type_to_string(upgrade_type: int) -> String:
	match upgrade_type:
		UpgradeType.TOOL:
			return "tool"
		UpgradeType.BACKPACK:
			return "backpack"
		UpgradeType.WAREHOUSE:
			return "warehouse"
		UpgradeType.EQUIPMENT:
			return "equipment"
		UpgradeType.GADGET:
			return "gadget"
		_:
			return "unknown"


func _cleanup() -> void:
	## Reset state after celebration
	visible = false
	stats_popup.visible = false
	_is_playing = false

	# Clear stats popup children
	for child in stats_popup.get_children():
		child.queue_free()


## Check if celebration is currently playing
func is_playing() -> bool:
	return _is_playing


## Quick celebration for minor upgrades (gadgets, supplies)
## Less dramatic than full celebrate()
func celebrate_minor(screen_pos: Vector2, color: Color = Color.WHITE) -> void:
	if _is_playing:
		return

	_is_playing = true
	visible = true

	# Skip effects if reduced motion
	if SettingsManager and SettingsManager.reduced_motion:
		_is_playing = false
		visible = false
		return

	# Just particles and small flash
	if particles:
		particles.position = screen_pos
		particles.color = color
		particles.amount = 8
		particles.emitting = true

	if flash_rect:
		flash_rect.color = Color(color.r, color.g, color.b, 0.0)
		var tween := create_tween()
		tween.tween_property(flash_rect, "color:a", 0.15, 0.05)
		tween.tween_property(flash_rect, "color:a", 0.0, 0.15)

	await get_tree().create_timer(0.5).timeout
	_cleanup()
