extends Control
## InventoryPanel - Full-featured inventory management UI.
##
## Shows all inventory slots with items, supports selection for:
## - Using consumables (ladders, ropes, teleport scrolls)
## - Dropping items
## - Viewing item details
## Connects to InventoryManager for real-time updates.

signal slot_selected(slot_index: int)
signal slot_deselected
signal item_used(item: Resource, slot_index: int)  ## Emitted when player uses an item
signal item_dropped(item: Resource, quantity: int, slot_index: int)  ## Emitted when player drops items
signal closed  ## Emitted when panel is closed

const InventorySlotScene := preload("res://scenes/ui/inventory_slot.tscn")

@onready var grid: GridContainer = $Panel/VBox/ScrollContainer/GridContainer
@onready var count_label: Label = $Panel/VBox/Header/SlotCountLabel
@onready var title_label: Label = $Panel/VBox/Header/TitleLabel
@onready var close_button: Button = $Panel/VBox/Header/CloseButton
@onready var action_container: HBoxContainer = $Panel/VBox/ActionContainer
@onready var use_button: Button = $Panel/VBox/ActionContainer/UseButton
@onready var drop_button: Button = $Panel/VBox/ActionContainer/DropButton
@onready var info_panel: PanelContainer = $Panel/VBox/InfoPanel
@onready var info_name_label: Label = $Panel/VBox/InfoPanel/VBox/ItemNameLabel
@onready var info_desc_label: Label = $Panel/VBox/InfoPanel/VBox/DescriptionLabel
@onready var info_value_label: Label = $Panel/VBox/InfoPanel/VBox/ValueLabel

var slots: Array = []  # Array of InventorySlot nodes
var selected_slot: int = -1


func _ready() -> void:
	InventoryManager.inventory_changed.connect(_refresh_display)

	# Connect close button
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

	# Connect action buttons
	if use_button:
		use_button.pressed.connect(_on_use_pressed)
	if drop_button:
		drop_button.pressed.connect(_on_drop_pressed)

	_create_slots()
	_refresh_display()
	_update_action_buttons()


func _create_slots() -> void:
	## Create slot UI elements based on max inventory capacity
	# Clear existing
	if grid == null:
		return
	for child in grid.get_children():
		child.queue_free()
	slots.clear()

	# Create slots based on max capacity
	for i in range(InventoryManager.max_slots):
		var slot = InventorySlotScene.instantiate()
		slot.slot_index = i
		slot.slot_pressed.connect(_on_slot_pressed)
		grid.add_child(slot)
		slots.append(slot)


func _refresh_display() -> void:
	## Update all slot displays from inventory data
	# Ensure we have the right number of slots
	if slots.size() != InventoryManager.max_slots:
		_create_slots()

	for i in range(slots.size()):
		if i < InventoryManager.slots.size():
			var slot_data = InventoryManager.slots[i]
			if slot_data and not slot_data.is_empty():
				slots[i].display_item(slot_data.item, slot_data.quantity)
			else:
				slots[i].display_empty()
		else:
			slots[i].display_empty()

	# Update count label
	_update_count_label()


func _update_count_label() -> void:
	## Update the slot count display
	var used := InventoryManager.get_used_slots()
	var total := InventoryManager.get_total_slots()

	if count_label:
		count_label.text = "%d/%d" % [used, total]

		# Change color when nearly full
		if used >= total - 1:
			count_label.add_theme_color_override("font_color", Color.RED)
		elif used >= total - 2:
			count_label.add_theme_color_override("font_color", Color.ORANGE)
		else:
			count_label.remove_theme_color_override("font_color")


func _on_slot_pressed(index: int) -> void:
	## Handle slot tap - toggle selection
	if selected_slot == index:
		# Deselect
		if selected_slot >= 0 and selected_slot < slots.size():
			slots[selected_slot].set_selected(false)
		selected_slot = -1
		slot_deselected.emit()
	else:
		# Select new slot (only if slot has an item)
		var slot_data = InventoryManager.slots[index] if index < InventoryManager.slots.size() else null
		if slot_data == null or slot_data.is_empty():
			# Clicking empty slot deselects current selection
			if selected_slot >= 0 and selected_slot < slots.size():
				slots[selected_slot].set_selected(false)
			selected_slot = -1
			slot_deselected.emit()
		else:
			# Deselect previous
			if selected_slot >= 0 and selected_slot < slots.size():
				slots[selected_slot].set_selected(false)

			selected_slot = index
			if selected_slot >= 0 and selected_slot < slots.size():
				slots[selected_slot].set_selected(true)

			slot_selected.emit(index)

	# Update action buttons and info panel
	_update_action_buttons()
	_update_info_panel()


func get_selected_item():
	## Get the ItemData of the currently selected slot
	if selected_slot < 0 or selected_slot >= InventoryManager.slots.size():
		return null

	var slot_data = InventoryManager.slots[selected_slot]
	if slot_data and not slot_data.is_empty():
		return slot_data.item
	return null


func get_selected_quantity() -> int:
	## Get the quantity of items in the selected slot
	if selected_slot < 0 or selected_slot >= InventoryManager.slots.size():
		return 0

	var slot_data = InventoryManager.slots[selected_slot]
	if slot_data and not slot_data.is_empty():
		return slot_data.quantity
	return 0


func clear_selection() -> void:
	## Clear any current selection
	if selected_slot >= 0 and selected_slot < slots.size():
		slots[selected_slot].set_selected(false)
	selected_slot = -1
	slot_deselected.emit()
	_update_action_buttons()
	_update_info_panel()


func refresh() -> void:
	## Force refresh the display
	_refresh_display()


func open() -> void:
	## Show the inventory panel
	visible = true
	clear_selection()
	_refresh_display()


func close() -> void:
	## Hide the inventory panel
	visible = false
	clear_selection()
	closed.emit()


func _on_close_pressed() -> void:
	## Handle close button press
	close()


func _update_action_buttons() -> void:
	## Update action button states based on selected item
	if action_container == null:
		return

	var item = get_selected_item()
	var has_selection := item != null

	# Show/hide action container based on selection
	action_container.visible = has_selection

	if not has_selection:
		return

	# Update Use button based on item type
	if use_button:
		var can_use := _is_usable_item(item)
		use_button.visible = can_use
		if can_use:
			use_button.text = _get_use_button_text(item)

	# Drop button always available for selected items
	if drop_button:
		drop_button.visible = true


func _update_info_panel() -> void:
	## Update the item info panel based on selection
	if info_panel == null:
		return

	var item = get_selected_item()
	if item == null:
		info_panel.visible = false
		return

	info_panel.visible = true

	# Update item name with rarity color
	if info_name_label:
		info_name_label.text = item.display_name
		var rarity_color := _get_rarity_display_color(item)
		info_name_label.add_theme_color_override("font_color", rarity_color)

	# Update description
	if info_desc_label:
		if item.description != null and not item.description.is_empty():
			info_desc_label.text = item.description
			info_desc_label.visible = true
		else:
			info_desc_label.visible = false

	# Update sell value
	if info_value_label:
		if item.category in ["ore", "gem"]:
			info_value_label.text = "Sell Value: $%d" % item.sell_value
			info_value_label.visible = true
		else:
			info_value_label.visible = false


func _is_usable_item(item) -> bool:
	## Check if an item can be used from inventory
	if item == null:
		return false
	# Consumables can be used
	if item.category == "consumable":
		return true
	# Specific items that can be used
	if item.id in ["ladder", "rope", "teleport_scroll", "torch"]:
		return true
	return false


func _get_use_button_text(item) -> String:
	## Get the text for the Use button based on item type
	if item == null:
		return "Use"
	match item.id:
		"ladder":
			return "Place Ladder"
		"rope":
			return "Place Rope"
		"teleport_scroll":
			return "Teleport"
		"torch":
			return "Place Torch"
		_:
			return "Use"


func _on_use_pressed() -> void:
	## Handle Use button press
	var item = get_selected_item()
	if item == null:
		return

	if not _is_usable_item(item):
		return

	# Emit signal for test_level to handle the actual use action
	item_used.emit(item, selected_slot)

	# For most items, close the inventory after use
	# The actual removal from inventory is handled by the signal receiver
	close()


func _on_drop_pressed() -> void:
	## Handle Drop button press - opens drop quantity dialog for stacks
	var item = get_selected_item()
	var quantity := get_selected_quantity()
	if item == null or quantity <= 0:
		return

	if quantity == 1:
		# Single item - just drop it
		_do_drop(1)
	else:
		# Multiple items - show drop confirmation with quantity
		# For simplicity, drop all for now (could add quantity picker later)
		_show_drop_confirmation(item, quantity)


func _show_drop_confirmation(item, quantity: int) -> void:
	## Show confirmation dialog for dropping multiple items
	# Create simple confirmation overlay
	var overlay := CanvasLayer.new()
	overlay.name = "DropConfirmation"
	overlay.layer = 100

	# Background
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.5)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			overlay.queue_free()
		elif event is InputEventScreenTouch and event.pressed:
			overlay.queue_free()
	)
	overlay.add_child(bg)

	# Panel
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(280, 0)
	overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "Drop Items?"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	# Info
	var info := Label.new()
	info.text = "Drop %d x %s?" % [quantity, item.display_name]
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(info)

	# Buttons
	var btn_container := HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_container.add_theme_constant_override("separation", 12)
	vbox.add_child(btn_container)

	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.custom_minimum_size = Vector2(100, 40)
	cancel_btn.pressed.connect(func(): overlay.queue_free())
	btn_container.add_child(cancel_btn)

	var drop_one_btn := Button.new()
	drop_one_btn.text = "Drop 1"
	drop_one_btn.custom_minimum_size = Vector2(100, 40)
	drop_one_btn.pressed.connect(func():
		overlay.queue_free()
		_do_drop(1)
	)
	btn_container.add_child(drop_one_btn)

	var drop_all_btn := Button.new()
	drop_all_btn.text = "Drop All"
	drop_all_btn.custom_minimum_size = Vector2(100, 40)
	drop_all_btn.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	drop_all_btn.pressed.connect(func():
		overlay.queue_free()
		_do_drop(quantity)
	)
	btn_container.add_child(drop_all_btn)

	# Add to tree
	add_child(overlay)

	# Position panel at center after frame
	await get_tree().process_frame
	var viewport_size := get_viewport().get_visible_rect().size
	var panel_size := panel.size
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(
		(viewport_size.x - panel_size.x) / 2.0,
		(viewport_size.y - panel_size.y) / 2.0
	)


func _do_drop(quantity: int) -> void:
	## Actually drop items from the selected slot
	var item = get_selected_item()
	if item == null:
		return

	var actual_qty := mini(quantity, get_selected_quantity())
	if actual_qty <= 0:
		return

	# Remove from inventory
	var removed := InventoryManager.remove_items_at_slot(selected_slot, actual_qty)
	if removed > 0:
		item_dropped.emit(item, removed, selected_slot)
		print("[InventoryPanel] Dropped %d x %s" % [removed, item.display_name])

	# Refresh display and clear selection if slot is now empty
	_refresh_display()
	if selected_slot >= 0 and selected_slot < InventoryManager.slots.size():
		var slot_data = InventoryManager.slots[selected_slot]
		if slot_data == null or slot_data.is_empty():
			clear_selection()


func _get_rarity_display_color(item) -> Color:
	## Get display color based on item rarity
	if item == null or not "rarity" in item:
		return Color.WHITE

	match item.rarity:
		"common":
			return Color(0.8, 0.8, 0.8)
		"uncommon":
			return Color(0.3, 0.9, 0.3)
		"rare":
			return Color(0.3, 0.6, 1.0)
		"epic":
			return Color(0.8, 0.4, 1.0)
		"legendary":
			return Color(1.0, 0.7, 0.2)
		_:
			return Color.WHITE
