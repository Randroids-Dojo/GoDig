extends CanvasLayer
## Settings Popup - In-game settings panel for accessibility and audio options.
##
## Provides controls for text size, colorblind mode, hand preference,
## haptics, reduced motion, screen shake, and audio volumes.

signal closed

@export var process_mode_paused: bool = true

## UI References (created programmatically)
var background: ColorRect
var panel: PanelContainer
var vbox: VBoxContainer
var close_btn: Button

# Setting controls
var text_size_slider: HSlider
var text_size_label: Label
var colorblind_option: OptionButton
var hand_mode_option: OptionButton
var haptics_check: CheckBox
var reduced_motion_check: CheckBox
var shake_slider: HSlider
var shake_label: Label
var master_slider: HSlider
var sfx_slider: HSlider
var music_slider: HSlider


func _ready() -> void:
	if process_mode_paused:
		process_mode = Node.PROCESS_MODE_ALWAYS

	_build_ui()
	_connect_signals()
	_load_current_settings()

	visible = false
	print("[SettingsPopup] Ready")


func _build_ui() -> void:
	## Build the settings UI programmatically

	# Semi-transparent background
	background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.6)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	# Main panel
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 600)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-200, -300)
	add_child(panel)

	# Main container
	vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	# === ACCESSIBILITY SECTION ===
	var access_title := Label.new()
	access_title.text = "Accessibility"
	access_title.add_theme_font_size_override("font_size", 18)
	access_title.add_theme_color_override("font_color", Color(0.9, 0.9, 0.6))
	vbox.add_child(access_title)

	# Text Size
	var text_row := _create_slider_row("Text Size:", 0, 4, 1)
	text_size_slider = text_row.get_node("Slider")
	text_size_label = text_row.get_node("ValueLabel")
	vbox.add_child(text_row)

	# Colorblind Mode
	var cb_row := _create_option_row("Colorblind:", ["Off", "Symbols", "High Contrast"])
	colorblind_option = cb_row.get_node("Option")
	vbox.add_child(cb_row)

	# Hand Mode
	var hand_row := _create_option_row("Controls:", ["Standard", "Left Hand", "Right Hand"])
	hand_mode_option = hand_row.get_node("Option")
	vbox.add_child(hand_row)

	# Haptics
	haptics_check = CheckBox.new()
	haptics_check.text = "Haptic Feedback"
	vbox.add_child(haptics_check)

	# Reduced Motion
	reduced_motion_check = CheckBox.new()
	reduced_motion_check.text = "Reduced Motion"
	vbox.add_child(reduced_motion_check)

	# Screen Shake
	var shake_row := _create_slider_row("Screen Shake:", 0, 100, 100)
	shake_slider = shake_row.get_node("Slider")
	shake_label = shake_row.get_node("ValueLabel")
	vbox.add_child(shake_row)

	vbox.add_child(HSeparator.new())

	# === AUDIO SECTION ===
	var audio_title := Label.new()
	audio_title.text = "Audio"
	audio_title.add_theme_font_size_override("font_size", 18)
	audio_title.add_theme_color_override("font_color", Color(0.9, 0.9, 0.6))
	vbox.add_child(audio_title)

	# Master Volume
	var master_row := _create_slider_row("Master:", 0, 100, 100)
	master_slider = master_row.get_node("Slider")
	vbox.add_child(master_row)

	# SFX Volume
	var sfx_row := _create_slider_row("SFX:", 0, 100, 100)
	sfx_slider = sfx_row.get_node("Slider")
	vbox.add_child(sfx_row)

	# Music Volume
	var music_row := _create_slider_row("Music:", 0, 100, 100)
	music_slider = music_row.get_node("Slider")
	vbox.add_child(music_row)

	vbox.add_child(HSeparator.new())

	# Close button
	close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(close_btn)


func _create_slider_row(label_text: String, min_val: float, max_val: float, default: float) -> HBoxContainer:
	## Create a row with label, slider, and value display
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(100, 0)
	row.add_child(label)

	var slider := HSlider.new()
	slider.name = "Slider"
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.custom_minimum_size = Vector2(150, 20)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)

	var value_label := Label.new()
	value_label.name = "ValueLabel"
	value_label.text = str(int(default))
	value_label.custom_minimum_size = Vector2(40, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)

	return row


func _create_option_row(label_text: String, options: Array) -> HBoxContainer:
	## Create a row with label and option button
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(100, 0)
	row.add_child(label)

	var option := OptionButton.new()
	option.name = "Option"
	for opt in options:
		option.add_item(opt)
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(option)

	return row


func _connect_signals() -> void:
	## Connect UI signals to handlers
	close_btn.pressed.connect(_on_close)
	background.gui_input.connect(_on_background_input)

	text_size_slider.value_changed.connect(_on_text_size_changed)
	colorblind_option.item_selected.connect(_on_colorblind_changed)
	hand_mode_option.item_selected.connect(_on_hand_mode_changed)
	haptics_check.toggled.connect(_on_haptics_toggled)
	reduced_motion_check.toggled.connect(_on_reduced_motion_toggled)
	shake_slider.value_changed.connect(_on_shake_changed)
	master_slider.value_changed.connect(_on_master_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)


func _load_current_settings() -> void:
	## Load current settings into UI controls
	if SettingsManager == null:
		return

	text_size_slider.value = SettingsManager.text_size_level
	_update_text_size_label()

	colorblind_option.selected = SettingsManager.colorblind_mode
	hand_mode_option.selected = SettingsManager.hand_mode
	haptics_check.button_pressed = SettingsManager.haptics_enabled
	reduced_motion_check.button_pressed = SettingsManager.reduced_motion
	shake_slider.value = SettingsManager.screen_shake_intensity * 100
	_update_shake_label()

	master_slider.value = SettingsManager.master_volume * 100
	sfx_slider.value = SettingsManager.sfx_volume * 100
	music_slider.value = SettingsManager.music_volume * 100


func _update_text_size_label() -> void:
	var scales := SettingsManager.get_text_scale_options()
	var idx := int(text_size_slider.value)
	if idx >= 0 and idx < scales.size():
		text_size_label.text = "%d%%" % int(scales[idx] * 100)


func _update_shake_label() -> void:
	shake_label.text = "%d%%" % int(shake_slider.value)


func show_settings() -> void:
	_load_current_settings()
	visible = true


func hide_settings() -> void:
	visible = false
	SettingsManager.save_now()


func _on_close() -> void:
	hide_settings()
	closed.emit()


func _on_background_input(event: InputEvent) -> void:
	# Close on background click
	if event is InputEventMouseButton and event.pressed:
		_on_close()


# === Setting change handlers ===

func _on_text_size_changed(value: float) -> void:
	SettingsManager.text_size_level = int(value)
	_update_text_size_label()


func _on_colorblind_changed(index: int) -> void:
	SettingsManager.colorblind_mode = index


func _on_hand_mode_changed(index: int) -> void:
	SettingsManager.hand_mode = index


func _on_haptics_toggled(enabled: bool) -> void:
	SettingsManager.haptics_enabled = enabled


func _on_reduced_motion_toggled(enabled: bool) -> void:
	SettingsManager.reduced_motion = enabled


func _on_shake_changed(value: float) -> void:
	SettingsManager.screen_shake_intensity = value / 100.0
	_update_shake_label()


func _on_master_volume_changed(value: float) -> void:
	SettingsManager.master_volume = value / 100.0


func _on_sfx_volume_changed(value: float) -> void:
	SettingsManager.sfx_volume = value / 100.0


func _on_music_volume_changed(value: float) -> void:
	SettingsManager.music_volume = value / 100.0
