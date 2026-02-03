extends Node
## WelcomeBackManager - Guilt-free returning player rewards.
##
## Based on Session 26 research: "welcome-back rewards should feel like a gift, not guilt."
## Mistplay found players were happier without streak pressure.
##
## Key principles:
## - NO streak mechanics that punish absence
## - Show depth record and progress reminders (celebration of what they achieved)
## - Gift free ladders without conditions
## - Only triggers after significant absence (4+ hours) to feel meaningful
## - Avoid daily login calendars entirely

signal welcome_back_ready(data: Dictionary)
signal welcome_back_claimed(data: Dictionary)

## Minimum time away (in seconds) before showing welcome back message
## 4 hours = 14400 seconds - long enough to feel like a gift, not spammy
const MIN_ABSENCE_SECONDS := 14400

## Free ladder gift amounts based on time away
## More time away = more ladders (up to a cap) - always a gift, never punishment
const LADDER_GIFT_BY_HOURS := {
	4: 2,    # 4-8 hours: 2 free ladders
	8: 3,    # 8-24 hours: 3 free ladders
	24: 5,   # 1-3 days: 5 free ladders
	72: 8,   # 3-7 days: 8 free ladders
	168: 10, # 7+ days: 10 free ladders (max gift)
}

## Whether welcome back data is pending (waiting to be shown/claimed)
var has_pending_welcome: bool = false

## Cached welcome back data for display
var _pending_data: Dictionary = {}

## Last time player played (Unix timestamp) - saved/loaded
var last_play_time: int = 0


func _ready() -> void:
	# Defer connection to allow SaveManager to initialize
	call_deferred("_connect_signals")
	print("[WelcomeBackManager] Ready")


func _connect_signals() -> void:
	# Connect to game state for tracking play time
	if GameManager and GameManager.has_signal("state_changed"):
		GameManager.state_changed.connect(_on_game_state_changed)


func _on_game_state_changed(new_state: int) -> void:
	# Update last play time when player starts playing
	if new_state == GameManager.GameState.PLAYING:
		last_play_time = int(Time.get_unix_time_from_system())


## Check if player qualifies for welcome back message
## Called after loading save data
func check_welcome_back() -> void:
	if last_play_time <= 0:
		# First time playing - no welcome back needed
		return

	var current_time := int(Time.get_unix_time_from_system())
	var seconds_away := current_time - last_play_time

	if seconds_away < MIN_ABSENCE_SECONDS:
		# Not away long enough - no message
		return

	# Player qualifies! Prepare the welcome back data
	_prepare_welcome_data(seconds_away)


## Prepare the welcome back data with progress reminders and gifts
func _prepare_welcome_data(seconds_away: int) -> void:
	var hours_away := seconds_away / 3600
	var days_away := hours_away / 24

	# Calculate ladder gift based on time away
	var ladder_gift := _calculate_ladder_gift(hours_away)

	# Build the welcome back data
	_pending_data = {
		# Time away (for display)
		"hours_away": hours_away,
		"days_away": days_away,
		"time_away_text": _format_time_away(hours_away),

		# Progress reminders (celebration, not guilt)
		"max_depth": PlayerStats.max_depth_reached if PlayerStats else 0,
		"blocks_mined": PlayerStats.blocks_mined_total if PlayerStats else 0,
		"ores_collected": PlayerStats.ores_collected_total if PlayerStats else 0,
		"playtime_text": PlayerStats.get_playtime_string() if PlayerStats else "0:00",

		# Free gift (always positive)
		"ladder_gift": ladder_gift,

		# Achievements (show recent accomplishments)
		"achievement_count": _get_achievement_count(),
	}

	has_pending_welcome = true
	welcome_back_ready.emit(_pending_data)
	print("[WelcomeBackManager] Welcome back ready! Away for %d hours, gifting %d ladders" % [hours_away, ladder_gift])


## Calculate how many free ladders to gift based on hours away
func _calculate_ladder_gift(hours_away: int) -> int:
	var gift := 0

	# Find the highest threshold the player meets
	for threshold in LADDER_GIFT_BY_HOURS.keys():
		if hours_away >= threshold:
			gift = LADDER_GIFT_BY_HOURS[threshold]

	return gift


## Format time away as human-readable text
func _format_time_away(hours_away: int) -> String:
	if hours_away < 24:
		return "%d hours" % hours_away
	elif hours_away < 48:
		return "1 day"
	elif hours_away < 168:  # Less than a week
		return "%d days" % (hours_away / 24)
	else:
		return "over a week"


## Get achievement count (for progress reminder)
func _get_achievement_count() -> int:
	if AchievementManager and AchievementManager.has_method("get_unlocked_count"):
		return AchievementManager.get_unlocked_count()
	return 0


## Get the pending welcome back data (for UI)
func get_pending_data() -> Dictionary:
	return _pending_data


## Claim the welcome back rewards (give ladders)
func claim_welcome_back() -> Dictionary:
	if not has_pending_welcome:
		return {}

	var data := _pending_data.duplicate()

	# Give the free ladders
	var ladder_gift: int = data.get("ladder_gift", 0)
	if ladder_gift > 0 and InventoryManager and DataRegistry:
		var ladder_item = DataRegistry.get_item("ladder")
		if ladder_item:
			InventoryManager.add_item(ladder_item, ladder_gift)
			print("[WelcomeBackManager] Gifted %d free ladders" % ladder_gift)

	# Clear pending state
	has_pending_welcome = false
	_pending_data.clear()

	# Update last play time
	last_play_time = int(Time.get_unix_time_from_system())

	# Save immediately
	if SaveManager:
		SaveManager.save_game()

	welcome_back_claimed.emit(data)
	return data


## Check if there's a pending welcome back message
func has_pending() -> bool:
	return has_pending_welcome


## Dismiss without claiming (player can skip)
func dismiss_welcome_back() -> void:
	has_pending_welcome = false
	_pending_data.clear()
	last_play_time = int(Time.get_unix_time_from_system())


## Reset (for new game)
func reset() -> void:
	has_pending_welcome = false
	_pending_data.clear()
	last_play_time = int(Time.get_unix_time_from_system())


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	return {
		"last_play_time": last_play_time,
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	last_play_time = data.get("last_play_time", 0)

	# Check if player qualifies for welcome back
	check_welcome_back()

	print("[WelcomeBackManager] Loaded - Last play: %d" % last_play_time)
