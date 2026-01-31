extends Node
## DailyRewardsManager - Tracks daily login streaks and provides rewards.
##
## Rewards players for consecutive daily logins with escalating bonuses.
## Features a 7-day cycle with a bonus jackpot on day 7.

signal reward_available(day: int, reward: Dictionary)
signal reward_claimed(day: int, reward: Dictionary)
signal streak_reset()
signal streak_milestone(days: int)

## Current consecutive login streak
var current_streak: int = 0

## Last login date (Unix timestamp, rounded to day)
var last_login_day: int = 0

## Whether today's reward has been claimed
var reward_claimed_today: bool = false

## Total rewards claimed lifetime
var total_rewards_claimed: int = 0

## 7-day reward cycle (coins, multiplied by streak for bonus)
const DAILY_REWARDS := [
	{"coins": 50, "description": "Day 1: 50 coins"},
	{"coins": 100, "description": "Day 2: 100 coins"},
	{"coins": 150, "description": "Day 3: 150 coins"},
	{"coins": 200, "description": "Day 4: 200 coins"},
	{"coins": 300, "description": "Day 5: 300 coins"},
	{"coins": 400, "description": "Day 6: 400 coins"},
	{"coins": 1000, "bonus_item": "teleport_scroll", "description": "Day 7: 1000 coins + Teleport Scroll!"},
]

## Streak milestone bonuses (streak_days -> bonus_coins)
const STREAK_MILESTONES := {
	7: 500,    # First week
	14: 1000,  # Two weeks
	30: 2500,  # One month
	60: 5000,  # Two months
	100: 10000 # Century!
}


func _ready() -> void:
	# Defer connection to allow SaveManager to initialize
	call_deferred("_connect_signals")
	call_deferred("_check_daily_login")
	print("[DailyRewardsManager] Ready")


func _connect_signals() -> void:
	# Connect to game state for checking rewards on resume
	if GameManager and GameManager.has_signal("state_changed"):
		GameManager.state_changed.connect(_on_game_state_changed)


func _on_game_state_changed(new_state: int) -> void:
	# Check for new day when returning to game
	if new_state == GameManager.GameState.PLAYING:
		_check_daily_login()


## Check if player logged in on a new day
func _check_daily_login() -> void:
	var today := _get_today_timestamp()

	if last_login_day == 0:
		# First ever login
		last_login_day = today
		current_streak = 1
		reward_claimed_today = false
		_emit_reward_available()
		return

	var days_since_login := (today - last_login_day) / 86400  # 86400 seconds per day

	if days_since_login == 0:
		# Same day, check if reward already claimed
		if not reward_claimed_today:
			_emit_reward_available()
		return

	if days_since_login == 1:
		# Consecutive day! Increase streak
		current_streak += 1
		last_login_day = today
		reward_claimed_today = false
		_emit_reward_available()
		_check_streak_milestone()
	else:
		# Missed a day, reset streak
		var old_streak := current_streak
		current_streak = 1
		last_login_day = today
		reward_claimed_today = false
		if old_streak > 1:
			streak_reset.emit()
			print("[DailyRewardsManager] Streak reset! Was %d days" % old_streak)
		_emit_reward_available()


func _emit_reward_available() -> void:
	var reward := get_todays_reward()
	reward_available.emit(get_streak_day(), reward)
	print("[DailyRewardsManager] Reward available for day %d" % get_streak_day())


func _check_streak_milestone() -> void:
	if STREAK_MILESTONES.has(current_streak):
		streak_milestone.emit(current_streak)
		print("[DailyRewardsManager] Streak milestone: %d days!" % current_streak)


## Get today's date as Unix timestamp (midnight UTC)
func _get_today_timestamp() -> int:
	var unix_time := int(Time.get_unix_time_from_system())
	# Round down to midnight UTC
	return (unix_time / 86400) * 86400


## Get the day in the 7-day cycle (1-7)
func get_streak_day() -> int:
	return ((current_streak - 1) % 7) + 1


## Get today's reward data
func get_todays_reward() -> Dictionary:
	var day_index := get_streak_day() - 1
	var base_reward: Dictionary = DAILY_REWARDS[day_index].duplicate()

	# Apply streak bonus: +10% per week completed
	var weeks_completed := (current_streak - 1) / 7
	var streak_multiplier := 1.0 + (weeks_completed * 0.1)
	base_reward["coins"] = int(base_reward["coins"] * streak_multiplier)
	base_reward["streak"] = current_streak
	base_reward["streak_bonus"] = streak_multiplier

	return base_reward


## Claim today's reward
func claim_reward() -> Dictionary:
	if reward_claimed_today:
		push_warning("[DailyRewardsManager] Reward already claimed today")
		return {}

	var reward := get_todays_reward()
	reward_claimed_today = true
	total_rewards_claimed += 1

	# Give the reward
	if reward.has("coins") and GameManager:
		GameManager.add_coins(reward["coins"])

	if reward.has("bonus_item") and PlayerData:
		# Add bonus item (teleport scroll)
		PlayerData.add_consumable(reward["bonus_item"], 1)

	# Check for streak milestone bonus
	if STREAK_MILESTONES.has(current_streak):
		var milestone_bonus: int = STREAK_MILESTONES[current_streak]
		if GameManager:
			GameManager.add_coins(milestone_bonus)
		reward["milestone_bonus"] = milestone_bonus

	reward_claimed.emit(get_streak_day(), reward)
	print("[DailyRewardsManager] Claimed reward: %s" % str(reward))

	# Auto-save
	if SaveManager:
		SaveManager.save_game()

	return reward


## Check if a reward is available to claim
func has_unclaimed_reward() -> bool:
	return not reward_claimed_today


## Get current streak
func get_current_streak() -> int:
	return current_streak


## Get total rewards claimed
func get_total_rewards_claimed() -> int:
	return total_rewards_claimed


## Reset (for new game)
func reset() -> void:
	current_streak = 0
	last_login_day = 0
	reward_claimed_today = false
	total_rewards_claimed = 0


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	return {
		"current_streak": current_streak,
		"last_login_day": last_login_day,
		"reward_claimed_today": reward_claimed_today,
		"total_rewards_claimed": total_rewards_claimed,
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	current_streak = data.get("current_streak", 0)
	last_login_day = data.get("last_login_day", 0)
	reward_claimed_today = data.get("reward_claimed_today", false)
	total_rewards_claimed = data.get("total_rewards_claimed", 0)

	# Check for new day after loading
	_check_daily_login()

	print("[DailyRewardsManager] Loaded - Streak: %d, Last login: %d" % [current_streak, last_login_day])
