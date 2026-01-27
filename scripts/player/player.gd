extends CharacterBody2D
## Player controller with grid-based movement, mining, and wall-jump.
## Uses a state machine: IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING.
## Player is 128x128 (same size as one dirt block).
## Supports tap-to-dig: tap or hold on adjacent blocks to mine them.

const TileTypesScript = preload("res://scripts/world/tile_types.gd")

signal block_destroyed(grid_pos: Vector2i)
signal depth_changed(depth: int)
signal jump_pressed  # Emitted when player wants to jump (for wall-jump)
signal hp_changed(current_hp: int, max_hp: int)
signal player_died(cause: String)

enum State { IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING, CLIMBING }

const BLOCK_SIZE := 128
const MOVE_DURATION := 0.15  # Seconds to move one block
const DIG_REACH: int = 1  # Max tiles distance for mining (future tool upgrades can increase)

# Wall-jump physics constants
const GRAVITY: float = 980.0
const WALL_SLIDE_SPEED: float = 50.0
const WALL_JUMP_FORCE_X: float = 200.0
const WALL_JUMP_FORCE_Y: float = 450.0
const WALL_JUMP_COOLDOWN: float = 0.2  # Prevent instant re-grab

# Tap-to-dig constants
const TAP_HOLD_THRESHOLD: float = 0.2  # Seconds before continuous mining starts
const TAP_MINE_INTERVAL_BASE: float = 0.15  # Base time between hits when holding (affected by tool speed)

# Fall damage constants
const FALL_DAMAGE_THRESHOLD: int = 3  # blocks (fall more than this to take damage)
const DAMAGE_PER_BLOCK: float = 10.0
const MAX_FALL_DAMAGE: float = 100.0

# HP constants
const MAX_HP: int = 100
const LOW_HP_THRESHOLD: float = 0.25  # 25% = low health warning

# Surface regeneration constants
const REGEN_INTERVAL: float = 2.0  # Seconds between heals at surface
const REGEN_AMOUNT: int = 5  # HP restored per tick

# Hitstop constants (game feel)
const HITSTOP_MIN_HARDNESS: float = 20.0  # Only apply hitstop for blocks this hard or harder
const HITSTOP_BASE_DURATION: float = 0.02  # Base duration for stone blocks
const HITSTOP_MAX_DURATION: float = 0.05  # Max duration for obsidian/legendary
const HITSTOP_TIME_SCALE: float = 0.1  # Slow-mo instead of full stop

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

# Surface regeneration state
var _regen_timer: float = 0.0

# Squash/stretch animation state
var _scale_tween: Tween

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $GameCamera


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

	# Surface regeneration: heal when at surface and not at full HP
	_process_surface_regen(delta)

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
		State.CLIMBING:
			_handle_climbing(delta)


func _handle_idle_input() -> void:
	var dir := _get_input_direction()
	if dir != Vector2i.ZERO:
		_try_move_or_mine(dir)

	# Handle keyboard dig action (E key) - mine in last/default direction
	if Input.is_action_just_pressed("dig") and dir == Vector2i.ZERO:
		# Default to digging down when no direction is pressed
		_try_move_or_mine(Vector2i.DOWN)


func _handle_mining_input() -> void:
	# Stop mining if player releases the direction key
	var dir := _get_input_direction()
	if dir != mining_direction:
		sprite.stop()
		sprite.speed_scale = 1.0  # Reset animation speed
		current_state = State.IDLE


func _get_input_direction() -> Vector2i:
	# Check touch controls first
	if touch_direction != Vector2i.ZERO:
		return touch_direction

	# Fall back to keyboard input (WASD or arrow keys)
	# Priority: down > left > right > up (up only for climbing)
	if Input.is_action_pressed("move_down"):
		return Vector2i(0, 1)
	elif Input.is_action_pressed("move_left"):
		return Vector2i(-1, 0)
	elif Input.is_action_pressed("move_right"):
		return Vector2i(1, 0)
	elif Input.is_action_pressed("move_up"):
		# Up is only used for climbing ladders
		return Vector2i(0, -1)
	return Vector2i.ZERO


## Check if keyboard input is currently being used (for UI feedback).
func is_using_keyboard() -> bool:
	return touch_direction == Vector2i.ZERO and _get_input_direction() != Vector2i.ZERO


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

	# Validate dig reach before attempting to mine
	if not can_dig_at(target):
		return

	# Check if target cell has a block
	if dirt_grid and dirt_grid.has_block(target):
		_start_mining(direction, target)
	else:
		_start_move(target)


## Check if player can dig at the specified target position.
## Validates: distance (reach), direction restrictions, and player state.
func can_dig_at(target: Vector2i) -> bool:
	# Calculate distance in tiles
	var distance := (target - grid_position).abs()

	# Must be within reach
	if distance.x > DIG_REACH or distance.y > DIG_REACH:
		return false

	# Must not be diagonal (only cardinal directions allowed)
	if distance.x > 0 and distance.y > 0:
		return false

	# Cannot dig upward (unless drill upgrade in future)
	if target.y < grid_position.y and not _has_drill_upgrade():
		return false

	# Cannot dig while falling (safety check)
	if current_state == State.FALLING or current_state == State.WALL_JUMPING:
		return false

	return true


## Check if player has the drill upgrade that allows upward mining.
## Reserved for future implementation (v1.1).
func _has_drill_upgrade() -> bool:
	# Future: Check PlayerData for drill equipment
	# if PlayerData and PlayerData.has_equipment("drill"):
	#     return true
	return false


## Get the current dig reach (affected by tool upgrades in future).
func get_dig_reach() -> int:
	# Future: Check for extended reach tools
	# if PlayerData and PlayerData.has_equipment("extended_pickaxe"):
	#     return 2
	return DIG_REACH


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

	# Track movement stat
	if PlayerStats:
		PlayerStats.track_tile_moved()

	# Check if there's ground below - if not, start falling
	if _should_fall():
		_start_falling()
	else:
		current_state = State.IDLE


func _start_mining(direction: Vector2i, target_block: Vector2i) -> void:
	# Check if player's tool can mine this block
	if dirt_grid and not dirt_grid.can_mine_block(target_block):
		_show_blocked_feedback(target_block)
		return

	current_state = State.MINING
	mining_direction = direction
	mining_target = target_block

	# Flip sprite based on direction
	if direction.x != 0:
		sprite.flip_h = (direction.x < 0)

	# Apply tool speed multiplier to animation speed
	var speed_mult := _get_tool_speed_multiplier()
	sprite.speed_scale = speed_mult
	sprite.play("swing")


func _show_blocked_feedback(target_block: Vector2i) -> void:
	## Visual feedback when player tries to mine ore they can't break
	# Flash block red briefly
	if dirt_grid == null:
		return
	var block = dirt_grid.get_block(target_block)
	if block == null:
		return

	# Store original modulate and flash red
	var original_modulate: Color = block.modulate
	block.modulate = Color.RED

	# Create a timer to restore the color
	var timer := get_tree().create_timer(0.15)
	timer.timeout.connect(func():
		if is_instance_valid(block):
			block.modulate = original_modulate
	)


func _on_animation_finished() -> void:
	if current_state != State.MINING:
		return

	if dirt_grid == null:
		current_state = State.IDLE
		return

	# Get block hardness before hitting (for hitstop calculation)
	var hardness: float = dirt_grid.get_block_hardness(mining_target)

	var destroyed: bool = dirt_grid.hit_block(mining_target)

	# Apply hitstop for game feel (only for hard blocks)
	_apply_hitstop(hardness)

	if destroyed:
		block_destroyed.emit(mining_target)
		sprite.speed_scale = 1.0  # Reset animation speed
		# Track block mining stat
		if PlayerStats:
			PlayerStats.track_block_mined()
		# Haptic feedback for block break
		if HapticFeedback:
			HapticFeedback.on_block_destroyed()
		# Block destroyed, move into the space
		_start_move(mining_target)
	else:
		# Block still has health, continue mining if key still pressed
		var dir := _get_input_direction()
		if dir == mining_direction:
			sprite.play("swing")
		else:
			sprite.speed_scale = 1.0  # Reset animation speed
			current_state = State.IDLE


func _update_depth() -> void:
	var depth := grid_position.y - GameManager.SURFACE_ROW
	if depth < 0:
		depth = 0
	depth_changed.emit(depth)

	# Track depth stat
	if PlayerStats:
		PlayerStats.track_depth(depth)


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
	_start_fall_tracking()


func _start_fall_tracking() -> void:
	## Begin tracking fall distance for damage calculation
	if not _is_tracking_fall:
		_is_tracking_fall = true
		_fall_start_y = position.y


func _handle_falling(delta: float) -> void:
	# Apply gravity
	velocity.y += GRAVITY * delta

	# Check for ladder - can grab while falling
	if _is_on_ladder():
		_check_ladder()
		return

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

	# Check left wall
	var left_pos := current_grid + Vector2i(-1, 0)
	if left_pos.x >= 0 and dirt_grid.has_block(left_pos):
		_wall_direction = -1
		return

	# Check right wall
	var right_pos := current_grid + Vector2i(1, 0)
	if right_pos.x < GameManager.GRID_WIDTH and dirt_grid.has_block(right_pos):
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

	# Track wall jump stat
	if PlayerStats:
		PlayerStats.track_wall_jump()

	# Haptic feedback for wall jump
	if HapticFeedback:
		HapticFeedback.on_wall_jump()

	# Jump away from wall
	velocity.x = WALL_JUMP_FORCE_X * (-_wall_direction)  # Jump away from wall
	velocity.y = -WALL_JUMP_FORCE_Y

	# Flip sprite to face jump direction
	sprite.flip_h = (_wall_direction > 0)

	# Stretch during jump - taller and thinner
	_squash_stretch(
		Vector2(0.8, 1.2),  # Stretch up
		Vector2.ONE,
		0.03, 0.2
	)


func _handle_wall_jumping(delta: float) -> void:
	# Apply gravity
	velocity.y += GRAVITY * delta

	# Move based on physics velocity
	position.x += velocity.x * delta
	position.y += velocity.y * delta

	# Clamp to world bounds
	var min_x := float(GameManager.GRID_OFFSET_X)
	var max_x := float(GameManager.GRID_OFFSET_X + (GameManager.GRID_WIDTH - 1) * BLOCK_SIZE)
	position.x = clamp(position.x, min_x, max_x)

	# Transition to falling after horizontal velocity dies down or we start falling
	if velocity.y > 0:
		current_state = State.FALLING
		_check_wall_grab()
		return

	# Check if we landed on a block
	_check_landing()


# ============================================
# CLIMBING STATE (LADDERS)
# ============================================

func _handle_climbing(delta: float) -> void:
	## Handle movement while on a ladder
	var input_dir := _get_input_direction()

	# Check if still on ladder
	if not _is_on_ladder():
		# Left the ladder - start falling
		current_state = State.FALLING
		_start_fall_tracking()
		return

	# Vertical movement on ladder
	if input_dir.y != 0:
		var target := grid_position + Vector2i(0, input_dir.y)
		# Can only move to empty tiles or other ladders
		if not dirt_grid.has_block(target) or _has_ladder_at(target):
			_start_climb_move(target)
			return

	# Horizontal movement off ladder
	if input_dir.x != 0:
		var target := grid_position + Vector2i(input_dir.x, 0)
		if not dirt_grid.has_block(target):
			_start_move_off_ladder(target)
			return

	# Jump off ladder
	if wants_jump:
		wants_jump = false
		current_state = State.FALLING
		_start_fall_tracking()
		return


func _start_climb_move(target: Vector2i) -> void:
	## Start moving to target position while climbing
	target_grid_position = target
	current_state = State.MOVING

	var target_pos := _grid_to_world(target)
	if _move_tween:
		_move_tween.kill()
	_move_tween = create_tween()
	_move_tween.tween_property(self, "position", target_pos, MOVE_DURATION)
	_move_tween.tween_callback(_on_climb_move_complete)


func _on_climb_move_complete() -> void:
	## Called when a climbing move completes
	grid_position = target_grid_position
	_update_depth()

	# Return to climbing state if still on ladder
	if _is_on_ladder():
		current_state = State.CLIMBING
	else:
		# Moved off ladder - check if should fall
		if _should_fall():
			current_state = State.FALLING
			_start_fall_tracking()
		else:
			current_state = State.IDLE


func _start_move_off_ladder(target: Vector2i) -> void:
	## Start moving off ladder to an adjacent tile
	target_grid_position = target
	current_state = State.MOVING

	var target_pos := _grid_to_world(target)
	if _move_tween:
		_move_tween.kill()
	_move_tween = create_tween()
	_move_tween.tween_property(self, "position", target_pos, MOVE_DURATION)
	_move_tween.tween_callback(_on_move_complete)


func _is_on_ladder() -> bool:
	## Check if current position has a ladder
	return _has_ladder_at(grid_position)


func _has_ladder_at(pos: Vector2i) -> bool:
	## Check if a position has a ladder placed
	if dirt_grid == null:
		return false
	# Check if tile type is LADDER
	return dirt_grid.get_tile_type(pos) == TileTypesScript.Type.LADDER


func _check_ladder() -> void:
	## Check if player should start climbing (standing on ladder)
	if _is_on_ladder():
		current_state = State.CLIMBING
		velocity = Vector2.ZERO
		_is_tracking_fall = false


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
	var fall_distance_px := 0.0
	if _is_tracking_fall:
		_is_tracking_fall = false
		fall_distance_px = position.y - _fall_start_y
		var fall_blocks := int(fall_distance_px / BLOCK_SIZE)
		_apply_fall_damage(fall_blocks)

	# Squash on landing - intensity scales with fall distance
	var intensity := clampf(fall_distance_px / 500.0, 0.1, 1.0)
	var squash_x := 1.0 + (0.25 * intensity)  # 1.0 to 1.25
	var squash_y := 1.0 - (0.2 * intensity)   # 1.0 to 0.8
	_squash_stretch(
		Vector2(squash_x, squash_y),
		Vector2.ONE,
		0.03 + (0.02 * intensity),
		0.1 + (0.05 * intensity)
	)

	# Screen shake on landing (if fall was significant)
	if camera and fall_distance_px > BLOCK_SIZE * 2:
		var shake_intensity := clampf(fall_distance_px / 200.0, 1.0, 6.0)
		camera.shake(shake_intensity)

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
	var final_damage := int(damage)

	# Track fall stat
	if PlayerStats:
		PlayerStats.track_fall(final_damage)

	take_damage(final_damage, "fall")


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
		# Faster tools have shorter intervals between hits
		_tap_mine_cooldown = TAP_MINE_INTERVAL_BASE / _get_tool_speed_multiplier()


func _hit_tap_target() -> void:
	## Hit the current tap target tile
	if dirt_grid == null or _tap_target_tile == Vector2i(-999, -999):
		return

	if not dirt_grid.has_block(_tap_target_tile):
		# Block already destroyed, stop mining
		_on_tap_end()
		return

	# Check if player's tool can mine this block
	if not dirt_grid.can_mine_block(_tap_target_tile):
		_show_blocked_feedback(_tap_target_tile)
		_on_tap_end()
		return

	# Get block hardness before hitting (for hitstop calculation)
	var hardness: float = dirt_grid.get_block_hardness(_tap_target_tile)

	var destroyed: bool = dirt_grid.hit_block(_tap_target_tile)

	# Apply hitstop for game feel (only for hard blocks)
	_apply_hitstop(hardness)

	if destroyed:
		block_destroyed.emit(_tap_target_tile)
		# Track block mining stat (tap-to-dig path)
		if PlayerStats:
			PlayerStats.track_block_mined()
		# Haptic feedback for block break (tap-to-dig)
		if HapticFeedback:
			HapticFeedback.on_block_destroyed()

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


func _get_tool_speed_multiplier() -> float:
	## Get the speed multiplier from the equipped tool
	if PlayerData == null:
		return 1.0
	return PlayerData.get_tool_speed_multiplier()


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

	# Visual feedback: flash red and screen shake
	_start_damage_flash()
	_shake_camera_on_damage(actual_damage)

	# Haptic feedback for damage
	if HapticFeedback:
		HapticFeedback.on_damage_taken(actual_damage)

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

	# Track death stat with current depth
	var depth := grid_position.y - GameManager.SURFACE_ROW
	if PlayerStats:
		PlayerStats.track_death(cause, depth)

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


## Process surface regeneration (called every frame)
func _process_surface_regen(delta: float) -> void:
	# Only regenerate at surface (depth 0 or above)
	if grid_position.y > GameManager.SURFACE_ROW:
		_regen_timer = 0.0
		return

	# Already at full HP
	if current_hp >= MAX_HP:
		_regen_timer = 0.0
		return

	# Accumulate regen timer
	_regen_timer += delta
	if _regen_timer >= REGEN_INTERVAL:
		_regen_timer -= REGEN_INTERVAL
		heal(REGEN_AMOUNT)


## Get HP as a percentage (0.0 to 1.0)
func get_hp_percent() -> float:
	return float(current_hp) / float(MAX_HP)


## Start the damage flash effect
func _start_damage_flash() -> void:
	modulate = Color.RED
	_damage_flash_timer = DAMAGE_FLASH_DURATION


## Apply brief hitstop for game feel on block hit
## Only triggers for hard blocks (stone or harder, hardness >= 20)
## Duration scales with block hardness for more impactful feedback
func _apply_hitstop(hardness: float = 0.0) -> void:
	# Skip if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		return

	# Only apply hitstop for hard blocks
	if hardness < HITSTOP_MIN_HARDNESS:
		return

	# Calculate duration based on hardness (harder blocks = longer pause)
	# Stone (25) = 20ms, Granite (50) = 30ms, Obsidian (100) = 50ms
	var hardness_ratio := clampf((hardness - HITSTOP_MIN_HARDNESS) / 80.0, 0.0, 1.0)
	var duration := lerpf(HITSTOP_BASE_DURATION, HITSTOP_MAX_DURATION, hardness_ratio)

	# Brief time slowdown for impact feel
	Engine.time_scale = HITSTOP_TIME_SCALE
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


## Shake camera when taking damage
func _shake_camera_on_damage(damage_amount: int) -> void:
	if camera == null:
		return

	# Scale shake intensity with damage (max around 25 damage)
	var intensity := clampf(float(damage_amount) / 25.0, 0.5, 3.0)
	camera.shake(intensity)


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


# ============================================
# SQUASH/STRETCH ANIMATION
# ============================================

func _squash_stretch(squash_scale: Vector2, stretch_scale: Vector2, squash_duration: float = 0.05, stretch_duration: float = 0.1) -> void:
	## Apply squash then stretch animation to sprite for juicy feel
	if _scale_tween:
		_scale_tween.kill()

	_scale_tween = create_tween()
	# Squash first (e.g., on impact)
	_scale_tween.tween_property(sprite, "scale", squash_scale, squash_duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	# Then stretch/recover
	_scale_tween.tween_property(sprite, "scale", stretch_scale, stretch_duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	# Return to normal
	_scale_tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)


# ============================================
# TESTING HELPERS (for PlayGodot automation)
# ============================================

## Directly hit the block in the specified direction (x, y integers)
## Used for automated testing when animations don't work in headless mode
## Returns false if the block is not mineable with current tool
func test_mine_direction(dir_x: int, dir_y: int) -> bool:
	if dirt_grid == null:
		return false

	var direction := Vector2i(dir_x, dir_y)
	var target := grid_position + direction

	if not dirt_grid.has_block(target):
		return false

	# Check if tool can mine this block
	if not dirt_grid.can_mine_block(target):
		return false

	var destroyed: bool = dirt_grid.hit_block(target)

	if destroyed:
		block_destroyed.emit(target)
		# Move into the space
		_start_move(target)

	return destroyed


## Get current grid position as separate x, y values for JSON serialization
func test_get_grid_x() -> int:
	return grid_position.x


func test_get_grid_y() -> int:
	return grid_position.y


## Force move to a grid position (for testing)
func test_force_move(x: int, y: int) -> void:
	var target := Vector2i(x, y)
	_start_move(target)
