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
signal safe_return(cargo_value: int)  # Emitted when player returns to surface with loot
signal close_call(conditions: Array, tier: int)  # Emitted on close-call escape
signal arrived_home(from_depth: int)  # Emitted when player returns to surface from underground

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
var _previous_depth: int = 0  # Track depth for safe return detection
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

# Trip tracking for close-call detection
var _max_depth_this_trip: int = 0  # Tracks deepest point this descent
var _ladders_at_trip_start: int = 0  # Ladders when player left surface
var _trip_started: bool = false  # Whether player has descended below surface

# Heat damage state
var _heat_damage_timer: float = 0.0
var _current_heat_damage: float = 0.0
const HEAT_DAMAGE_INTERVAL: float = 1.0  # Apply heat damage every second
signal heat_damage_warning(damage_per_second: float)

# Squash/stretch animation state
var _scale_tween: Tween

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $GameCamera


func _ready() -> void:
	# Add to player group so other nodes (like HUD) can find us
	add_to_group("player")

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

	# Heat damage: take damage in hot zones
	_process_heat_damage(delta)

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
func _has_drill_upgrade() -> bool:
	if PlayerData and PlayerData.has_drill():
		return true
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

	# Check if this block contains ore before hitting (for Tier 2 juice)
	var is_ore_block := dirt_grid.get_ore_at(mining_target) != ""

	var destroyed: bool = dirt_grid.hit_block(mining_target)

	# Apply hitstop for game feel (two-tier system)
	# Tier 1: Only hard blocks get hitstop
	# Tier 2: Ore discovery gets hitstop regardless of hardness
	_apply_hitstop(hardness, is_ore_block and destroyed)

	# Apply screen shake for mining feedback (two-tier system)
	_shake_camera_on_mining(hardness, destroyed, is_ore_block)

	if destroyed:
		block_destroyed.emit(mining_target)
		sprite.speed_scale = 1.0  # Reset animation speed
		# Track block mining stat
		if PlayerStats:
			PlayerStats.track_block_mined()
		# Track combo for bonus system
		if MiningBonusManager:
			MiningBonusManager.on_block_mined()
		# Haptic feedback for block break
		if HapticFeedback:
			HapticFeedback.on_block_destroyed()

		# Check for first-dig-after-upgrade celebration
		_check_upgrade_celebration()

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

	# Update saved position for instant resume on mobile
	# This ensures player resumes at exact position after app interruption
	if SaveManager:
		SaveManager.set_player_position(grid_position)

	# Track trip data for close-call detection
	_update_trip_tracking(depth)

	# Check for surface arrival: going from underground to surface
	if _previous_depth > 0 and depth == 0:
		# Show warm welcome home visual effect (subtle warmth flash)
		_show_home_arrival_effect(_previous_depth)
		# Emit arrived_home signal for cozy surface effects
		arrived_home.emit(_previous_depth)
		# Check for special celebrations (safe return with loot, close-call)
		_check_safe_return()
		_reset_trip_tracking()  # Reset after return
	_previous_depth = depth


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

	# Play jump sound
	if SoundManager:
		SoundManager.play_jump()

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

	# Play landing sound
	if SoundManager and fall_distance_px > BLOCK_SIZE:
		SoundManager.play_land(intensity)

	# Snap to proper grid position
	grid_position = landing_grid
	position = _grid_to_world(grid_position)
	velocity = Vector2.ZERO
	current_state = State.IDLE
	_update_depth()


func _apply_fall_damage(fall_blocks: int) -> void:
	## Apply fall damage based on the number of blocks fallen
	## Boots can reduce damage and increase the threshold before damage starts

	# Get fall threshold bonus from boots (if equipped)
	var threshold_bonus := 0
	if PlayerData:
		threshold_bonus = PlayerData.get_fall_threshold_bonus()

	var effective_threshold := FALL_DAMAGE_THRESHOLD + threshold_bonus

	if fall_blocks <= effective_threshold:
		return

	var excess_blocks := fall_blocks - effective_threshold
	var damage := float(excess_blocks) * DAMAGE_PER_BLOCK

	# Apply boots damage reduction (if equipped)
	if PlayerData:
		var reduction := PlayerData.get_fall_damage_reduction()
		if reduction > 0:
			damage *= (1.0 - reduction)

	damage = minf(damage, MAX_FALL_DAMAGE)
	var final_damage := int(damage)

	if final_damage <= 0:
		return  # Boots fully absorbed the damage

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

	# Check if this block contains ore before hitting (for Tier 2 juice)
	var is_ore_block := dirt_grid.get_ore_at(_tap_target_tile) != ""

	var destroyed: bool = dirt_grid.hit_block(_tap_target_tile)

	# Apply hitstop for game feel (two-tier system)
	_apply_hitstop(hardness, is_ore_block and destroyed)

	# Apply screen shake for mining feedback (tap-to-dig, two-tier system)
	_shake_camera_on_mining(hardness, destroyed, is_ore_block)

	if destroyed:
		block_destroyed.emit(_tap_target_tile)
		# Track block mining stat (tap-to-dig path)
		if PlayerStats:
			PlayerStats.track_block_mined()
		# Track combo for bonus system (tap-to-dig path)
		if MiningBonusManager:
			MiningBonusManager.on_block_mined()
		# Haptic feedback for block break (tap-to-dig)
		if HapticFeedback:
			HapticFeedback.on_block_destroyed()

		# Check for first-dig-after-upgrade celebration (tap-to-dig path)
		_check_upgrade_celebration()

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


func _check_upgrade_celebration() -> void:
	## Check if this is the first dig after upgrading and trigger celebration
	if PlayerData == null:
		return

	if PlayerData.consume_upgrade_celebration():
		# This is the first block broken after an upgrade - celebrate!
		_play_upgrade_first_dig_celebration()


func _play_upgrade_first_dig_celebration() -> void:
	## Play a micro-celebration for the first dig after upgrading
	## This reinforces the feeling of power from the new tool

	# Extra screen shake for impact
	if camera:
		camera.shake(2.5)

	# Extra squash-stretch for juicy feel
	_squash_stretch(
		Vector2(1.3, 0.7),  # Wide squash
		Vector2(0.85, 1.15),  # Tall stretch
		0.04, 0.12
	)

	# Extra haptic feedback burst (success pattern)
	if HapticFeedback:
		HapticFeedback.trigger(HapticFeedback.HapticType.SUCCESS)

	print("[Player] First dig with new tool - POWER!")


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

	# Play hurt sound
	if SoundManager:
		SoundManager.play_player_hurt()

	# Reset mining combo on damage
	if MiningBonusManager:
		MiningBonusManager.reset_combo()

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

	# Play death sound
	if SoundManager:
		SoundManager.play_player_death()

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


## Process heat damage from hot zones (called every frame)
func _process_heat_damage(delta: float) -> void:
	# Calculate current depth
	var depth := grid_position.y - GameManager.SURFACE_ROW
	if depth <= 0:
		_current_heat_damage = 0.0
		_heat_damage_timer = 0.0
		return

	# Get current layer and its heat damage
	var layer = DataRegistry.get_layer_at_depth(depth)
	if layer == null:
		_current_heat_damage = 0.0
		return

	var heat_damage := layer.get_heat_damage_at(depth)
	if heat_damage <= 0:
		_current_heat_damage = 0.0
		_heat_damage_timer = 0.0
		return

	# Update heat damage warning if it changed significantly
	if absf(heat_damage - _current_heat_damage) > 0.1:
		_current_heat_damage = heat_damage
		heat_damage_warning.emit(_current_heat_damage)

	# Accumulate damage timer
	_heat_damage_timer += delta
	if _heat_damage_timer >= HEAT_DAMAGE_INTERVAL:
		_heat_damage_timer -= HEAT_DAMAGE_INTERVAL
		var damage_amount := int(ceilf(_current_heat_damage))
		if damage_amount > 0:
			take_damage(damage_amount, "heat")
			print("[Player] Heat damage: %d (zone: %.1f/s)" % [damage_amount, _current_heat_damage])


## Check if player is currently in a heat zone
func is_in_heat_zone() -> bool:
	return _current_heat_damage > 0.0


## Get current heat damage per second (for UI display)
func get_current_heat_damage() -> float:
	return _current_heat_damage


## Get HP as a percentage (0.0 to 1.0)
func get_hp_percent() -> float:
	return float(current_hp) / float(MAX_HP)


## Start the damage flash effect
func _start_damage_flash() -> void:
	modulate = Color.RED
	_damage_flash_timer = DAMAGE_FLASH_DURATION


## Apply brief hitstop for game feel on block hit
## Two-tier juice system:
## - Tier 1 (regular mining): Only hard blocks (hardness >= 20) get hitstop
## - Tier 2 (ore discovery): Always get hitstop (0.05s) for celebration feel
## Duration scales with block hardness for more impactful feedback
func _apply_hitstop(hardness: float = 0.0, is_ore_discovery: bool = false) -> void:
	# Skip if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		return

	var duration: float = 0.0

	# Tier 2: Ore discovery always gets hitstop for celebration
	if is_ore_discovery:
		duration = HITSTOP_MAX_DURATION  # 0.05s discovery hitstop
	# Tier 1: Regular mining only hard blocks
	elif hardness >= HITSTOP_MIN_HARDNESS:
		# Calculate duration based on hardness (harder blocks = longer pause)
		# Stone (25) = 20ms, Granite (50) = 30ms, Obsidian (100) = 50ms
		var hardness_ratio := clampf((hardness - HITSTOP_MIN_HARDNESS) / 80.0, 0.0, 1.0)
		duration = lerpf(HITSTOP_BASE_DURATION, HITSTOP_MAX_DURATION, hardness_ratio)
	else:
		return  # No hitstop for soft blocks without ore

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


## Shake camera on mining hit based on block hardness
## Two-tier juice system: subtle for regular mining, reserved shake for discoveries
## Tier 1 (normal mining): NO screen shake for soft blocks, minimal for hard blocks
## Tier 2 (ore discovery): Handled separately via ore_discovered signal
func _shake_camera_on_mining(hardness: float, destroyed: bool, is_ore: bool = false) -> void:
	if camera == null:
		return

	# Skip if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		return

	# TWO-TIER JUICE SYSTEM:
	# Tier 1 - Regular mining feedback (subtle, no fatigue)
	# Reserve intense shake for Tier 2 (discoveries) and Tier 3 (major events)

	var intensity: float = 0.0

	if destroyed:
		# Block break - only shake for medium+ hardness blocks
		if hardness < 20.0:
			# Soft block break (dirt) - NO shake, just particles
			intensity = 0.0
		elif hardness < 50.0:
			# Medium block break (stone) - subtle shake
			intensity = 2.0
		else:
			# Hard block break (granite, obsidian) - noticeable
			intensity = 4.0

		# Ore discovery gets Tier 2 bonus shake
		if is_ore:
			intensity += 2.0
	else:
		# Block hit (not destroyed) - minimal feedback
		if hardness < 50.0:
			# Soft/medium block hit - no shake (particles are enough)
			intensity = 0.0
		else:
			# Hard block hit - subtle feedback for resistance feel
			intensity = 1.5

	if intensity > 0:
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
# CONSUMABLE ITEM USAGE
# ============================================

signal rope_used(ascent_blocks: int)
signal teleport_used
signal grappling_hook_used(start_pos: Vector2, end_pos: Vector2)

## Grappling hook state
var _grappling_hook_active: bool = false
var _grappling_hook_target: Vector2 = Vector2.ZERO
const GRAPPLING_HOOK_RANGE: int = 8  # Maximum range in blocks
const GRAPPLING_HOOK_SPEED: float = 2000.0  # Pixels per second

## Use a rope item to ascend quickly
## Returns true if rope was used successfully
func use_rope() -> bool:
	# Check if we have a rope in inventory
	if not InventoryManager.has_item_by_id("rope"):
		return false

	# Calculate ascent - move up 5 blocks (or to surface, whichever is closer)
	var current_depth := grid_position.y - GameManager.SURFACE_ROW
	var ascent_blocks := mini(5, maxi(0, current_depth))

	if ascent_blocks <= 0:
		return false  # Already at or above surface

	# Find a valid landing spot (first empty space going up)
	var target_y := grid_position.y - ascent_blocks
	var target := Vector2i(grid_position.x, target_y)

	# Check if we can actually move there (no solid block)
	if dirt_grid and dirt_grid.has_block(target):
		# Try to find closest empty space above
		var found_spot := false
		for y in range(grid_position.y - 1, target_y - 1, -1):
			var check_pos := Vector2i(grid_position.x, y)
			if not dirt_grid.has_block(check_pos):
				target = check_pos
				ascent_blocks = grid_position.y - y
				found_spot = true
				break
		if not found_spot:
			return false  # No valid landing spot

	# Consume the rope
	if not InventoryManager.remove_item_by_id("rope", 1):
		return false

	# Teleport player up
	position = GameManager.grid_to_world(target) + Vector2(BLOCK_SIZE / 2.0, BLOCK_SIZE / 2.0)
	grid_position = target
	current_state = State.IDLE
	velocity = Vector2.ZERO

	# Update depth
	var new_depth := grid_position.y - GameManager.SURFACE_ROW
	if new_depth < 0:
		new_depth = 0
	GameManager.update_depth(new_depth)
	depth_changed.emit(new_depth)

	rope_used.emit(ascent_blocks)
	print("[Player] Used rope to ascend %d blocks" % ascent_blocks)
	return true


## Use a teleport scroll to return to surface
## Returns true if scroll was used successfully
func use_teleport_scroll() -> bool:
	# Check if we have a teleport scroll in inventory or gadgets
	var has_scroll := InventoryManager.has_item_by_id("teleport_scroll")
	var has_gadget := PlayerData and PlayerData.get_gadget_count("teleport_scroll") > 0
	if not has_scroll and not has_gadget:
		return false

	# Check if already at surface
	var current_depth := grid_position.y - GameManager.SURFACE_ROW
	if current_depth <= 0:
		return false  # Already at surface

	# Consume the scroll (prefer inventory, then gadget)
	if has_scroll:
		if not InventoryManager.remove_item_by_id("teleport_scroll", 1):
			return false
	elif has_gadget:
		if not PlayerData.use_gadget("teleport_scroll"):
			return false
	else:
		return false

	# Teleport to surface spawn point
	var spawn_y := GameManager.SURFACE_ROW - 1
	var target := Vector2i(grid_position.x, spawn_y)

	position = GameManager.grid_to_world(target) + Vector2(BLOCK_SIZE / 2.0, BLOCK_SIZE / 2.0)
	grid_position = target
	current_state = State.IDLE
	velocity = Vector2.ZERO

	# Update depth to 0 (surface)
	GameManager.update_depth(0)
	depth_changed.emit(0)

	teleport_used.emit()
	print("[Player] Used teleport scroll to return to surface")
	return true


## Use the grappling hook to quickly travel to a target position
## target_direction: Vector2i direction to grapple (e.g., Vector2i(0, -1) for up)
## Returns true if grappling hook was used successfully
func use_grappling_hook(target_direction: Vector2i) -> bool:
	# Check if we have a grappling hook gadget
	if not PlayerData or PlayerData.get_gadget_count("grappling_hook") <= 0:
		return false

	# Can't use while falling or wall jumping
	if current_state in [State.FALLING, State.WALL_JUMPING]:
		return false

	# Normalize direction
	if target_direction == Vector2i.ZERO:
		return false

	# Find furthest valid landing point in direction
	var landing_pos: Vector2i = grid_position
	var found_target := false

	for distance in range(1, GRAPPLING_HOOK_RANGE + 1):
		var check_pos := grid_position + target_direction * distance

		# Check if position is blocked
		if dirt_grid and dirt_grid.has_block(check_pos):
			# Hit a wall - land at previous position
			if distance > 1:
				landing_pos = grid_position + target_direction * (distance - 1)
				found_target = true
			break
		else:
			# Valid empty space
			landing_pos = check_pos
			found_target = true

	if not found_target or landing_pos == grid_position:
		return false

	# Consume the grappling hook use
	if not PlayerData.use_gadget("grappling_hook"):
		return false

	# Calculate world positions for visual effect
	var start_world := position
	var end_world := _grid_to_world(landing_pos)

	# Instantly move player (could be animated in future)
	position = end_world
	grid_position = landing_pos
	current_state = State.IDLE
	velocity = Vector2.ZERO

	# Update depth
	_update_depth()

	# Emit signal for visual effects
	grappling_hook_used.emit(start_world, end_world)

	print("[Player] Used grappling hook to travel to %s" % str(landing_pos))
	return true


## Use grappling hook toward a screen position (for tap-to-grapple)
func use_grappling_hook_to(screen_pos: Vector2) -> bool:
	var target_grid := _screen_to_grid(screen_pos)
	var direction := target_grid - grid_position

	# Normalize to cardinal direction
	if abs(direction.x) > abs(direction.y):
		direction = Vector2i(signi(direction.x), 0)
	else:
		direction = Vector2i(0, signi(direction.y))

	return use_grappling_hook(direction)


# ============================================
# LADDER PLACEMENT
# ============================================

signal ladder_placed(grid_pos: Vector2i)

## Place a ladder at the player's current position
## Called from the HUD quickslot for one-tap ladder placement
## Returns true if ladder was placed successfully
func place_ladder_at_position() -> bool:
	# Can't place while falling or wall jumping (safety)
	if current_state in [State.FALLING, State.WALL_JUMPING]:
		return false

	# Check if we have a ladder in inventory
	if not InventoryManager.has_item_by_id("ladder"):
		return false

	# Check if dirt_grid is available
	if dirt_grid == null:
		return false

	# Check if there's already a ladder at current position
	if dirt_grid.has_ladder(grid_position):
		return false

	# Check if current position has a solid block (can't place ladder inside block)
	if dirt_grid.has_block(grid_position):
		return false

	# Try to place the ladder
	if not dirt_grid.place_ladder(grid_position):
		return false

	# Consume the ladder from inventory
	if not InventoryManager.remove_item_by_id("ladder", 1):
		# Failed to remove ladder - this shouldn't happen, but undo the placement
		dirt_grid.remove_ladder(grid_position)
		return false

	# Play sound effect for placement
	if SoundManager:
		SoundManager.play_item_pickup()

	# Brief visual feedback (subtle squash-stretch)
	_squash_stretch(
		Vector2(1.1, 0.9),
		Vector2.ONE,
		0.02, 0.08
	)

	# Emit signal for other systems to react
	ladder_placed.emit(grid_position)

	print("[Player] Placed ladder at %s" % str(grid_position))
	return true


## Check if player can place a ladder at current position
## Used by HUD to determine if quickslot should be disabled
func can_place_ladder() -> bool:
	# Can't place while falling or wall jumping
	if current_state in [State.FALLING, State.WALL_JUMPING]:
		return false

	# Check if we have a ladder in inventory
	if not InventoryManager.has_item_by_id("ladder"):
		return false

	# Check if dirt_grid is available
	if dirt_grid == null:
		return false

	# Check if there's already a ladder at current position
	if dirt_grid.has_ladder(grid_position):
		return false

	# Check if current position has a solid block
	if dirt_grid.has_block(grid_position):
		return false

	return true


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

	# Get hardness before hitting
	var hardness: float = dirt_grid.get_block_hardness(target)

	var destroyed: bool = dirt_grid.hit_block(target)

	# Apply mining feedback (test helper also gets feedback)
	_shake_camera_on_mining(hardness, destroyed)

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


# ============================================
# SAFE RETURN CELEBRATION
# ============================================

## Value thresholds for celebration tiers
const SAFE_RETURN_MEDIUM_VALUE := 200  # Medium celebration threshold
const SAFE_RETURN_JACKPOT_VALUE := 500  # Jackpot celebration threshold

## Check if player returned to surface with loot and trigger celebration
func _check_safe_return() -> void:
	# Check for close-call conditions first (more specific celebration)
	_check_close_call()

	# Only celebrate safe return if player has items to sell
	var cargo_value := _calculate_cargo_value()
	if cargo_value <= 0:
		return  # Empty inventory, no celebration

	# Determine celebration tier based on cargo value
	var tier: int = 0
	if cargo_value >= SAFE_RETURN_JACKPOT_VALUE:
		tier = 2  # Jackpot
	elif cargo_value >= SAFE_RETURN_MEDIUM_VALUE:
		tier = 1  # Medium

	# Play celebration sound
	if SoundManager:
		SoundManager.play_safe_return(tier)

	# Haptic feedback for safe return
	if HapticFeedback:
		if tier >= 2:
			HapticFeedback.heavy_tap()
		elif tier >= 1:
			HapticFeedback.medium_tap()
		else:
			HapticFeedback.light_tap()

	# Create visual celebration effect
	_show_safe_return_celebration(tier, cargo_value)

	# Emit signal for external listeners
	safe_return.emit(cargo_value)
	print("[Player] Safe return! Cargo value: %d, tier: %d" % [cargo_value, tier])


## Calculate total sell value of items in inventory
func _calculate_cargo_value() -> int:
	if not InventoryManager:
		return 0

	var total: int = 0
	for slot in InventoryManager.slots:
		if slot.is_empty() or slot.item == null:
			continue
		# Only count sellable items (ores and gems)
		if slot.item.category in ["ore", "gem"]:
			total += slot.item.sell_value * slot.quantity
	return total


## Show visual celebration effect for safe return
func _show_safe_return_celebration(tier: int, cargo_value: int) -> void:
	# Brief golden glow around player
	var original_modulate := modulate

	# Scale glow intensity by tier
	var glow_color: Color
	var glow_duration: float
	var toast_text: String

	match tier:
		0:  # Small haul
			glow_color = Color(1.2, 1.15, 1.0)  # Subtle warm
			glow_duration = 0.3
			toast_text = "Safe!"
		1:  # Medium haul
			glow_color = Color(1.3, 1.2, 0.8)  # Warm gold
			glow_duration = 0.5
			toast_text = "Cargo secured!"
		2, _:  # Jackpot
			glow_color = Color(1.5, 1.3, 0.5)  # Bright gold
			glow_duration = 0.7
			toast_text = "JACKPOT HAUL!"

	# Apply glow with tween
	var tween := create_tween()
	tween.tween_property(self, "modulate", glow_color, 0.1)
	tween.tween_property(self, "modulate", original_modulate, glow_duration)

	# Flash screen for jackpot hauls
	if tier >= 2:
		_flash_screen_gold()

	# Spawn floating text toast above player
	_spawn_safe_return_toast(toast_text, tier)


## Flash the screen with a brief golden overlay (for jackpot hauls)
func _flash_screen_gold() -> void:
	# Find or create the UI layer to put the flash on
	var main_node = get_tree().get_first_node_in_group("main")
	if not main_node:
		main_node = get_parent()

	var flash := ColorRect.new()
	flash.name = "SafeReturnFlash"
	flash.color = Color(1.0, 0.9, 0.5, 0.4)  # Golden semi-transparent
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Add to a canvas layer so it appears above everything
	var flash_layer := CanvasLayer.new()
	flash_layer.layer = 80
	flash_layer.add_child(flash)
	main_node.add_child(flash_layer)

	# Quick fade out
	var tween := flash.create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.3)
	tween.tween_callback(flash_layer.queue_free)


## Spawn a floating toast text above the player
func _spawn_safe_return_toast(text: String, tier: int) -> void:
	# Create floating label
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Style based on tier
	match tier:
		0:
			label.add_theme_font_size_override("font_size", 16)
			label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.8))
		1:
			label.add_theme_font_size_override("font_size", 20)
			label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
		2, _:
			label.add_theme_font_size_override("font_size", 26)
			label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))

	# Position above player
	label.position = Vector2(-label.size.x / 2.0, -80)

	add_child(label)

	# Animate: float up and fade
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 40, 1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(0.5)
	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)


# ============================================
# CLOSE-CALL ESCAPE DETECTION
# ============================================

## Close-call thresholds
const CLOSE_CALL_MIN_DEPTH := 30  # Min depth for close-call to count
const CLOSE_CALL_LOW_HP_THRESHOLD := 0.30  # <30% HP is low
const CLOSE_CALL_LOW_LADDERS := 1  # 0-1 ladders is a close-call
const CLOSE_CALL_FULL_INV_LADDERS := 2  # Full inventory with <=2 ladders

## Close-call condition types
enum CloseCallCondition {
	LAST_LADDER,      # Returned with 0-1 ladders from deep
	LOW_HP,           # Returned with <30% HP with loot
	FULL_INVENTORY,   # Full inventory with few ladders
	DEPTH_RECORD,     # Set new depth record and returned
}


## Update trip tracking when depth changes
func _update_trip_tracking(depth: int) -> void:
	# Start trip when player goes below surface
	if depth > 0 and not _trip_started:
		_trip_started = true
		_ladders_at_trip_start = _get_ladder_count()
		_max_depth_this_trip = 0

	# Update max depth for this trip
	if depth > _max_depth_this_trip:
		_max_depth_this_trip = depth


## Reset trip tracking when returning to surface
func _reset_trip_tracking() -> void:
	_trip_started = false
	_max_depth_this_trip = 0
	_ladders_at_trip_start = 0


## Get current ladder count from inventory
func _get_ladder_count() -> int:
	if not InventoryManager:
		return 0
	return InventoryManager.get_item_count_by_id("ladder")


## Check for close-call conditions and trigger celebration if met
func _check_close_call() -> void:
	# Must have actually gone deep enough
	if _max_depth_this_trip < CLOSE_CALL_MIN_DEPTH:
		return

	var conditions: Array = []
	var ladder_count := _get_ladder_count()
	var hp_percent := float(current_hp) / float(MAX_HP)
	var has_loot := _calculate_cargo_value() > 0
	var inventory_full := InventoryManager.is_full() if InventoryManager else false

	# 1. Last-Ladder Escape: 0-1 ladders remaining after deep trip
	if ladder_count <= CLOSE_CALL_LOW_LADDERS:
		conditions.append(CloseCallCondition.LAST_LADDER)

	# 2. Low-HP Return: <30% HP with loot
	if hp_percent < CLOSE_CALL_LOW_HP_THRESHOLD and has_loot:
		conditions.append(CloseCallCondition.LOW_HP)

	# 3. Full-Inventory Clutch: 8/8 slots with few ladders
	if inventory_full and ladder_count <= CLOSE_CALL_FULL_INV_LADDERS:
		conditions.append(CloseCallCondition.FULL_INVENTORY)

	# 4. Depth Record Escape: Broke personal record and returned with loot
	var broke_record := _max_depth_this_trip > GameManager.max_depth_reached
	if broke_record and has_loot:
		conditions.append(CloseCallCondition.DEPTH_RECORD)

	# If no conditions met, no close-call
	if conditions.is_empty():
		return

	# Determine tier based on number of conditions
	# 1 condition = normal close-call, 2+ = hero return
	var tier := 0
	if conditions.size() >= 2:
		tier = 1  # Hero return

	# Trigger close-call celebration
	_show_close_call_celebration(conditions, tier)
	close_call.emit(conditions, tier)

	# Track achievement for first close-call
	if AchievementManager:
		AchievementManager.unlock("narrow_escape")

	print("[Player] Close-call! Conditions: %s, tier: %d" % [
		conditions.map(func(c): return CloseCallCondition.keys()[c]),
		tier
	])


## Show visual celebration for close-call escape
func _show_close_call_celebration(conditions: Array, tier: int) -> void:
	# Build message based on conditions
	var messages: Array[String] = []
	var ladder_count := _get_ladder_count()
	var hp_percent := int(float(current_hp) / float(MAX_HP) * 100)

	for condition in conditions:
		match condition:
			CloseCallCondition.LAST_LADDER:
				messages.append("Made it with %d ladder%s!" % [
					ladder_count,
					"" if ladder_count == 1 else "s"
				])
			CloseCallCondition.LOW_HP:
				messages.append("Barely made it! HP: %d%%" % hp_percent)
			CloseCallCondition.FULL_INVENTORY:
				messages.append("Perfect haul! Not a slot wasted!")
			CloseCallCondition.DEPTH_RECORD:
				messages.append("NEW RECORD: %dm!" % _max_depth_this_trip)

	var title: String
	var text: String
	var glow_color: Color
	var glow_duration: float

	if tier >= 1:
		# Hero return (2+ conditions)
		title = "LEGENDARY ESCAPE!"
		text = title + "\n" + "\n".join(messages)
		glow_color = Color(1.6, 1.4, 0.4)  # Bright gold
		glow_duration = 1.0
	else:
		# Single condition close-call
		title = "CLOSE CALL!"
		text = title + "\n" + messages[0]
		glow_color = Color(1.3, 1.15, 0.6)  # Warm
		glow_duration = 0.6

	# Play celebration sound
	if SoundManager:
		if tier >= 1:
			SoundManager.play_milestone()  # Big sound for hero return
		else:
			SoundManager.play_safe_return(1)  # Medium celebration

	# Haptic feedback
	if HapticFeedback:
		if tier >= 1:
			HapticFeedback.heavy_tap()
		else:
			HapticFeedback.medium_tap()

	# Visual glow around player
	var original_modulate := modulate
	var glow_tween := create_tween()
	glow_tween.tween_property(self, "modulate", glow_color, 0.1)
	glow_tween.tween_property(self, "modulate", original_modulate, glow_duration)

	# Screen flash for hero return
	if tier >= 1:
		_flash_screen_close_call()

	# Spawn particle burst
	_spawn_close_call_particles()

	# Show toast notification
	_spawn_close_call_toast(text, tier)


## Flash the screen for close-call (white flash for relief)
func _flash_screen_close_call() -> void:
	var main_node = get_tree().get_first_node_in_group("main")
	if not main_node:
		main_node = get_parent()

	var flash := ColorRect.new()
	flash.name = "CloseCallFlash"
	flash.color = Color(1.0, 1.0, 0.9, 0.3)  # Bright white/yellow
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var flash_layer := CanvasLayer.new()
	flash_layer.layer = 80
	flash_layer.add_child(flash)
	main_node.add_child(flash_layer)

	var tween := flash.create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.4)
	tween.tween_callback(flash_layer.queue_free)


# ============================================
# HOME ARRIVAL COZY EFFECTS
# ============================================

## Show warm visual effect when arriving home from underground
func _show_home_arrival_effect(from_depth: int) -> void:
	# Subtle warm screen flash (more subtle than celebrations)
	# Intensity scales with depth - deeper trip = more relief
	var alpha := 0.1 + minf(float(from_depth) / 200.0, 0.15)  # 0.1-0.25 range

	var main_node = get_tree().get_first_node_in_group("main")
	if not main_node:
		main_node = get_parent()

	# Warm golden/amber flash representing warmth of home
	var flash := ColorRect.new()
	flash.name = "HomeArrivalFlash"
	flash.color = Color(1.0, 0.95, 0.8, alpha)  # Warm amber
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var flash_layer := CanvasLayer.new()
	flash_layer.layer = 75  # Below close-call flash
	flash_layer.add_child(flash)
	main_node.add_child(flash_layer)

	# Longer, gentler fade than celebration flashes (comfort, not excitement)
	var tween := flash.create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.8)
	tween.tween_callback(flash_layer.queue_free)

	# Spawn subtle dust particles settling (coming home = rest)
	if from_depth >= 20:
		_spawn_home_dust_particles()


## Spawn gentle dust particles settling around player (home arrival atmosphere)
func _spawn_home_dust_particles() -> void:
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 15
	particles.lifetime = 1.5
	particles.explosiveness = 0.3  # Spread out over time (gentle)
	particles.direction = Vector2(0, 1)  # Falling down gently
	particles.spread = 60.0
	particles.gravity = Vector2(0, 30)  # Very gentle settling
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 30.0
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 3.0
	particles.color = Color(1.0, 0.95, 0.85, 0.4)  # Warm dust motes

	# Position above player
	particles.position = Vector2(0, -50)
	add_child(particles)
	particles.finished.connect(particles.queue_free)


## Spawn particle burst for close-call celebration
func _spawn_close_call_particles() -> void:
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 30
	particles.lifetime = 1.0
	particles.explosiveness = 1.0
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 200)
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 250.0
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = Color(1.0, 0.9, 0.3, 1.0)  # Golden

	add_child(particles)
	particles.finished.connect(particles.queue_free)


## Spawn floating toast for close-call
func _spawn_close_call_toast(text: String, tier: int) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Style based on tier
	if tier >= 1:
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	else:
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.4))

	# Position above player
	label.position = Vector2(-100, -100)
	label.custom_minimum_size = Vector2(200, 0)

	add_child(label)

	# Animate: float up and fade
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 60, 2.0)
	tween.tween_property(label, "modulate:a", 0.0, 2.0).set_delay(1.0)
	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)
