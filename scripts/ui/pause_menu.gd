extends CanvasLayer
## Pause Menu - Pauses game and shows options.
##
## Provides resume, settings, emergency rescue, reload save, and quit options.
## Auto-pauses when app goes to background.

signal resumed
signal settings_opened
signal rescue_requested(cargo_lost_count: int)  # Emits number of items lost as fee
signal forfeit_cargo_requested(cargo_lost_count: int)  # Emits number of ore/gem items lost
signal reload_requested
signal quit_requested

@export var process_mode_paused: bool = true

## Rescue fee configuration
## Fee percentage scales with depth: base_percent + (depth * depth_scale_percent)
const RESCUE_BASE_FEE_PERCENT := 20.0  # Minimum 20% cargo lost
const RESCUE_DEPTH_SCALE_PERCENT := 0.3  # +0.3% per meter depth
const RESCUE_MAX_FEE_PERCENT := 80.0  # Maximum 80% cargo lost (always keep some)
const RESCUE_MIN_ITEMS_KEPT := 1  # Always keep at least 1 item if player has any

@onready var background: ColorRect = $Background
@onready var panel: PanelContainer = $Panel
@onready var resume_btn: Button = $Panel/VBox/ResumeButton
@onready var settings_btn: Button = $Panel/VBox/SettingsButton
@onready var forfeit_btn: Button = $Panel/VBox/ForfeitCargoButton
@onready var rescue_btn: Button = $Panel/VBox/RescueButton
@onready var reload_btn: Button = $Panel/VBox/ReloadButton
@onready var quit_btn: Button = $Panel/VBox/QuitButton

## Stats label (created programmatically)
var stats_label: Label = null

## Debug button (created programmatically)
var copy_logs_btn: Button = null

## Confirmation dialog for dangerous actions
var _confirm_dialog: ConfirmationDialog = null
var _pending_action: String = ""


func _ready() -> void:
	# Set process mode so we can receive input while paused
	if process_mode_paused:
		process_mode = Node.PROCESS_MODE_ALWAYS

	resume_btn.pressed.connect(_on_resume)
	settings_btn.pressed.connect(_on_settings)
	forfeit_btn.pressed.connect(_on_forfeit_cargo)
	rescue_btn.pressed.connect(_on_rescue)
	reload_btn.pressed.connect(_on_reload)
	quit_btn.pressed.connect(_on_quit)

	# Create confirmation dialog
	_create_confirm_dialog()

	# Create stats label
	_create_stats_label()

	# Create debug section
	_create_debug_section()

	visible = false
	print("[PauseMenu] Ready")


func _create_confirm_dialog() -> void:
	"""Create a reusable confirmation dialog for dangerous actions."""
	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.name = "ConfirmDialog"
	_confirm_dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	_confirm_dialog.confirmed.connect(_on_confirm_dialog_confirmed)
	_confirm_dialog.canceled.connect(_on_confirm_dialog_canceled)
	add_child(_confirm_dialog)


func _create_stats_label() -> void:
	"""Create a stats display label at the bottom of the pause menu."""
	stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 14)
	stats_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))

	# Get the VBox container and add the stats label at the bottom
	var vbox := $Panel/VBox as VBoxContainer
	if vbox:
		# Add separator before stats
		var separator := HSeparator.new()
		separator.custom_minimum_size = Vector2(0, 10)
		vbox.add_child(separator)
		vbox.add_child(stats_label)


func _create_debug_section() -> void:
	"""Create debug tools section at the bottom of the pause menu."""
	var vbox := $Panel/VBox as VBoxContainer
	if vbox == null:
		return

	# Add separator before debug section
	var separator := HSeparator.new()
	separator.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(separator)

	# Debug section label
	var debug_label := Label.new()
	debug_label.text = "Debug Tools"
	debug_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	debug_label.add_theme_font_size_override("font_size", 12)
	debug_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	vbox.add_child(debug_label)

	# Copy Logs button
	copy_logs_btn = Button.new()
	copy_logs_btn.name = "CopyLogsButton"
	copy_logs_btn.text = "Copy Console Logs"
	copy_logs_btn.pressed.connect(_on_copy_logs)
	vbox.add_child(copy_logs_btn)


func _on_copy_logs() -> void:
	"""Copy debug logs to clipboard."""
	if DebugLogger:
		DebugLogger.copy_to_clipboard()
		# Update button text briefly to show success
		copy_logs_btn.text = "Copied!"
		await get_tree().create_timer(1.5).timeout
		copy_logs_btn.text = "Copy Console Logs"
	else:
		copy_logs_btn.text = "Logger not available"


func _update_stats_display() -> void:
	"""Update the stats label with current player statistics."""
	if stats_label == null:
		return

	var lines: Array[String] = []

	# Add depth
	if PlayerData:
		lines.append("Max Depth: %dm" % PlayerData.max_depth_reached)

	# Add deaths and coins from save data
	if SaveManager.current_save:
		lines.append("Coins: $%d | Deaths: %d" % [SaveManager.current_save.coins, SaveManager.current_save.deaths])
		lines.append("Blocks Mined: %d" % SaveManager.current_save.blocks_mined)

	# Add achievements
	if AchievementManager:
		var unlocked := AchievementManager.get_unlocked_count()
		var total := AchievementManager.get_total_count()
		lines.append("Achievements: %d/%d" % [unlocked, total])

	stats_label.text = "\n".join(lines)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			_on_resume()
		else:
			show_menu()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	# Auto-pause when app goes to background (mobile)
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if not visible and GameManager.is_running:
			show_menu()


func show_menu() -> void:
	"""Show the pause menu and pause the game."""
	if visible:
		return

	visible = true
	get_tree().paused = true

	# Update button states
	_update_button_states()

	# Update stats display
	_update_stats_display()

	print("[PauseMenu] Game paused")


func hide_menu() -> void:
	"""Hide the pause menu and resume the game."""
	if not visible:
		return

	visible = false
	get_tree().paused = false

	print("[PauseMenu] Game resumed")


func _update_button_states() -> void:
	"""Update button enabled states based on current game state."""
	# Reload button is disabled if no save exists
	var can_reload: bool = false
	if SaveManager.current_slot >= 0:
		can_reload = SaveManager.has_save(SaveManager.current_slot)
	reload_btn.disabled = not can_reload

	# Update reload button text with time since save
	if can_reload:
		var time_text := SaveManager.get_time_since_save_text()
		reload_btn.text = "Reload Save (%s)" % time_text
	else:
		reload_btn.text = "Reload Save (no save)"


func _on_resume() -> void:
	hide_menu()
	resumed.emit()


func _on_settings() -> void:
	# Settings will be handled by parent/main scene
	settings_opened.emit()


func _on_rescue() -> void:
	"""Show confirmation dialog before emergency rescue with depth-scaled fee.
	Now uses ladder checkpoint system (Cairn-inspired) - rescue returns to
	highest placed ladder, not surface. Keeps 60% cargo (Loop Hero model)."""
	_pending_action = "rescue"
	_confirm_dialog.title = "Call for Rescue?"

	# Calculate rescue fee - fixed at 40% loss (60% retention, Loop Hero model)
	# Retention is rounded UP (player-favorable) to reinforce rescue as valid strategy
	var total_items := InventoryManager.get_total_item_count() if InventoryManager else 0
	var cargo_retention := 0.60  # Keep 60% of cargo
	var items_to_keep := int(ceil(float(total_items) * cargo_retention))  # Round UP (player favor)
	var items_to_lose := total_items - items_to_keep

	# Check for ladder checkpoint
	var ladder_checkpoint: Variant = null
	var dirt_grid = _get_dirt_grid()
	if dirt_grid and dirt_grid.has_method("get_highest_ladder_position"):
		ladder_checkpoint = dirt_grid.get_highest_ladder_position()

	# Build dialog message - frame rescue as VALID STRATEGY (Loop Hero design)
	# Player should feel smart for choosing rescue, not punished
	var dialog_text: String
	if ladder_checkpoint != null:
		var ladder_depth: int = ladder_checkpoint.y - GameManager.SURFACE_ROW
		dialog_text = "STRATEGIC EVACUATION\n\n"
		dialog_text += "Rescue to your LADDER checkpoint!\n"
		dialog_text += "Position: %dm deep\n\n" % ladder_depth
	else:
		dialog_text = "STRATEGIC EVACUATION\n\n"
		dialog_text += "A rescue team will bring you to the surface.\n\n"

	if total_items == 0:
		dialog_text += "No cargo at risk - free rescue!"
	else:
		dialog_text += "Evacuation Fee: 40% of cargo\n\n"
		dialog_text += "You KEEP: %d item(s)\n" % items_to_keep
		dialog_text += "You LOSE: %d item(s)\n\n" % items_to_lose
		dialog_text += "(Smart miners know when to retreat!)"

	_confirm_dialog.dialog_text = dialog_text
	_confirm_dialog.ok_button_text = "Evacuate Now"
	_confirm_dialog.cancel_button_text = "Continue Mining"
	_confirm_dialog.popup_centered()


func _get_dirt_grid() -> Node:
	"""Get reference to DirtGrid node for ladder checkpoint lookup."""
	var test_level := get_tree().get_first_node_in_group("test_level")
	if test_level and test_level.has_node("DirtGrid"):
		return test_level.get_node("DirtGrid")
	return null


func _calculate_rescue_fee_percent(depth: int) -> float:
	"""Calculate the rescue fee percentage based on depth.
	Deeper = higher fee, but capped at RESCUE_MAX_FEE_PERCENT."""
	var fee := RESCUE_BASE_FEE_PERCENT + (depth * RESCUE_DEPTH_SCALE_PERCENT)
	return minf(fee, RESCUE_MAX_FEE_PERCENT)


func _calculate_items_to_lose(total_items: int, fee_percent: float) -> int:
	"""Calculate how many items to lose based on fee percentage.
	Always keeps at least RESCUE_MIN_ITEMS_KEPT if player has items."""
	if total_items <= 0:
		return 0
	if total_items <= RESCUE_MIN_ITEMS_KEPT:
		return 0  # Don't take their last item(s)

	var items_to_lose := int(ceil(total_items * (fee_percent / 100.0)))
	var max_loseable := total_items - RESCUE_MIN_ITEMS_KEPT
	return mini(items_to_lose, max_loseable)


func _on_forfeit_cargo() -> void:
	"""Show confirmation dialog before forfeiting cargo."""
	_pending_action = "forfeit"
	_confirm_dialog.title = "Forfeit Cargo & Escape?"

	# Get cargo and utility counts
	var cargo_count := InventoryManager.get_cargo_count() if InventoryManager else 0
	var utility_count := InventoryManager.get_utility_count() if InventoryManager else 0

	# Build dialog message
	var dialog_text: String
	if cargo_count == 0:
		dialog_text = "You have no ore or gems to lose!\nYou will return to the surface safely."
	else:
		dialog_text = "You will LOSE:\n"
		dialog_text += "- All ore items\n"
		dialog_text += "- All gem items\n"
		dialog_text += "(%d items total)\n\n" % cargo_count
		dialog_text += "You will KEEP:\n"
		dialog_text += "- Ladders, ropes, tools\n"
		dialog_text += "- Equipment and coins\n"
		if utility_count > 0:
			dialog_text += "(%d utility items)\n" % utility_count

	_confirm_dialog.dialog_text = dialog_text
	_confirm_dialog.ok_button_text = "Forfeit & Escape"
	_confirm_dialog.cancel_button_text = "Cancel"
	_confirm_dialog.popup_centered()


func _on_reload() -> void:
	"""Show confirmation dialog before reloading save."""
	_pending_action = "reload"
	_confirm_dialog.title = "Reload Last Save?"
	var time_text := SaveManager.get_time_since_save_text()
	_confirm_dialog.dialog_text = "All progress since your last save (%s) will be lost.\nThis cannot be undone." % time_text
	_confirm_dialog.ok_button_text = "Reload"
	_confirm_dialog.cancel_button_text = "Cancel"
	_confirm_dialog.popup_centered()


func _on_confirm_dialog_confirmed() -> void:
	"""Handle confirmation of dangerous action."""
	match _pending_action:
		"forfeit":
			# Clear cargo (ore/gems) but keep utility items
			var lost := 0
			if InventoryManager:
				lost = InventoryManager.clear_cargo()
				print("[PauseMenu] Forfeited cargo: lost %d ore/gem items" % lost)

			forfeit_cargo_requested.emit(lost)
			hide_menu()
		"rescue":
			# Apply 60% cargo retention (Loop Hero model)
			# Player keeps 60% of items, loses 40%
			# Retention rounded UP to be player-favorable (rescue = valid strategy)
			var total_items := InventoryManager.get_total_item_count() if InventoryManager else 0
			var cargo_retention := 0.60
			var items_to_keep := int(ceil(float(total_items) * cargo_retention))  # Round UP
			var items_to_lose := total_items - items_to_keep

			# Remove random items as the rescue fee (less valuable items prioritized)
			var lost := 0
			if items_to_lose > 0 and InventoryManager:
				lost = InventoryManager.remove_random_items(items_to_lose)
				print("[PauseMenu] Rescue evacuation fee: lost %d items, kept %d" % [lost, items_to_keep])

			rescue_requested.emit(lost)
			hide_menu()
		"reload":
			reload_requested.emit()
			# Don't hide menu - reload will reset scene
	_pending_action = ""


func _on_confirm_dialog_canceled() -> void:
	"""Handle cancellation of dangerous action."""
	_pending_action = ""


func _on_quit() -> void:
	# Auto-save before quitting
	if SaveManager.current_slot >= 0:
		SaveManager.save_game()

	quit_requested.emit()
	hide_menu()
