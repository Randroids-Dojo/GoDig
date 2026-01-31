extends Node2D
## Visual representation of the elevator shaft in the mine.
##
## Creates a vertical shaft visual that extends from surface to deepest elevator stop.
## Shows the elevator platform moving when player uses the elevator.

signal elevator_arrived(depth: int)

const BLOCK_SIZE := 128
const SHAFT_WIDTH := 128
const PLATFORM_HEIGHT := 32

@export var shaft_color: Color = Color(0.2, 0.2, 0.25, 0.9)
@export var rail_color: Color = Color(0.4, 0.4, 0.45)
@export var platform_color: Color = Color(0.5, 0.3, 0.2)
@export var cable_color: Color = Color(0.3, 0.3, 0.3)

var _platform_y: float = 0.0
var _target_y: float = 0.0
var _is_moving: bool = false
var _move_tween: Tween

@onready var shaft_rect: ColorRect = $ShaftBackground
@onready var left_rail: ColorRect = $LeftRail
@onready var right_rail: ColorRect = $RightRail
@onready var platform: ColorRect = $Platform
@onready var cable: Line2D = $Cable


func _ready() -> void:
	_setup_visuals()
	# Connect to PlayerData to update when elevator stops change
	if PlayerData:
		# Update shaft when stops change
		call_deferred("_update_shaft_depth")


func _setup_visuals() -> void:
	# Set colors
	if shaft_rect:
		shaft_rect.color = shaft_color
	if left_rail:
		left_rail.color = rail_color
	if right_rail:
		right_rail.color = rail_color
	if platform:
		platform.color = platform_color
	if cable:
		cable.default_color = cable_color


func _update_shaft_depth() -> void:
	## Update shaft visual to extend to deepest elevator stop
	if not PlayerData:
		return

	var stops := PlayerData.get_elevator_stops()
	var max_depth := 0
	for stop in stops:
		if stop > max_depth:
			max_depth = stop

	# If no stops, use a default depth
	if max_depth == 0:
		max_depth = 100  # Default visual depth

	var shaft_height := (max_depth + 5) * BLOCK_SIZE

	# Update shaft background size
	if shaft_rect:
		shaft_rect.size.y = shaft_height

	# Update rail heights
	if left_rail:
		left_rail.size.y = shaft_height
	if right_rail:
		right_rail.size.y = shaft_height


func move_platform_to(target_depth: int, instant: bool = false) -> void:
	## Move the elevator platform to a specific depth
	_target_y = target_depth * BLOCK_SIZE

	if instant or not is_inside_tree():
		_platform_y = _target_y
		_update_platform_position()
		return

	_is_moving = true

	if _move_tween:
		_move_tween.kill()

	# Calculate travel time based on distance
	var distance := absf(_target_y - _platform_y)
	var travel_time := distance / 500.0  # 500 pixels per second
	travel_time = clampf(travel_time, 0.5, 5.0)

	_move_tween = create_tween()
	_move_tween.tween_property(self, "_platform_y", _target_y, travel_time) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_move_tween.tween_callback(_on_platform_arrived)


func _on_platform_arrived() -> void:
	_is_moving = false
	var depth := int(_platform_y / BLOCK_SIZE)
	elevator_arrived.emit(depth)


func _process(_delta: float) -> void:
	_update_platform_position()


func _update_platform_position() -> void:
	if platform:
		platform.position.y = _platform_y

	if cable:
		# Update cable from top to platform
		cable.clear_points()
		cable.add_point(Vector2(SHAFT_WIDTH / 2, 0))
		cable.add_point(Vector2(SHAFT_WIDTH / 2, _platform_y))


## Get current platform depth
func get_platform_depth() -> int:
	return int(_platform_y / BLOCK_SIZE)


## Check if platform is currently moving
func is_moving() -> bool:
	return _is_moving
