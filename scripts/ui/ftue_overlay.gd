extends CanvasLayer
## FTUE (First Time User Experience) Overlay
##
## Provides minimal, non-intrusive guidance during the player's first 60 seconds.
## Shows only directional hints - no walls of text, no tutorials, just play.
##
## Timeline:
## - 0-5s: Finger pointing down hint
## - After first ore: Arrow to surface
## - At surface with ore: Arrow to shop

signal ftue_completed
signal dig_hint_shown
signal ore_found_hint_shown
signal sell_hint_shown

## FTUE states
enum FTUEState { INACTIVE, SHOWING_DIG_HINT, WAITING_FOR_ORE, SHOWING_RETURN_HINT, SHOWING_SELL_HINT, COMPLETE }
var current_state: FTUEState = FTUEState.INACTIVE

## Node references
var dig_hint: Control = null
var return_hint: Control = null
var sell_hint: Control = null

## Hint timing
const DIG_HINT_DELAY := 1.0  # Show dig hint after 1 second
const DIG_HINT_DURATION := 5.0  # Hide dig hint after 5 seconds
const HINT_FADE_DURATION := 0.5

## Colors
const HINT_COLOR := Color(1.0, 0.9, 0.4, 0.9)  # Warm gold
const ARROW_SIZE := 48


func _ready() -> void:
	# Create hint elements
	_create_dig_hint()
	_create_return_hint()
	_create_sell_hint()

	# Start hidden
	_hide_all_hints()


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
	if dig_hint:
		dig_hint.visible = true
		dig_hint.modulate = Color(1, 1, 1, 0)
		var tween := create_tween()
		tween.tween_property(dig_hint, "modulate:a", 1.0, HINT_FADE_DURATION)
		dig_hint_shown.emit()
		print("[FTUE] Showing dig hint")

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
		current_state = FTUEState.SHOWING_RETURN_HINT
		_show_return_hint()


func _show_return_hint() -> void:
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
	if current_state == FTUEState.SHOWING_RETURN_HINT:
		_hide_return_hint()
		current_state = FTUEState.SHOWING_SELL_HINT
		_show_sell_hint()


func _show_sell_hint() -> void:
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
	if current_state == FTUEState.SHOWING_SELL_HINT or current_state == FTUEState.SHOWING_RETURN_HINT:
		_hide_return_hint()
		_hide_sell_hint()
		current_state = FTUEState.COMPLETE
		_complete_ftue()


func _complete_ftue() -> void:
	## FTUE complete! Show brief celebration and mark as done.
	print("[FTUE] First-time experience complete!")

	# Mark as complete in save data
	var save_mgr = _get_save_manager()
	if save_mgr:
		save_mgr.set_ftue_completed()

	# Hide all hints
	_hide_all_hints()

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
