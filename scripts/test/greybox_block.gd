extends ColorRect
## Minimal greybox block for core mining test.
## No textures, no ore, no progression - just basic mining feel.

const BLOCK_SIZE := 128

var grid_pos := Vector2i.ZERO
var max_health := 30.0  # Default block health
var current_health := 30.0

## Visual state
var _base_color := Color(0.35, 0.35, 0.35)  # Grey
var _damaged_color := Color(0.25, 0.25, 0.25)  # Darker grey when damaged


func _ready() -> void:
	size = Vector2(BLOCK_SIZE, BLOCK_SIZE)
	color = _base_color


func activate(pos: Vector2i) -> void:
	## Activate this block at the given grid position
	grid_pos = pos
	position = Vector2(pos.x * BLOCK_SIZE, pos.y * BLOCK_SIZE)
	current_health = max_health
	color = _base_color
	visible = true


func deactivate() -> void:
	## Return to pool
	visible = false


func take_hit(damage: float) -> bool:
	## Take damage and return true if destroyed
	current_health -= damage

	if current_health <= 0:
		return true

	# Visual feedback - darken based on damage
	var damage_percent := 1.0 - (current_health / max_health)
	color = _base_color.lerp(_damaged_color, damage_percent)

	# Scale pulse for feedback
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(self, "scale", Vector2.ONE, 0.05)

	return false
