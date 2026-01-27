extends Node
## PlayerStats autoload singleton for tracking detailed player statistics.
##
## Tracks comprehensive gameplay statistics including:
## - Mining stats (by block type, total)
## - Movement stats (distance, jumps, wall jumps)
## - Collection stats (by ore type)
## - Session stats (current session vs all-time)
## - Time-based stats (play sessions, fastest depths)

signal stat_updated(stat_name: String, new_value: int)
signal milestone_reached(stat_name: String, milestone_value: int)

# ============================================
# LIFETIME STATISTICS (persisted in save)
# ============================================

## Mining statistics
var blocks_mined_total: int = 0
var blocks_mined_by_type: Dictionary = {}  # String block_type -> int count

## Collection statistics
var ores_collected_total: int = 0
var ores_collected_by_type: Dictionary = {}  # String ore_id -> int count
var items_sold_total: int = 0
var items_sold_by_type: Dictionary = {}  # String item_id -> int count

## Movement statistics
var tiles_moved: int = 0
var jumps_performed: int = 0
var wall_jumps_performed: int = 0
var ladders_climbed: int = 0
var falls_taken: int = 0
var fall_damage_taken: int = 0

## Economy statistics
var coins_earned_total: int = 0
var coins_spent_total: int = 0
var items_purchased: int = 0

## Death statistics
var deaths_total: int = 0
var deaths_by_cause: Dictionary = {}  # String cause -> int count

## Time statistics
var total_playtime_seconds: float = 0.0
var sessions_played: int = 0

## Depth statistics
var max_depth_reached: int = 0
var deepest_death_depth: int = 0
var times_reached_depth: Dictionary = {}  # int depth_milestone -> int count

# ============================================
# SESSION STATISTICS (reset each session)
# ============================================

var session_blocks_mined: int = 0
var session_ores_collected: int = 0
var session_tiles_moved: int = 0
var session_coins_earned: int = 0
var session_deaths: int = 0
var session_start_time: float = 0.0
var session_max_depth: int = 0

# Milestone thresholds for notifications
const MINING_MILESTONES := [10, 50, 100, 500, 1000, 5000, 10000]
const MOVEMENT_MILESTONES := [100, 500, 1000, 5000, 10000, 50000]
const COIN_MILESTONES := [100, 500, 1000, 5000, 10000, 50000, 100000]


func _ready() -> void:
	_start_new_session()
	print("[PlayerStats] Ready")


func _start_new_session() -> void:
	session_blocks_mined = 0
	session_ores_collected = 0
	session_tiles_moved = 0
	session_coins_earned = 0
	session_deaths = 0
	session_start_time = Time.get_unix_time_from_system()
	session_max_depth = 0
	sessions_played += 1


# ============================================
# MINING STAT TRACKING
# ============================================

## Track a block being mined
func track_block_mined(block_type: String = "dirt") -> void:
	blocks_mined_total += 1
	session_blocks_mined += 1

	if not blocks_mined_by_type.has(block_type):
		blocks_mined_by_type[block_type] = 0
	blocks_mined_by_type[block_type] += 1

	stat_updated.emit("blocks_mined", blocks_mined_total)
	_check_milestone("blocks_mined", blocks_mined_total, MINING_MILESTONES)


## Track an ore being collected
func track_ore_collected(ore_id: String) -> void:
	ores_collected_total += 1
	session_ores_collected += 1

	if not ores_collected_by_type.has(ore_id):
		ores_collected_by_type[ore_id] = 0
	ores_collected_by_type[ore_id] += 1

	stat_updated.emit("ores_collected", ores_collected_total)


# ============================================
# MOVEMENT STAT TRACKING
# ============================================

## Track player moving to a new tile
func track_tile_moved() -> void:
	tiles_moved += 1
	session_tiles_moved += 1
	stat_updated.emit("tiles_moved", tiles_moved)
	_check_milestone("tiles_moved", tiles_moved, MOVEMENT_MILESTONES)


## Track a jump being performed
func track_jump() -> void:
	jumps_performed += 1
	stat_updated.emit("jumps", jumps_performed)


## Track a wall jump being performed
func track_wall_jump() -> void:
	wall_jumps_performed += 1
	stat_updated.emit("wall_jumps", wall_jumps_performed)


## Track climbing a ladder tile
func track_ladder_climbed() -> void:
	ladders_climbed += 1
	stat_updated.emit("ladders_climbed", ladders_climbed)


## Track a fall (regardless of damage)
func track_fall(damage: int = 0) -> void:
	falls_taken += 1
	fall_damage_taken += damage
	stat_updated.emit("falls", falls_taken)


# ============================================
# ECONOMY STAT TRACKING
# ============================================

## Track coins earned (from selling items)
func track_coins_earned(amount: int) -> void:
	coins_earned_total += amount
	session_coins_earned += amount
	stat_updated.emit("coins_earned", coins_earned_total)
	_check_milestone("coins_earned", coins_earned_total, COIN_MILESTONES)


## Track coins spent (on purchases)
func track_coins_spent(amount: int) -> void:
	coins_spent_total += amount
	stat_updated.emit("coins_spent", coins_spent_total)


## Track an item being sold
func track_item_sold(item_id: String, quantity: int = 1) -> void:
	items_sold_total += quantity

	if not items_sold_by_type.has(item_id):
		items_sold_by_type[item_id] = 0
	items_sold_by_type[item_id] += quantity


## Track an item being purchased
func track_item_purchased() -> void:
	items_purchased += 1


# ============================================
# DEATH STAT TRACKING
# ============================================

## Track a player death
func track_death(cause: String, depth: int = 0) -> void:
	deaths_total += 1
	session_deaths += 1

	if not deaths_by_cause.has(cause):
		deaths_by_cause[cause] = 0
	deaths_by_cause[cause] += 1

	if depth > deepest_death_depth:
		deepest_death_depth = depth

	stat_updated.emit("deaths", deaths_total)


# ============================================
# DEPTH STAT TRACKING
# ============================================

## Track reaching a new depth
func track_depth(depth: int) -> void:
	if depth > session_max_depth:
		session_max_depth = depth

	if depth > max_depth_reached:
		max_depth_reached = depth
		stat_updated.emit("max_depth", max_depth_reached)


## Track reaching a depth milestone
func track_depth_milestone(milestone: int) -> void:
	if not times_reached_depth.has(milestone):
		times_reached_depth[milestone] = 0
	times_reached_depth[milestone] += 1


# ============================================
# TIME STAT TRACKING
# ============================================

## Update playtime (called each frame or periodically)
func update_playtime(delta: float) -> void:
	total_playtime_seconds += delta


## Get current session duration in seconds
func get_session_duration() -> float:
	return Time.get_unix_time_from_system() - session_start_time


# ============================================
# MILESTONE CHECKING
# ============================================

func _check_milestone(stat_name: String, value: int, milestones: Array) -> void:
	for m in milestones:
		if value == m:
			milestone_reached.emit(stat_name, m)
			break


# ============================================
# SAVE/LOAD INTEGRATION
# ============================================

## Get all stats as a dictionary for saving
func get_save_data() -> Dictionary:
	return {
		# Mining
		"blocks_mined_total": blocks_mined_total,
		"blocks_mined_by_type": blocks_mined_by_type.duplicate(),
		"ores_collected_total": ores_collected_total,
		"ores_collected_by_type": ores_collected_by_type.duplicate(),
		"items_sold_total": items_sold_total,
		"items_sold_by_type": items_sold_by_type.duplicate(),
		# Movement
		"tiles_moved": tiles_moved,
		"jumps_performed": jumps_performed,
		"wall_jumps_performed": wall_jumps_performed,
		"ladders_climbed": ladders_climbed,
		"falls_taken": falls_taken,
		"fall_damage_taken": fall_damage_taken,
		# Economy
		"coins_earned_total": coins_earned_total,
		"coins_spent_total": coins_spent_total,
		"items_purchased": items_purchased,
		# Deaths
		"deaths_total": deaths_total,
		"deaths_by_cause": deaths_by_cause.duplicate(),
		"deepest_death_depth": deepest_death_depth,
		# Time
		"total_playtime_seconds": total_playtime_seconds,
		"sessions_played": sessions_played,
		# Depth
		"max_depth_reached": max_depth_reached,
		"times_reached_depth": times_reached_depth.duplicate(),
	}


## Load stats from a saved dictionary
func load_save_data(data: Dictionary) -> void:
	# Mining
	blocks_mined_total = data.get("blocks_mined_total", 0)
	blocks_mined_by_type = data.get("blocks_mined_by_type", {}).duplicate()
	ores_collected_total = data.get("ores_collected_total", 0)
	ores_collected_by_type = data.get("ores_collected_by_type", {}).duplicate()
	items_sold_total = data.get("items_sold_total", 0)
	items_sold_by_type = data.get("items_sold_by_type", {}).duplicate()
	# Movement
	tiles_moved = data.get("tiles_moved", 0)
	jumps_performed = data.get("jumps_performed", 0)
	wall_jumps_performed = data.get("wall_jumps_performed", 0)
	ladders_climbed = data.get("ladders_climbed", 0)
	falls_taken = data.get("falls_taken", 0)
	fall_damage_taken = data.get("fall_damage_taken", 0)
	# Economy
	coins_earned_total = data.get("coins_earned_total", 0)
	coins_spent_total = data.get("coins_spent_total", 0)
	items_purchased = data.get("items_purchased", 0)
	# Deaths
	deaths_total = data.get("deaths_total", 0)
	deaths_by_cause = data.get("deaths_by_cause", {}).duplicate()
	deepest_death_depth = data.get("deepest_death_depth", 0)
	# Time
	total_playtime_seconds = data.get("total_playtime_seconds", 0.0)
	sessions_played = data.get("sessions_played", 0)
	# Depth
	max_depth_reached = data.get("max_depth_reached", 0)
	times_reached_depth = data.get("times_reached_depth", {}).duplicate()

	# Start a new session after loading
	_start_new_session()


## Reset all stats (for new game)
func reset() -> void:
	blocks_mined_total = 0
	blocks_mined_by_type.clear()
	ores_collected_total = 0
	ores_collected_by_type.clear()
	items_sold_total = 0
	items_sold_by_type.clear()
	tiles_moved = 0
	jumps_performed = 0
	wall_jumps_performed = 0
	ladders_climbed = 0
	falls_taken = 0
	fall_damage_taken = 0
	coins_earned_total = 0
	coins_spent_total = 0
	items_purchased = 0
	deaths_total = 0
	deaths_by_cause.clear()
	deepest_death_depth = 0
	total_playtime_seconds = 0.0
	sessions_played = 0
	max_depth_reached = 0
	times_reached_depth.clear()

	_start_new_session()


# ============================================
# CONVENIENCE GETTERS
# ============================================

## Get formatted playtime string (HH:MM:SS)
func get_playtime_string() -> String:
	var total_seconds := int(total_playtime_seconds)
	var hours := total_seconds / 3600
	var minutes := (total_seconds % 3600) / 60
	var seconds := total_seconds % 60

	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, seconds]
	else:
		return "%d:%02d" % [minutes, seconds]


## Get most mined block type
func get_most_mined_block_type() -> String:
	var max_count := 0
	var max_type := "dirt"
	for block_type in blocks_mined_by_type:
		if blocks_mined_by_type[block_type] > max_count:
			max_count = blocks_mined_by_type[block_type]
			max_type = block_type
	return max_type


## Get most collected ore type
func get_most_collected_ore() -> String:
	var max_count := 0
	var max_ore := ""
	for ore_id in ores_collected_by_type:
		if ores_collected_by_type[ore_id] > max_count:
			max_count = ores_collected_by_type[ore_id]
			max_ore = ore_id
	return max_ore


## Get most common death cause
func get_most_common_death_cause() -> String:
	var max_count := 0
	var max_cause := "unknown"
	for cause in deaths_by_cause:
		if deaths_by_cause[cause] > max_count:
			max_count = deaths_by_cause[cause]
			max_cause = cause
	return max_cause


## Get blocks mined count for a specific type
func get_blocks_mined_count(block_type: String) -> int:
	return blocks_mined_by_type.get(block_type, 0)


## Get ores collected count for a specific type
func get_ores_collected_count(ore_id: String) -> int:
	return ores_collected_by_type.get(ore_id, 0)


## Get death count for a specific cause
func get_deaths_by_cause_count(cause: String) -> int:
	return deaths_by_cause.get(cause, 0)
