extends Node
## EconomyConfig - Central economy configuration with remote tuning support.
##
## Provides tunable economy values that can be adjusted without app updates.
## Values are loaded from remote config on startup, with local fallbacks.
## Supports A/B testing for economy experiments.
##
## Key Design Principles:
## - Values don't change mid-session (snapshot on session start)
## - All values have sensible local defaults
## - Remote config is optional - game works fully offline
## - A/B test groups are assigned once per user and persisted

# ============================================
# SIGNALS
# ============================================

signal config_loaded
signal ab_test_assigned(test_name: String, group: String)

# ============================================
# CONSTANTS
# ============================================

## Config cache file for offline play
const CONFIG_CACHE_PATH := "user://economy_config_cache.json"

## User A/B test assignments
const AB_ASSIGNMENTS_PATH := "user://economy_ab_tests.json"

## Remote config URL (placeholder - replace with actual endpoint)
const REMOTE_CONFIG_URL := ""

# ============================================
# A/B TEST CONFIGURATION
# ============================================

## Active A/B tests (name -> {groups: [group_names], weights: [weights]})
var _active_tests: Dictionary = {
	"ore_value_v1": {
		"groups": ["control", "boosted_early", "boosted_late"],
		"weights": [0.5, 0.25, 0.25],
	},
	"upgrade_curve_v1": {
		"groups": ["control", "linear"],
		"weights": [0.5, 0.5],
	},
}

## User's assigned A/B test groups
var ab_assignments: Dictionary = {}

# ============================================
# ECONOMY VALUES - ORE SELL PRICES
# These multiply the base ore sell_value from OreData
# ============================================

## Base ore value multiplier (all ores)
var ore_value_multiplier: float = 1.0

## Depth-based ore value bonus (percentage per 100m depth)
## e.g., 0.1 = +10% value per 100m depth
var ore_depth_value_bonus: float = 0.1

## Early game ore boost (applies to first 50m only)
var early_ore_boost: float = 1.0

## Specific ore multipliers (ore_id -> multiplier)
var ore_multipliers: Dictionary = {
	"coal": 1.0,
	"copper": 1.0,
	"iron": 1.0,
	"silver": 1.0,
	"gold": 1.0,
	"platinum": 1.0,
	"titanium": 1.0,
	"obsidian": 1.0,
	"void_crystal": 1.0,
}

# ============================================
# ECONOMY VALUES - TOOL COSTS
# These override the base tool costs from ToolData
# ============================================

## Tool cost multiplier (all tools)
var tool_cost_multiplier: float = 1.0

## Specific tool cost overrides (tool_id -> cost)
## Empty = use base cost * multiplier
var tool_cost_overrides: Dictionary = {}

# ============================================
# ECONOMY VALUES - LADDER/CONSUMABLE COSTS
# ============================================

## Ladder base cost
var ladder_cost: int = 20

## Rope base cost
var rope_cost: int = 15

## Teleport scroll base cost
var teleport_scroll_cost: int = 100

# ============================================
# ECONOMY VALUES - UPGRADE CURVE PARAMETERS
# Controls how upgrade costs scale
# ============================================

## Upgrade cost scaling model: "exponential", "linear", "soft_cap"
var upgrade_cost_model: String = "soft_cap"

## For exponential: base multiplier per tier
var upgrade_exp_base: float = 2.0

## For soft_cap: growth rate decreases at this tier
var upgrade_soft_cap_tier: int = 4

## For soft_cap: multiplier at soft cap point
var upgrade_soft_cap_mult: float = 1.5

# ============================================
# ECONOMY VALUES - SESSION TARGETS
# Tuning for ideal session pacing
# ============================================

## Target time to first ore (seconds)
var target_first_ore_time: float = 30.0

## Target time to first sell (seconds)
var target_first_sell_time: float = 60.0

## Target time to first upgrade (seconds)
var target_first_upgrade_time: float = 180.0

## Target session length (minutes)
var target_session_length: float = 5.0

## Target trips per upgrade (1-3 is ideal)
var target_trips_per_upgrade: int = 2

# ============================================
# ECONOMY VALUES - RISK/REWARD SCALING
# ============================================

## Risk scaling by depth zone
## Format: {min_depth: {value_mult, variance, has_jackpots}}
var risk_zones: Dictionary = {
	0: {"value_mult": 1.0, "variance": 0.05, "has_jackpots": false},
	10: {"value_mult": 1.2, "variance": 0.2, "has_jackpots": false},
	25: {"value_mult": 1.5, "variance": 0.4, "has_jackpots": false},
	50: {"value_mult": 2.0, "variance": 0.6, "has_jackpots": true},
	100: {"value_mult": 3.0, "variance": 0.8, "has_jackpots": true},
}

## Jackpot chance at eligible depths (0-1)
var jackpot_chance: float = 0.02

## Jackpot multiplier range
var jackpot_mult_min: float = 3.0
var jackpot_mult_max: float = 10.0

# ============================================
# INITIALIZATION
# ============================================

## Session snapshot - values locked at session start
var _session_snapshot: Dictionary = {}

## Whether config has been loaded this session
var _config_loaded: bool = false


func _ready() -> void:
	_load_ab_assignments()
	_load_cached_config()
	_fetch_remote_config()
	_take_session_snapshot()
	print("[EconomyConfig] Ready - AB tests: %s" % str(ab_assignments.keys()))


func _load_ab_assignments() -> void:
	## Load or create A/B test assignments
	var file := FileAccess.open(AB_ASSIGNMENTS_PATH, FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
			ab_assignments = json.data
		file.close()

	# Assign to any new tests
	var changed := false
	for test_name in _active_tests:
		if not ab_assignments.has(test_name):
			ab_assignments[test_name] = _assign_to_test(test_name)
			changed = true
			ab_test_assigned.emit(test_name, ab_assignments[test_name])

	if changed:
		_save_ab_assignments()


func _assign_to_test(test_name: String) -> String:
	## Randomly assign user to a test group based on weights
	var test: Dictionary = _active_tests[test_name]
	var groups: Array = test["groups"]
	var weights: Array = test["weights"]

	var total_weight := 0.0
	for w in weights:
		total_weight += w

	var roll := randf() * total_weight
	var cumulative := 0.0

	for i in range(groups.size()):
		cumulative += weights[i]
		if roll <= cumulative:
			return groups[i]

	return groups[groups.size() - 1]


func _save_ab_assignments() -> void:
	var file := FileAccess.open(AB_ASSIGNMENTS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(ab_assignments, "\t"))
		file.close()


func _load_cached_config() -> void:
	## Load cached remote config from previous session
	var file := FileAccess.open(CONFIG_CACHE_PATH, FileAccess.READ)
	if not file:
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
		_apply_config(json.data)
	file.close()


func _fetch_remote_config() -> void:
	## Fetch remote config (non-blocking)
	## NOTE: This is a placeholder - implement actual HTTP request
	if REMOTE_CONFIG_URL.is_empty():
		_config_loaded = true
		config_loaded.emit()
		return

	# TODO: Implement HTTPRequest for remote config
	# For now, just mark as loaded
	_config_loaded = true
	config_loaded.emit()


func _apply_config(config: Dictionary) -> void:
	## Apply remote config values to local properties
	if config.has("ore_value_multiplier"):
		ore_value_multiplier = config["ore_value_multiplier"]
	if config.has("ore_depth_value_bonus"):
		ore_depth_value_bonus = config["ore_depth_value_bonus"]
	if config.has("early_ore_boost"):
		early_ore_boost = config["early_ore_boost"]
	if config.has("ore_multipliers"):
		for ore_id in config["ore_multipliers"]:
			ore_multipliers[ore_id] = config["ore_multipliers"][ore_id]
	if config.has("tool_cost_multiplier"):
		tool_cost_multiplier = config["tool_cost_multiplier"]
	if config.has("tool_cost_overrides"):
		tool_cost_overrides = config["tool_cost_overrides"]
	if config.has("ladder_cost"):
		ladder_cost = config["ladder_cost"]
	if config.has("rope_cost"):
		rope_cost = config["rope_cost"]
	if config.has("teleport_scroll_cost"):
		teleport_scroll_cost = config["teleport_scroll_cost"]
	if config.has("upgrade_cost_model"):
		upgrade_cost_model = config["upgrade_cost_model"]
	if config.has("risk_zones"):
		risk_zones = config["risk_zones"]
	if config.has("jackpot_chance"):
		jackpot_chance = config["jackpot_chance"]

	# Cache the config for offline use
	_cache_config(config)


func _cache_config(config: Dictionary) -> void:
	var file := FileAccess.open(CONFIG_CACHE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(config, "\t"))
		file.close()


func _take_session_snapshot() -> void:
	## Lock economy values for this session
	_session_snapshot = {
		"ore_value_multiplier": ore_value_multiplier,
		"ore_depth_value_bonus": ore_depth_value_bonus,
		"early_ore_boost": early_ore_boost,
		"ore_multipliers": ore_multipliers.duplicate(),
		"tool_cost_multiplier": tool_cost_multiplier,
		"tool_cost_overrides": tool_cost_overrides.duplicate(),
		"ladder_cost": ladder_cost,
		"rope_cost": rope_cost,
		"teleport_scroll_cost": teleport_scroll_cost,
		"upgrade_cost_model": upgrade_cost_model,
		"risk_zones": risk_zones.duplicate(true),
		"jackpot_chance": jackpot_chance,
		"ab_assignments": ab_assignments.duplicate(),
	}


# ============================================
# PUBLIC API - ECONOMY VALUE GETTERS
# All getters use session snapshot to ensure values don't change mid-session
# ============================================

## Get the effective sell value for an ore at a given depth
func get_ore_sell_value(ore_id: String, base_value: int, depth: int) -> int:
	var multiplier := _session_snapshot.get("ore_value_multiplier", 1.0) as float

	# Apply ore-specific multiplier
	var ore_mults: Dictionary = _session_snapshot.get("ore_multipliers", {})
	if ore_mults.has(ore_id):
		multiplier *= ore_mults[ore_id]

	# Apply depth bonus
	var depth_bonus: float = _session_snapshot.get("ore_depth_value_bonus", 0.1)
	multiplier *= (1.0 + (float(depth) / 100.0) * depth_bonus)

	# Apply early game boost
	if depth < 50:
		multiplier *= _session_snapshot.get("early_ore_boost", 1.0) as float

	# Apply risk zone value multiplier and variance
	var zone_data := _get_risk_zone_data(depth)
	var zone_mult: float = zone_data.get("value_mult", 1.0)
	var variance: float = zone_data.get("variance", 0.0)

	# Apply variance (random within +-variance range)
	var variance_roll := randf_range(1.0 - variance, 1.0 + variance)
	multiplier *= zone_mult * variance_roll

	# Check for jackpot
	if zone_data.get("has_jackpots", false):
		var jackpot_roll := randf()
		if jackpot_roll < _session_snapshot.get("jackpot_chance", 0.02):
			var jp_min: float = jackpot_mult_min
			var jp_max: float = jackpot_mult_max
			multiplier *= randf_range(jp_min, jp_max)

	return maxi(1, int(float(base_value) * multiplier))


## Get the effective cost for a tool
func get_tool_cost(tool_id: String, base_cost: int) -> int:
	var overrides: Dictionary = _session_snapshot.get("tool_cost_overrides", {})
	if overrides.has(tool_id):
		return overrides[tool_id]

	var multiplier: float = _session_snapshot.get("tool_cost_multiplier", 1.0)
	return maxi(0, int(float(base_cost) * multiplier))


## Get the cost for a consumable item
func get_consumable_cost(item_id: String) -> int:
	match item_id:
		"ladder":
			return _session_snapshot.get("ladder_cost", ladder_cost)
		"rope":
			return _session_snapshot.get("rope_cost", rope_cost)
		"teleport_scroll":
			return _session_snapshot.get("teleport_scroll_cost", teleport_scroll_cost)
		_:
			return 0


## Get risk zone data for a depth
func _get_risk_zone_data(depth: int) -> Dictionary:
	var zones: Dictionary = _session_snapshot.get("risk_zones", risk_zones)
	var best_zone := {}
	var best_depth := -1

	# Convert keys to int for comparison (JSON loads as strings)
	for zone_depth in zones:
		var d: int = 0
		if zone_depth is String:
			d = int(zone_depth)
		else:
			d = zone_depth
		if d <= depth and d > best_depth:
			best_depth = d
			best_zone = zones[zone_depth]

	return best_zone if not best_zone.is_empty() else {"value_mult": 1.0, "variance": 0.0, "has_jackpots": false}


## Get the user's A/B test group for a specific test
func get_ab_group(test_name: String) -> String:
	return ab_assignments.get(test_name, "control")


## Check if config has been loaded
func is_config_loaded() -> bool:
	return _config_loaded


# ============================================
# ANALYTICS INTEGRATION
# Track economy events for balancing decisions
# ============================================

## Track ore value calculation for analytics
func track_ore_value(ore_id: String, base_value: int, final_value: int, depth: int) -> void:
	if AnalyticsManager:
		AnalyticsManager.log_event("economy_ore_value", {
			"ore_id": ore_id,
			"base_value": base_value,
			"final_value": final_value,
			"depth": depth,
			"multiplier": float(final_value) / float(base_value) if base_value > 0 else 1.0,
			"ab_tests": ab_assignments,
		})


## Track tool purchase for analytics
func track_tool_purchase(tool_id: String, cost: int, player_coins_before: int) -> void:
	if AnalyticsManager:
		AnalyticsManager.log_event("economy_tool_purchase", {
			"tool_id": tool_id,
			"cost": cost,
			"coins_before": player_coins_before,
			"coins_after": player_coins_before - cost,
			"ab_tests": ab_assignments,
		})


## Track time to milestone for pacing analysis
func track_milestone_timing(milestone: String, time_seconds: float, session_num: int) -> void:
	if AnalyticsManager:
		AnalyticsManager.log_event("economy_milestone", {
			"milestone": milestone,
			"time_seconds": time_seconds,
			"session_num": session_num,
			"ab_tests": ab_assignments,
		})


# ============================================
# DEBUG / DEVELOPMENT
# ============================================

## Get current config as dictionary for debugging
func get_config_debug() -> Dictionary:
	return {
		"ore_value_multiplier": ore_value_multiplier,
		"ore_depth_value_bonus": ore_depth_value_bonus,
		"early_ore_boost": early_ore_boost,
		"tool_cost_multiplier": tool_cost_multiplier,
		"upgrade_cost_model": upgrade_cost_model,
		"ladder_cost": ladder_cost,
		"ab_assignments": ab_assignments,
		"session_snapshot_keys": _session_snapshot.keys(),
	}


## Force reload config (for testing)
func force_reload() -> void:
	_load_cached_config()
	_take_session_snapshot()
	config_loaded.emit()
