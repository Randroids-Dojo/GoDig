extends Control
## GoDig Main Menu
##
## Entry point of the game. Shows New Game, Continue (if save exists), and Settings.
## Optimized for portrait mobile layout.

signal new_game_started
signal continue_game
signal settings_opened

@onready var new_game_btn: Button = $CenterContainer/VBox/ButtonContainer/NewGameButton
@onready var continue_btn: Button = $CenterContainer/VBox/ButtonContainer/ContinueButton
@onready var settings_btn: Button = $CenterContainer/VBox/ButtonContainer/SettingsButton
@onready var version_label: Label = $VersionLabel

## Game version (loaded from project settings in _setup_version)
var _game_version: String = ""

## Error dialog for save/load failures
var error_dialog: AcceptDialog = null

## Loading indicator
var loading_label: Label = null
var _is_loading: bool = false


func _ready() -> void:
	_setup_version()
	_setup_buttons()
	_setup_error_dialog()
	_setup_loading_indicator()
	_update_continue_visibility()

	# Connect to SaveManager error signals
	if SaveManager:
		SaveManager.load_error.connect(_on_load_error)
		SaveManager.save_error.connect(_on_save_error)

	print("[MainMenu] Ready")

	# FTUE: Auto-start for brand new players (no saves exist)
	# This creates a seamless first experience - no menus, just play
	# On web, we need user interaction first for keyboard focus
	if _should_auto_start_ftue():
		if OS.get_name() == "Web":
			_show_tap_to_start_overlay()
		else:
			_auto_start_new_game()


func _should_auto_start_ftue() -> bool:
	## Check if we should auto-start a new game for FTUE
	## Only auto-starts if: no saves exist AND never played before
	if SaveManager == null:
		return false

	# Check if any save slot has data
	for slot in range(SaveManager.MAX_SLOTS):
		if SaveManager.has_save(slot):
			return false  # Has previous saves, show menu

	# No saves exist - this is a brand new player
	return true


## "Tap to Start" overlay for web builds
## Required because browsers need user interaction before keyboard input works
var _tap_to_start_overlay: ColorRect = null

func _show_tap_to_start_overlay() -> void:
	## Show a "Tap to Start" overlay for web builds
	## This ensures user interaction happens before game starts, granting keyboard focus
	print("[MainMenu] Web build: Showing tap to start overlay")

	# Create fullscreen overlay
	_tap_to_start_overlay = ColorRect.new()
	_tap_to_start_overlay.color = Color(0.1, 0.08, 0.06, 0.95)
	_tap_to_start_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tap_to_start_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_tap_to_start_overlay)

	# Create centered container
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tap_to_start_overlay.add_child(center)

	# Create text container
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "GoDig"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.95, 0.76, 0.34))  # Gold
	vbox.add_child(title)

	# Tap instruction
	var instruction := Label.new()
	instruction.text = "Tap or Click to Start"
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction.add_theme_font_size_override("font_size", 28)
	instruction.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(instruction)

	# Keyboard hint for desktop web
	var hint := Label.new()
	hint.text = "(WASD or Arrow Keys to move)"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	vbox.add_child(hint)

	# Connect input
	_tap_to_start_overlay.gui_input.connect(_on_tap_to_start_input)


func _on_tap_to_start_input(event: InputEvent) -> void:
	## Handle tap/click on the start overlay
	var should_start := false

	# Mouse click
	if event is InputEventMouseButton and event.pressed:
		should_start = true
	# Touch
	elif event is InputEventScreenTouch and event.pressed:
		should_start = true
	# Any key press
	elif event is InputEventKey and event.pressed:
		should_start = true

	if should_start:
		print("[MainMenu] Tap to start received - starting game")
		# Remove overlay
		if _tap_to_start_overlay:
			_tap_to_start_overlay.queue_free()
			_tap_to_start_overlay = null
		# Now start the game (user interaction has granted focus)
		_auto_start_new_game()


func _auto_start_new_game() -> void:
	## Auto-start a new game for brand new players (FTUE flow)
	## Skips the menu entirely for immediate gameplay
	print("[MainMenu] FTUE: Auto-starting new game for brand new player")

	# Brief delay for visual feedback that something is happening
	_show_loading()
	await get_tree().create_timer(0.3).timeout

	# Start new game in slot 0
	if SaveManager.new_game(0):
		_transition_to_game()
	else:
		# If failed, let them use the menu normally
		push_warning("[MainMenu] FTUE auto-start failed, showing menu")
		_is_loading = false
		if loading_label:
			loading_label.visible = false


func _setup_loading_indicator() -> void:
	## Create a loading indicator that shows during scene transitions
	loading_label = Label.new()
	loading_label.name = "LoadingLabel"
	loading_label.text = "Loading..."
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_label.add_theme_font_size_override("font_size", 24)
	loading_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))  # Gold color
	loading_label.set_anchors_preset(Control.PRESET_CENTER)
	loading_label.position = Vector2(-60, 100)  # Below center
	loading_label.visible = false
	add_child(loading_label)


func _show_loading() -> void:
	## Show loading indicator and disable buttons
	_is_loading = true
	if loading_label:
		loading_label.visible = true
	if new_game_btn:
		new_game_btn.disabled = true
	if continue_btn:
		continue_btn.disabled = true
	if settings_btn:
		settings_btn.disabled = true


func _setup_version() -> void:
	# Get version from project settings if available
	_game_version = "v" + ProjectSettings.get_setting("application/config/version", "0.1.0")
	if version_label:
		version_label.text = _game_version


func _setup_buttons() -> void:
	if new_game_btn:
		new_game_btn.pressed.connect(_on_new_game_pressed)
	if continue_btn:
		continue_btn.pressed.connect(_on_continue_pressed)
	if settings_btn:
		settings_btn.pressed.connect(_on_settings_pressed)


func _update_continue_visibility() -> void:
	"""Show continue button only if a save exists in any slot."""
	if continue_btn == null:
		return

	# Check if any save slot has data
	var has_any_save := false
	for slot in range(SaveManager.MAX_SLOTS):
		if SaveManager.has_save(slot):
			has_any_save = true
			break

	continue_btn.visible = has_any_save
	print("[MainMenu] Continue button visible: %s" % has_any_save)


func _on_new_game_pressed() -> void:
	if _is_loading:
		return  # Prevent double-click

	print("[MainMenu] New Game pressed")
	new_game_started.emit()

	# Show loading immediately
	_show_loading()

	# Wait a frame for UI to update before heavy operations
	await get_tree().process_frame

	# Start new game in first available slot
	var slot := _find_empty_or_oldest_slot()
	if SaveManager.new_game(slot):
		_transition_to_game()
	else:
		push_warning("[MainMenu] Failed to start new game")


func _on_continue_pressed() -> void:
	if _is_loading:
		return  # Prevent double-click

	print("[MainMenu] Continue pressed")
	continue_game.emit()

	# Show loading immediately
	_show_loading()

	# Wait a frame for UI to update before heavy operations
	await get_tree().process_frame

	# Load the most recent save
	var slot := _find_most_recent_save()
	if slot >= 0:
		if SaveManager.load_game(slot):
			_transition_to_game()
		# Error handling is done via _on_load_error signal
	else:
		# No save found - this shouldn't happen since button is hidden
		_show_error("No save file found to continue.")


func _on_settings_pressed() -> void:
	print("[MainMenu] Settings pressed")
	settings_opened.emit()
	# TODO: Show settings panel when implemented


func _transition_to_game() -> void:
	"""Transition to the main game scene."""
	var error := get_tree().change_scene_to_file("res://scenes/test_level.tscn")
	if error != OK:
		push_error("[MainMenu] Failed to change scene: %s" % error_string(error))


func _find_empty_or_oldest_slot() -> int:
	"""Find an empty slot, or the oldest save slot if all are full."""
	var oldest_slot := 0
	var oldest_time := 0

	for slot in range(SaveManager.MAX_SLOTS):
		if not SaveManager.has_save(slot):
			return slot  # Found empty slot

		# Track oldest for overwrite
		var info := SaveManager.get_save_info(slot)
		if info and (oldest_time == 0 or info.last_save_time < oldest_time):
			oldest_time = info.last_save_time
			oldest_slot = slot

	# All slots full, return oldest
	return oldest_slot


func _find_most_recent_save() -> int:
	"""Find the most recently saved slot."""
	var newest_slot := -1
	var newest_time := 0

	for slot in range(SaveManager.MAX_SLOTS):
		if SaveManager.has_save(slot):
			var info := SaveManager.get_save_info(slot)
			if info and info.last_save_time > newest_time:
				newest_time = info.last_save_time
				newest_slot = slot

	return newest_slot


func _setup_error_dialog() -> void:
	"""Create an error dialog for displaying save/load failures."""
	error_dialog = AcceptDialog.new()
	error_dialog.title = "Error"
	error_dialog.dialog_autowrap = true
	error_dialog.min_size = Vector2(300, 100)
	add_child(error_dialog)


func _on_load_error(error_message: String, slot: int) -> void:
	"""Handle save load errors by showing a dialog."""
	if error_dialog:
		error_dialog.dialog_text = "Failed to load save:\n%s\n\nThe save file may be corrupted. You can start a new game or try a different save slot." % error_message
		error_dialog.popup_centered()
	push_error("[MainMenu] Load error: %s (slot %d)" % [error_message, slot])


func _on_save_error(error_message: String) -> void:
	"""Handle save errors by showing a dialog."""
	if error_dialog:
		error_dialog.dialog_text = "Failed to save game:\n%s\n\nPlease try again." % error_message
		error_dialog.popup_centered()
	push_error("[MainMenu] Save error: %s" % error_message)


func _show_error(message: String) -> void:
	"""Show a generic error message."""
	if error_dialog:
		error_dialog.dialog_text = message
		error_dialog.popup_centered()
