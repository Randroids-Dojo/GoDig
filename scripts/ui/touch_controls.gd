extends Control
## Touch controls UI for mobile devices.
## Provides on-screen buttons for directional movement and jump.

signal direction_pressed(direction: Vector2i)
signal direction_released()
signal jump_pressed()

var current_direction: Vector2i = Vector2i.ZERO


func _ready() -> void:
	# Connect button signals
	$LeftButton.button_down.connect(_on_left_pressed)
	$LeftButton.button_up.connect(_on_button_released)
	$RightButton.button_down.connect(_on_right_pressed)
	$RightButton.button_up.connect(_on_button_released)
	$DownButton.button_down.connect(_on_down_pressed)
	$DownButton.button_up.connect(_on_button_released)
	$JumpButton.button_down.connect(_on_jump_pressed)


func _on_left_pressed() -> void:
	current_direction = Vector2i(-1, 0)
	direction_pressed.emit(current_direction)


func _on_right_pressed() -> void:
	current_direction = Vector2i(1, 0)
	direction_pressed.emit(current_direction)


func _on_down_pressed() -> void:
	current_direction = Vector2i(0, 1)
	direction_pressed.emit(current_direction)


func _on_button_released() -> void:
	current_direction = Vector2i.ZERO
	direction_released.emit()


func get_direction() -> Vector2i:
	return current_direction


func _on_jump_pressed() -> void:
	jump_pressed.emit()
