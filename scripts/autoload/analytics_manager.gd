extends Node
## AnalyticsManager autoload singleton for tracking game events.
##
## Provides a unified interface for analytics tracking that can be
## extended to support various analytics backends. Currently supports
## local event logging with optional export.

signal event_logged(event_name: String, params: Dictionary)

# ============================================
# CONFIGURATION
# ============================================

## Whether analytics tracking is enabled
var enabled: bool = true

## Session ID for this play session
var session_id: String = ""

## User ID (anonymous, generated on first run)
var user_id: String = ""

## Queue of events waiting to be sent
var _event_queue: Array[Dictionary] = []

## Maximum queue size before auto-flush
const MAX_QUEUE_SIZE := 100

## Batch size for sending events
const BATCH_SIZE := 25

## Path for local analytics cache
const ANALYTICS_CACHE_PATH := "user://analytics_cache.json"

## Path for user ID persistence
const USER_ID_PATH := "user://analytics_user.cfg"


func _ready() -> void:
	_load_or_create_user_id()
	_start_new_session()
	_load_cached_events()
	print("[AnalyticsManager] Ready - Session: %s" % session_id)


func _load_or_create_user_id() -> void:
	var config := ConfigFile.new()
	if config.load(USER_ID_PATH) == OK:
		user_id = config.get_value("analytics", "user_id", "")

	if user_id.is_empty():
		user_id = _generate_anonymous_id()
		config.set_value("analytics", "user_id", user_id)
		config.save(USER_ID_PATH)


func _generate_anonymous_id() -> String:
	var timestamp := Time.get_unix_time_from_system()
	var random := randi()
	return "%x-%x" % [int(timestamp), random]


func _start_new_session() -> void:
	session_id = "%x" % int(Time.get_unix_time_from_system())
	log_event("session_start", {
		"platform": OS.get_name(),
		"version": ProjectSettings.get_setting("application/config/version", "0.0.0"),
	})


# ============================================
# EVENT LOGGING
# ============================================

## Log a generic event with optional parameters
func log_event(event_name: String, params: Dictionary = {}) -> void:
	if not enabled:
		return

	var event := {
		"event": event_name,
		"timestamp": Time.get_unix_time_from_system(),
		"session_id": session_id,
		"user_id": user_id,
		"params": params,
	}

	_event_queue.append(event)
	event_logged.emit(event_name, params)

	if _event_queue.size() >= MAX_QUEUE_SIZE:
		_flush_events()


## Log a game progression event
func log_progression(event_type: String, level: String, score: int = 0) -> void:
	log_event("progression", {
		"type": event_type,  # start, complete, fail
		"level": level,
		"score": score,
	})


## Log a resource event (currency earned/spent)
func log_resource(flow: String, currency: String, amount: int, item_type: String = "") -> void:
	log_event("resource", {
		"flow": flow,  # source, sink
		"currency": currency,
		"amount": amount,
		"item_type": item_type,
	})


## Log a design event (custom game events)
func log_design(event_id: String, value: float = 0.0) -> void:
	log_event("design", {
		"event_id": event_id,
		"value": value,
	})


# ============================================
# GAME-SPECIFIC EVENTS
# ============================================

## Track block mined event
func track_block_mined(block_type: String, depth: int) -> void:
	log_event("block_mined", {
		"block_type": block_type,
		"depth": depth,
	})


## Track ore collected event
func track_ore_collected(ore_id: String, depth: int, rarity: int) -> void:
	log_event("ore_collected", {
		"ore_id": ore_id,
		"depth": depth,
		"rarity": rarity,
	})


## Track item sold event
func track_item_sold(item_id: String, quantity: int, coins_earned: int) -> void:
	log_event("item_sold", {
		"item_id": item_id,
		"quantity": quantity,
		"coins_earned": coins_earned,
	})
	log_resource("source", "coins", coins_earned, item_id)


## Track tool upgraded event
func track_tool_upgrade(tool_id: String, tier: int, cost: int) -> void:
	log_event("tool_upgrade", {
		"tool_id": tool_id,
		"tier": tier,
		"cost": cost,
	})
	log_resource("sink", "coins", cost, "tool_upgrade")


## Track depth milestone reached
func track_depth_milestone(depth: int) -> void:
	log_event("depth_milestone", {
		"depth": depth,
	})
	log_progression("complete", "depth_%d" % depth, depth)


## Track player death
func track_death(cause: String, depth: int) -> void:
	log_event("player_death", {
		"cause": cause,
		"depth": depth,
	})
	log_progression("fail", "depth_%d" % depth, depth)


## Track building unlocked
func track_building_unlocked(building_id: String, depth: int) -> void:
	log_event("building_unlocked", {
		"building_id": building_id,
		"unlock_depth": depth,
	})


## Track shop interaction
func track_shop_visit(shop_type: String) -> void:
	log_event("shop_visit", {
		"shop_type": shop_type,
	})


## Track achievement unlocked
func track_achievement(achievement_id: String) -> void:
	log_event("achievement_unlocked", {
		"achievement_id": achievement_id,
	})


## Track tutorial step completed
func track_tutorial_step(step_name: String) -> void:
	log_event("tutorial_step", {
		"step": step_name,
	})


## Track session end with summary
func track_session_end(playtime_seconds: float, max_depth: int, coins_earned: int) -> void:
	log_event("session_end", {
		"playtime_seconds": playtime_seconds,
		"max_depth": max_depth,
		"coins_earned": coins_earned,
	})
	_flush_events()


# ============================================
# EVENT QUEUE MANAGEMENT
# ============================================

func _flush_events() -> void:
	if _event_queue.is_empty():
		return

	# Process events in batches
	var batch_count := ceili(float(_event_queue.size()) / BATCH_SIZE)
	for i in range(batch_count):
		var start := i * BATCH_SIZE
		var end := mini(start + BATCH_SIZE, _event_queue.size())
		var batch := _event_queue.slice(start, end)
		_send_batch(batch)

	_event_queue.clear()


func _send_batch(batch: Array) -> void:
	# For now, just log locally. Could be extended to send to backend.
	_cache_events(batch)


func _cache_events(events: Array) -> void:
	## Cache events locally for later export or debugging
	var file := FileAccess.open(ANALYTICS_CACHE_PATH, FileAccess.READ)
	var existing: Array = []
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			if json.data is Array:
				existing = json.data
		file.close()

	existing.append_array(events)

	# Keep only last 1000 events
	if existing.size() > 1000:
		existing = existing.slice(existing.size() - 1000)

	var write_file := FileAccess.open(ANALYTICS_CACHE_PATH, FileAccess.WRITE)
	if write_file:
		write_file.store_string(JSON.stringify(existing, "\t"))
		write_file.close()


func _load_cached_events() -> void:
	## Load any cached events from previous sessions
	var file := FileAccess.open(ANALYTICS_CACHE_PATH, FileAccess.READ)
	if not file:
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		if json.data is Array:
			# Could process cached events here if needed
			pass
	file.close()


# ============================================
# DATA EXPORT
# ============================================

## Export all analytics data as JSON string
func export_data() -> String:
	var file := FileAccess.open(ANALYTICS_CACHE_PATH, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		file.close()
		return content
	return "[]"


## Get summary statistics
func get_summary() -> Dictionary:
	var file := FileAccess.open(ANALYTICS_CACHE_PATH, FileAccess.READ)
	var events: Array = []
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			if json.data is Array:
				events = json.data
		file.close()

	var summary := {
		"total_events": events.size(),
		"unique_sessions": [],
		"event_types": {},
	}

	for event in events:
		if event is Dictionary:
			var sid = event.get("session_id", "")
			if sid and sid not in summary.unique_sessions:
				summary.unique_sessions.append(sid)

			var etype = event.get("event", "unknown")
			if not summary.event_types.has(etype):
				summary.event_types[etype] = 0
			summary.event_types[etype] += 1

	summary["unique_session_count"] = summary.unique_sessions.size()
	summary.erase("unique_sessions")  # Remove full list for brevity

	return summary


## Clear all cached analytics data
func clear_data() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ANALYTICS_CACHE_PATH))
	_event_queue.clear()


# ============================================
# SETTINGS
# ============================================

## Enable or disable analytics
func set_enabled(value: bool) -> void:
	enabled = value
	if enabled:
		log_event("analytics_enabled")
	else:
		# Flush remaining events before disabling
		_flush_events()


## Check if analytics is enabled
func is_enabled() -> bool:
	return enabled


# ============================================
# LIFECYCLE
# ============================================

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			# Flush events on app close
			if PlayerStats:
				track_session_end(
					PlayerStats.get_session_duration(),
					PlayerStats.session_max_depth,
					PlayerStats.session_coins_earned
				)
			else:
				_flush_events()
		NOTIFICATION_APPLICATION_PAUSED:
			# Mobile: flush on background
			_flush_events()
