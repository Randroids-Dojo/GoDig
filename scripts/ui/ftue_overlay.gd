extends CanvasLayer
## FTUE (First Time User Experience) Overlay - Progressive Tutorial System
##
## Provides minimal, non-intrusive guidance during the player's first 60 seconds.
## Uses brief toast messages and directional hints - never blocks gameplay.
##
## Key principles (from mobile onboarding research):
## - Teach ONE mechanic at a time
## - Win player's heart in first 60 seconds
## - Start immediately at launch - no splash screens
## - Let players discover, then confirm their discovery
##
## Timeline:
## - 0-5s: "Tap a block to dig" toast + arrow down
## - After first ore: "Your first ore!" toast
## - After 3 ores: "Inventory filling. Return when ready." toast + arrow up
## - At surface with ore: "Sell your ore here" toast + arrow to shop
## - After first sell: "Buy ladders and upgrades!" toast

signal ftue_completed
signal dig_hint_shown
signal ore_found_hint_shown
signal sell_hint_shown
signal toast_shown(message: String)

## FTUE states - expanded for progressive tutorial
enum FTUEState {
	INACTIVE,
	SHOWING_DIG_HINT,      # Initial state - show dig prompt
	WAITING_FOR_ORE,       # Player is digging, waiting for ore
	FIRST_ORE_FOUND,       # Celebrate first ore
	WAITING_FOR_MORE_ORE,  # Continue collecting
	INVENTORY_FILLING,     # Show return hint after 3+ ores
	SHOWING_RETURN_HINT,   # Arrow pointing to surface
	AT_SURFACE_WITH_ORE,   # At surface, show sell hint
	SHOWING_SELL_HINT,     # Arrow pointing to shop
	COMPLETE               # Tutorial done
}
var current_state: FTUEState = FTUEState.INACTIVE

## Track ore count for progressive hints
var _ores_collected: int = 0
const ORES_BEFORE_RETURN_HINT := 3

## Node references - directional arrows
var dig_hint: Control = null
var return_hint: Control = null
var sell_hint: Control = null

## Toast notification node
var toast_container: Control = null
var toast_label: Label = null
var _toast_tween: Tween = null

## Hint timing
const DIG_HINT_DELAY := 0.5  # Show dig hint after 0.5 second (faster start)
const DIG_HINT_DURATION := 8.0  # Hide dig hint after 8 seconds (longer for new players)
const HINT_FADE_DURATION := 0.4
const TOAST_DURATION := 2.5  # How long toasts stay visible
const TOAST_FADE_IN := 0.2
const TOAST_FADE_OUT := 0.3

## Colors
const HINT_COLOR := Color(1.0, 0.9, 0.4, 0.9)  # Warm gold
const TOAST_BG_COLOR := Color(0.1, 0.1, 0.1, 0.85)  # Dark semi-transparent
const TOAST_TEXT_COLOR := Color(1.0, 0.95, 0.8, 1.0)  # Warm white
const ARROW_SIZE := 48


func _ready() -> void:
	# Create UI elements
	_create_toast_ui()
	_create_dig_hint()
	_create_return_hint()
	_create_sell_hint()

	# Start hidden
	_hide_all_hints()
	_hide_toast_immediate()


func _create_toast_ui() -> void:
	## Create the toast notification container
	toast_container = Control.new()
	toast_container.name = "ToastContainer"
	toast_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast_container.position = Vector2(0, 80)  # Below top of screen
	toast_container.modulate.a = 0.0
	add_child(toast_container)

	# Background panel with rounded corners effect
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = TOAST_BG_COLOR
	bg.size = Vector2(280, 50)
	bg.position = Vector2(-140, 0)  # Center horizontally
	toast_container.add_child(bg)

	# Toast text label
	toast_label = Label.new()
	toast_label.name = "ToastLabel"
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 18)
	toast_label.add_theme_color_override("font_color", TOAST_TEXT_COLOR)
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	toast_label.size = Vector2(260, 40)
	toast_label.position = Vector2(-130, 5)
	toast_container.add_child(toast_label)


## Show a brief toast message (non-blocking)
func _show_toast(message: String, duration: float = TOAST_DURATION) -> void:
	if toast_label == null or toast_container == null:
		return

	toast_label.text = message
	toast_shown.emit(message)

	# Cancel any existing toast animation
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()

	# Skip fancy animations if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		toast_container.modulate.a = 1.0
		_toast_tween = create_tween()
		_toast_tween.tween_interval(duration)
		_toast_tween.tween_property(toast_container, "modulate:a", 0.0, TOAST_FADE_OUT)
		return

	# Animated: slide down + fade in, hold, fade out
	toast_container.modulate.a = 0.0
	toast_container.position.y = 60  # Start higher

	_toast_tween = create_tween()
	_toast_tween.set_parallel(true)

	# Fade in and slide down
	_toast_tween.tween_property(toast_container, "modulate:a", 1.0, TOAST_FADE_IN)
	_toast_tween.tween_property(toast_container, "position:y", 80.0, TOAST_FADE_IN) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# Hold then fade out
	_toast_tween = create_tween()
	_toast_tween.tween_property(toast_container, "modulate:a", 1.0, TOAST_FADE_IN)
	_toast_tween.tween_property(toast_container, "position:y", 80.0, TOAST_FADE_IN) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_toast_tween.tween_interval(duration)
	_toast_tween.tween_property(toast_container, "modulate:a", 0.0, TOAST_FADE_OUT)

	print("[FTUE] Toast: %s" % message)


func _hide_toast_immediate() -> void:
	if toast_container:
		toast_container.modulate.a = 0.0


func _create_dig_hint() -> void:
	## Create the "dig down" hint with bouncing arrow
	dig_hint = Control.new()
	dig_hint.name = "DigHint"
	dig_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	dig_hint.position = Vector2(-24, -200)

	# Arrow pointing down
	var arrow := Label.new()
	arrow.text = "v"
	arrow.add_theme_font_size_override("font_size", 64)
	arrow.add_theme_color_override("font_color", HINT_COLOR)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dig_hint.add_child(arrow)

	# Bounce animation
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(dig_hint, "position:y", dig_hint.position.y - 20, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(dig_hint, "position:y", dig_hint.position.y, 0.5).set_trans(Tween.TRANS_SINE)

	add_child(dig_hint)


func _create_return_hint() -> void:
	## Create the "return to surface" hint with arrow pointing up
	return_hint = Control.new()
	return_hint.name = "ReturnHint"
	return_hint.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	return_hint.position = Vector2(-80, 150)

	# Arrow pointing up
	var arrow := Label.new()
	arrow.text = "^"
	arrow.add_theme_font_size_override("font_size", 64)
	arrow.add_theme_color_override("font_color", HINT_COLOR)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return_hint.add_child(arrow)

	# Bounce animation
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(return_hint, "position:y", return_hint.position.y - 15, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(return_hint, "position:y", return_hint.position.y, 0.4).set_trans(Tween.TRANS_SINE)

	add_child(return_hint)


func _create_sell_hint() -> void:
	## Create the "sell at shop" hint with arrow pointing to shop
	sell_hint = Control.new()
	sell_hint.name = "SellHint"
	sell_hint.set_anchors_preset(Control.PRESET_TOP_LEFT)
	sell_hint.position = Vector2(60, 200)

	# Arrow pointing to shop
	var arrow := Label.new()
	arrow.text = "<"
	arrow.add_theme_font_size_override("font_size", 64)
	arrow.add_theme_color_override("font_color", HINT_COLOR)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sell_hint.add_child(arrow)

	# Bounce animation (horizontal)
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(sell_hint, "position:x", sell_hint.position.x - 15, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sell_hint, "position:x", sell_hint.position.x, 0.4).set_trans(Tween.TRANS_SINE)

	add_child(sell_hint)


func _hide_all_hints() -> void:
	if dig_hint:
		dig_hint.visible = false
	if return_hint:
		return_hint.visible = false
	if sell_hint:
		sell_hint.visible = false


## Start the FTUE flow for a new player
func start_ftue() -> void:
	if current_state != FTUEState.INACTIVE:
		return

	print("[FTUE] Starting first-time user experience")
	current_state = FTUEState.SHOWING_DIG_HINT

	# Show dig hint after a brief delay
	await get_tree().create_timer(DIG_HINT_DELAY).timeout
	_show_dig_hint()


func _show_dig_hint() -> void:
	# Show toast message - short and actionable (under 10 words)
	_show_toast("Tap a block to dig", 4.0)

	# Show directional arrow
	if dig_hint:
		dig_hint.visible = true
		dig_hint.modulate = Color(1, 1, 1, 0)
		var tween := create_tween()
		tween.tween_property(dig_hint, "modulate:a", 1.0, HINT_FADE_DURATION)
		dig_hint_shown.emit()
		print("[FTUE] Showing dig hint with toast")

	# Auto-hide after duration (will be hidden earlier if player digs)
	await get_tree().create_timer(DIG_HINT_DURATION).timeout
	if current_state == FTUEState.SHOWING_DIG_HINT:
		_hide_dig_hint()
		current_state = FTUEState.WAITING_FOR_ORE


func _hide_dig_hint() -> void:
	if dig_hint and dig_hint.visible:
		var tween := create_tween()
		tween.tween_property(dig_hint, "modulate:a", 0.0, HINT_FADE_DURATION)
		await tween.finished
		dig_hint.visible = false


## Called when player destroys their first block
func on_first_block_mined() -> void:
	if current_state == FTUEState.SHOWING_DIG_HINT:
		_hide_dig_hint()
		current_state = FTUEState.WAITING_FOR_ORE
		print("[FTUE] First block mined, waiting for ore discovery")


## Called when player finds their first ore
func on_first_ore_found() -> void:
	if current_state == FTUEState.WAITING_FOR_ORE or current_state == FTUEState.SHOWING_DIG_HINT:
		_hide_dig_hint()
		current_state = FTUEState.FIRST_ORE_FOUND
		_ores_collected = 1

		# Celebrate first ore - brief, non-blocking
		_show_toast("Your first ore!", 2.0)
		print("[FTUE] First ore found - celebration toast")

		# Transition to waiting for more ore
		await get_tree().create_timer(1.0).timeout
		if current_state == FTUEState.FIRST_ORE_FOUND:
			current_state = FTUEState.WAITING_FOR_MORE_ORE


## Called when player collects additional ore (after first)
func on_ore_collected() -> void:
	if current_state == FTUEState.WAITING_FOR_MORE_ORE or current_state == FTUEState.FIRST_ORE_FOUND:
		_ores_collected += 1
		print("[FTUE] Ore collected: %d total" % _ores_collected)

		# After collecting enough ore, suggest returning to surface
		if _ores_collected >= ORES_BEFORE_RETURN_HINT and current_state != FTUEState.INVENTORY_FILLING:
			current_state = FTUEState.INVENTORY_FILLING
			_show_inventory_filling_hint()


## Show hint that inventory is filling up
func _show_inventory_filling_hint() -> void:
	# Toast about inventory (under 10 words)
	_show_toast("Inventory filling. Return when ready.", 3.0)

	# Wait a moment then show return arrow
	await get_tree().create_timer(1.5).timeout
	if current_state == FTUEState.INVENTORY_FILLING:
		current_state = FTUEState.SHOWING_RETURN_HINT
		_show_return_hint()


func _show_return_hint() -> void:
	# Show directional arrow pointing up
	if return_hint:
		return_hint.visible = true
		return_hint.modulate = Color(1, 1, 1, 0)
		var tween := create_tween()
		tween.tween_property(return_hint, "modulate:a", 1.0, HINT_FADE_DURATION)
		ore_found_hint_shown.emit()
		print("[FTUE] Showing return to surface hint")


func _hide_return_hint() -> void:
	if return_hint and return_hint.visible:
		var tween := create_tween()
		tween.tween_property(return_hint, "modulate:a", 0.0, HINT_FADE_DURATION)
		await tween.finished
		return_hint.visible = false


## Called when player reaches the surface with ore
func on_reached_surface_with_ore() -> void:
	# Accept this event from multiple states (player might not have triggered return hint)
	if current_state in [FTUEState.SHOWING_RETURN_HINT, FTUEState.INVENTORY_FILLING,
			FTUEState.WAITING_FOR_MORE_ORE, FTUEState.FIRST_ORE_FOUND]:
		_hide_return_hint()
		current_state = FTUEState.AT_SURFACE_WITH_ORE

		# Show toast about selling (under 10 words)
		_show_toast("Sell your ore here", 3.0)

		# Wait a moment then show arrow
		await get_tree().create_timer(0.8).timeout
		if current_state == FTUEState.AT_SURFACE_WITH_ORE:
			current_state = FTUEState.SHOWING_SELL_HINT
			_show_sell_hint()


func _show_sell_hint() -> void:
	# Show directional arrow pointing to shop
	if sell_hint:
		sell_hint.visible = true
		sell_hint.modulate = Color(1, 1, 1, 0)
		var tween := create_tween()
		tween.tween_property(sell_hint, "modulate:a", 1.0, HINT_FADE_DURATION)
		sell_hint_shown.emit()
		print("[FTUE] Showing sell at shop hint")


func _hide_sell_hint() -> void:
	if sell_hint and sell_hint.visible:
		var tween := create_tween()
		tween.tween_property(sell_hint, "modulate:a", 0.0, HINT_FADE_DURATION)
		await tween.finished
		sell_hint.visible = false


## Called when player makes their first sale
func on_first_sale_complete() -> void:
	# Accept from multiple states - player might have skipped some steps
	if current_state != FTUEState.COMPLETE and current_state != FTUEState.INACTIVE:
		_hide_return_hint()
		_hide_sell_hint()

		# Show final toast about what's next (under 10 words)
		_show_toast("Buy ladders and upgrades with coins!", 3.5)

		# Wait for toast, then complete
		await get_tree().create_timer(2.0).timeout
		current_state = FTUEState.COMPLETE
		_complete_ftue()


func _complete_ftue() -> void:
	## FTUE complete! Show brief celebration and mark as done.
	print("[FTUE] First-time experience complete!")

	# Mark as complete in save data
	var save_mgr = _get_save_manager()
	if save_mgr:
		save_mgr.set_ftue_completed()

	# Hide all hints and toast
	_hide_all_hints()
	_hide_toast_immediate()

	ftue_completed.emit()


## Check if FTUE is currently active
func is_active() -> bool:
	return current_state != FTUEState.INACTIVE and current_state != FTUEState.COMPLETE


## Force complete FTUE (for testing or skip scenarios)
func force_complete() -> void:
	_hide_all_hints()
	current_state = FTUEState.COMPLETE
	var save_mgr = _get_save_manager()
	if save_mgr:
		save_mgr.set_ftue_completed()
	print("[FTUE] Force completed")


## Helper to get SaveManager autoload safely
func _get_save_manager():
	if Engine.has_singleton("SaveManager"):
		return Engine.get_singleton("SaveManager")
	return get_node_or_null("/root/SaveManager")
