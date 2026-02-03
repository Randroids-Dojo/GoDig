extends ColorRect
## A single dirt block that can be mined.
## Managed by DirtGrid via object pooling.
## Supports multiple layer types with different hardness and colors.

const BLOCK_SIZE := 128
const DEFAULT_TOOL_DAMAGE := 5.0  # Base tool damage (tier 1 pickaxe)

# Shake effect constants
const SHAKE_INTENSITY := 4.0  # Max shake offset in pixels
const SHAKE_DURATION := 0.15  # Total shake animation time

# Crack overlay scene for visual damage feedback
const CrackOverlayScene = preload("res://scenes/effects/block_crack_overlay.tscn")

var grid_position: Vector2i = Vector2i.ZERO
var max_health: float = 10.0
var current_health: float = 10.0
var base_color: Color = Color.BROWN
var _base_position: Vector2 = Vector2.ZERO  # Original position for shake effect
var _shake_tween: Tween = null  # Active shake animation
var _crack_overlay: Node2D = null  # Crack overlay visual effect
var _exploration_modulate: Color = Color.WHITE  # Fog of war modulation

## Special block types for handcrafted caves
var is_weak_block: bool = false  # Crumbling/breakable weak blocks for eureka mechanics
var is_secret_wall: bool = false  # Hidden passages that look solid but are breakable


func _init() -> void:
	size = Vector2(BLOCK_SIZE, BLOCK_SIZE)


func activate(pos: Vector2i) -> void:
	grid_position = pos
	_base_position = _grid_to_world(pos)
	position = _base_position
	visible = true

	# Get hardness and color from DataRegistry based on depth
	max_health = DataRegistry.get_block_hardness(pos)
	current_health = max_health
	base_color = DataRegistry.get_block_color(pos)

	# Set initial visual
	color = base_color

	# Apply exploration-based fog modulation
	_update_exploration_modulate()

	# Clean up any previous shake tween
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
		_shake_tween = null

	# Initialize crack overlay (create if needed)
	_init_crack_overlay()


func deactivate() -> void:
	visible = false
	# Clean up shake tween to prevent memory leaks
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
		_shake_tween = null
	# Reset position to base
	position = _base_position
	# Reset crack overlay for reuse
	if _crack_overlay:
		_crack_overlay.reset()
	# Reset special block flags
	is_weak_block = false
	is_secret_wall = false


func take_hit(tool_damage: float = DEFAULT_TOOL_DAMAGE) -> bool:
	## Hit the block with a tool. Returns true if block was destroyed.
	## tool_damage: damage dealt by the equipped tool
	current_health -= tool_damage

	# Visual feedback - darken based on damage
	var damage_ratio := 1.0 - (current_health / max_health)
	damage_ratio = clamp(damage_ratio, 0.0, 1.0)
	modulate = Color.WHITE.lerp(Color(0.3, 0.3, 0.3), damage_ratio)

	# Update crack overlay to show progressive damage
	_update_crack_overlay(damage_ratio)

	# Shake effect for mining feedback
	_play_shake_effect(damage_ratio)

	return current_health <= 0


func _play_shake_effect(damage_ratio: float) -> void:
	## Play a shake animation to provide tactile mining feedback.
	## Intensity scales with damage ratio for progressive visual feedback.

	# Kill any existing shake
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()

	# Calculate shake intensity based on damage (more damage = stronger shake)
	var intensity := SHAKE_INTENSITY * (0.5 + damage_ratio * 0.5)

	# Create shake sequence
	_shake_tween = create_tween()
	_shake_tween.set_ease(Tween.EASE_OUT)
	_shake_tween.set_trans(Tween.TRANS_SINE)

	# Quick shake left-right-center
	var shake_step := SHAKE_DURATION / 3.0
	_shake_tween.tween_property(self, "position", _base_position + Vector2(intensity, 0), shake_step)
	_shake_tween.tween_property(self, "position", _base_position + Vector2(-intensity, 0), shake_step)
	_shake_tween.tween_property(self, "position", _base_position, shake_step)


func get_hits_remaining(tool_damage: float = DEFAULT_TOOL_DAMAGE) -> int:
	## Calculate how many more hits needed to break this block
	if current_health <= 0:
		return 0
	return ceili(current_health / tool_damage)


func apply_ore_hardness(ore_hardness: float) -> void:
	## Add ore hardness bonus to block health. Makes ore blocks harder to mine.
	max_health += ore_hardness
	current_health = max_health


func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * BLOCK_SIZE + GameManager.GRID_OFFSET_X,
		grid_pos.y * BLOCK_SIZE
	)


func _init_crack_overlay() -> void:
	## Initialize or reset the crack overlay for this block.
	## Creates the overlay node on first use, then reuses it.
	if _crack_overlay == null:
		_crack_overlay = CrackOverlayScene.instantiate()
		add_child(_crack_overlay)

	# Reset and configure for current block
	_crack_overlay.reset()
	_crack_overlay.set_crack_color(base_color)


func _update_crack_overlay(damage_ratio: float) -> void:
	## Update the crack overlay based on current damage ratio (0.0 to 1.0).
	if _crack_overlay:
		_crack_overlay.update_damage(damage_ratio)


func _update_exploration_modulate() -> void:
	## Update modulate based on exploration/fog state.
	## Called when block is activated and when exploration changes.
	if ExplorationManager == null:
		modulate = Color.WHITE
		return

	_exploration_modulate = ExplorationManager.get_block_modulate(grid_position)
	modulate = _exploration_modulate


func update_visibility() -> void:
	## Called by DirtGrid when exploration state changes.
	## Updates the fog modulation without resetting damage visual.
	if ExplorationManager == null:
		return

	var new_modulate := ExplorationManager.get_block_modulate(grid_position)
	if new_modulate != _exploration_modulate:
		_exploration_modulate = new_modulate
		# Blend exploration modulate with damage modulate
		var damage_ratio := 1.0 - (current_health / max_health) if max_health > 0 else 0.0
		damage_ratio = clamp(damage_ratio, 0.0, 1.0)
		var damage_color := Color.WHITE.lerp(Color(0.3, 0.3, 0.3), damage_ratio)
		modulate = _exploration_modulate * damage_color
