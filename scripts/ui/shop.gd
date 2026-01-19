extends Control
## Shop UI for selling resources and buying upgrades.
##
## Displays inventory items for sale and tool upgrades for purchase.
## Uses GameManager for coin transactions and InventoryManager for items.

signal closed

@onready var coins_label: Label = $Panel/VBox/Header/CoinsLabel
@onready var sell_tab: Control = $Panel/VBox/TabContainer/Sell
@onready var upgrades_tab: Control = $Panel/VBox/TabContainer/Upgrades
@onready var sell_items_container: GridContainer = $Panel/VBox/TabContainer/Sell/ScrollContainer/ItemsGrid
@onready var sell_total_label: Label = $Panel/VBox/TabContainer/Sell/TotalSection/TotalLabel
@onready var sell_all_button: Button = $Panel/VBox/TabContainer/Sell/TotalSection/SellAllButton
@onready var upgrades_container: VBoxContainer = $Panel/VBox/TabContainer/Upgrades/ScrollContainer/UpgradesVBox
@onready var close_button: Button = $Panel/VBox/CloseButton

## Upgrade definitions for MVP
var tool_upgrades := [
	{"level": 1, "damage": 1.0, "cost": 0, "name": "Rusty Pickaxe"},
	{"level": 2, "damage": 2.0, "cost": 500, "name": "Copper Pickaxe"},
	{"level": 3, "damage": 3.5, "cost": 2000, "name": "Iron Pickaxe"},
	{"level": 4, "damage": 5.0, "cost": 5000, "name": "Steel Pickaxe"},
]

var backpack_upgrades := [
	{"level": 1, "slots": 8, "cost": 0, "min_depth": 0},
	{"level": 2, "slots": 12, "cost": 1000, "min_depth": 50},
	{"level": 3, "slots": 20, "cost": 3000, "min_depth": 200},
	{"level": 4, "slots": 30, "cost": 8000, "min_depth": 500},
]


func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	sell_all_button.pressed.connect(_on_sell_all_pressed)
	GameManager.coins_changed.connect(_on_coins_changed)
	InventoryManager.inventory_changed.connect(_refresh_sell_tab)


func open() -> void:
	visible = true
	_refresh_ui()


func _refresh_ui() -> void:
	_update_coins_display()
	_refresh_sell_tab()
	_refresh_upgrades_tab()


func _update_coins_display() -> void:
	coins_label.text = "$%d" % GameManager.get_coins()


func _on_coins_changed(_new_amount: int) -> void:
	_update_coins_display()


# ============================================
# SELL TAB
# ============================================

func _refresh_sell_tab() -> void:
	# Clear existing items
	for child in sell_items_container.get_children():
		child.queue_free()

	var total_value := 0
	var sellable_count := 0

	# Add each unique item type from inventory
	var items_seen := {}
	for slot in InventoryManager.slots:
		if slot.is_empty():
			continue
		if slot.item == null:
			continue
		if slot.item.category not in ["ore", "gem"]:
			continue

		var item_id: String = slot.item.id
		if items_seen.has(item_id):
			items_seen[item_id].quantity += slot.quantity
		else:
			items_seen[item_id] = {
				"item": slot.item,
				"quantity": slot.quantity
			}

	# Create UI for each item type
	for item_id in items_seen:
		var data = items_seen[item_id]
		var item = data.item
		var qty: int = data.quantity
		var value: int = item.sell_value * qty
		total_value += value
		sellable_count += qty

		var item_panel := _create_sell_item_panel(item, qty, value)
		sell_items_container.add_child(item_panel)

	# Update total
	sell_total_label.text = "Total: $%d" % total_value
	sell_all_button.disabled = sellable_count == 0


func _create_sell_item_panel(item, quantity: int, total_value: int) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(150, 120)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Item name
	var name_label := Label.new()
	name_label.text = item.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	# Quantity
	var qty_label := Label.new()
	qty_label.text = "x%d" % quantity
	qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(qty_label)

	# Value
	var value_label := Label.new()
	value_label.text = "$%d" % total_value
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_color_override("font_color", Color.GOLD)
	vbox.add_child(value_label)

	# Sell button for this item
	var sell_btn := Button.new()
	sell_btn.text = "Sell"
	sell_btn.pressed.connect(_on_sell_item.bind(item))
	vbox.add_child(sell_btn)

	return panel


func _on_sell_item(item) -> void:
	## Sell all of one item type
	var total := 0
	for slot in InventoryManager.slots:
		if slot.item != null and slot.item.id == item.id:
			total += slot.item.sell_value * slot.quantity

	if total > 0:
		InventoryManager.remove_all_of_item(item)
		GameManager.add_coins(total)
		_refresh_sell_tab()


func _on_sell_all_pressed() -> void:
	## Sell all sellable items
	var total := 0
	var items_to_remove := []

	for slot in InventoryManager.slots:
		if slot.is_empty():
			continue
		if slot.item == null:
			continue
		if slot.item.category in ["ore", "gem"]:
			total += slot.item.sell_value * slot.quantity
			if slot.item not in items_to_remove:
				items_to_remove.append(slot.item)

	if total > 0:
		# Remove all sellable items
		for item in items_to_remove:
			InventoryManager.remove_all_of_item(item)

		GameManager.add_coins(total)
		_refresh_sell_tab()


# ============================================
# UPGRADES TAB
# ============================================

func _refresh_upgrades_tab() -> void:
	# Clear existing
	for child in upgrades_container.get_children():
		child.queue_free()

	# Tool upgrade section
	var tool_section := _create_upgrade_section("Pickaxe", _get_current_tool_level(), tool_upgrades, "_on_tool_upgrade")
	upgrades_container.add_child(tool_section)

	# Backpack upgrade section
	var backpack_section := _create_upgrade_section("Backpack", _get_current_backpack_level(), backpack_upgrades, "_on_backpack_upgrade")
	upgrades_container.add_child(backpack_section)


func _get_current_tool_level() -> int:
	# TODO: Get from player equipment system when implemented
	return 1


func _get_current_backpack_level() -> int:
	var slots := InventoryManager.get_total_slots()
	for i in range(backpack_upgrades.size()):
		if backpack_upgrades[i].slots == slots:
			return i + 1
	return 1


func _create_upgrade_section(title: String, current_level: int, upgrades: Array, callback: String) -> Control:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Title
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title_label)

	# Current level info
	var current_idx := current_level - 1
	if current_idx >= 0 and current_idx < upgrades.size():
		var current: Dictionary = upgrades[current_idx]
		var current_info := Label.new()
		if current.has("damage"):
			current_info.text = "Level %d: %s (Damage: %.1f)" % [current_level, current.get("name", ""), current.damage]
		else:
			current_info.text = "Level %d: %d slots" % [current_level, current.slots]
		vbox.add_child(current_info)

	# Next upgrade info
	var next_idx := current_level
	if next_idx < upgrades.size():
		var next: Dictionary = upgrades[next_idx]
		var next_info := Label.new()
		if next.has("damage"):
			next_info.text = "→ Level %d: %s (Damage: %.1f)" % [next_idx + 1, next.get("name", ""), next.damage]
		else:
			next_info.text = "→ Level %d: %d slots" % [next_idx + 1, next.slots]
		vbox.add_child(next_info)

		var cost: int = next.cost
		var can_afford := GameManager.can_afford(cost)
		var min_depth: int = next.get("min_depth", 0)
		var depth_ok := GameManager.current_depth >= min_depth

		var upgrade_btn := Button.new()
		if not depth_ok:
			upgrade_btn.text = "LOCKED - Reach %dm" % min_depth
			upgrade_btn.disabled = true
		elif not can_afford:
			upgrade_btn.text = "UPGRADE - $%d (Need $%d more)" % [cost, cost - GameManager.get_coins()]
			upgrade_btn.disabled = true
		else:
			upgrade_btn.text = "UPGRADE - $%d" % cost
			upgrade_btn.pressed.connect(Callable(self, callback))

		vbox.add_child(upgrade_btn)
	else:
		var max_label := Label.new()
		max_label.text = "MAX LEVEL"
		max_label.add_theme_color_override("font_color", Color.GOLD)
		vbox.add_child(max_label)

	return panel


func _on_tool_upgrade() -> void:
	var current_level := _get_current_tool_level()
	if current_level < tool_upgrades.size():
		var next: Dictionary = tool_upgrades[current_level]
		if GameManager.spend_coins(next.cost):
			# TODO: Apply tool upgrade to player
			print("[Shop] Tool upgraded to level %d" % (current_level + 1))
			_refresh_upgrades_tab()


func _on_backpack_upgrade() -> void:
	var current_level := _get_current_backpack_level()
	if current_level < backpack_upgrades.size():
		var next: Dictionary = backpack_upgrades[current_level]
		if GameManager.spend_coins(next.cost):
			InventoryManager.upgrade_capacity(next.slots)
			print("[Shop] Backpack upgraded to %d slots" % next.slots)
			_refresh_upgrades_tab()


func _on_close_pressed() -> void:
	visible = false
	closed.emit()
