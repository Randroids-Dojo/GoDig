extends Node
## ProgressionGateManager - Controls progressive disclosure of game features.
##
## Tracks player progression milestones and emits signals when new features
## should be revealed. UI elements subscribe to feature_unlocked to show/hide.
##
## Design Goals:
## - First 5 minutes: Only basic mining and selling
## - Depth-based unlocks for advanced features
## - "NEW" badge tracking for recently unlocked features
## - Skip option for experienced players

signal feature_unlocked(feature_id: String)
signal new_badge_shown(feature_id: String)
signal new_badge_dismissed(feature_id: String)

## Feature IDs and their unlock conditions
## Format: "feature_id": { "depth": int, "runs": int, "coins_earned": int, "blocks_mined": int }
## All conditions must be met (AND logic)
const FEATURE_GATES := {
	# Core features - always available
	"basic_movement": {},
	"basic_mining": {},

	# Early unlocks (first 5 minutes of play)
	"inventory_display": {"blocks_mined": 1},
	"depth_indicator": {"depth": 10},
	"coin_display": {"coins_earned": 1},

	# First session unlocks (5-15 minutes)
	"shop_access": {"coins_earned": 5},
	"tool_upgrades": {"first_sale": true},
	"backpack_upgrades": {"first_upgrade": true},

	# Depth-gated unlocks
	"ladder_shop": {"depth": 50},
	"passive_income_upgrades": {"depth": 100},
	"equipment_shop": {"depth": 150},
	"warehouse": {"depth": 500},
	"auto_miner": {"depth": 1000},

	# Run-count unlocks (experience based)
	"statistics_screen": {"runs": 5},
	"achievement_list": {"achievements": 1},
	"depth_records": {"depth": 100},

	# Late-game features
	"prestige_hints": {"depth": 2000},
}

## Default unlock states for new players (none unlocked)
var _unlocked_features: Dictionary = {}

## Features that should show "NEW" badge
var _new_badges: Dictionary = {}

## Whether to skip progressive disclosure (for experienced players)
var skip_disclosure: bool = false


func _ready() -> void:
	# Connect to progression signals
	if GameManager:
		GameManager.depth_updated.connect(_on_depth_updated)
		GameManager.coins_changed.connect(_on_coins_changed)

	if PlayerData:
		PlayerData.max_depth_updated.connect(_on_max_depth_updated)

	if PlayerStats:
		if PlayerStats.has_signal("blocks_mined_changed"):
			PlayerStats.blocks_mined_changed.connect(_on_blocks_mined_changed)

	if AchievementManager:
		AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)

	print("[ProgressionGateManager] Ready")


## Check if a feature is unlocked
func is_feature_unlocked(feature_id: String) -> bool:
	if skip_disclosure:
		return true
	return _unlocked_features.get(feature_id, false)


## Check if a feature should show "NEW" badge
func has_new_badge(feature_id: String) -> bool:
	return _new_badges.get(feature_id, false)


## Dismiss the "NEW" badge for a feature (called when player interacts)
func dismiss_new_badge(feature_id: String) -> void:
	if _new_badges.get(feature_id, false):
		_new_badges[feature_id] = false
		new_badge_dismissed.emit(feature_id)


## Unlock a feature and mark it as new
func unlock_feature(feature_id: String) -> void:
	if _unlocked_features.get(feature_id, false):
		return  # Already unlocked

	_unlocked_features[feature_id] = true
	_new_badges[feature_id] = true
	feature_unlocked.emit(feature_id)
	new_badge_shown.emit(feature_id)
	print("[ProgressionGateManager] Feature unlocked: %s" % feature_id)


## Check all feature gates against current progression
func check_all_gates() -> void:
	var progression := _get_current_progression()

	for feature_id in FEATURE_GATES:
		if _unlocked_features.get(feature_id, false):
			continue  # Already unlocked

		var gate: Dictionary = FEATURE_GATES[feature_id]
		if _check_gate(gate, progression):
			unlock_feature(feature_id)


## Get current player progression values
func _get_current_progression() -> Dictionary:
	return {
		"depth": PlayerData.max_depth_reached if PlayerData else 0,
		"coins_earned": SaveManager.current_save.lifetime_coins if SaveManager and SaveManager.current_save else 0,
		"blocks_mined": SaveManager.current_save.blocks_mined if SaveManager and SaveManager.current_save else 0,
		"runs": PlayerStats.total_runs if PlayerStats else 0,
		"achievements": AchievementManager.get_unlocked_count() if AchievementManager else 0,
		"first_sale": SaveManager.has_ftue_first_sell() if SaveManager else false,
		"first_upgrade": SaveManager.has_first_upgrade_purchased() if SaveManager else false,
	}


## Check if a gate's conditions are met
func _check_gate(gate: Dictionary, progression: Dictionary) -> bool:
	for condition_key in gate:
		var required_value = gate[condition_key]
		var current_value = progression.get(condition_key, 0)

		# Boolean conditions
		if required_value is bool:
			if current_value != required_value:
				return false
		# Numeric conditions (>=)
		elif current_value < required_value:
			return false

	return true


## Signal handlers
func _on_depth_updated(depth: int) -> void:
	check_all_gates()


func _on_max_depth_updated(depth: int) -> void:
	check_all_gates()


func _on_coins_changed(coins: int) -> void:
	check_all_gates()


func _on_blocks_mined_changed(count: int) -> void:
	check_all_gates()


func _on_achievement_unlocked(achievement_id: String) -> void:
	check_all_gates()


## Enable skip mode (for returning players or debug)
func enable_skip_disclosure() -> void:
	skip_disclosure = true
	print("[ProgressionGateManager] Skip disclosure enabled - all features unlocked")


## Disable skip mode
func disable_skip_disclosure() -> void:
	skip_disclosure = false
	check_all_gates()


## Get list of all locked features (for debug/UI)
func get_locked_features() -> Array[String]:
	var locked: Array[String] = []
	for feature_id in FEATURE_GATES:
		if not is_feature_unlocked(feature_id):
			locked.append(feature_id)
	return locked


## Get list of all unlocked features
func get_unlocked_features() -> Array[String]:
	var unlocked: Array[String] = []
	for feature_id in _unlocked_features:
		if _unlocked_features[feature_id]:
			unlocked.append(feature_id)
	return unlocked


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	return {
		"unlocked_features": _unlocked_features.duplicate(),
		"new_badges": _new_badges.duplicate(),
		"skip_disclosure": skip_disclosure,
	}


## Load save data
func load_save_data(data: Dictionary) -> void:
	_unlocked_features = data.get("unlocked_features", {}).duplicate()
	_new_badges = data.get("new_badges", {}).duplicate()
	skip_disclosure = data.get("skip_disclosure", false)

	# Recheck gates in case progression exceeded saved state
	check_all_gates()

	print("[ProgressionGateManager] Loaded - %d features unlocked, skip=%s" % [
		_unlocked_features.size(),
		skip_disclosure
	])


## Reset to defaults (for new game)
func reset() -> void:
	_unlocked_features.clear()
	_new_badges.clear()
	skip_disclosure = false

	# Always unlock core features
	_unlocked_features["basic_movement"] = true
	_unlocked_features["basic_mining"] = true

	print("[ProgressionGateManager] Reset to defaults")
