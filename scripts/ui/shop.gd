extends Control
## Shop UI for selling resources and buying upgrades.
##
## Supports multiple shop types with different functionality.
## Uses GameManager for coin transactions and InventoryManager for items.

const ShopBuilding = preload("res://scripts/surface/shop_building.gd")

signal closed

@onready var coins_label: Label = $Panel/VBox/Header/CoinsLabel
@onready var shop_title: Label = $Panel/VBox/Header/ShopTitle
@onready var sell_tab: Control = $Panel/VBox/TabContainer/Sell
@onready var upgrades_tab: Control = $Panel/VBox/TabContainer/Upgrades
@onready var sell_items_container: GridContainer = $Panel/VBox/TabContainer/Sell/ScrollContainer/ItemsGrid
@onready var sell_total_label: Label = $Panel/VBox/TabContainer/Sell/TotalSection/TotalLabel
@onready var sell_all_button: Button = $Panel/VBox/TabContainer/Sell/TotalSection/SellAllButton
@onready var upgrades_container: VBoxContainer = $Panel/VBox/TabContainer/Upgrades/ScrollContainer/UpgradesVBox
@onready var close_button: Button = $Panel/VBox/CloseButton
@onready var tab_container: TabContainer = $Panel/VBox/TabContainer

## Current shop type being displayed
var current_shop_type: int = ShopBuilding.ShopType.GENERAL_STORE

## Tool upgrades now loaded from DataRegistry (ToolData resources)

var backpack_upgrades := [
	{"level": 1, "slots": 8, "cost": 0, "min_depth": 0},
	{"level": 2, "slots": 12, "cost": 1000, "min_depth": 50},
	{"level": 3, "slots": 20, "cost": 3000, "min_depth": 200},
	{"level": 4, "slots": 30, "cost": 8000, "min_depth": 500},
]

## Warehouse storage upgrades - extra slots from warehouse building
var warehouse_upgrades := [
	{"level": 1, "bonus_slots": 5, "cost": 5000, "min_depth": 500},
	{"level": 2, "bonus_slots": 10, "cost": 15000, "min_depth": 500},
	{"level": 3, "bonus_slots": 20, "cost": 40000, "min_depth": 500},
]

## Gadgets available for purchase
var gadgets := [
	{"id": "teleport_scroll", "name": "Teleport Scroll", "cost": 500, "description": "Return to surface instantly"},
	{"id": "grappling_hook", "name": "Grappling Hook", "cost": 1000, "description": "Quickly travel up to 8 blocks"},
	{"id": "depth_beacon", "name": "Depth Beacon", "cost": 2000, "description": "Mark a depth to return to"},
	{"id": "ore_detector", "name": "Ore Detector", "cost": 3000, "description": "Highlights nearby ores"},
	{"id": "auto_torch", "name": "Auto Torch", "cost": 1500, "description": "Place torches automatically"},
]


func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	sell_all_button.pressed.connect(_on_sell_all_pressed)
	GameManager.coins_changed.connect(_on_coins_changed)
	InventoryManager.inventory_changed.connect(_refresh_sell_tab)


func open(shop_type: int = ShopBuilding.ShopType.GENERAL_STORE) -> void:
	current_shop_type = shop_type
	visible = true
	_configure_for_shop_type()
	_refresh_ui()


func _configure_for_shop_type() -> void:
	## Configure UI based on current shop type
	match current_shop_type:
		ShopBuilding.ShopType.GENERAL_STORE:
			if shop_title:
				shop_title.text = "General Store"
			sell_tab.visible = true
			upgrades_tab.visible = true
		ShopBuilding.ShopType.BLACKSMITH:
			if shop_title:
				shop_title.text = "Blacksmith"
			sell_tab.visible = false
			upgrades_tab.visible = true
			if tab_container:
				tab_container.current_tab = 1  # Show upgrades tab
		ShopBuilding.ShopType.GEM_APPRAISER:
			if shop_title:
				shop_title.text = "Gem Appraiser"
			sell_tab.visible = true
			upgrades_tab.visible = false
			if tab_container:
				tab_container.current_tab = 0  # Show sell tab
		ShopBuilding.ShopType.WAREHOUSE:
			if shop_title:
				shop_title.text = "Warehouse"
			sell_tab.visible = false
			upgrades_tab.visible = true
			if tab_container:
				tab_container.current_tab = 1  # Show upgrades tab
		ShopBuilding.ShopType.GADGET_SHOP:
			if shop_title:
				shop_title.text = "Gadget Shop"
			sell_tab.visible = false
			upgrades_tab.visible = true
			if tab_container:
				tab_container.current_tab = 1  # Show upgrades tab (repurposed for gadgets)
		ShopBuilding.ShopType.SUPPLY_STORE:
			if shop_title:
				shop_title.text = "Supply Store"
			sell_tab.visible = false
			upgrades_tab.visible = true
			if tab_container:
				tab_container.current_tab = 1  # Show upgrades tab (for ladders, ropes)
		ShopBuilding.ShopType.EQUIPMENT_SHOP:
			if shop_title:
				shop_title.text = "Equipment Shop"
			sell_tab.visible = false
			upgrades_tab.visible = true
			if tab_container:
				tab_container.current_tab = 1  # Show upgrades tab
		ShopBuilding.ShopType.ELEVATOR:
			if shop_title:
				shop_title.text = "Elevator"
			sell_tab.visible = false
			upgrades_tab.visible = true
			if tab_container:
				tab_container.current_tab = 1  # Show upgrades tab (repurposed for elevator)
		_:
			# Default configuration for other shop types
			if shop_title:
				shop_title.text = "Shop"
			sell_tab.visible = true
			upgrades_tab.visible = true


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
		var multiplier := _get_sell_multiplier(item)
		var base_value: int = item.sell_value * qty
		var value: int = int(base_value * multiplier)
		total_value += value
		sellable_count += qty

		var item_panel := _create_sell_item_panel(item, qty, base_value, value, multiplier)
		sell_items_container.add_child(item_panel)

	# Update total with depth bonus display
	var total_text := "Total: $%d" % total_value

	# Show depth multiplier if active
	var depth_mult := PlayerData.get_depth_sell_multiplier() if PlayerData else 1.0
	if depth_mult > 1.0:
		var depth_bonus := int((depth_mult - 1.0) * 100)
		total_text += " (+%d%% depth bonus!)" % depth_bonus

	# Show gem appraiser bonus
	if current_shop_type == ShopBuilding.ShopType.GEM_APPRAISER:
		total_text += " (Gems +50%!)"

	sell_total_label.text = total_text
	sell_all_button.disabled = sellable_count == 0


func _create_sell_item_panel(item, quantity: int, base_value: int, total_value: int, multiplier: float) -> Control:
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

	# Value (with multiplier indicator)
	var value_label := Label.new()
	if multiplier > 1.0:
		var bonus_pct := int((multiplier - 1.0) * 100)
		value_label.text = "$%d (+%d%%)" % [total_value, bonus_pct]
		value_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))  # Green for bonus
	else:
		value_label.text = "$%d" % total_value
		value_label.add_theme_color_override("font_color", Color.GOLD)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(value_label)

	# Sell button for this item
	var sell_btn := Button.new()
	sell_btn.text = "Sell"
	sell_btn.pressed.connect(_on_sell_item.bind(item))
	vbox.add_child(sell_btn)

	return panel


## Get sell price multiplier based on shop type, item category, and dive depth
func _get_sell_multiplier(item) -> float:
	var multiplier := 1.0

	## Depth-based multiplier from current dive (deeper = more valuable)
	if PlayerData:
		multiplier = PlayerData.get_depth_sell_multiplier()

	## Gem Appraiser gives additional 50% bonus on gems
	if current_shop_type == ShopBuilding.ShopType.GEM_APPRAISER:
		if item.category == "gem":
			multiplier *= 1.5  # 50% bonus for gems at Gem Appraiser

	return multiplier


func _on_sell_item(item) -> void:
	## Sell all of one item type
	var multiplier := _get_sell_multiplier(item)
	var total := 0
	for slot in InventoryManager.slots:
		if slot.item != null and slot.item.id == item.id:
			total += int(slot.item.sell_value * slot.quantity * multiplier)

	if total > 0:
		InventoryManager.remove_all_of_item(item)
		GameManager.add_coins(total)
		_refresh_sell_tab()
		# Track for achievements
		if AchievementManager:
			AchievementManager.track_sale(total)
		# Complete tutorial after first sale
		_check_tutorial_sale_complete()
		# Auto-save after transaction
		SaveManager.save_game()


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
			var multiplier := _get_sell_multiplier(slot.item)
			total += int(slot.item.sell_value * slot.quantity * multiplier)
			if slot.item not in items_to_remove:
				items_to_remove.append(slot.item)

	if total > 0:
		# Remove all sellable items
		for item in items_to_remove:
			InventoryManager.remove_all_of_item(item)

		GameManager.add_coins(total)
		_refresh_sell_tab()
		# Track for achievements
		if AchievementManager:
			AchievementManager.track_sale(total)
		# Complete tutorial after first sale
		_check_tutorial_sale_complete()
		# Auto-save after transaction
		SaveManager.save_game()


func _check_tutorial_sale_complete() -> void:
	## Complete the tutorial if player is in SELLING state and just made a sale
	if GameManager and GameManager.is_tutorial_active():
		if GameManager.tutorial_state == GameManager.TutorialState.SELLING:
			GameManager.advance_tutorial(GameManager.TutorialState.COMPLETE)

	# Notify FTUE of first sale
	_notify_ftue_first_sale()


func _notify_ftue_first_sale() -> void:
	## Notify the test level's FTUE overlay that first sale is complete
	# Find the test_level node and call its FTUE notification
	var test_level = get_tree().get_first_node_in_group("test_level")
	if test_level == null:
		# Try to find by going up the tree
		var parent = get_parent()
		while parent != null:
			if parent.has_method("_notify_ftue_first_sale"):
				parent._notify_ftue_first_sale()
				return
			parent = parent.get_parent()

		# Fallback: Check if SaveManager has FTUE tracking
		if SaveManager and not SaveManager.has_ftue_first_sell():
			SaveManager.set_ftue_first_sell()
			if SaveManager.is_ftue_completed() == false:
				SaveManager.set_ftue_completed()
	else:
		if test_level.has_method("_notify_ftue_first_sale"):
			test_level._notify_ftue_first_sale()


# ============================================
# UPGRADES TAB
# ============================================

func _refresh_upgrades_tab() -> void:
	# Clear existing
	for child in upgrades_container.get_children():
		child.queue_free()

	match current_shop_type:
		ShopBuilding.ShopType.WAREHOUSE:
			# Warehouse: show storage upgrades
			var warehouse_section := _create_warehouse_upgrade_section()
			upgrades_container.add_child(warehouse_section)
		ShopBuilding.ShopType.GADGET_SHOP:
			# Gadget Shop: show gadgets for purchase
			var gadget_section := _create_gadget_section()
			upgrades_container.add_child(gadget_section)
		ShopBuilding.ShopType.SUPPLY_STORE:
			# Supply Store: show consumables
			var supply_section := _create_supply_section()
			upgrades_container.add_child(supply_section)
		ShopBuilding.ShopType.EQUIPMENT_SHOP:
			# Equipment Shop: show equipment purchases
			var equipment_section := _create_equipment_section()
			upgrades_container.add_child(equipment_section)
		ShopBuilding.ShopType.ELEVATOR:
			# Elevator: show fast travel options
			var elevator_section := _create_elevator_section()
			upgrades_container.add_child(elevator_section)
		_:
			# Default: Tool and backpack upgrades
			var tool_section := _create_tool_upgrade_section()
			upgrades_container.add_child(tool_section)

			var backpack_section := _create_upgrade_section("Backpack", _get_current_backpack_level(), backpack_upgrades, "_on_backpack_upgrade")
			upgrades_container.add_child(backpack_section)


func _get_current_tool_level() -> int:
	## Get current tool tier from PlayerData
	var tool_data: ToolData = PlayerData.get_equipped_tool()
	if tool_data == null:
		return 1
	return tool_data.tier


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
			next_info.text = "-> Level %d: %s (Damage: %.1f)" % [next_idx + 1, next.get("name", ""), next.damage]
		else:
			next_info.text = "-> Level %d: %d slots" % [next_idx + 1, next.slots]
		vbox.add_child(next_info)

		var cost: int = next.cost
		var can_afford: bool = GameManager.can_afford(cost)
		var min_depth: int = next.get("min_depth", 0)
		var depth_ok: bool = GameManager.current_depth >= min_depth

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


func _create_tool_upgrade_section() -> Control:
	## Creates the tool upgrade UI section using ToolData resources
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Title
	var title_label := Label.new()
	title_label.text = "Pickaxe"
	title_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title_label)

	# Get current tool info
	var current_tool: ToolData = PlayerData.get_equipped_tool()
	if current_tool != null:
		var current_info := Label.new()
		var effective_dmg: float = current_tool.damage * current_tool.speed_multiplier
		current_info.text = "Level %d: %s (Damage: %.1f)" % [current_tool.tier, current_tool.display_name, effective_dmg]
		vbox.add_child(current_info)

	# Get next upgrade
	var next_tool: ToolData = PlayerData.get_next_tool_upgrade()
	if next_tool != null:
		var next_info := Label.new()
		var next_effective_dmg: float = next_tool.damage * next_tool.speed_multiplier
		next_info.text = "-> Level %d: %s (Damage: %.1f)" % [next_tool.tier, next_tool.display_name, next_effective_dmg]
		vbox.add_child(next_info)

		var can_afford: bool = GameManager.can_afford(next_tool.cost)
		var depth_ok: bool = PlayerData.max_depth_reached >= next_tool.unlock_depth

		var upgrade_btn := Button.new()
		if not depth_ok:
			upgrade_btn.text = "LOCKED - Reach %dm" % next_tool.unlock_depth
			upgrade_btn.disabled = true
		elif not can_afford:
			upgrade_btn.text = "UPGRADE - $%d (Need $%d more)" % [next_tool.cost, next_tool.cost - GameManager.get_coins()]
			upgrade_btn.disabled = true
		else:
			upgrade_btn.text = "UPGRADE - $%d" % next_tool.cost
			upgrade_btn.pressed.connect(_on_tool_upgrade)

		vbox.add_child(upgrade_btn)
	else:
		var max_label := Label.new()
		max_label.text = "MAX LEVEL"
		max_label.add_theme_color_override("font_color", Color.GOLD)
		vbox.add_child(max_label)

	return panel


func _on_tool_upgrade() -> void:
	## Purchase the next tool upgrade
	var next_tool: ToolData = PlayerData.get_next_tool_upgrade()
	if next_tool == null:
		return

	# Verify player can afford and meets depth requirement
	if not PlayerData.can_unlock_tool(next_tool):
		return
	if not GameManager.can_afford(next_tool.cost):
		return

	if GameManager.spend_coins(next_tool.cost):
		PlayerData.equip_tool(next_tool.id)
		print("[Shop] Tool upgraded to: %s" % next_tool.display_name)

		# Play dramatic upgrade celebration sound
		if SoundManager:
			SoundManager.play_tool_upgrade()

		_refresh_upgrades_tab()
		# Track for achievements
		if AchievementManager:
			AchievementManager.track_upgrade()
		# Auto-save after tool upgrade
		SaveManager.save_game()


func _on_backpack_upgrade() -> void:
	var current_level := _get_current_backpack_level()
	if current_level < backpack_upgrades.size():
		var next: Dictionary = backpack_upgrades[current_level]
		if GameManager.spend_coins(next.cost):
			InventoryManager.upgrade_capacity(next.slots)
			print("[Shop] Backpack upgraded to %d slots" % next.slots)
			_refresh_upgrades_tab()
			# Track for achievements
			if AchievementManager:
				AchievementManager.track_upgrade()
			# Auto-save after backpack upgrade
			SaveManager.save_game()


func _on_close_pressed() -> void:
	visible = false
	closed.emit()


# ============================================
# WAREHOUSE UPGRADES
# ============================================

func _get_current_warehouse_level() -> int:
	## Get current warehouse upgrade level from PlayerData
	if PlayerData == null:
		return 0
	return PlayerData.warehouse_level

func _create_warehouse_upgrade_section() -> Control:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Title
	var title_label := Label.new()
	title_label.text = "Storage Expansion"
	title_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title_label)

	# Description
	var desc_label := Label.new()
	desc_label.text = "Permanently increase your inventory capacity!"
	desc_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc_label)

	# Current level info
	var current_level := _get_current_warehouse_level()
	var current_bonus := 0
	if current_level > 0 and current_level <= warehouse_upgrades.size():
		current_bonus = warehouse_upgrades[current_level - 1].bonus_slots

	var current_info := Label.new()
	if current_level > 0:
		current_info.text = "Level %d: +%d bonus slots" % [current_level, current_bonus]
	else:
		current_info.text = "No storage expansion purchased"
	vbox.add_child(current_info)

	# Next upgrade
	if current_level < warehouse_upgrades.size():
		var next = warehouse_upgrades[current_level]
		var next_info := Label.new()
		next_info.text = "-> Level %d: +%d total bonus slots" % [current_level + 1, next.bonus_slots]
		vbox.add_child(next_info)

		var cost: int = next.cost
		var can_afford: bool = GameManager.can_afford(cost)

		var upgrade_btn := Button.new()
		if not can_afford:
			upgrade_btn.text = "UPGRADE - $%d (Need $%d more)" % [cost, cost - GameManager.get_coins()]
			upgrade_btn.disabled = true
		else:
			upgrade_btn.text = "UPGRADE - $%d" % cost
			upgrade_btn.pressed.connect(_on_warehouse_upgrade)

		vbox.add_child(upgrade_btn)
	else:
		var max_label := Label.new()
		max_label.text = "MAX LEVEL - +%d bonus slots" % current_bonus
		max_label.add_theme_color_override("font_color", Color.GOLD)
		vbox.add_child(max_label)

	return panel


func _on_warehouse_upgrade() -> void:
	var current_level := _get_current_warehouse_level()
	if current_level >= warehouse_upgrades.size():
		return

	var next = warehouse_upgrades[current_level]
	if GameManager.spend_coins(next.cost):
		PlayerData.warehouse_level = current_level + 1
		# Calculate slot bonus (difference from previous level)
		var prev_bonus = 0 if current_level == 0 else warehouse_upgrades[current_level - 1].bonus_slots
		var new_slots = next.bonus_slots - prev_bonus
		InventoryManager.upgrade_capacity(InventoryManager.get_total_slots() + new_slots)
		print("[Shop] Warehouse upgraded to level %d (+%d slots)" % [current_level + 1, new_slots])
		_refresh_upgrades_tab()
		if AchievementManager:
			AchievementManager.track_upgrade()
		SaveManager.save_game()


# ============================================
# GADGET SHOP
# ============================================

func _create_gadget_section() -> Control:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Title
	var title_label := Label.new()
	title_label.text = "Gadgets & Utilities"
	title_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title_label)

	# Add each gadget
	for gadget in gadgets:
		var gadget_panel := _create_gadget_item(gadget)
		vbox.add_child(gadget_panel)

	return panel


func _create_gadget_item(gadget: Dictionary) -> Control:
	var hbox := HBoxContainer.new()

	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label := Label.new()
	name_label.text = gadget.name
	info_vbox.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = gadget.description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info_vbox.add_child(desc_label)

	hbox.add_child(info_vbox)

	# Count owned
	var owned := PlayerData.get_gadget_count(gadget.id) if PlayerData else 0
	var count_label := Label.new()
	count_label.text = "x%d" % owned
	count_label.custom_minimum_size.x = 50
	hbox.add_child(count_label)

	# Buy button
	var buy_btn := Button.new()
	var cost: int = gadget.cost
	var can_afford := GameManager.can_afford(cost)
	buy_btn.text = "$%d" % cost
	buy_btn.disabled = not can_afford
	buy_btn.pressed.connect(_on_buy_gadget.bind(gadget.id, cost))
	hbox.add_child(buy_btn)

	return hbox


func _on_buy_gadget(gadget_id: String, cost: int) -> void:
	if GameManager.spend_coins(cost):
		PlayerData.add_gadget(gadget_id, 1)
		print("[Shop] Purchased gadget: %s" % gadget_id)
		_refresh_upgrades_tab()
		SaveManager.save_game()


# ============================================
# SUPPLY STORE
# ============================================

func _create_supply_section() -> Control:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Title
	var title_label := Label.new()
	title_label.text = "Supplies"
	title_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title_label)

	# Ladders
	var ladder_hbox := HBoxContainer.new()
	var ladder_info := VBoxContainer.new()
	ladder_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var ladder_name := Label.new()
	ladder_name.text = "Ladder"
	ladder_info.add_child(ladder_name)

	var ladder_desc := Label.new()
	ladder_desc.text = "Place to climb vertical shafts"
	ladder_desc.add_theme_font_size_override("font_size", 12)
	ladder_info.add_child(ladder_desc)

	ladder_hbox.add_child(ladder_info)

	var ladder_count := InventoryManager.get_item_count_by_id("ladder") if InventoryManager else 0
	var ladder_count_label := Label.new()
	ladder_count_label.text = "x%d" % ladder_count
	ladder_count_label.custom_minimum_size.x = 50
	ladder_hbox.add_child(ladder_count_label)

	var ladder_cost := 8
	var ladder_btn := Button.new()
	ladder_btn.text = "$%d" % ladder_cost
	ladder_btn.disabled = not GameManager.can_afford(ladder_cost)
	ladder_btn.pressed.connect(_on_buy_ladder.bind(ladder_cost))
	ladder_hbox.add_child(ladder_btn)

	vbox.add_child(ladder_hbox)

	# Torches
	var torch_hbox := HBoxContainer.new()
	var torch_info := VBoxContainer.new()
	torch_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var torch_name := Label.new()
	torch_name.text = "Torch"
	torch_info.add_child(torch_name)

	var torch_desc := Label.new()
	torch_desc.text = "Light up dark areas"
	torch_desc.add_theme_font_size_override("font_size", 12)
	torch_info.add_child(torch_desc)

	torch_hbox.add_child(torch_info)

	var torch_count := InventoryManager.get_item_count_by_id("torch") if InventoryManager else 0
	var torch_count_label := Label.new()
	torch_count_label.text = "x%d" % torch_count
	torch_count_label.custom_minimum_size.x = 50
	torch_hbox.add_child(torch_count_label)

	var torch_cost := 25
	var torch_btn := Button.new()
	torch_btn.text = "$%d" % torch_cost
	torch_btn.disabled = not GameManager.can_afford(torch_cost)
	torch_btn.pressed.connect(_on_buy_torch.bind(torch_cost))
	torch_hbox.add_child(torch_btn)

	vbox.add_child(torch_hbox)

	return panel


func _on_buy_ladder(cost: int) -> void:
	if GameManager.spend_coins(cost):
		# Add ladder to inventory (need to get the item from DataRegistry)
		var ladder_item = DataRegistry.get_item("ladder")
		if ladder_item:
			InventoryManager.add_item(ladder_item, 1)
		else:
			# Create placeholder if not in registry
			PlayerData.add_consumable("ladder", 1)
		print("[Shop] Purchased ladder")
		_refresh_upgrades_tab()
		SaveManager.save_game()


func _on_buy_torch(cost: int) -> void:
	if GameManager.spend_coins(cost):
		var torch_item = DataRegistry.get_item("torch")
		if torch_item:
			InventoryManager.add_item(torch_item, 1)
		else:
			PlayerData.add_consumable("torch", 1)
		print("[Shop] Purchased torch")
		_refresh_upgrades_tab()
		SaveManager.save_game()


# ============================================
# EQUIPMENT SHOP
# ============================================

func _create_equipment_section() -> Control:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Title
	var title_label := Label.new()
	title_label.text = "Equipment"
	title_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title_label)

	# Get equipment from DataRegistry
	var all_boots = DataRegistry.get_all_boots() if DataRegistry else []
	var all_helmets = DataRegistry.get_all_helmets() if DataRegistry else []

	# Boots section
	if not all_boots.is_empty():
		var boots_label := Label.new()
		boots_label.text = "Boots"
		boots_label.add_theme_font_size_override("font_size", 18)
		vbox.add_child(boots_label)

		for boots in all_boots:
			var boots_item := _create_equipment_item(boots, "boots")
			vbox.add_child(boots_item)

	# Helmets section
	if not all_helmets.is_empty():
		var helmets_label := Label.new()
		helmets_label.text = "Helmets"
		helmets_label.add_theme_font_size_override("font_size", 18)
		vbox.add_child(helmets_label)

		for helmet in all_helmets:
			var helmet_item := _create_equipment_item(helmet, "helmet")
			vbox.add_child(helmet_item)

	if all_boots.is_empty() and all_helmets.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No equipment available"
		vbox.add_child(empty_label)

	return panel


func _create_equipment_item(equipment, equip_type: String) -> Control:
	var hbox := HBoxContainer.new()

	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label := Label.new()
	name_label.text = equipment.display_name if equipment.has_method("get") else str(equipment)
	info_vbox.add_child(name_label)

	# Show bonuses
	var bonus_text := ""
	if "fall_damage_reduction" in equipment and equipment.fall_damage_reduction > 0:
		bonus_text += "-%d%% fall dmg " % int(equipment.fall_damage_reduction * 100)
	if "light_radius_bonus" in equipment and equipment.light_radius_bonus > 0:
		bonus_text += "+%d light " % equipment.light_radius_bonus
	if "speed_bonus" in equipment and equipment.speed_bonus > 0:
		bonus_text += "+%d%% speed " % int(equipment.speed_bonus * 100)

	if bonus_text != "":
		var bonus_label := Label.new()
		bonus_label.text = bonus_text.strip_edges()
		bonus_label.add_theme_font_size_override("font_size", 12)
		bonus_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
		info_vbox.add_child(bonus_label)

	hbox.add_child(info_vbox)

	# Check if already owned
	var is_owned := false
	if PlayerData:
		if equip_type == "boots":
			is_owned = PlayerData.has_boots(equipment.id)
		elif equip_type == "helmet":
			is_owned = PlayerData.has_helmet(equipment.id)

	if is_owned:
		var owned_label := Label.new()
		owned_label.text = "OWNED"
		owned_label.add_theme_color_override("font_color", Color.GOLD)
		hbox.add_child(owned_label)

		# Equip button if not currently equipped
		var is_equipped := false
		if equip_type == "boots":
			is_equipped = PlayerData.equipped_boots_id == equipment.id
		elif equip_type == "helmet":
			is_equipped = PlayerData.equipped_helmet_id == equipment.id

		if not is_equipped:
			var equip_btn := Button.new()
			equip_btn.text = "EQUIP"
			equip_btn.pressed.connect(_on_equip_item.bind(equipment.id, equip_type))
			hbox.add_child(equip_btn)
		else:
			var equipped_label := Label.new()
			equipped_label.text = "[EQUIPPED]"
			equipped_label.add_theme_color_override("font_color", Color.GREEN)
			hbox.add_child(equipped_label)
	else:
		# Buy button
		var cost: int = equipment.cost if "cost" in equipment else 1000
		var can_afford := GameManager.can_afford(cost)
		var depth_ok := true
		if "unlock_depth" in equipment:
			depth_ok = GameManager.max_depth_reached >= equipment.unlock_depth

		var buy_btn := Button.new()
		if not depth_ok:
			buy_btn.text = "LOCKED (%dm)" % equipment.unlock_depth
			buy_btn.disabled = true
		elif not can_afford:
			buy_btn.text = "$%d" % cost
			buy_btn.disabled = true
		else:
			buy_btn.text = "$%d" % cost
			buy_btn.pressed.connect(_on_buy_equipment.bind(equipment.id, equip_type, cost))

		hbox.add_child(buy_btn)

	return hbox


func _on_buy_equipment(equip_id: String, equip_type: String, cost: int) -> void:
	if GameManager.spend_coins(cost):
		if equip_type == "boots":
			PlayerData.unlock_boots(equip_id)
			PlayerData.equip_boots(equip_id)
		elif equip_type == "helmet":
			PlayerData.unlock_helmet(equip_id)
			PlayerData.equip_helmet(equip_id)
		print("[Shop] Purchased and equipped %s: %s" % [equip_type, equip_id])
		_refresh_upgrades_tab()
		SaveManager.save_game()


func _on_equip_item(equip_id: String, equip_type: String) -> void:
	if equip_type == "boots":
		PlayerData.equip_boots(equip_id)
	elif equip_type == "helmet":
		PlayerData.equip_helmet(equip_id)
	print("[Shop] Equipped %s: %s" % [equip_type, equip_id])
	_refresh_upgrades_tab()
	SaveManager.save_game()


# ============================================
# ELEVATOR
# ============================================

## Elevator travel costs
const ELEVATOR_COST_PER_BLOCK := 1  # Coins per block traveled
const ELEVATOR_MIN_COST := 50  # Minimum travel cost
const ELEVATOR_STOP_COST := 500  # Cost to add a new stop

func _create_elevator_section() -> Control:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# Title
	var title_label := Label.new()
	title_label.text = "Elevator - Fast Travel"
	title_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title_label)

	# Description
	var desc_label := Label.new()
	desc_label.text = "Travel quickly between saved depths!"
	desc_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc_label)

	# Current depth info
	var current_depth := GameManager.current_depth if GameManager else 0
	var depth_info := Label.new()
	depth_info.text = "Current depth: %dm" % current_depth
	vbox.add_child(depth_info)

	# Add spacer
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 10
	vbox.add_child(spacer)

	# Surface stop (always available)
	var surface_section := _create_elevator_stop_item(0, "Surface", true)
	vbox.add_child(surface_section)

	# Get saved elevator stops
	var stops = PlayerData.get_elevator_stops() if PlayerData else []

	# Show saved stops
	for stop_depth in stops:
		if stop_depth > 0:  # Surface is already shown
			var stop_item := _create_elevator_stop_item(stop_depth, "%dm" % stop_depth, true)
			vbox.add_child(stop_item)

	# Option to add current depth as new stop
	if current_depth > 0 and current_depth not in stops:
		var add_stop_section := _create_add_stop_section(current_depth)
		vbox.add_child(add_stop_section)

	return panel


func _create_elevator_stop_item(depth: int, name: String, can_travel: bool) -> Control:
	var hbox := HBoxContainer.new()

	var name_label := Label.new()
	name_label.text = name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(name_label)

	# Calculate travel cost
	var current_depth := GameManager.current_depth if GameManager else 0
	var distance := absi(current_depth - depth)
	var travel_cost := maxi(ELEVATOR_MIN_COST, distance * ELEVATOR_COST_PER_BLOCK)

	if distance == 0:
		# Already at this depth
		var here_label := Label.new()
		here_label.text = "[HERE]"
		here_label.add_theme_color_override("font_color", Color.GREEN)
		hbox.add_child(here_label)
	elif can_travel:
		var travel_btn := Button.new()
		var can_afford := GameManager.can_afford(travel_cost)
		travel_btn.text = "GO ($%d)" % travel_cost
		travel_btn.disabled = not can_afford
		travel_btn.pressed.connect(_on_elevator_travel.bind(depth, travel_cost))
		hbox.add_child(travel_btn)

	return hbox


func _create_add_stop_section(depth: int) -> Control:
	var hbox := HBoxContainer.new()

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 10
	hbox.add_child(spacer)

	var info_label := Label.new()
	info_label.text = "Add stop at %dm" % depth
	info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_label)

	var add_btn := Button.new()
	var can_afford := GameManager.can_afford(ELEVATOR_STOP_COST)
	add_btn.text = "ADD ($%d)" % ELEVATOR_STOP_COST
	add_btn.disabled = not can_afford
	add_btn.pressed.connect(_on_add_elevator_stop.bind(depth))
	hbox.add_child(add_btn)

	return hbox


func _on_elevator_travel(target_depth: int, cost: int) -> void:
	if not GameManager.spend_coins(cost):
		return

	# Find the player and teleport them
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		# Try to find player another way
		var main = get_tree().get_first_node_in_group("main")
		if main and main.has_node("Player"):
			player = main.get_node("Player")

	if player:
		# Calculate target grid position
		var target_y := GameManager.SURFACE_ROW + target_depth
		var target_grid := Vector2i(player.grid_position.x, target_y)

		# Teleport player
		player.position = GameManager.grid_to_world(target_grid) + Vector2(player.BLOCK_SIZE / 2.0, player.BLOCK_SIZE / 2.0)
		player.grid_position = target_grid
		player.current_state = player.State.IDLE
		player.velocity = Vector2.ZERO

		# Update game state
		GameManager.update_depth(target_depth)
		player.depth_changed.emit(target_depth)

		print("[Shop] Elevator traveled to depth %dm for $%d" % [target_depth, cost])

	# Close shop after travel
	visible = false
	closed.emit()
	SaveManager.save_game()


func _on_add_elevator_stop(depth: int) -> void:
	if not GameManager.spend_coins(ELEVATOR_STOP_COST):
		return

	PlayerData.add_elevator_depth(depth)
	print("[Shop] Added elevator stop at %dm" % depth)
	_refresh_upgrades_tab()
	SaveManager.save_game()
