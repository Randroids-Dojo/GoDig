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

## Game version from project settings
var _game_version: String = "v0.1.0"


func _ready() -> void:
	_setup_version()
	_setup_buttons()
	_update_continue_visibility()
	print("[MainMenu] Ready")


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
	print("[MainMenu] New Game pressed")
	new_game_started.emit()

	# Start new game in first available slot
	var slot := _find_empty_or_oldest_slot()
	if SaveManager.new_game(slot):
		_transition_to_game()
	else:
		push_warning("[MainMenu] Failed to start new game")


func _on_continue_pressed() -> void:
	print("[MainMenu] Continue pressed")
	continue_game.emit()

	# Load the most recent save
	var slot := _find_most_recent_save()
	if slot >= 0:
		if SaveManager.load_game(slot):
			_transition_to_game()
		else:
			push_warning("[MainMenu] Failed to load save from slot %d" % slot)
	else:
		push_warning("[MainMenu] No save found to continue")


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
