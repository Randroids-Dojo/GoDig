extends CanvasLayer
## Pause Menu - Pauses game and shows options.
##
## Provides resume, settings, emergency rescue, reload save, and quit options.
## Auto-pauses when app goes to background.

signal resumed
signal settings_opened
signal rescue_requested
signal reload_requested
signal quit_requested

@export var process_mode_paused: bool = true

@onready var background: ColorRect = $Background
@onready var panel: PanelContainer = $Panel
@onready var resume_btn: Button = $Panel/VBox/ResumeButton
@onready var settings_btn: Button = $Panel/VBox/SettingsButton
@onready var rescue_btn: Button = $Panel/VBox/RescueButton
@onready var reload_btn: Button = $Panel/VBox/ReloadButton
@onready var quit_btn: Button = $Panel/VBox/QuitButton


func _ready() -> void:
	# Set process mode so we can receive input while paused
	if process_mode_paused:
		process_mode = Node.PROCESS_MODE_ALWAYS

	resume_btn.pressed.connect(_on_resume)
	settings_btn.pressed.connect(_on_settings)
	rescue_btn.pressed.connect(_on_rescue)
	reload_btn.pressed.connect(_on_reload)
	quit_btn.pressed.connect(_on_quit)

	visible = false
	print("[PauseMenu] Ready")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			_on_resume()
		else:
			show_menu()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	# Auto-pause when app goes to background (mobile)
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if not visible and GameManager.is_running:
			show_menu()


func show_menu() -> void:
	"""Show the pause menu and pause the game."""
	if visible:
		return

	visible = true
	get_tree().paused = true

	# Update button states
	_update_button_states()

	print("[PauseMenu] Game paused")


func hide_menu() -> void:
	"""Hide the pause menu and resume the game."""
	if not visible:
		return

	visible = false
	get_tree().paused = false

	print("[PauseMenu] Game resumed")


func _update_button_states() -> void:
	"""Update button enabled states based on current game state."""
	# Reload button is disabled if no save exists
	var can_reload: bool = false
	if SaveManager.current_slot >= 0:
		can_reload = SaveManager.has_save(SaveManager.current_slot)
	reload_btn.disabled = not can_reload


func _on_resume() -> void:
	hide_menu()
	resumed.emit()


func _on_settings() -> void:
	# Settings will be handled by parent/main scene
	settings_opened.emit()


func _on_rescue() -> void:
	# Show confirmation before rescuing
	# For now, emit signal directly (confirmation dialog can be added later)
	rescue_requested.emit()
	hide_menu()


func _on_reload() -> void:
	# Show confirmation before reloading
	# For now, emit signal directly (confirmation dialog can be added later)
	reload_requested.emit()


func _on_quit() -> void:
	# Auto-save before quitting
	if SaveManager.current_slot >= 0:
		SaveManager.save_game()

	quit_requested.emit()
	hide_menu()
