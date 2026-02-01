extends Node
## DebugLogger - Captures log messages for debugging.
##
## Stores recent log messages that can be copied to clipboard.
## Useful for debugging issues on web builds where console access is limited.

## Maximum number of log lines to keep
const MAX_LOG_LINES := 500

## Stored log messages
var _log_buffer: PackedStringArray = PackedStringArray()

## Original print function (if we could override it, which we can't in GDScript)
## Instead, use write() method to capture important messages


func _ready() -> void:
	# Log startup
	write("DebugLogger initialized", "System")

	# Connect to game signals after other autoloads are ready
	call_deferred("_connect_game_signals")


func _connect_game_signals() -> void:
	## Connect to key game signals for automatic logging

	# GameManager signals
	if GameManager:
		if GameManager.has_signal("game_started"):
			GameManager.game_started.connect(_on_game_started)
		if GameManager.has_signal("game_over"):
			GameManager.game_over.connect(_on_game_over)
		if GameManager.has_signal("coins_changed"):
			GameManager.coins_changed.connect(_on_coins_changed)
		if GameManager.has_signal("depth_updated"):
			GameManager.depth_updated.connect(_on_depth_updated)
		if GameManager.has_signal("depth_milestone_reached"):
			GameManager.depth_milestone_reached.connect(_on_milestone_reached)
		if GameManager.has_signal("layer_entered"):
			GameManager.layer_entered.connect(_on_layer_entered)
		write("Connected to GameManager signals", "System")

	# SaveManager signals
	if SaveManager:
		if SaveManager.has_signal("save_completed"):
			SaveManager.save_completed.connect(_on_save_completed)
		if SaveManager.has_signal("load_completed"):
			SaveManager.load_completed.connect(_on_load_completed)
		write("Connected to SaveManager signals", "System")

	# AchievementManager signals
	if AchievementManager:
		if AchievementManager.has_signal("achievement_unlocked"):
			AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)
		write("Connected to AchievementManager signals", "System")

	# PlayerData signals
	if PlayerData:
		if PlayerData.has_signal("player_died"):
			PlayerData.player_died.connect(_on_player_died)
		if PlayerData.has_signal("tool_changed"):
			PlayerData.tool_changed.connect(_on_tool_changed)
		write("Connected to PlayerData signals", "System")


# ============================================
# AUTOMATIC EVENT LOGGING
# ============================================

func _on_game_started() -> void:
	write("Game started", "Game")

func _on_game_over() -> void:
	write("Game over", "Game")

func _on_coins_changed(new_amount: int) -> void:
	write("Coins changed to %d" % new_amount, "Game")

func _on_depth_updated(depth: int) -> void:
	# Only log significant depth changes to avoid spam
	if depth > 0 and depth % 10 == 0:
		write("Reached depth %dm" % depth, "Game")

func _on_milestone_reached(depth: int) -> void:
	write("Depth milestone reached: %dm" % depth, "Game")

func _on_layer_entered(layer_name: String) -> void:
	write("Entered layer: %s" % layer_name, "World")

func _on_save_completed(success: bool) -> void:
	if success:
		write("Game saved successfully", "Save")
	else:
		write("Game save FAILED", "Save")

func _on_load_completed(success: bool) -> void:
	if success:
		write("Game loaded successfully", "Save")
	else:
		write("Game load FAILED", "Save")

func _on_achievement_unlocked(achievement: Dictionary) -> void:
	var name: String = achievement.get("name", "Unknown")
	write("Achievement unlocked: %s" % name, "Achievement")

func _on_player_died() -> void:
	write("Player died", "Player")

func _on_tool_changed(tool_data) -> void:
	if tool_data:
		write("Tool equipped: %s" % tool_data.display_name, "Player")
	else:
		write("Tool unequipped", "Player")


## Log a message and store it in the buffer
## Note: Named 'write' instead of 'log' to avoid conflict with built-in log() function
func write(message: String, source: String = "") -> void:
	var timestamp := Time.get_time_string_from_system()
	var formatted: String
	if source.is_empty():
		formatted = "[%s] %s" % [timestamp, message]
	else:
		formatted = "[%s] [%s] %s" % [timestamp, source, message]

	_log_buffer.append(formatted)

	# Trim buffer if too large
	while _log_buffer.size() > MAX_LOG_LINES:
		_log_buffer.remove_at(0)

	# Also print to console
	print(formatted)


## Log an error message
func log_error(message: String, source: String = "") -> void:
	write("ERROR: " + message, source)


## Log a warning message
func log_warning(message: String, source: String = "") -> void:
	write("WARNING: " + message, source)


## Get all logs as a single string
func get_logs() -> String:
	return "\n".join(_log_buffer)


## Get recent logs (last N lines)
func get_recent_logs(count: int = 100) -> String:
	var start_idx := maxi(0, _log_buffer.size() - count)
	var recent: PackedStringArray = PackedStringArray()
	for i in range(start_idx, _log_buffer.size()):
		recent.append(_log_buffer[i])
	return "\n".join(recent)


## Clear the log buffer
func clear() -> void:
	_log_buffer.clear()
	write("Log buffer cleared", "DebugLogger")


## Copy logs to clipboard with full game state
func copy_to_clipboard() -> bool:
	# Collect current game state
	var state_info := _collect_game_state()

	var logs := get_logs()
	if logs.is_empty():
		logs = "(No captured logs - use DebugLogger.write() to capture)"

	# Add header with system info
	var header := "=== GoDig Debug Report ===\n"
	header += "Time: %s\n" % Time.get_datetime_string_from_system()
	header += "Platform: %s\n" % OS.get_name()
	header += "Version: %s\n" % ProjectSettings.get_setting("application/config/version", "unknown")
	header += "==========================\n\n"

	header += "=== Game State ===\n"
	header += state_info
	header += "\n=== Log Buffer (%d entries) ===\n" % _log_buffer.size()

	var full_log := header + logs

	DisplayServer.clipboard_set(full_log)
	write("Debug report copied to clipboard", "DebugLogger")
	return true


func _collect_game_state() -> String:
	"""Collect current game state for debug report."""
	var lines: PackedStringArray = PackedStringArray()

	# GameManager state
	if GameManager:
		lines.append("GameManager.state: %s" % GameManager.state)
		lines.append("GameManager.is_running: %s" % GameManager.is_running)
		lines.append("GameManager.current_depth: %d" % GameManager.current_depth)
		lines.append("GameManager.tutorial_state: %s" % GameManager.tutorial_state)

	# SaveManager state
	if SaveManager:
		lines.append("SaveManager.current_slot: %d" % SaveManager.current_slot)
		if SaveManager.current_save:
			lines.append("Save.coins: %d" % SaveManager.current_save.coins)
			lines.append("Save.blocks_mined: %d" % SaveManager.current_save.blocks_mined)
			lines.append("Save.deaths: %d" % SaveManager.current_save.deaths)

	# PlayerData state
	if PlayerData:
		lines.append("PlayerData.current_tool: %s" % PlayerData.current_tool)
		lines.append("PlayerData.max_depth_reached: %d" % PlayerData.max_depth_reached)

	# InventoryManager state
	if InventoryManager:
		lines.append("Inventory: %d/%d slots used" % [InventoryManager.get_used_slots(), InventoryManager.get_total_slots()])

	# DataRegistry state
	if DataRegistry:
		lines.append("DataRegistry: %d items, %d tools, %d ores loaded" % [
			DataRegistry.items.size(),
			DataRegistry.tools.size(),
			DataRegistry.ores.size()
		])

	# PlatformDetector state
	if PlatformDetector:
		lines.append("PlatformDetector.is_mobile: %s" % PlatformDetector.is_mobile_platform)
		lines.append("PlatformDetector.touch_controls: %s" % PlatformDetector.should_show_touch_controls())

	return "\n".join(lines) + "\n"


## Get log count
func get_log_count() -> int:
	return _log_buffer.size()
