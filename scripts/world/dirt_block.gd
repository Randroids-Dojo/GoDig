extends ColorRect
## A single dirt block that can be mined.
## Managed by DirtGrid via object pooling.
## Supports multiple layer types with different hardness and colors.

const BLOCK_SIZE := 128
const DEFAULT_TOOL_DAMAGE := 5.0  # Base tool damage (tier 1 pickaxe)

var grid_position: Vector2i = Vector2i.ZERO
var max_health: float = 10.0
var current_health: float = 10.0
var base_color: Color = Color.BROWN


func _init() -> void:
	size = Vector2(BLOCK_SIZE, BLOCK_SIZE)


func activate(pos: Vector2i) -> void:
	grid_position = pos
	position = _grid_to_world(pos)
	visible = true

	# Get hardness and color from DataRegistry based on depth
	max_health = DataRegistry.get_block_hardness(pos)
	current_health = max_health
	base_color = DataRegistry.get_block_color(pos)

	# Set initial visual
	color = base_color
	modulate = Color.WHITE


func deactivate() -> void:
	visible = false


func take_hit(tool_damage: float = DEFAULT_TOOL_DAMAGE) -> bool:
	## Hit the block with a tool. Returns true if block was destroyed.
	## tool_damage: damage dealt by the equipped tool
	current_health -= tool_damage

	# Visual feedback - darken based on damage
	var damage_ratio := 1.0 - (current_health / max_health)
	damage_ratio = clamp(damage_ratio, 0.0, 1.0)
	modulate = Color.WHITE.lerp(Color(0.3, 0.3, 0.3), damage_ratio)

	return current_health <= 0


func get_hits_remaining(tool_damage: float = DEFAULT_TOOL_DAMAGE) -> int:
	## Calculate how many more hits needed to break this block
	if current_health <= 0:
		return 0
	return ceili(current_health / tool_damage)


func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * BLOCK_SIZE + GameManager.GRID_OFFSET_X,
		grid_pos.y * BLOCK_SIZE
	)
