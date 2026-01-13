extends ColorRect
## A single dirt block that can be mined.
## Managed by DirtGrid via object pooling.

const DIRT_COLOR := Color(0.545, 0.353, 0.169)  # Brown
const BLOCK_SIZE := 128
const MAX_HITS := 4

var grid_position: Vector2i = Vector2i.ZERO
var hits_remaining: int = MAX_HITS


func _init() -> void:
	size = Vector2(BLOCK_SIZE, BLOCK_SIZE)
	color = DIRT_COLOR


func activate(pos: Vector2i) -> void:
	grid_position = pos
	hits_remaining = MAX_HITS
	position = _grid_to_world(pos)
	visible = true
	modulate = Color.WHITE


func deactivate() -> void:
	visible = false


func take_hit() -> bool:
	## Returns true if block was destroyed
	hits_remaining -= 1
	# Visual feedback - darken on hit
	var damage_ratio := (MAX_HITS - hits_remaining) / float(MAX_HITS)
	modulate = Color.WHITE.lerp(Color(0.3, 0.2, 0.1), damage_ratio)
	return hits_remaining <= 0


func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * BLOCK_SIZE + GameManager.GRID_OFFSET_X,
		grid_pos.y * BLOCK_SIZE
	)
