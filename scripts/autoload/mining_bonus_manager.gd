extends Node
## MiningBonusManager - Handles mining bonus systems.
##
## Features:
## - Combo mining: Chain blocks for bonus coins
## - Lucky strike: Random critical hits for extra rewards
## - Depth milestone rewards: Bonus coins when reaching new depths

signal combo_updated(combo_count: int, multiplier: float)
signal combo_ended(final_count: int, bonus_coins: int)
signal lucky_strike(ore_id: String, multiplier: float, bonus_coins: int)
signal milestone_reward(depth: int, coins_awarded: int)
signal streak_zone_entered()  # Emitted when streak hits 5+ ("in the zone")
signal streak_zone_exited()   # Emitted when streak drops below 5

# ============================================
# COMBO SYSTEM
# ============================================

## Time window to continue combo (seconds)
const COMBO_TIMEOUT: float = 2.0

## Maximum combo multiplier
const MAX_COMBO_MULTIPLIER: float = 3.0

## Blocks per combo level (every N blocks = +1 combo level)
const BLOCKS_PER_LEVEL: int = 5

## Current combo state
var combo_count: int = 0
var combo_timer: float = 0.0
var combo_active: bool = false

## Streak audio feedback state
## Streak pitch bonus: 0-2 blocks normal, 3 blocks +5%, 4 blocks +10%, 5+ blocks +15%
var _in_streak_zone: bool = false
const STREAK_ZONE_THRESHOLD: int = 5

# ============================================
# LUCKY STRIKE SYSTEM
# ============================================

## Base chance for lucky strike (5%)
const LUCKY_STRIKE_BASE_CHANCE: float = 0.05

## Lucky strike multiplier for coin bonus
const LUCKY_STRIKE_MULTIPLIER: float = 2.0

## Lucky strike ore multiplier (double ore drop)
const LUCKY_STRIKE_ORE_BONUS: int = 1

## Track consecutive misses to implement pity system
var _consecutive_misses: int = 0
const PITY_THRESHOLD: int = 20  # Guaranteed strike after 20 misses

# ============================================
# DEPTH MILESTONE REWARDS
# ============================================

## Milestone depths and their coin rewards
const DEPTH_MILESTONE_REWARDS: Dictionary = {
	25: 50,
	50: 100,
	100: 250,
	150: 400,
	200: 600,
	300: 1000,
	500: 2000,
	750: 3500,
	1000: 5000,
}

## Track which milestones have been claimed (session-based, saved separately)
var _claimed_milestones: Dictionary = {}

# ============================================
# ORE VEIN BONUS
# ============================================

## Bonus for mining multiple ores in a vein without leaving
var vein_streak: int = 0
var vein_ore_type: String = ""
const VEIN_BONUS_THRESHOLD: int = 3
const VEIN_BONUS_MULTIPLIER: float = 1.5


func _ready() -> void:
	# Connect to game events
	if GameManager:
		GameManager.depth_milestone_reached.connect(_on_depth_milestone)
	print("[MiningBonusManager] Ready")


func _process(delta: float) -> void:
	# Update combo timer
	if combo_active:
		combo_timer -= delta
		if combo_timer <= 0:
			_end_combo()


# ============================================
# COMBO SYSTEM METHODS
# ============================================

## Called when a block is mined
func on_block_mined() -> void:
	var prev_count := combo_count
	combo_count += 1
	combo_timer = COMBO_TIMEOUT
	combo_active = true

	var multiplier := get_combo_multiplier()
	combo_updated.emit(combo_count, multiplier)

	# Check for streak zone transitions
	_check_streak_zone_transition(prev_count, combo_count)


## Get current combo multiplier (1.0 to MAX_COMBO_MULTIPLIER)
func get_combo_multiplier() -> float:
	if combo_count <= 0:
		return 1.0

	var level := combo_count / BLOCKS_PER_LEVEL
	var multiplier := 1.0 + (level * 0.2)  # +20% per level
	return minf(multiplier, MAX_COMBO_MULTIPLIER)


## End the current combo and award bonus coins
func _end_combo() -> void:
	if combo_count >= BLOCKS_PER_LEVEL:
		var bonus := _calculate_combo_bonus()
		if bonus > 0 and GameManager:
			GameManager.add_coins(bonus)
			combo_ended.emit(combo_count, bonus)
			print("[MiningBonusManager] Combo ended: %d blocks, +%d coins" % [combo_count, bonus])

	var prev_count := combo_count
	combo_count = 0
	combo_timer = 0.0
	combo_active = false
	_check_streak_zone_transition(prev_count, combo_count)


## Calculate bonus coins for completed combo
func _calculate_combo_bonus() -> int:
	if combo_count < BLOCKS_PER_LEVEL:
		return 0

	# Base bonus: 1 coin per block in combo
	# Multiplied by combo level
	var level := combo_count / BLOCKS_PER_LEVEL
	var bonus := combo_count * level
	return bonus


## Reset combo (called when player takes damage, dies, etc.)
func reset_combo() -> void:
	var prev_count := combo_count
	combo_count = 0
	combo_timer = 0.0
	combo_active = false
	_check_streak_zone_transition(prev_count, combo_count)


## Get the current streak pitch multiplier for audio feedback
## Returns: pitch scale (1.0 to 1.15 based on streak)
## - 1-2 blocks: 1.0 (normal)
## - 3 blocks: 1.05 (+5%)
## - 4 blocks: 1.10 (+10%)
## - 5+ blocks: 1.15 (+15%)
func get_streak_pitch_multiplier() -> float:
	if combo_count <= 2:
		return 1.0
	elif combo_count == 3:
		return 1.05
	elif combo_count == 4:
		return 1.10
	else:
		return 1.15


## Get the particle multiplier for streak visual feedback
## Returns: 1.0 to 1.5 based on streak
func get_streak_particle_multiplier() -> float:
	if combo_count <= 3:
		return 1.0
	elif combo_count == 4:
		return 1.2
	else:
		return 1.4


## Check if player is "in the zone" (5+ streak)
func is_in_streak_zone() -> bool:
	return _in_streak_zone


## Check and handle streak zone transitions
func _check_streak_zone_transition(old_count: int, new_count: int) -> void:
	var was_in_zone := old_count >= STREAK_ZONE_THRESHOLD
	var is_in_zone := new_count >= STREAK_ZONE_THRESHOLD

	if is_in_zone and not was_in_zone:
		_in_streak_zone = true
		streak_zone_entered.emit()
		# Trigger subtle camera pulse for "in the zone" feeling
		_trigger_zone_pulse()
	elif was_in_zone and not is_in_zone:
		_in_streak_zone = false
		streak_zone_exited.emit()


## Trigger a subtle camera pulse when entering streak zone
func _trigger_zone_pulse() -> void:
	# Find the player's camera and apply a very subtle shake
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var camera = player.get_node_or_null("GameCamera")
	if camera and camera.has_method("shake"):
		# Very subtle pulse - just 1.5 pixels of shake for "zone" feeling
		camera.shake(1.5)


# ============================================
# LUCKY STRIKE METHODS
# ============================================

## Check for lucky strike when mining an ore
## Returns the bonus multiplier (1.0 = no bonus, >1.0 = lucky strike)
func check_lucky_strike(ore_id: String) -> float:
	# Calculate effective chance with pity
	var pity_bonus := float(_consecutive_misses) / float(PITY_THRESHOLD) * 0.1
	var effective_chance := LUCKY_STRIKE_BASE_CHANCE + pity_bonus

	# Guaranteed strike at pity threshold
	if _consecutive_misses >= PITY_THRESHOLD:
		_consecutive_misses = 0
		return _trigger_lucky_strike(ore_id)

	# Random check
	if randf() < effective_chance:
		_consecutive_misses = 0
		return _trigger_lucky_strike(ore_id)

	_consecutive_misses += 1
	return 1.0


func _trigger_lucky_strike(ore_id: String) -> float:
	# Calculate bonus coins based on ore value
	var ore_data = DataRegistry.get_ore(ore_id)
	var bonus_coins := 0
	if ore_data:
		bonus_coins = int(ore_data.sell_value * (LUCKY_STRIKE_MULTIPLIER - 1.0))

	lucky_strike.emit(ore_id, LUCKY_STRIKE_MULTIPLIER, bonus_coins)
	print("[MiningBonusManager] Lucky strike on %s! +%d bonus coins" % [ore_id, bonus_coins])

	# Award bonus coins
	if bonus_coins > 0 and GameManager:
		GameManager.add_coins(bonus_coins)

	return LUCKY_STRIKE_MULTIPLIER


## Get the extra ore count from lucky strike
func get_lucky_strike_ore_bonus() -> int:
	return LUCKY_STRIKE_ORE_BONUS


# ============================================
# DEPTH MILESTONE REWARDS
# ============================================

func _on_depth_milestone(depth: int) -> void:
	_check_milestone_reward(depth)


func _check_milestone_reward(depth: int) -> void:
	# Check if this is a reward milestone and hasn't been claimed
	if not DEPTH_MILESTONE_REWARDS.has(depth):
		return

	if _claimed_milestones.get(depth, false):
		return  # Already claimed

	var coins: int = DEPTH_MILESTONE_REWARDS[depth]
	_claimed_milestones[depth] = true

	if GameManager:
		GameManager.add_coins(coins)

	milestone_reward.emit(depth, coins)
	print("[MiningBonusManager] Depth milestone %dm reached! +%d coins" % [depth, coins])


## Manually check for unclaimed milestones (called when loading save)
func check_unclaimed_milestones(current_max_depth: int) -> void:
	for depth in DEPTH_MILESTONE_REWARDS.keys():
		if depth <= current_max_depth and not _claimed_milestones.get(depth, false):
			_check_milestone_reward(depth)


# ============================================
# ORE VEIN BONUS
# ============================================

## Called when an ore is collected
func on_ore_collected(ore_id: String) -> float:
	if ore_id == vein_ore_type:
		vein_streak += 1
	else:
		vein_streak = 1
		vein_ore_type = ore_id

	# Return multiplier if streak threshold reached
	if vein_streak >= VEIN_BONUS_THRESHOLD:
		return VEIN_BONUS_MULTIPLIER

	return 1.0


## Reset vein tracking (called when player returns to surface)
func reset_vein_streak() -> void:
	vein_streak = 0
	vein_ore_type = ""


# ============================================
# SAVE/LOAD
# ============================================

func get_save_data() -> Dictionary:
	return {
		"claimed_milestones": _claimed_milestones.duplicate(),
		"consecutive_misses": _consecutive_misses,
	}


func load_save_data(data: Dictionary) -> void:
	_claimed_milestones = data.get("claimed_milestones", {}).duplicate()
	_consecutive_misses = data.get("consecutive_misses", 0)


func reset() -> void:
	var prev_count := combo_count
	combo_count = 0
	combo_timer = 0.0
	combo_active = false
	_consecutive_misses = 0
	_claimed_milestones.clear()
	vein_streak = 0
	vein_ore_type = ""
	_check_streak_zone_transition(prev_count, combo_count)
