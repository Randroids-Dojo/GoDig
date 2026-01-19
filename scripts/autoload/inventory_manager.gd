extends Node
## InventoryManager - Singleton managing player inventory state.
##
## Handles slot-based storage with stacking. Limited capacity forces
## return trips to the surface (core game loop tension).

const ItemData = preload("res://resources/items/item_data.gd")

## Emitted when inventory contents change
signal inventory_changed

## Emitted when inventory is full and items cannot be added
signal inventory_full

## Emitted when a specific item is added (for floating text feedback)
signal item_added(item: ItemData, amount: int)


## Inner class representing a single inventory slot
class InventorySlot:
	var item: ItemData = null
	var quantity: int = 0

	func clear() -> void:
		item = null
		quantity = 0

	func is_empty() -> bool:
		return item == null or quantity <= 0

	func has_space() -> bool:
		if item == null:
			return true
		return quantity < item.max_stack

	func space_remaining() -> int:
		if item == null:
			return 0  # Empty slot has unlimited space for any item
		return item.max_stack - quantity


## Current inventory slots
var slots: Array = []

## Maximum number of slots (upgradeable from 8 to 30)
var max_slots: int = 8


func _ready() -> void:
	_initialize_slots()
	print("[InventoryManager] Ready with %d slots" % max_slots)


func _initialize_slots() -> void:
	slots.clear()
	for i in range(max_slots):
		slots.append(InventorySlot.new())


## Add item(s) to inventory. Returns the amount that couldn't fit.
func add_item(item: ItemData, amount: int = 1) -> int:
	if item == null or amount <= 0:
		return amount

	var remaining := amount

	# First pass: Try to stack with existing slots of same item
	for slot in slots:
		if slot.item != null and slot.item.id == item.id:
			var space: int = slot.space_remaining()
			var to_add: int = mini(space, remaining)
			if to_add > 0:
				slot.quantity += to_add
				remaining -= to_add
				if remaining <= 0:
					break

	# Second pass: Use empty slots
	if remaining > 0:
		for slot in slots:
			if slot.is_empty():
				slot.item = item
				var to_add: int = mini(item.max_stack, remaining)
				slot.quantity = to_add
				remaining -= to_add
				if remaining <= 0:
					break

	# Calculate how much was actually added
	var added := amount - remaining
	if added > 0:
		item_added.emit(item, added)
		inventory_changed.emit()

	# If we couldn't fit everything, signal inventory full
	if remaining > 0:
		inventory_full.emit()

	return remaining


## Remove item(s) from inventory. Returns true if successful.
func remove_item(item: ItemData, amount: int = 1) -> bool:
	if item == null or amount <= 0:
		return false

	if get_item_count(item) < amount:
		return false

	var remaining := amount

	# Remove from slots (last in, first out)
	for i in range(slots.size() - 1, -1, -1):
		var slot = slots[i]
		if slot.item != null and slot.item.id == item.id:
			var to_remove := mini(slot.quantity, remaining)
			slot.quantity -= to_remove
			remaining -= to_remove

			# Clear slot if empty
			if slot.quantity <= 0:
				slot.clear()

			if remaining <= 0:
				break

	inventory_changed.emit()
	return true


## Get total count of a specific item across all slots
func get_item_count(item: ItemData) -> int:
	if item == null:
		return 0

	var total := 0
	for slot in slots:
		if slot.item != null and slot.item.id == item.id:
			total += slot.quantity
	return total


## Check if inventory has space for at least one item
func has_space() -> bool:
	for slot in slots:
		if slot.is_empty() or slot.has_space():
			return true
	return false


## Get number of used slots
func get_used_slots() -> int:
	var count := 0
	for slot in slots:
		if not slot.is_empty():
			count += 1
	return count


## Get total number of slots
func get_total_slots() -> int:
	return max_slots


## Upgrade inventory capacity
func upgrade_capacity(new_max: int) -> void:
	if new_max <= max_slots:
		return

	var slots_to_add := new_max - max_slots
	for i in range(slots_to_add):
		slots.append(InventorySlot.new())

	max_slots = new_max
	inventory_changed.emit()
	print("[InventoryManager] Upgraded to %d slots" % max_slots)


## Clear all inventory slots
func clear_all() -> void:
	for slot in slots:
		slot.clear()
	inventory_changed.emit()


## Remove all instances of a specific item from inventory
func remove_all_of_item(item: ItemData) -> int:
	if item == null:
		return 0

	var total_removed := 0
	for slot in slots:
		if slot.item != null and slot.item.id == item.id:
			total_removed += slot.quantity
			slot.clear()

	if total_removed > 0:
		inventory_changed.emit()

	return total_removed


## Get all non-empty slots (for UI display or saving)
func get_occupied_slots() -> Array:
	var occupied := []
	for i in range(slots.size()):
		if not slots[i].is_empty():
			occupied.append({
				"slot_index": i,
				"item": slots[i].item,
				"quantity": slots[i].quantity
			})
	return occupied


## Serialize inventory for saving
func to_dict() -> Dictionary:
	var data := {
		"max_slots": max_slots,
		"slots": []
	}

	for slot in slots:
		if slot.is_empty():
			data.slots.append(null)
		else:
			data.slots.append({
				"item_id": slot.item.id,
				"quantity": slot.quantity
			})

	return data


## Deserialize inventory from save data
func from_dict(data: Dictionary, item_registry: Dictionary) -> void:
	max_slots = data.get("max_slots", 8)
	_initialize_slots()

	var slot_data = data.get("slots", [])
	for i in range(mini(slot_data.size(), max_slots)):
		var sdata = slot_data[i]
		if sdata != null and sdata is Dictionary:
			var item_id = sdata.get("item_id", "")
			if item_registry.has(item_id):
				slots[i].item = item_registry[item_id]
				slots[i].quantity = sdata.get("quantity", 0)

	inventory_changed.emit()
