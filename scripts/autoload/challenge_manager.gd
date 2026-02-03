extends Node
## ChallengeManager autoload singleton for challenge run modifiers.
##
## Manages optional difficulty modifiers that experienced players can enable
## for challenge runs. Inspired by Hades' Pact of Punishment system.
##
## Challenge tiers:
## - Tier 1: Cosmetic rewards (recolors)
## - Tier 2: Special pickaxe skins
## - Tier 3: Rare badges/titles

const ChallengeDataScript = preload("res://resources/challenges/challenge_data.gd")

signal challenge_activated(challenge_id: String)
signal challenge_deactivated(challenge_id: String)
signal challenge_completed(challenge_id: String, reward_id: String)
signal challenge_failed(challenge_id: String, reason: String)
signal all_challenges_cleared
signal run_started(active_challenges: Array[String])
signal run_ended(completed_challenges: Array[String], failed_challenges: Array[String])

## All available challenge definitions
var _challenges: Dictionary = {}  # id -> ChallengeData

## Currently active challenges for this run
var _active_challenges: Array[String] = []

## Challenges completed during current run (pending reward)
var _run_completed: Array[String] = []

## Challenges failed during current run
var _run_failed: Array[String] = []

## Whether a challenge run is currently active
var _run_active: bool = false

## Permanently unlocked rewards (persisted via save)
var _unlocked_rewards: Array[String] = []

## Completed challenges (for tracking, persisted)
var _completed_challenges: Dictionary = {}  # challenge_id -> completion_count

## Run-specific state tracking
var _run_start_time: int = 0
var _run_start_depth: int = 0
var _run_ladders_used: int = 0
var _run_blocks_mined: int = 0
var _run_emergency_rescues: int = 0
var _run_damage_taken: int = 0


func _ready() -> void:
	_init_challenges()
	print("[ChallengeManager] Ready with %d challenges" % _challenges.size())


## Create a challenge instance
func _create_challenge(
	p_id: String,
	p_display_name: String,
	p_description: String,
	p_tier: int = 1,
	p_parameters: Dictionary = {}
) -> ChallengeDataScript:
	var challenge = ChallengeDataScript.new()
	challenge.id = p_id
	challenge.display_name = p_display_name
	challenge.description = p_description
	challenge.tier = p_tier
	challenge.parameters = p_parameters
	challenge.reward_id = "reward_%s" % p_id
	return challenge


## Initialize all challenge definitions
func _init_challenges() -> void:
	# Tier 1 Challenges - Cosmetic rewards (recolors)
	_add_challenge(_create_challenge(
		"scarce_ladders",
		"Scarce Ladders",
		"Start with only 3 ladders instead of 5",
		1,
		{"starting_ladders": 3}
	))

	_add_challenge(_create_challenge(
		"no_wall_jump",
		"No Wall-Jump",
		"Disable wall-jump ability",
		1,
		{}
	))

	_add_challenge(_create_challenge(
		"fragile_cargo",
		"Fragile Cargo",
		"Lose 50% more ore on emergency rescue",
		1,
		{"rescue_loss_multiplier": 1.5}
	))

	_add_challenge(_create_challenge(
		"weak_pickaxe",
		"Weak Pickaxe",
		"Mining takes 1 extra hit per block",
		1,
		{"extra_hits": 1}
	))

	# Tier 2 Challenges - Special pickaxe skins
	_add_challenge(_create_challenge(
		"timed_run",
		"Timed Run",
		"Reach 100m depth within 3 minutes",
		2,
		{"target_depth": 100, "time_limit_seconds": 180}
	))

	_add_challenge(_create_challenge(
		"minimalist",
		"Minimalist",
		"Complete a full loop with max 5 ladder purchases",
		2,
		{"max_ladder_purchases": 5}
	))

	_add_challenge(_create_challenge(
		"glass_cannon",
		"Glass Cannon",
		"Emergency rescue triggers on any damage",
		2,
		{}
	))

	_add_challenge(_create_challenge(
		"depth_sprint",
		"Depth Sprint",
		"Reach your personal best depth +50m",
		2,
		{"depth_bonus": 50}
	))

	# Tier 3 Challenges - Rare badges/titles
	_add_challenge(_create_challenge(
		"ironman",
		"Ironman",
		"No emergency rescue allowed - lose all cargo if stuck",
		3,
		{}
	))

	_add_challenge(_create_challenge(
		"pacifist_miner",
		"Pacifist Miner",
		"Cannot break any non-ore blocks",
		3,
		{}
	))

	_add_challenge(_create_challenge(
		"speed_demon",
		"Speed Demon",
		"Complete a full loop in under 90 seconds",
		3,
		{"time_limit_seconds": 90}
	))

	# Set up incompatibilities
	var ironman = _challenges.get("ironman")
	if ironman:
		ironman.incompatible_with.clear()
		ironman.incompatible_with.append("glass_cannon")

	var glass_cannon = _challenges.get("glass_cannon")
	if glass_cannon:
		glass_cannon.incompatible_with.clear()
		glass_cannon.incompatible_with.append("ironman")


func _add_challenge(challenge: ChallengeDataScript) -> void:
	_challenges[challenge.id] = challenge


## Get all available challenges
func get_all_challenges() -> Array:
	return _challenges.values()


## Get challenges by tier
func get_challenges_by_tier(tier: int) -> Array:
	var result := []
	for challenge in _challenges.values():
		if challenge.tier == tier:
			result.append(challenge)
	return result


## Get a specific challenge by ID
func get_challenge(challenge_id: String) -> ChallengeDataScript:
	return _challenges.get(challenge_id)


## Check if a challenge is currently active
func is_challenge_active(challenge_id: String) -> bool:
	return challenge_id in _active_challenges


## Get all currently active challenges
func get_active_challenges() -> Array[String]:
	return _active_challenges.duplicate()


## Get the count of active challenges
func get_active_challenge_count() -> int:
	return _active_challenges.size()


## Check if any challenge run is active
func is_run_active() -> bool:
	return _run_active


# ============================================
# CHALLENGE ACTIVATION (Before Run Starts)
# ============================================

## Toggle a challenge on/off before starting a run
func toggle_challenge(challenge_id: String) -> bool:
	if _run_active:
		push_warning("[ChallengeManager] Cannot toggle challenges during a run")
		return false

	if challenge_id not in _challenges:
		push_warning("[ChallengeManager] Unknown challenge: %s" % challenge_id)
		return false

	if is_challenge_active(challenge_id):
		return deactivate_challenge(challenge_id)
	else:
		return activate_challenge(challenge_id)


## Activate a challenge for the next run
func activate_challenge(challenge_id: String) -> bool:
	if _run_active:
		push_warning("[ChallengeManager] Cannot activate challenges during a run")
		return false

	if challenge_id not in _challenges:
		push_warning("[ChallengeManager] Unknown challenge: %s" % challenge_id)
		return false

	if is_challenge_active(challenge_id):
		return false  # Already active

	var challenge: ChallengeDataScript = _challenges[challenge_id]

	# Check incompatibilities
	for active_id in _active_challenges:
		if not challenge.is_compatible_with(active_id):
			push_warning("[ChallengeManager] %s is incompatible with %s" % [challenge_id, active_id])
			return false

	_active_challenges.append(challenge_id)
	challenge_activated.emit(challenge_id)
	print("[ChallengeManager] Activated challenge: %s" % challenge_id)
	return true


## Deactivate a challenge before starting a run
func deactivate_challenge(challenge_id: String) -> bool:
	if _run_active:
		push_warning("[ChallengeManager] Cannot deactivate challenges during a run")
		return false

	var idx := _active_challenges.find(challenge_id)
	if idx < 0:
		return false  # Not active

	_active_challenges.remove_at(idx)
	challenge_deactivated.emit(challenge_id)
	print("[ChallengeManager] Deactivated challenge: %s" % challenge_id)
	return true


## Clear all active challenges
func clear_all_challenges() -> void:
	if _run_active:
		push_warning("[ChallengeManager] Cannot clear challenges during a run")
		return

	_active_challenges.clear()
	all_challenges_cleared.emit()
	print("[ChallengeManager] Cleared all active challenges")


# ============================================
# RUN MANAGEMENT
# ============================================

## Start a challenge run with currently active challenges
func start_run() -> void:
	if _run_active:
		push_warning("[ChallengeManager] Run already active")
		return

	if _active_challenges.is_empty():
		push_warning("[ChallengeManager] No challenges selected for run")
		return

	_run_active = true
	_run_completed.clear()
	_run_failed.clear()
	_run_start_time = Time.get_ticks_msec()
	_run_start_depth = GameManager.current_depth if GameManager else 0
	_run_ladders_used = 0
	_run_blocks_mined = 0
	_run_emergency_rescues = 0
	_run_damage_taken = 0

	# Apply starting modifiers
	_apply_starting_modifiers()

	run_started.emit(_active_challenges.duplicate())
	print("[ChallengeManager] Challenge run started with: %s" % str(_active_challenges))


## End the current challenge run
func end_run(completed_loop: bool) -> void:
	if not _run_active:
		return

	_run_active = false

	# Evaluate challenge completion
	_evaluate_challenges(completed_loop)

	# Grant rewards for completed challenges
	for challenge_id in _run_completed:
		_grant_reward(challenge_id)

	run_ended.emit(_run_completed.duplicate(), _run_failed.duplicate())
	print("[ChallengeManager] Run ended - Completed: %s, Failed: %s" % [
		str(_run_completed), str(_run_failed)
	])


## Cancel the current challenge run (no rewards)
func cancel_run() -> void:
	if not _run_active:
		return

	_run_active = false

	# All active challenges count as failed
	_run_failed = _active_challenges.duplicate()
	_run_completed.clear()

	run_ended.emit(_run_completed.duplicate(), _run_failed.duplicate())
	print("[ChallengeManager] Challenge run cancelled")


## Apply starting modifiers (like reduced ladder count)
func _apply_starting_modifiers() -> void:
	# Scarce Ladders: Reduce starting ladders
	if is_challenge_active("scarce_ladders"):
		var challenge = get_challenge("scarce_ladders")
		var starting_ladders: int = challenge.parameters.get("starting_ladders", 3)
		# Note: The save_manager new_game sets 5 ladders, we need to remove some
		if InventoryManager:
			var current_ladders := InventoryManager.get_item_count_by_id("ladder")
			var to_remove := maxi(0, current_ladders - starting_ladders)
			if to_remove > 0:
				InventoryManager.remove_item_by_id("ladder", to_remove)
				print("[ChallengeManager] Reduced ladders to %d" % starting_ladders)


## Evaluate which challenges were completed at run end
func _evaluate_challenges(completed_loop: bool) -> void:
	var run_time_ms := Time.get_ticks_msec() - _run_start_time
	var run_time_seconds := run_time_ms / 1000.0
	var current_depth := GameManager.current_depth if GameManager else 0
	var max_depth := GameManager.max_depth_reached if GameManager else 0

	for challenge_id in _active_challenges:
		var challenge = get_challenge(challenge_id)
		if challenge == null:
			continue

		var completed := false
		var failed := false

		match challenge_id:
			"scarce_ladders":
				# Complete if survived the run with limited ladders
				completed = completed_loop
			"no_wall_jump":
				# Complete if finished loop without wall jump
				completed = completed_loop
			"fragile_cargo":
				# Complete if finished loop
				completed = completed_loop
			"weak_pickaxe":
				# Complete if finished loop
				completed = completed_loop
			"timed_run":
				var target_depth: int = challenge.parameters.get("target_depth", 100)
				var time_limit: float = challenge.parameters.get("time_limit_seconds", 180)
				completed = max_depth >= target_depth and run_time_seconds <= time_limit
				failed = run_time_seconds > time_limit
			"minimalist":
				var max_purchases: int = challenge.parameters.get("max_ladder_purchases", 5)
				completed = completed_loop and _run_ladders_used <= max_purchases
				failed = _run_ladders_used > max_purchases
			"glass_cannon":
				completed = completed_loop and _run_damage_taken == 0
				failed = _run_damage_taken > 0
			"depth_sprint":
				var depth_bonus: int = challenge.parameters.get("depth_bonus", 50)
				var target_depth: int = _run_start_depth + depth_bonus
				if PlayerStats:
					# Get personal best before this run
					var personal_best = PlayerStats.get_stat("max_depth_ever", 0)
					target_depth = personal_best + depth_bonus
				completed = max_depth >= target_depth
			"ironman":
				completed = completed_loop and _run_emergency_rescues == 0
				failed = _run_emergency_rescues > 0
			"pacifist_miner":
				# Would need block type tracking - for now, complete if loop done
				completed = completed_loop
			"speed_demon":
				var time_limit: float = challenge.parameters.get("time_limit_seconds", 90)
				completed = completed_loop and run_time_seconds <= time_limit
				failed = run_time_seconds > time_limit

		if completed:
			_run_completed.append(challenge_id)
			challenge_completed.emit(challenge_id, challenge.reward_id)
		elif failed:
			_run_failed.append(challenge_id)
			challenge_failed.emit(challenge_id, "Requirements not met")


## Grant reward for completing a challenge
func _grant_reward(challenge_id: String) -> void:
	var challenge = get_challenge(challenge_id)
	if challenge == null:
		return

	var reward_id: String = challenge.reward_id
	if reward_id.is_empty():
		reward_id = "reward_%s" % challenge_id

	if reward_id not in _unlocked_rewards:
		_unlocked_rewards.append(reward_id)
		print("[ChallengeManager] Unlocked reward: %s" % reward_id)

	# Track completion count
	if challenge_id not in _completed_challenges:
		_completed_challenges[challenge_id] = 0
	_completed_challenges[challenge_id] += 1


# ============================================
# MODIFIER QUERIES (Used by Game Systems)
# ============================================

## Check if wall-jump is disabled
func is_wall_jump_disabled() -> bool:
	return _run_active and is_challenge_active("no_wall_jump")


## Get extra hits required for mining
func get_extra_mining_hits() -> int:
	if not _run_active:
		return 0
	if is_challenge_active("weak_pickaxe"):
		var challenge = get_challenge("weak_pickaxe")
		return challenge.parameters.get("extra_hits", 1)
	return 0


## Get emergency rescue cargo loss multiplier
func get_rescue_loss_multiplier() -> float:
	if not _run_active:
		return 1.0
	if is_challenge_active("fragile_cargo"):
		var challenge = get_challenge("fragile_cargo")
		return challenge.parameters.get("rescue_loss_multiplier", 1.5)
	return 1.0


## Check if emergency rescue is disabled (Ironman mode)
func is_emergency_rescue_disabled() -> bool:
	return _run_active and is_challenge_active("ironman")


## Check if glass cannon mode is active
func is_glass_cannon_active() -> bool:
	return _run_active and is_challenge_active("glass_cannon")


## Get time remaining for timed challenges (returns -1 if no time limit)
func get_time_remaining_seconds() -> float:
	if not _run_active:
		return -1.0

	var time_limit: float = -1.0

	if is_challenge_active("timed_run"):
		var challenge = get_challenge("timed_run")
		time_limit = challenge.parameters.get("time_limit_seconds", 180)
	elif is_challenge_active("speed_demon"):
		var challenge = get_challenge("speed_demon")
		time_limit = challenge.parameters.get("time_limit_seconds", 90)

	if time_limit < 0:
		return -1.0

	var elapsed_ms := Time.get_ticks_msec() - _run_start_time
	var elapsed_seconds := elapsed_ms / 1000.0
	return maxf(0.0, time_limit - elapsed_seconds)


## Get target depth for depth-based challenges
func get_target_depth() -> int:
	if not _run_active:
		return -1

	if is_challenge_active("timed_run"):
		var challenge = get_challenge("timed_run")
		return challenge.parameters.get("target_depth", 100)
	elif is_challenge_active("depth_sprint"):
		var challenge = get_challenge("depth_sprint")
		var bonus: int = challenge.parameters.get("depth_bonus", 50)
		if PlayerStats:
			var personal_best = PlayerStats.get_stat("max_depth_ever", 0)
			return personal_best + bonus
		return GameManager.max_depth_reached + bonus if GameManager else bonus

	return -1


# ============================================
# EVENT TRACKING (Called by Game Systems)
# ============================================

## Track ladder purchase/use
func track_ladder_used() -> void:
	if _run_active:
		_run_ladders_used += 1
		print("[ChallengeManager] Ladder used: %d total" % _run_ladders_used)

		# Check minimalist challenge failure
		if is_challenge_active("minimalist"):
			var challenge = get_challenge("minimalist")
			var max_purchases: int = challenge.parameters.get("max_ladder_purchases", 5)
			if _run_ladders_used > max_purchases:
				challenge_failed.emit("minimalist", "Too many ladders used")


## Track damage taken
func track_damage_taken(amount: int) -> void:
	if _run_active:
		_run_damage_taken += amount
		print("[ChallengeManager] Damage taken: %d (total: %d)" % [amount, _run_damage_taken])

		# Check glass cannon failure
		if is_challenge_active("glass_cannon") and amount > 0:
			challenge_failed.emit("glass_cannon", "Took damage")


## Track emergency rescue used
func track_emergency_rescue() -> void:
	if _run_active:
		_run_emergency_rescues += 1
		print("[ChallengeManager] Emergency rescue used: %d total" % _run_emergency_rescues)

		# Check ironman failure
		if is_challenge_active("ironman"):
			challenge_failed.emit("ironman", "Emergency rescue used")


## Track block mined (for pacifist challenge)
func track_block_mined(is_ore: bool) -> void:
	if _run_active:
		_run_blocks_mined += 1

		# Check pacifist failure
		if is_challenge_active("pacifist_miner") and not is_ore:
			challenge_failed.emit("pacifist_miner", "Non-ore block mined")


# ============================================
# REWARD TRACKING
# ============================================

## Check if a reward is unlocked
func is_reward_unlocked(reward_id: String) -> bool:
	return reward_id in _unlocked_rewards


## Get all unlocked rewards
func get_unlocked_rewards() -> Array[String]:
	return _unlocked_rewards.duplicate()


## Get completion count for a challenge
func get_completion_count(challenge_id: String) -> int:
	return _completed_challenges.get(challenge_id, 0)


## Check if a challenge has ever been completed
func has_completed_challenge(challenge_id: String) -> bool:
	return get_completion_count(challenge_id) > 0


# ============================================
# SAVE/LOAD
# ============================================

## Get save data for persistence
func get_save_data() -> Dictionary:
	return {
		"unlocked_rewards": _unlocked_rewards.duplicate(),
		"completed_challenges": _completed_challenges.duplicate(),
	}


## Load save data
func load_save_data(data: Dictionary) -> void:
	_unlocked_rewards.clear()
	for reward in data.get("unlocked_rewards", []):
		if reward is String:
			_unlocked_rewards.append(reward)

	_completed_challenges.clear()
	var completed = data.get("completed_challenges", {})
	if completed is Dictionary:
		for key in completed:
			if key is String and completed[key] is int:
				_completed_challenges[key] = completed[key]


## Reset (for new game)
func reset() -> void:
	_active_challenges.clear()
	_run_active = false
	_run_completed.clear()
	_run_failed.clear()
	# Note: Don't reset unlocked_rewards or completed_challenges
	# Those persist across runs/new games
