extends CanvasLayer
## Death Screen - Shown when player dies.
##
## Offers respawn options and displays death statistics.
## Respawn at surface costs half of inventory, reload loses progress since save.
## Optimized for fast restart - under 2 seconds from death to moveable player.

signal respawn_requested
signal reload_requested
signal dive_again_requested  # Quick dive if player has supplies
signal quick_retry_requested  # Ultra-fast retry, skips stats entirely

@export var process_mode_paused: bool = true

## Animation timings (optimized for fast restart)
const FADE_IN_DURATION := 0.25  # Ultra-quick fade for fast restart
const PANEL_FADE_DELAY := 0.05
const QUICK_RETRY_WINDOW := 1.5  # Seconds before full menu appears

## UI Elements (created programmatically)
var background: ColorRect = null
var panel: PanelContainer = null
var title_label: Label = null
var death_cause_label: Label = null
var stats_label: Label = null
var respawn_btn: Button = null
var reload_btn: Button = null
var vbox: VBoxContainer = null
var dive_again_btn: Button = null  # Quick dive button

## Quick retry UI (shown immediately, fades out)
var quick_retry_container: Control = null
var quick_retry_btn: Button = null
var quick_retry_hint: Label = null

## Death info
var _death_cause: String = "unknown"
var _death_depth: int = 0

## Fade animation
var _fade_tween: Tween = null
var _quick_retry_timer: Timer = null

## Minimum ladders required to show "Dive Again" prompt
const MIN_LADDERS_FOR_DIVE := 3


func _ready() -> void:
	if process_mode_paused:
		process_mode = Node.PROCESS_MODE_ALWAYS

	_create_ui()
	visible = false
	print("[DeathScreen] Ready")


func _create_ui() -> void:
	## Create all UI elements programmatically

	# Background overlay
	background = ColorRect.new()
	background.name = "Background"
	background.color = Color(0.1, 0.0, 0.0, 0.8)
	background.anchors_preset = Control.PRESET_FULL_RECT
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	# Panel container
	panel = PanelContainer.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(300, 350)
	panel.position = Vector2(-150, -175)
	add_child(panel)

	# VBox container
	vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	# Add padding margin
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var inner_vbox := VBoxContainer.new()
	inner_vbox.add_theme_constant_override("separation", 16)
	margin.add_child(inner_vbox)

	# Title
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "YOU DIED"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color.RED)
	inner_vbox.add_child(title_label)

	# Death cause
	death_cause_label = Label.new()
	death_cause_label.name = "DeathCauseLabel"
	death_cause_label.text = "Cause: Unknown"
	death_cause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_cause_label.add_theme_font_size_override("font_size", 18)
	death_cause_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.7))
	inner_vbox.add_child(death_cause_label)

	# Stats
	stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.text = ""
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 14)
	stats_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	inner_vbox.add_child(stats_label)

	# Separator
	inner_vbox.add_child(HSeparator.new())

	# Respawn button
	respawn_btn = Button.new()
	respawn_btn.name = "RespawnButton"
	respawn_btn.text = "Respawn at Surface"
	respawn_btn.custom_minimum_size = Vector2(200, 50)
	respawn_btn.pressed.connect(_on_respawn_pressed)
	inner_vbox.add_child(respawn_btn)

	# Respawn cost label
	var respawn_cost_label := Label.new()
	respawn_cost_label.name = "RespawnCostLabel"
	respawn_cost_label.text = "(Lose 50% of inventory)"
	respawn_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	respawn_cost_label.add_theme_font_size_override("font_size", 12)
	respawn_cost_label.add_theme_color_override("font_color", Color(0.7, 0.6, 0.6))
	inner_vbox.add_child(respawn_cost_label)

	# Dive Again button (shown if player has supplies)
	dive_again_btn = Button.new()
	dive_again_btn.name = "DiveAgainButton"
	dive_again_btn.text = "DIVE AGAIN!"
	dive_again_btn.custom_minimum_size = Vector2(200, 50)
	dive_again_btn.pressed.connect(_on_dive_again_pressed)
	dive_again_btn.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	inner_vbox.add_child(dive_again_btn)

	# Reload button
	reload_btn = Button.new()
	reload_btn.name = "ReloadButton"
	reload_btn.text = "Reload Last Save"
	reload_btn.custom_minimum_size = Vector2(200, 50)
	reload_btn.pressed.connect(_on_reload_pressed)
	inner_vbox.add_child(reload_btn)

	# Quick retry overlay (shown immediately, large tappable area at top)
	_create_quick_retry_ui()


func _create_quick_retry_ui() -> void:
	## Create the quick retry UI that appears immediately on death
	## This is a large tappable button that allows instant restart
	quick_retry_container = Control.new()
	quick_retry_container.name = "QuickRetryContainer"
	quick_retry_container.set_anchors_preset(Control.PRESET_TOP_WIDE)
	quick_retry_container.custom_minimum_size = Vector2(0, 200)
	quick_retry_container.modulate.a = 0.0  # Start hidden
	add_child(quick_retry_container)

	# Large touch area background
	var bg := ColorRect.new()
	bg.name = "QuickRetryBackground"
	bg.color = Color(0.2, 0.5, 0.2, 0.9)  # Green tint for positive action
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	quick_retry_container.add_child(bg)

	# Quick retry button (full width for easy tapping)
	quick_retry_btn = Button.new()
	quick_retry_btn.name = "QuickRetryButton"
	quick_retry_btn.text = "TAP TO RETRY"
	quick_retry_btn.flat = false
	quick_retry_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	quick_retry_btn.add_theme_font_size_override("font_size", 36)
	quick_retry_btn.add_theme_color_override("font_color", Color.WHITE)
	quick_retry_btn.pressed.connect(_on_quick_retry_pressed)
	quick_retry_container.add_child(quick_retry_btn)

	# Hint label
	quick_retry_hint = Label.new()
	quick_retry_hint.name = "QuickRetryHint"
	quick_retry_hint.text = "(Respawn at surface, lose 50% cargo)"
	quick_retry_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quick_retry_hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	quick_retry_hint.position = Vector2(0, -40)
	quick_retry_hint.add_theme_font_size_override("font_size", 16)
	quick_retry_hint.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 0.8))
	quick_retry_container.add_child(quick_retry_hint)


func show_death(cause: String, depth: int) -> void:
	## Show the death screen with cause and stats
	## Quick retry button appears immediately, full menu fades in after
	_death_cause = cause
	_death_depth = depth

	# Update cause label
	var cause_text := _format_death_cause(cause)
	death_cause_label.text = "Cause: %s" % cause_text

	# Update stats
	_update_stats_display()

	# Update reload button state
	_update_reload_button()

	# Update dive again button state
	_update_dive_again_button()

	# Pause the game
	get_tree().paused = true

	# Show screen immediately
	visible = true
	background.modulate.a = 0.0
	panel.modulate.a = 0.0

	# Show quick retry immediately (optimized for instant restart)
	if quick_retry_container:
		quick_retry_container.modulate.a = 1.0
		quick_retry_container.visible = true

	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	# Fast fade in: background + quick retry first, then panel
	_fade_tween = create_tween()
	_fade_tween.tween_property(background, "modulate:a", 1.0, FADE_IN_DURATION)
	# Delay the full menu panel slightly to encourage quick retry
	_fade_tween.parallel().tween_property(panel, "modulate:a", 1.0, FADE_IN_DURATION * 2).set_delay(QUICK_RETRY_WINDOW)

	print("[DeathScreen] Showing death screen - Cause: %s, Depth: %d" % [cause, depth])


func hide_death() -> void:
	## Hide the death screen
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	visible = false
	get_tree().paused = false
	print("[DeathScreen] Hidden")


func _format_death_cause(cause: String) -> String:
	## Format the death cause for display
	match cause:
		"fall": return "Fell too far"
		"mining": return "Crushed while mining"
		"suffocation": return "Suffocated underground"
		"lava": return "Burned in lava"
		"cave_in": return "Buried in a cave-in"
		"heat": return "Overwhelmed by extreme heat"
		_: return cause.capitalize()


func _update_stats_display() -> void:
	## Update the stats label
	var lines: Array[String] = []

	# Death depth
	lines.append("Depth at death: %dm" % _death_depth)

	# Max depth reached
	if PlayerData:
		lines.append("Max depth reached: %dm" % PlayerData.max_depth_reached)

	# Inventory value
	var inv_value := _calculate_inventory_value()
	if inv_value > 0:
		lines.append("Inventory value: $%d" % inv_value)
		lines.append("Loss on respawn: $%d" % int(inv_value * 0.5))

	# Death count
	if SaveManager and SaveManager.current_save:
		lines.append("Total deaths: %d" % (SaveManager.current_save.deaths + 1))

	stats_label.text = "\n".join(lines)


func _update_reload_button() -> void:
	## Update reload button state
	if SaveManager == null:
		reload_btn.disabled = true
		reload_btn.text = "Reload Save (no save)"
		return

	var can_reload := SaveManager.current_slot >= 0 and SaveManager.has_save(SaveManager.current_slot)
	reload_btn.disabled = not can_reload

	if can_reload:
		var time_text := SaveManager.get_time_since_save_text()
		reload_btn.text = "Reload Save (%s)" % time_text
	else:
		reload_btn.text = "Reload Save (no save)"


func _calculate_inventory_value() -> int:
	## Calculate total value of inventory items
	if InventoryManager == null:
		return 0

	var total := 0
	for slot in InventoryManager.slots:
		if slot.is_empty() or slot.item == null:
			continue
		total += slot.item.sell_value * slot.quantity

	return total


func _on_respawn_pressed() -> void:
	## Respawn at surface with inventory penalty
	# Apply 50% inventory loss
	_apply_respawn_penalty()

	# Increment death counter
	if SaveManager and SaveManager.current_save:
		SaveManager.current_save.deaths += 1
		SaveManager.save_game()

	hide_death()
	respawn_requested.emit()
	print("[DeathScreen] Respawn requested")


func _apply_respawn_penalty() -> void:
	## Remove 50% of inventory items (by value or by slot)
	if InventoryManager == null:
		return

	var slots_to_clear := InventoryManager.get_used_slots() / 2
	var cleared := 0

	# Remove items from slots, prioritizing lower-value items
	for i in range(InventoryManager.slots.size()):
		if cleared >= slots_to_clear:
			break

		var slot = InventoryManager.slots[i]
		if not slot.is_empty() and slot.item != null:
			# Remove half the quantity or all if quantity is 1
			var remove_qty := maxi(1, slot.quantity / 2)
			InventoryManager.remove_items_at_slot(i, remove_qty)
			cleared += 1

	print("[DeathScreen] Applied respawn penalty: cleared %d slots" % cleared)


func _on_reload_pressed() -> void:
	## Reload the last save
	hide_death()
	reload_requested.emit()
	print("[DeathScreen] Reload requested")


func _update_dive_again_button() -> void:
	## Update the Dive Again button visibility based on player supplies
	if dive_again_btn == null:
		return

	var ladder_count := _get_ladder_count()
	if ladder_count >= MIN_LADDERS_FOR_DIVE:
		dive_again_btn.visible = true
		dive_again_btn.text = "DIVE AGAIN! (%d ladders)" % ladder_count
	else:
		dive_again_btn.visible = false


func _get_ladder_count() -> int:
	## Get the number of ladders in inventory
	if InventoryManager == null:
		return 0

	for slot in InventoryManager.slots:
		if slot.is_empty() or slot.item == null:
			continue
		if slot.item.id == "ladder":
			return slot.quantity

	return 0


func _on_dive_again_pressed() -> void:
	## Quick respawn and dive again - same as respawn but with intention to dive
	# Apply 50% inventory loss
	_apply_respawn_penalty()

	# Increment death counter
	if SaveManager and SaveManager.current_save:
		SaveManager.current_save.deaths += 1
		SaveManager.save_game()

	hide_death()
	dive_again_requested.emit()
	print("[DeathScreen] Dive again requested")


func _on_quick_retry_pressed() -> void:
	## Ultra-fast respawn - optimized for minimum time to playable state
	## This is the "instant restart" path for frustrated players
	# Apply 50% inventory loss (same as regular respawn)
	_apply_respawn_penalty()

	# Increment death counter
	if SaveManager and SaveManager.current_save:
		SaveManager.current_save.deaths += 1
		SaveManager.save_game()

	# Hide immediately (no fade out for speed)
	_quick_hide_death()
	quick_retry_requested.emit()
	print("[DeathScreen] Quick retry - instant respawn requested")


func _quick_hide_death() -> void:
	## Instant hide with no animation - maximum speed for quick retry
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	visible = false
	get_tree().paused = false
