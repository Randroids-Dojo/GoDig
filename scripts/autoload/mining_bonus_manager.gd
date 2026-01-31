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
	combo_count += 1
	combo_timer = COMBO_TIMEOUT
	combo_active = true

	var multiplier := get_combo_multiplier()
	combo_updated.emit(combo_count, multiplier)


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

	combo_count = 0
	combo_timer = 0.0
	combo_active = false


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
	combo_count = 0
	combo_timer = 0.0
	combo_active = false


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
	combo_count = 0
	combo_timer = 0.0
	combo_active = false
	_consecutive_misses = 0
	_claimed_milestones.clear()
	vein_streak = 0
	vein_ore_type = ""
