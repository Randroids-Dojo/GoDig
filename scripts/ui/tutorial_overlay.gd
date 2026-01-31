extends CanvasLayer
## Tutorial Overlay - Shows tutorial hints during first playthrough.
##
## Displays step-by-step tutorial prompts that guide new players
## through the basic mechanics: movement, digging, collecting, and selling.

signal tutorial_step_completed(step: int)
signal tutorial_dismissed

## Tutorial step definitions
const TUTORIAL_STEPS := {
	GameManager.TutorialState.MOVEMENT: {
		"title": "Welcome to GoDig!",
		"message": "Tap the joystick to move, or swipe in a direction.\nTap on blocks next to you to dig.",
		"position": "center",
	},
	GameManager.TutorialState.DIGGING: {
		"title": "Digging",
		"message": "Great! Now dig down to find valuable ores.\nHold the joystick down or tap blocks below you.",
		"position": "top",
	},
	GameManager.TutorialState.COLLECTING: {
		"title": "Collecting Ores",
		"message": "You found an ore! Ores are added to your inventory.\nKeep mining to collect more.",
		"position": "center",
	},
	GameManager.TutorialState.SELLING: {
		"title": "Time to Sell",
		"message": "Head back to the surface and enter the shop\nto sell your ores for coins!",
		"position": "top",
	},
	GameManager.TutorialState.COMPLETE: {
		"title": "Tutorial Complete!",
		"message": "You've mastered the basics!\nNow dig deeper, find rare ores,\nand upgrade your equipment!",
		"position": "center",
		"is_final": true,
	},
}

## UI Elements
var background: ColorRect = null
var panel: PanelContainer = null
var title_label: Label = null
var message_label: Label = null
var continue_btn: Button = null
var skip_btn: Button = null

var _current_step: int = -1
var _fade_tween: Tween = null

@export var process_mode_paused: bool = true


func _ready() -> void:
	if process_mode_paused:
		process_mode = Node.PROCESS_MODE_ALWAYS

	_build_ui()
	visible = false

	# Connect to GameManager tutorial signals
	if GameManager:
		GameManager.tutorial_state_changed.connect(_on_tutorial_state_changed)
		GameManager.tutorial_completed.connect(_on_tutorial_completed)

		# Check if we should show the initial tutorial
		if GameManager.is_tutorial_active():
			call_deferred("_check_initial_tutorial")

	# Handle viewport resize to reposition panel
	get_viewport().size_changed.connect(_on_viewport_resized)

	print("[TutorialOverlay] Ready")


func _check_initial_tutorial() -> void:
	## Check if we should show the tutorial on game start
	if GameManager.tutorial_state == GameManager.TutorialState.MOVEMENT:
		# Wait a moment before showing
		await get_tree().create_timer(0.5).timeout
		show_step(GameManager.TutorialState.MOVEMENT)


func _build_ui() -> void:
	## Build the tutorial overlay UI

	# Semi-transparent background (dimmer)
	background = ColorRect.new()
	background.name = "Background"
	background.color = Color(0, 0, 0, 0.5)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.gui_input.connect(_on_background_input)
	add_child(background)

	# Panel container
	panel = PanelContainer.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(320, 180)
	panel.position = Vector2(-160, -90)
	add_child(panel)

	# Margin container
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	panel.add_child(margin)

	# VBox for content
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	# Title label
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color.YELLOW)
	vbox.add_child(title_label)

	# Message label
	message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(message_label)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	# Button container
	var btn_container := HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 20)
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_container)

	# Continue button
	continue_btn = Button.new()
	continue_btn.name = "ContinueButton"
	continue_btn.text = "Got it!"
	continue_btn.custom_minimum_size = Vector2(100, 40)
	continue_btn.pressed.connect(_on_continue_pressed)
	btn_container.add_child(continue_btn)

	# Skip button
	skip_btn = Button.new()
	skip_btn.name = "SkipButton"
	skip_btn.text = "Skip Tutorial"
	skip_btn.custom_minimum_size = Vector2(120, 40)
	skip_btn.pressed.connect(_on_skip_pressed)
	btn_container.add_child(skip_btn)


func show_step(step: int) -> void:
	## Show a specific tutorial step
	if not TUTORIAL_STEPS.has(step):
		return

	_current_step = step
	var step_data: Dictionary = TUTORIAL_STEPS[step]

	title_label.text = step_data["title"]
	message_label.text = step_data["message"]

	# Position panel based on step preference
	_position_panel(step_data.get("position", "center"))

	# Update button text and visibility for final step
	var is_final: bool = step_data.get("is_final", false)
	if is_final:
		continue_btn.text = "Let's Go!"
		skip_btn.visible = false
	else:
		continue_btn.text = "Got it!"
		skip_btn.visible = true

	# Fade in
	visible = true
	background.modulate.a = 0.0
	panel.modulate.a = 0.0

	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(background, "modulate:a", 1.0, 0.3)
	_fade_tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.3)

	print("[TutorialOverlay] Showing step: %d" % step)


func _position_panel(pos: String) -> void:
	## Position the panel on screen, ensuring it stays within viewport bounds
	var viewport_size := get_viewport().get_visible_rect().size
	var panel_width := panel.custom_minimum_size.x
	var panel_height := panel.custom_minimum_size.y

	# Ensure panel isn't wider than viewport (with margins)
	var margin := 20.0
	var max_width := viewport_size.x - (margin * 2)
	if panel_width > max_width:
		panel.custom_minimum_size.x = max_width
		panel_width = max_width

	# Use TOP_LEFT preset for predictable positioning
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)

	# Calculate centered X position
	var center_x := (viewport_size.x - panel_width) / 2.0

	match pos:
		"top":
			panel.position = Vector2(center_x, 80)
		"bottom":
			panel.position = Vector2(center_x, viewport_size.y - panel_height - margin)
		_:  # center
			panel.position = Vector2(center_x, (viewport_size.y - panel_height) / 2.0)


func hide_tutorial() -> void:
	## Hide the tutorial overlay
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(background, "modulate:a", 0.0, 0.2)
	_fade_tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.2)
	_fade_tween.tween_callback(func(): visible = false)


func _on_continue_pressed() -> void:
	## User acknowledged the tutorial step
	hide_tutorial()
	tutorial_step_completed.emit(_current_step)

	# For SELLING step, don't auto-advance - wait for actual sale to happen
	# The shop will trigger advancement when a sale is made
	if _current_step == GameManager.TutorialState.SELLING:
		return

	# For COMPLETE step, tutorial is already done, just dismiss
	if _current_step == GameManager.TutorialState.COMPLETE:
		return

	# Advance to next step in GameManager
	if GameManager:
		var next_step := _current_step + 1
		if next_step <= GameManager.TutorialState.COMPLETE:
			GameManager.advance_tutorial(next_step)


func _on_skip_pressed() -> void:
	## User wants to skip the tutorial entirely
	hide_tutorial()
	tutorial_dismissed.emit()

	if GameManager:
		GameManager.complete_tutorial()


func _on_background_input(event: InputEvent) -> void:
	## Handle background clicks (dismiss on tap)
	if event is InputEventMouseButton and event.pressed:
		_on_continue_pressed()


func _on_tutorial_state_changed(new_state: int) -> void:
	## Show the tutorial step when GameManager changes state
	# Small delay to let game actions complete
	await get_tree().create_timer(0.3).timeout
	show_step(new_state)


func _on_tutorial_completed() -> void:
	## Tutorial is fully complete - show celebration message
	# The COMPLETE step will be shown via _on_tutorial_state_changed
	# This is called after, so we just log it
	print("[TutorialOverlay] Tutorial completed!")


func _on_viewport_resized() -> void:
	## Reposition panel when viewport size changes (e.g., orientation change)
	if visible and _current_step >= 0 and TUTORIAL_STEPS.has(_current_step):
		var step_data: Dictionary = TUTORIAL_STEPS[_current_step]
		_position_panel(step_data.get("position", "center"))
