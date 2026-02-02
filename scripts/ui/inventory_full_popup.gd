extends CanvasLayer
## InventoryFullPopup - Decision moment when inventory is full.
##
## Creates a meaningful decision moment when player tries to collect
## ore with a full inventory. Options: drop item, return to surface,
## or keep mining (ore stays in block).
##
## Research: Inventory limits force decisions - 'Is it worth the risk to
## grab that rare loot or head back to camp and unload?' This IS the
## push-your-luck moment in our game.

signal item_dropped(item: Resource, slot_index: int)  ## Player chose to drop an item
signal return_to_surface_requested  ## Player wants to return to surface
signal keep_mining_requested  ## Player dismisses popup, ore stays in world
signal popup_closed  ## Popup was closed (any reason)

const InventorySlotScene := preload("res://scenes/ui/inventory_slot.tscn")

## Minimum ladders for safe warning
const LADDER_WARNING_THRESHOLD := 3
## Deep depth threshold for extra warning
const DEEP_DEPTH_THRESHOLD := 50

## UI Elements (created programmatically)
var background: ColorRect = null
var panel: PanelContainer = null
var title_label: Label = null
var ore_info_label: Label = null
var warning_container: Control = null
var warning_label: Label = null
var quick_drop_container: ScrollContainer = null
var quick_drop_grid: GridContainer = null
var action_container: HBoxContainer = null
var drop_btn: Button = null
var return_btn: Button = null
var keep_mining_btn: Button = null
var drop_suggestion_label: Label = null

## The ore that couldn't be picked up
var _pending_ore: Resource = null
var _pending_amount: int = 1

## Inventory slot references for quick drop
var _slot_buttons: Array = []
var _selected_slot: int = -1

## Animation
var _fade_tween: Tween = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_ui()
	visible = false
	print("[InventoryFullPopup] Ready")


func _create_ui() -> void:
	## Create all UI elements programmatically

	# Background overlay (semi-transparent, tap dismisses)
	background = ColorRect.new()
	background.name = "Background"
	background.color = Color(0.0, 0.0, 0.0, 0.7)
	background.anchors_preset = Control.PRESET_FULL_RECT
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.gui_input.connect(_on_background_input)
	# CRITICAL: Disable input when hidden (for web builds)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	# Main panel
	panel = PanelContainer.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(320, 0)  # Min width, auto-height
	add_child(panel)

	# Panel styling
	var style := StyleBoxFlat.new()
	style.bg_color = UIColors.PANEL_DARK
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.border_color = UIColors.WARNING_ORANGE
	panel.add_theme_stylebox_override("panel", style)

	# Content margin
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	# Main vertical layout
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Title
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "INVENTORY FULL"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", UIColors.WARNING_ORANGE)
	UIColors.apply_outline(title_label)
	vbox.add_child(title_label)

	# Ore info (what we're trying to collect)
	ore_info_label = Label.new()
	ore_info_label.name = "OreInfoLabel"
	ore_info_label.text = "Can't pick up: Coal"
	ore_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ore_info_label.add_theme_font_size_override("font_size", 16)
	ore_info_label.add_theme_color_override("font_color", UIColors.TEXT_LIGHT)
	vbox.add_child(ore_info_label)

	# Separator
	var sep1 := HSeparator.new()
	vbox.add_child(sep1)

	# Warning container (shown for deep dives with low ladders)
	warning_container = Control.new()
	warning_container.name = "WarningContainer"
	warning_container.custom_minimum_size = Vector2(0, 0)
	warning_container.visible = false
	vbox.add_child(warning_container)

	var warning_bg := ColorRect.new()
	warning_bg.color = UIColors.WARNING_BG_RED
	warning_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	warning_container.add_child(warning_bg)

	var warning_margin := MarginContainer.new()
	warning_margin.add_theme_constant_override("margin_left", 8)
	warning_margin.add_theme_constant_override("margin_right", 8)
	warning_margin.add_theme_constant_override("margin_top", 6)
	warning_margin.add_theme_constant_override("margin_bottom", 6)
	warning_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	warning_container.add_child(warning_margin)

	warning_label = Label.new()
	warning_label.name = "WarningLabel"
	warning_label.text = "Low ladders! Consider returning."
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.add_theme_font_size_override("font_size", 14)
	warning_label.add_theme_color_override("font_color", UIColors.WARNING_RED)
	warning_margin.add_child(warning_label)

	# Quick drop section header
	var drop_header := Label.new()
	drop_header.text = "Drop an item to make room:"
	drop_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	drop_header.add_theme_font_size_override("font_size", 14)
	drop_header.add_theme_color_override("font_color", UIColors.TEXT_MEDIUM)
	vbox.add_child(drop_header)

	# Drop suggestion (auto-select lowest value)
	drop_suggestion_label = Label.new()
	drop_suggestion_label.name = "DropSuggestionLabel"
	drop_suggestion_label.text = "(Suggested: Coal - lowest value)"
	drop_suggestion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	drop_suggestion_label.add_theme_font_size_override("font_size", 12)
	drop_suggestion_label.add_theme_color_override("font_color", UIColors.TEXT_DIM)
	vbox.add_child(drop_suggestion_label)

	# Quick drop grid (scrollable inventory view)
	quick_drop_container = ScrollContainer.new()
	quick_drop_container.name = "QuickDropContainer"
	quick_drop_container.custom_minimum_size = Vector2(0, 140)  # 2 rows of items
	quick_drop_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(quick_drop_container)

	quick_drop_grid = GridContainer.new()
	quick_drop_grid.name = "QuickDropGrid"
	quick_drop_grid.columns = 4
	quick_drop_grid.add_theme_constant_override("h_separation", 8)
	quick_drop_grid.add_theme_constant_override("v_separation", 8)
	quick_drop_container.add_child(quick_drop_grid)

	# Separator
	var sep2 := HSeparator.new()
	vbox.add_child(sep2)

	# Action buttons
	action_container = HBoxContainer.new()
	action_container.name = "ActionContainer"
	action_container.alignment = BoxContainer.ALIGNMENT_CENTER
	action_container.add_theme_constant_override("separation", 8)
	vbox.add_child(action_container)

	# Drop button (primary action when slot selected)
	drop_btn = Button.new()
	drop_btn.name = "DropButton"
	drop_btn.text = "Drop Selected"
	drop_btn.custom_minimum_size = Vector2(95, 44)
	drop_btn.add_theme_font_size_override("font_size", 14)
	drop_btn.pressed.connect(_on_drop_pressed)
	drop_btn.disabled = true  # Enabled when slot selected
	action_container.add_child(drop_btn)

	# Return to surface button
	return_btn = Button.new()
	return_btn.name = "ReturnButton"
	return_btn.text = "Return"
	return_btn.custom_minimum_size = Vector2(80, 44)
	return_btn.add_theme_font_size_override("font_size", 14)
	return_btn.pressed.connect(_on_return_pressed)
	action_container.add_child(return_btn)

	# Keep mining button (dismiss)
	keep_mining_btn = Button.new()
	keep_mining_btn.name = "KeepMiningButton"
	keep_mining_btn.text = "Keep Mining"
	keep_mining_btn.custom_minimum_size = Vector2(95, 44)
	keep_mining_btn.add_theme_font_size_override("font_size", 14)
	keep_mining_btn.add_theme_color_override("font_color", UIColors.TEXT_DIM)
	keep_mining_btn.pressed.connect(_on_keep_mining_pressed)
	action_container.add_child(keep_mining_btn)


func show_popup(pending_ore: Resource, pending_amount: int = 1) -> void:
	## Show the popup with the ore that couldn't be picked up.
	## pending_ore: The ItemData of the ore that was mined
	## pending_amount: How many were trying to be picked up
	_pending_ore = pending_ore
	_pending_amount = pending_amount

	# Update ore info display
	if pending_ore != null:
		var rarity_text := ""
		if "rarity" in pending_ore and pending_ore.rarity != "common":
			rarity_text = " (%s)" % pending_ore.rarity.capitalize()
		ore_info_label.text = "Can't pick up: %s%s" % [pending_ore.display_name, rarity_text]
		ore_info_label.add_theme_color_override("font_color", _get_rarity_color(pending_ore))
	else:
		ore_info_label.text = "Inventory is full!"

	# Update warning display based on depth and ladders
	_update_warning_display()

	# Populate quick drop grid with inventory items
	_populate_quick_drop()

	# Pause the game
	get_tree().paused = true

	# Enable background input
	background.mouse_filter = Control.MOUSE_FILTER_STOP

	# Show with fade
	visible = true
	background.modulate.a = 0.0
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.9, 0.9)

	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	_fade_tween.tween_property(background, "modulate:a", 1.0, 0.15)
	_fade_tween.tween_property(panel, "modulate:a", 1.0, 0.15)
	_fade_tween.tween_property(panel, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Position panel after frame so size is calculated
	await get_tree().process_frame
	_center_panel()

	print("[InventoryFullPopup] Showing popup for: %s" % (pending_ore.display_name if pending_ore else "none"))


func hide_popup() -> void:
	## Hide the popup
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	# Disable background input before hiding
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	visible = false
	get_tree().paused = false
	_selected_slot = -1
	popup_closed.emit()
	print("[InventoryFullPopup] Hidden")


func _center_panel() -> void:
	## Center the panel on screen
	var viewport_size := get_viewport().get_visible_rect().size
	var panel_size := panel.size
	panel.position = Vector2(
		(viewport_size.x - panel_size.x) / 2.0,
		(viewport_size.y - panel_size.y) / 2.0
	)


func _update_warning_display() -> void:
	## Update warning based on depth and ladder count
	var depth := 0
	if GameManager != null:
		depth = GameManager.current_depth

	var ladder_count := _get_ladder_count()

	# Show warning if deep and low on ladders
	var should_warn := depth >= DEEP_DEPTH_THRESHOLD and ladder_count < LADDER_WARNING_THRESHOLD
	warning_container.visible = should_warn

	if should_warn:
		warning_label.text = "Depth: %dm | Ladders: %d\nConsider returning to safety!" % [depth, ladder_count]
		# Adjust warning container size to fit content
		warning_container.custom_minimum_size = Vector2(0, 50)
		# Color return button orange for emphasis
		return_btn.add_theme_color_override("font_color", UIColors.WARNING_ORANGE)
	else:
		warning_container.custom_minimum_size = Vector2(0, 0)
		return_btn.remove_theme_color_override("font_color")

	# Update return button text with depth info
	if depth > 0:
		return_btn.text = "Return (%dm)" % depth
	else:
		return_btn.text = "Return"


func _populate_quick_drop() -> void:
	## Populate the quick drop grid with inventory items sorted by value
	# Clear existing slots
	for child in quick_drop_grid.get_children():
		child.queue_free()
	_slot_buttons.clear()
	_selected_slot = -1
	drop_btn.disabled = true

	# Get occupied slots sorted by value (lowest first)
	var sorted_slots: Array = []
	for i in range(InventoryManager.slots.size()):
		var slot = InventoryManager.slots[i]
		if not slot.is_empty() and slot.item != null:
			sorted_slots.append({
				"index": i,
				"item": slot.item,
				"quantity": slot.quantity,
				"value": slot.item.sell_value
			})

	# Sort by value (lowest first for easy dropping)
	sorted_slots.sort_custom(func(a, b): return a.value < b.value)

	# Update drop suggestion
	if sorted_slots.size() > 0:
		var lowest: Dictionary = sorted_slots[0]
		drop_suggestion_label.text = "(Suggested: %s - $%d)" % [lowest.item.display_name, lowest.value]
		drop_suggestion_label.visible = true
	else:
		drop_suggestion_label.visible = false

	# Create slot buttons
	for slot_data: Dictionary in sorted_slots:
		var slot_btn: Button = _create_slot_button(slot_data)
		quick_drop_grid.add_child(slot_btn)
		_slot_buttons.append(slot_btn)

	# Auto-select the lowest value item
	if _slot_buttons.size() > 0:
		_select_slot(0)


func _create_slot_button(slot_data: Dictionary) -> Button:
	## Create a button for a slot item
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(64, 64)
	btn.tooltip_text = "%s x%d ($%d ea)" % [slot_data.item.display_name, slot_data.quantity, slot_data.value]

	# Store slot index in metadata
	btn.set_meta("slot_index", slot_data.index)
	btn.set_meta("item", slot_data.item)
	btn.set_meta("quantity", slot_data.quantity)
	btn.set_meta("value", slot_data.value)

	# Button styling
	var style := StyleBoxFlat.new()
	style.bg_color = UIColors.PANEL_MEDIUM
	style.set_corner_radius_all(4)
	style.set_border_width_all(1)
	style.border_color = _get_rarity_border_color(slot_data.item)
	btn.add_theme_stylebox_override("normal", style)

	# Hover/pressed styles
	var hover_style := style.duplicate()
	hover_style.bg_color = UIColors.PANEL_LIGHT
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := style.duplicate()
	pressed_style.bg_color = UIColors.GOLD_DIM
	pressed_style.border_color = UIColors.GOLD
	btn.add_theme_stylebox_override("pressed", pressed_style)

	# Content layout
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn.add_child(vbox)

	# Item name (abbreviated)
	var name_label := Label.new()
	var display_name: String = slot_data.item.display_name
	if display_name.length() > 6:
		display_name = display_name.substr(0, 5) + "."
	name_label.text = display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", _get_rarity_color(slot_data.item))
	vbox.add_child(name_label)

	# Quantity
	var qty_label := Label.new()
	qty_label.text = "x%d" % slot_data.quantity
	qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qty_label.add_theme_font_size_override("font_size", 10)
	qty_label.add_theme_color_override("font_color", UIColors.TEXT_MEDIUM)
	vbox.add_child(qty_label)

	# Value
	var value_label := Label.new()
	value_label.text = "$%d" % slot_data.value
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 10)
	value_label.add_theme_color_override("font_color", UIColors.GOLD_DIM)
	vbox.add_child(value_label)

	# Connect press
	btn.pressed.connect(_on_slot_button_pressed.bind(btn))

	return btn


func _select_slot(button_index: int) -> void:
	## Select a slot button for dropping
	if button_index < 0 or button_index >= _slot_buttons.size():
		return

	# Deselect previous
	if _selected_slot >= 0 and _selected_slot < _slot_buttons.size():
		var prev_btn: Button = _slot_buttons[_selected_slot]
		prev_btn.button_pressed = false

	_selected_slot = button_index
	var btn: Button = _slot_buttons[button_index]
	btn.button_pressed = true

	# Update drop button
	var item = btn.get_meta("item")
	drop_btn.text = "Drop %s" % item.display_name.substr(0, 8)
	drop_btn.disabled = false


func _on_slot_button_pressed(btn: Button) -> void:
	## Handle slot button press - select for dropping
	var idx := _slot_buttons.find(btn)
	if idx >= 0:
		_select_slot(idx)


func _on_drop_pressed() -> void:
	## Drop the selected item
	if _selected_slot < 0 or _selected_slot >= _slot_buttons.size():
		return

	var btn: Button = _slot_buttons[_selected_slot]
	var slot_index: int = btn.get_meta("slot_index")
	var item = btn.get_meta("item")

	# Remove 1 item from inventory
	var removed := InventoryManager.remove_items_at_slot(slot_index, 1)
	if removed > 0:
		print("[InventoryFullPopup] Dropped 1 x %s from slot %d" % [item.display_name, slot_index])
		item_dropped.emit(item, slot_index)

		# Now try to add the pending ore
		if _pending_ore != null:
			var leftover := InventoryManager.add_item(_pending_ore, _pending_amount)
			if leftover == 0:
				print("[InventoryFullPopup] Successfully picked up %s after drop" % _pending_ore.display_name)

	hide_popup()


func _on_return_pressed() -> void:
	## Player wants to return to surface
	print("[InventoryFullPopup] Return to surface requested")
	return_to_surface_requested.emit()
	hide_popup()


func _on_keep_mining_pressed() -> void:
	## Player dismisses popup - ore stays in world (actually gone, but semantically "not collected")
	print("[InventoryFullPopup] Keep mining - ore not collected")
	keep_mining_requested.emit()
	hide_popup()


func _on_background_input(event: InputEvent) -> void:
	## Handle taps on background - dismiss popup
	if event is InputEventMouseButton and event.pressed:
		_on_keep_mining_pressed()
	elif event is InputEventScreenTouch and event.pressed:
		_on_keep_mining_pressed()


func _get_ladder_count() -> int:
	## Get ladder count from inventory
	if InventoryManager == null:
		return 0
	return InventoryManager.get_item_count_by_id("ladder")


func _get_rarity_color(item) -> Color:
	## Get display color based on item rarity
	if item == null or not "rarity" in item:
		return UIColors.TEXT_WHITE

	match item.rarity:
		"common":
			return Color(0.9, 0.9, 0.9)
		"uncommon":
			return Color(0.3, 0.9, 0.3)
		"rare":
			return Color(0.4, 0.7, 1.0)
		"epic":
			return Color(0.8, 0.4, 1.0)
		"legendary":
			return Color(1.0, 0.7, 0.2)
		_:
			return UIColors.TEXT_WHITE


func _get_rarity_border_color(item) -> Color:
	## Get border color based on item rarity (dimmer than text color)
	if item == null or not "rarity" in item:
		return UIColors.PANEL_LIGHT

	match item.rarity:
		"common":
			return Color(0.4, 0.4, 0.4)
		"uncommon":
			return Color(0.2, 0.5, 0.2)
		"rare":
			return Color(0.2, 0.4, 0.6)
		"epic":
			return Color(0.4, 0.2, 0.5)
		"legendary":
			return Color(0.5, 0.35, 0.1)
		_:
			return UIColors.PANEL_LIGHT
