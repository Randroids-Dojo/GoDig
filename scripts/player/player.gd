extends CharacterBody2D
## Player controller with grid-based movement, mining, and wall-jump.
## Uses a state machine: IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING.
## Player is 128x128 (same size as one dirt block).
## Supports tap-to-dig: tap or hold on adjacent blocks to mine them.

signal block_destroyed(grid_pos: Vector2i)
signal depth_changed(depth: int)
signal jump_pressed  # Emitted when player wants to jump (for wall-jump)
signal hp_changed(current_hp: int, max_hp: int)
signal player_died(cause: String)

enum State { IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING }

const BLOCK_SIZE := 128
const MOVE_DURATION := 0.15  # Seconds to move one block

# Wall-jump physics constants
const GRAVITY: float = 980.0
const WALL_SLIDE_SPEED: float = 50.0
const WALL_JUMP_FORCE_X: float = 200.0
const WALL_JUMP_FORCE_Y: float = 450.0
const WALL_JUMP_COOLDOWN: float = 0.2  # Prevent instant re-grab

# Tap-to-dig constants
const TAP_HOLD_THRESHOLD: float = 0.2  # Seconds before continuous mining starts
const TAP_MINE_INTERVAL: float = 0.15  # Time between hits when holding

# Fall damage constants
const FALL_DAMAGE_THRESHOLD: int = 3  # blocks (fall more than this to take damage)
const DAMAGE_PER_BLOCK: float = 10.0
const MAX_FALL_DAMAGE: float = 100.0

# HP constants
const MAX_HP: int = 100
const LOW_HP_THRESHOLD: float = 0.25  # 25% = low health warning

var dirt_grid: Node2D  # Set by test_level.gd
var touch_direction: Vector2i = Vector2i.ZERO  # Direction from touch controls
var wants_jump: bool = false  # Set by touch controls or keyboard

var current_state: State = State.IDLE
var grid_position: Vector2i  # Player's grid cell (1x1 now)
var target_grid_position: Vector2i
var mining_direction: Vector2i
var mining_target: Vector2i
var _move_tween: Tween

# Wall-jump state
var _wall_direction: int = 0  # -1 = wall on left, 1 = wall on right, 0 = no wall
var _wall_jump_timer: float = 0.0  # Cooldown after wall-jump

# Fall tracking state
var _fall_start_y: float = 0.0
var _is_tracking_fall: bool = false

# Tap-to-dig state
var _tap_target_tile: Vector2i = Vector2i(-999, -999)  # Invalid default
var _tap_hold_timer: float = 0.0
var _is_tap_mining: bool = false
var _tap_mine_cooldown: float = 0.0  # Prevent double-hits

# HP state
var current_hp: int = MAX_HP
var is_dead: bool = false
var _damage_flash_timer: float = 0.0
const DAMAGE_FLASH_DURATION: float = 0.1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	grid_position = _world_to_grid(position)
	sprite.animation_finished.connect(_on_animation_finished)
	# Emit initial HP state
	hp_changed.emit(current_hp, MAX_HP)


func _input(event: InputEvent) -> void:
	# Handle tap-to-dig via touch or mouse
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_tap_start(event.position)
		else:
			_on_tap_end()
	elif event is InputEventScreenDrag:
		_on_tap_drag(event.position)
	elif event is InputEventMouseButton:
		# Support mouse for desktop testing
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_on_tap_start(event.position)
			else:
				_on_tap_end()
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Mouse drag while holding button
		_on_tap_drag(event.position)


func _process(delta: float) -> void:
	# Don't process if dead
	if is_dead:
		return

	# Update wall-jump cooldown timer
	if _wall_jump_timer > 0:
		_wall_jump_timer -= delta

	# Update tap-to-dig mining cooldown
	if _tap_mine_cooldown > 0:
		_tap_mine_cooldown -= delta

	# Update damage flash
	if _damage_flash_timer > 0:
		_damage_flash_timer -= delta
		if _damage_flash_timer <= 0:
			modulate = Color.WHITE

	# Handle tap-to-dig hold mining
	_process_tap_mining(delta)

	match current_state:
		State.IDLE:
			_handle_idle_input()
		State.MOVING:
			pass  # Tween handles movement
		State.MINING:
			_handle_mining_input()
		State.FALLING:
			_handle_falling(delta)
		State.WALL_SLIDING:
			_handle_wall_sliding(delta)
		State.WALL_JUMPING:
			_handle_wall_jumping(delta)


func _handle_idle_input() -> void:
	var dir := _get_input_direction()
	if dir != Vector2i.ZERO:
		_try_move_or_mine(dir)


func _handle_mining_input() -> void:
	# Stop mining if player releases the direction key
	var dir := _get_input_direction()
	if dir != mining_direction:
		sprite.stop()
		current_state = State.IDLE


func _get_input_direction() -> Vector2i:
	# Check touch controls first
	if touch_direction != Vector2i.ZERO:
		return touch_direction

	# Fall back to keyboard input
	if Input.is_action_pressed("move_down"):
		return Vector2i(0, 1)
	elif Input.is_action_pressed("move_left"):
		return Vector2i(-1, 0)
	elif Input.is_action_pressed("move_right"):
		return Vector2i(1, 0)
	return Vector2i.ZERO


func _check_jump_input() -> bool:
	# Check touch jump or keyboard
	if wants_jump:
		wants_jump = false  # Consume the input
		return true
	if Input.is_action_just_pressed("jump"):
		return true
	return false


func _try_move_or_mine(direction: Vector2i) -> void:
	var target := grid_position + direction

	# No horizontal bounds - infinite horizontal space!
	# (Vertical bounds are still enforced by surface row)

	# Check if target cell has a block
	if dirt_grid and dirt_grid.has_block(target):
		_start_mining(direction, target)
	else:
		_start_move(target)


func _start_move(target: Vector2i) -> void:
	current_state = State.MOVING
	target_grid_position = target

	if _move_tween:
		_move_tween.kill()

	_move_tween = create_tween()
	_move_tween.tween_property(self, "position", _grid_to_world(target), MOVE_DURATION)
	_move_tween.tween_callback(_on_move_complete)


func _on_move_complete() -> void:
	grid_position = target_grid_position
	_update_depth()

	# Check if there's ground below - if not, start falling
	if _should_fall():
		_start_falling()
	else:
		current_state = State.IDLE


func _start_mining(direction: Vector2i, target_block: Vector2i) -> void:
	current_state = State.MINING
	mining_direction = direction
	mining_target = target_block

	# Flip sprite based on direction
	if direction.x != 0:
		sprite.flip_h = (direction.x < 0)

	sprite.play("swing")


func _on_animation_finished() -> void:
	if current_state != State.MINING:
		return

	if dirt_grid == null:
		current_state = State.IDLE
		return

	var destroyed: bool = dirt_grid.hit_block(mining_target)

	if destroyed:
		block_destroyed.emit(mining_target)
		# Block destroyed, move into the space
		_start_move(mining_target)
	else:
		# Block still has health, continue mining if key still pressed
		var dir := _get_input_direction()
		if dir == mining_direction:
			sprite.play("swing")
		else:
			current_state = State.IDLE


func _update_depth() -> void:
	var depth := grid_position.y - GameManager.SURFACE_ROW
	if depth < 0:
		depth = 0
	depth_changed.emit(depth)


func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * BLOCK_SIZE + GameManager.GRID_OFFSET_X,
		grid_pos.y * BLOCK_SIZE
	)


func _world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int((world_pos.x - GameManager.GRID_OFFSET_X) / BLOCK_SIZE),
		int(world_pos.y / BLOCK_SIZE)
	)


## Called by TouchControls when a direction button is pressed
func set_touch_direction(direction: Vector2i) -> void:
	touch_direction = direction


## Called by TouchControls when all direction buttons are released
func clear_touch_direction() -> void:
	touch_direction = Vector2i.ZERO


## Called by TouchControls when jump button is pressed
func trigger_jump() -> void:
	wants_jump = true


## Called by TouchControls when dig button is pressed
## Starts mining in the current movement direction
var wants_dig: bool = false

func trigger_dig() -> void:
	wants_dig = true
	# If we have a direction, try to mine in that direction
	var dir := _get_input_direction()
	if dir != Vector2i.ZERO and current_state == State.IDLE:
		_try_move_or_mine(dir)


## Called by TouchControls when dig button is released
func stop_dig() -> void:
	wants_dig = false


# ============================================
# FALLING AND WALL-JUMP LOGIC
# ============================================

func _should_fall() -> bool:
	## Returns true if the player should start falling (no block below)
	if dirt_grid == null:
		return false
	var below := grid_position + Vector2i(0, 1)
	return not dirt_grid.has_block(below)


func _start_falling() -> void:
	current_state = State.FALLING
	velocity = Vector2.ZERO
	# Start tracking fall from current position
	if not _is_tracking_fall:
		_is_tracking_fall = true
		_fall_start_y = position.y


func _handle_falling(delta: float) -> void:
	# Apply gravity
	velocity.y += GRAVITY * delta

	# Check for walls on either side for potential wall-slide
	_update_wall_direction()

	# Check if we can grab a wall (pressing toward it and cooldown expired)
	if _wall_direction != 0 and _wall_jump_timer <= 0:
		var input_dir := _get_input_direction()
		# Must be pressing toward the wall to grab it
		if (input_dir.x < 0 and _wall_direction == -1) or (input_dir.x > 0 and _wall_direction == 1):
			_start_wall_slide()
			return

	# Move based on physics velocity
	position.y += velocity.y * delta

	# Check if we landed on a block
	_check_landing()


func _update_wall_direction() -> void:
	## Detect adjacent walls using the grid
	_wall_direction = 0
	if dirt_grid == null:
		return

	# Get current grid position from world position
	var current_grid := _world_to_grid(position)

	# Check left wall (no bounds check - infinite horizontal space)
	var left_pos := current_grid + Vector2i(-1, 0)
	if dirt_grid.has_block(left_pos):
		_wall_direction = -1
		return

	# Check right wall (no bounds check - infinite horizontal space)
	var right_pos := current_grid + Vector2i(1, 0)
	if dirt_grid.has_block(right_pos):
		_wall_direction = 1


func _start_wall_slide() -> void:
	current_state = State.WALL_SLIDING
	velocity.y = 0  # Reset vertical velocity when grabbing wall
	# Reset fall tracking - grabbing wall cancels fall damage
	_is_tracking_fall = false


func _handle_wall_sliding(delta: float) -> void:
	# Slide down slowly
	velocity.y = WALL_SLIDE_SPEED
	position.y += velocity.y * delta

	# Update wall detection
	_update_wall_direction()

	# Check if wall is still there
	if _wall_direction == 0:
		current_state = State.FALLING
		return

	# Check for jump input
	if _check_jump_input():
		_do_wall_jump()
		return

	# Check if still pressing toward wall
	var input_dir := _get_input_direction()
	var pressing_toward_wall := (input_dir.x < 0 and _wall_direction == -1) or \
								(input_dir.x > 0 and _wall_direction == 1)
	if not pressing_toward_wall:
		current_state = State.FALLING
		return

	# Check if we landed on a block
	_check_landing()


func _do_wall_jump() -> void:
	current_state = State.WALL_JUMPING
	_wall_jump_timer = WALL_JUMP_COOLDOWN

	# Jump away from wall
	velocity.x = WALL_JUMP_FORCE_X * (-_wall_direction)  # Jump away from wall
	velocity.y = -WALL_JUMP_FORCE_Y

	# Flip sprite to face jump direction
	sprite.flip_h = (_wall_direction > 0)


func _handle_wall_jumping(delta: float) -> void:
	# Apply gravity
	velocity.y += GRAVITY * delta

	# Move based on physics velocity
	position.x += velocity.x * delta
	position.y += velocity.y * delta

	# No horizontal bounds - infinite horizontal space!

	# Transition to falling after horizontal velocity dies down or we start falling
	if velocity.y > 0:
		current_state = State.FALLING
		_check_wall_grab()
		return

	# Check if we landed on a block
	_check_landing()


func _check_wall_grab() -> void:
	## Check if we can grab a wall during/after wall-jump
	if _wall_jump_timer > 0:
		return  # Still in cooldown

	_update_wall_direction()
	if _wall_direction != 0:
		var input_dir := _get_input_direction()
		if (input_dir.x < 0 and _wall_direction == -1) or (input_dir.x > 0 and _wall_direction == 1):
			_start_wall_slide()


func _check_landing() -> void:
	## Check if player has landed on a block
	if dirt_grid == null:
		return

	# Get current grid position from world position
	var current_grid := _world_to_grid(position)
	var below := current_grid + Vector2i(0, 1)

	# Check if there's a block below us and we're close to being on top of it
	if dirt_grid.has_block(below):
		# Calculate the top of the block below
		var block_top := below.y * BLOCK_SIZE
		# If we're at or past the top of the block, snap and land
		if position.y >= block_top - BLOCK_SIZE:
			_land_on_grid(current_grid)


func _land_on_grid(landing_grid: Vector2i) -> void:
	## Snap player to grid position and return to IDLE state
	# Calculate and apply fall damage before resetting state
	if _is_tracking_fall:
		_is_tracking_fall = false
		var fall_distance_px := position.y - _fall_start_y
		var fall_blocks := int(fall_distance_px / BLOCK_SIZE)
		_apply_fall_damage(fall_blocks)

	# Snap to proper grid position
	grid_position = landing_grid
	position = _grid_to_world(grid_position)
	velocity = Vector2.ZERO
	current_state = State.IDLE
	_update_depth()


func _apply_fall_damage(fall_blocks: int) -> void:
	## Apply fall damage based on the number of blocks fallen
	if fall_blocks <= FALL_DAMAGE_THRESHOLD:
		return

	var excess_blocks := fall_blocks - FALL_DAMAGE_THRESHOLD
	var damage := excess_blocks * DAMAGE_PER_BLOCK

	# Future: Apply modifiers (boots, surface type)
	# damage *= (1.0 - boots_reduction)
	# damage *= surface_hardness_multiplier

	damage = minf(damage, MAX_FALL_DAMAGE)
	take_damage(int(damage), "fall")


# ============================================
# TAP-TO-DIG LOGIC
# ============================================

func _on_tap_start(screen_pos: Vector2) -> void:
	## Called when player taps/clicks on the screen
	var tile_pos := _screen_to_grid(screen_pos)

	# Check if this is a valid diggable target
	if _is_tap_diggable(tile_pos):
		_tap_target_tile = tile_pos
		_tap_hold_timer = 0.0
		_is_tap_mining = true

		# Immediate first hit on tap
		_hit_tap_target()


func _on_tap_end() -> void:
	## Called when player releases tap/click
	_is_tap_mining = false
	_tap_target_tile = Vector2i(-999, -999)
	_tap_hold_timer = 0.0


func _on_tap_drag(screen_pos: Vector2) -> void:
	## Called when player drags while touching
	if not _is_tap_mining:
		return

	var tile_pos := _screen_to_grid(screen_pos)

	# If dragged to a different tile, check if new tile is valid
	if tile_pos != _tap_target_tile:
		if _is_tap_diggable(tile_pos):
			# Switch to new target
			_tap_target_tile = tile_pos
			_tap_hold_timer = 0.0
			_hit_tap_target()
		else:
			# Dragged to invalid position, stop mining
			_on_tap_end()


func _process_tap_mining(delta: float) -> void:
	## Process continuous mining while holding tap
	if not _is_tap_mining:
		return

	if _tap_target_tile == Vector2i(-999, -999):
		return

	# Verify the target is still valid (player might have moved)
	if not _is_tap_diggable(_tap_target_tile):
		_on_tap_end()
		return

	# Accumulate hold time
	_tap_hold_timer += delta

	# After threshold, start continuous mining
	if _tap_hold_timer >= TAP_HOLD_THRESHOLD and _tap_mine_cooldown <= 0:
		_hit_tap_target()
		_tap_mine_cooldown = TAP_MINE_INTERVAL


func _hit_tap_target() -> void:
	## Hit the current tap target tile
	if dirt_grid == null or _tap_target_tile == Vector2i(-999, -999):
		return

	if not dirt_grid.has_block(_tap_target_tile):
		# Block already destroyed, stop mining
		_on_tap_end()
		return

	var destroyed: bool = dirt_grid.hit_block(_tap_target_tile)

	if destroyed:
		block_destroyed.emit(_tap_target_tile)

		# Check if we should move into the space (if it was adjacent and in a movable direction)
		var diff := _tap_target_tile - grid_position
		if current_state == State.IDLE and abs(diff.x) + abs(diff.y) == 1:
			# Adjacent and we can move there
			if diff.y >= 0:  # Down, left, or right (not up)
				_start_move(_tap_target_tile)

		_on_tap_end()


func _is_tap_diggable(tile_pos: Vector2i) -> bool:
	## Check if the tile can be dug via tap
	## Must be adjacent to player and contain a block

	# Must have a dirt grid
	if dirt_grid == null:
		return false

	# Must have a block there
	if not dirt_grid.has_block(tile_pos):
		return false

	# Must be adjacent to player (not diagonal)
	if not _is_adjacent_to_player(tile_pos):
		return false

	# Player must be in a state that allows mining
	if current_state not in [State.IDLE, State.WALL_SLIDING]:
		return false

	return true


func _is_adjacent_to_player(tile_pos: Vector2i) -> bool:
	## Check if tile is adjacent (not diagonal) to player
	var diff := tile_pos - grid_position

	# Must be exactly 1 tile away in one direction (not diagonal)
	if abs(diff.x) + abs(diff.y) != 1:
		return false

	# MVP: Don't allow digging upward
	if diff.y < 0:
		return false

	return true


func _screen_to_grid(screen_pos: Vector2) -> Vector2i:
	## Convert screen coordinates to grid position
	# Get the canvas transform to convert screen to world coordinates
	var canvas_transform := get_viewport().canvas_transform
	var world_pos := canvas_transform.affine_inverse() * screen_pos

	return _world_to_grid(world_pos)


# ============================================
# HP SYSTEM
# ============================================

## Take damage from a source. Returns the actual damage taken.
func take_damage(amount: int, source: String = "unknown") -> int:
	if is_dead:
		return 0
	if amount <= 0:
		return 0

	var actual_damage := mini(amount, current_hp)
	current_hp = maxi(0, current_hp - amount)
	hp_changed.emit(current_hp, MAX_HP)

	# Visual feedback: flash red
	_start_damage_flash()

	print("[Player] Took %d damage from %s (HP: %d/%d)" % [actual_damage, source, current_hp, MAX_HP])

	if current_hp <= 0:
		die(source)

	return actual_damage


## Heal the player. Returns the actual amount healed.
func heal(amount: int) -> int:
	if is_dead:
		return 0
	if amount <= 0:
		return 0

	var old_hp := current_hp
	current_hp = mini(MAX_HP, current_hp + amount)
	var actual_heal := current_hp - old_hp
	hp_changed.emit(current_hp, MAX_HP)

	if actual_heal > 0:
		print("[Player] Healed %d HP (HP: %d/%d)" % [actual_heal, current_hp, MAX_HP])

	return actual_heal


## Fully heal the player
func full_heal() -> void:
	if is_dead:
		return
	current_hp = MAX_HP
	hp_changed.emit(current_hp, MAX_HP)
	print("[Player] Fully healed (HP: %d/%d)" % [current_hp, MAX_HP])


## Kill the player
func die(cause: String = "unknown") -> void:
	if is_dead:
		return

	is_dead = true
	current_hp = 0
	hp_changed.emit(current_hp, MAX_HP)
	player_died.emit(cause)
	print("[Player] Died from: %s" % cause)


## Revive the player with specified HP (defaults to full)
func revive(hp_amount: int = MAX_HP) -> void:
	is_dead = false
	current_hp = clampi(hp_amount, 1, MAX_HP)
	modulate = Color.WHITE
	hp_changed.emit(current_hp, MAX_HP)
	print("[Player] Revived with %d HP" % current_hp)


## Check if player is at low health (below threshold)
func is_low_health() -> bool:
	return float(current_hp) / float(MAX_HP) <= LOW_HP_THRESHOLD


## Get HP as a percentage (0.0 to 1.0)
func get_hp_percent() -> float:
	return float(current_hp) / float(MAX_HP)


## Start the damage flash effect
func _start_damage_flash() -> void:
	modulate = Color.RED
	_damage_flash_timer = DAMAGE_FLASH_DURATION


## Reset HP to full (for new game)
func reset_hp() -> void:
	is_dead = false
	current_hp = MAX_HP
	modulate = Color.WHITE
	hp_changed.emit(current_hp, MAX_HP)


## Get save data for HP
func get_hp_save_data() -> Dictionary:
	return {
		"current_hp": current_hp,
		"is_dead": is_dead,
	}


## Load HP from save data
func load_hp_save_data(data: Dictionary) -> void:
	current_hp = data.get("current_hp", MAX_HP)
	is_dead = data.get("is_dead", false)
	if is_dead:
		current_hp = 0
	current_hp = clampi(current_hp, 0, MAX_HP)
	modulate = Color.WHITE
	hp_changed.emit(current_hp, MAX_HP)
