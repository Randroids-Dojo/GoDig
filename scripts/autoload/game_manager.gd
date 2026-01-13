extends Node
## GoDig Game Manager
##
## Central game state manager. Currently a placeholder for future game logic.

signal game_started
signal game_over

var is_running: bool = false


func _ready() -> void:
	print("[GameManager] Ready")


func start_game() -> void:
	is_running = true
	game_started.emit()
	print("[GameManager] Game started")


func end_game() -> void:
	is_running = false
	game_over.emit()
	print("[GameManager] Game over")
