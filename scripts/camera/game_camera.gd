class_name GameCamera
extends Camera2D
## Camera that follows the player vertically with smooth interpolation.
## Horizontal position is locked to center of viewport.

@export var target: Node2D
@export var vertical_offset := -100.0  # Look ahead (negative = show more below player)
@export var smooth_speed := 8.0

var _center_x: float


func _ready() -> void:
	# Lock horizontal position to viewport center
	_center_x = get_viewport_rect().size.x / 2.0
	position.x = _center_x


func _process(delta: float) -> void:
	if target == null:
		return

	# Smooth vertical follow with offset
	var target_y := target.position.y + vertical_offset
	position.y = lerpf(position.y, target_y, smooth_speed * delta)

	# Keep horizontal position locked
	position.x = _center_x
