extends Control
## InventoryPanel - Displays the player's inventory in a grid layout.
##
## Shows all inventory slots with items, supports selection for selling.
## Connects to InventoryManager for real-time updates.

signal slot_selected(slot_index: int)
signal slot_deselected

const InventorySlotScene := preload("res://scenes/ui/inventory_slot.tscn")

@onready var grid: GridContainer = $Panel/VBox/GridContainer
@onready var count_label: Label = $Panel/VBox/Header/SlotCountLabel
@onready var title_label: Label = $Panel/VBox/Header/TitleLabel

var slots: Array = []  # Array of InventorySlot nodes
var selected_slot: int = -1


func _ready() -> void:
	InventoryManager.inventory_changed.connect(_refresh_display)
	_create_slots()
	_refresh_display()


func _create_slots() -> void:
	## Create slot UI elements based on max inventory capacity
	# Clear existing
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
		# Select new slot
		if selected_slot >= 0 and selected_slot < slots.size():
			slots[selected_slot].set_selected(false)

		selected_slot = index
		if selected_slot >= 0 and selected_slot < slots.size():
			slots[selected_slot].set_selected(true)

		slot_selected.emit(index)


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


func refresh() -> void:
	## Force refresh the display
	_refresh_display()
