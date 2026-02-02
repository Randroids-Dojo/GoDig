extends Control
## HUD - Heads Up Display for game information.
##
## Displays player health, depth, coins, and status indicators.
## Provides visual feedback for low health and damage.

## Reference to the health bar
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/HealthLabel

## Reference to coins and depth displays
@onready var coins_label: Label = $CoinsLabel
@onready var depth_label: Label = $DepthLabel

## Depth bonus indicator (created programmatically)
var depth_bonus_label: Label = null

## Reference to pause button
@onready var pause_button: Button = $PauseButton

## Reference to low health warning overlay
@onready var low_health_vignette: ColorRect = $LowHealthVignette

## Quick-sell button (created programmatically)
var quick_sell_button: Button = null

## Tool indicator label (created programmatically)
var tool_label: Label = null

## Tool durability bar (created programmatically)
var tool_durability_container: Control = null
var tool_durability_bar: ProgressBar = null
var tool_durability_label: Label = null

## Inventory slots label (created programmatically)
var inventory_label: Label = null

## Milestone notification scene
const MilestoneNotificationScene = preload("res://scenes/ui/milestone_notification.tscn")
var milestone_notification: Control = null

## Cached values for comparison
var _last_hp: int = -1
var _last_max_hp: int = -1
var _last_coins: int = -1

## Animation state
var _vignette_pulse_time: float = 0.0
var _coins_tween: Tween = null
const VIGNETTE_PULSE_SPEED: float = 3.0
const VIGNETTE_MIN_ALPHA: float = 0.1
const VIGNETTE_MAX_ALPHA: float = 0.4

## Next upgrade goal display (created programmatically)
var upgrade_goal_container: Control = null
var upgrade_goal_label: Label = null
var upgrade_goal_progress: ProgressBar = null
var upgrade_goal_value_label: Label = null
var _upgrade_goal_tween: Tween = null

## Time since save indicator (created programmatically)
var save_indicator_label: Label = null
var _save_timer: float = 0.0
const SAVE_UPDATE_INTERVAL: float = 1.0  # Update every second

## Ladder quick-slot (created programmatically)
var ladder_quickslot: Control = null
var ladder_count_label: Label = null
var ladder_button: Button = null
var ladder_buy_button: Button = null  # Quick-buy button for surface purchases

## Ladder cost for quick-buy
const LADDER_COST := 8

## Rope quick-slot
var rope_quickslot: Control = null
var rope_count_label: Label = null
var rope_button: Button = null

## Teleport scroll quick-slot
var teleport_quickslot: Control = null
var teleport_count_label: Label = null
var teleport_button: Button = null

## Standard outline settings for HUD text
const HUD_OUTLINE_SIZE := 3
const HUD_OUTLINE_COLOR := Color(0.0, 0.0, 0.0, 0.9)

## HUD panel colors
const HUD_PANEL_COLOR := Color(0.1, 0.1, 0.15, 0.85)
const HUD_BUTTON_COLOR := Color(0.15, 0.15, 0.2, 0.9)

## Left panel backdrop
var left_panel_bg: ColorRect = null

## Guidance toast system (non-blocking tutorial hints)
var guidance_toast: Control = null
var guidance_toast_label: Label = null
var guidance_toast_icon: Label = null
var _guidance_toast_tween: Tween = null
var _guidance_toast_visible: bool = false
var _guidance_toast_queue: Array = []  # Queue of pending toast messages

## Guidance state tracking (to prevent repeat toasts)
var _shown_inventory_half_toast: bool = false
var _shown_upgrade_affordable_toast: bool = false
var _last_inventory_check_fill_ratio: float = 0.0
var _last_coin_check_amount: int = 0


## Apply standard dark outline to a label for readability
static func apply_text_outline(label: Label, outline_size: int = HUD_OUTLINE_SIZE, outline_color: Color = HUD_OUTLINE_COLOR) -> void:
	label.add_theme_constant_override("outline_size", outline_size)
	label.add_theme_color_override("font_outline_color", outline_color)


func _ready() -> void:
	# Create dark backdrop panel for left-side HUD (must be first so it's behind other elements)
	_setup_left_panel_backdrop()

	# Initialize display
	_update_health_display(100, 100)
	low_health_vignette.visible = false

	# Apply outlines to scene-defined labels for readability against any background
	if health_label:
		apply_text_outline(health_label)
	if coins_label:
		apply_text_outline(coins_label)
	if depth_label:
		apply_text_outline(depth_label)

	# Connect to GameManager signals
	if GameManager:
		GameManager.coins_changed.connect(_on_coins_changed)
		GameManager.depth_updated.connect(_on_depth_updated)
		GameManager.depth_milestone_reached.connect(_on_depth_milestone_reached)
		GameManager.layer_entered.connect(_on_layer_entered)
		GameManager.building_unlocked.connect(_on_building_unlocked)
		_update_coins_display(GameManager.get_coins())
		_update_depth_display(0)

	# Connect text size changes for accessibility
	if SettingsManager:
		SettingsManager.text_size_changed.connect(_on_text_size_changed)
		# Apply initial text scale
		call_deferred("_apply_text_scale")

	# Create milestone notification
	_setup_milestone_notification()

	# Connect pause button
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)

	# Create quick-sell button
	_setup_quick_sell_button()

	# Create tool indicator
	_setup_tool_indicator()

	# Create tool durability indicator
	_setup_tool_durability()

	# Create inventory slots indicator
	_setup_inventory_indicator()

	# Connect inventory changes to update quick-sell button and inventory indicator
	if InventoryManager:
		InventoryManager.inventory_changed.connect(_update_quick_sell_button)
		InventoryManager.inventory_changed.connect(_update_inventory_indicator)
		InventoryManager.inventory_changed.connect(_check_guidance_prompts)

	# Connect tool changes to update tool indicator
	if PlayerData:
		PlayerData.tool_changed.connect(_on_tool_changed)
		PlayerData.dive_depth_updated.connect(_on_dive_depth_updated)
		_update_tool_indicator()

	# Create depth bonus indicator
	_setup_depth_bonus_indicator()

	# Create next upgrade goal display
	_setup_upgrade_goal_display()

	# Create time since save indicator
	_setup_save_indicator()

	# Create ladder quick-slot
	_setup_ladder_quickslot()

	# Create rope quick-slot
	_setup_rope_quickslot()

	# Create teleport scroll quick-slot
	_setup_teleport_quickslot()

	# Create mining progress indicator
	_setup_mining_progress()

	# Connect save events
	if SaveManager:
		SaveManager.save_completed.connect(_on_save_completed)

	# Create guidance toast system
	_setup_guidance_toast()


func _process(delta: float) -> void:
	# Pulse the low health vignette
	if low_health_vignette.visible:
		_vignette_pulse_time += delta * VIGNETTE_PULSE_SPEED
		var pulse := (sin(_vignette_pulse_time) + 1.0) / 2.0  # 0 to 1
		var alpha := lerpf(VIGNETTE_MIN_ALPHA, VIGNETTE_MAX_ALPHA, pulse)
		low_health_vignette.modulate.a = alpha

	# Update save indicator periodically
	_save_timer += delta
	if _save_timer >= SAVE_UPDATE_INTERVAL:
		_save_timer = 0.0
		_update_save_indicator()

	# Update mining progress indicator every frame
	_update_mining_progress()


## Connect to a player's HP signals
func connect_to_player(player: Node) -> void:
	if player.has_signal("hp_changed"):
		player.hp_changed.connect(_on_player_hp_changed)
	if player.has_signal("player_died"):
		player.player_died.connect(_on_player_died)

	# Track player for mining progress indicator
	track_player_for_mining(player)


## Disconnect from a player's HP signals
func disconnect_from_player(player: Node) -> void:
	if player.has_signal("hp_changed") and player.hp_changed.is_connected(_on_player_hp_changed):
		player.hp_changed.disconnect(_on_player_hp_changed)
	if player.has_signal("player_died") and player.player_died.is_connected(_on_player_died):
		player.player_died.disconnect(_on_player_died)


func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
	_update_health_display(current_hp, max_hp)


func _on_player_died(_cause: String) -> void:
	# Flash the health bar or show death indicator
	_update_health_display(0, _last_max_hp if _last_max_hp > 0 else 100)


func _update_health_display(current_hp: int, max_hp: int) -> void:
	_last_hp = current_hp
	_last_max_hp = max_hp

	# Update progress bar
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current_hp

		# Color the bar based on health percentage
		var hp_percent := float(current_hp) / float(max_hp) if max_hp > 0 else 0.0
		if hp_percent <= 0.25:
			# Critical - red
			health_bar.modulate = Color(1.0, 0.2, 0.2)
		elif hp_percent <= 0.5:
			# Low - orange
			health_bar.modulate = Color(1.0, 0.6, 0.2)
		else:
			# Normal - green
			health_bar.modulate = Color(0.3, 0.8, 0.3)

	# Update label
	if health_label:
		health_label.text = "HP %d/%d" % [current_hp, max_hp]

	# Show/hide low health warning
	var is_low := float(current_hp) / float(max_hp) <= 0.25 if max_hp > 0 else false
	if low_health_vignette:
		if is_low and current_hp > 0:
			if not low_health_vignette.visible:
				low_health_vignette.visible = true
				_vignette_pulse_time = 0.0
		else:
			low_health_vignette.visible = false


## Force refresh the display
func refresh() -> void:
	if _last_hp >= 0 and _last_max_hp > 0:
		_update_health_display(_last_hp, _last_max_hp)


func _on_coins_changed(new_amount: int) -> void:
	_update_coins_display(new_amount)
	_check_guidance_prompts()


func _on_depth_updated(depth_meters: int) -> void:
	_update_depth_display(depth_meters)


func _update_coins_display(amount: int) -> void:
	if coins_label:
		coins_label.text = "$%d" % amount

		# Pulse animation when coins increase
		if _last_coins >= 0 and amount > _last_coins:
			_pulse_coins_label()
		_last_coins = amount


func _pulse_coins_label() -> void:
	## Brief scale pulse on the coins label
	if coins_label == null:
		return

	# Skip if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		return

	# Cancel any existing animation
	if _coins_tween and _coins_tween.is_valid():
		_coins_tween.kill()

	# Pulse up and back down
	coins_label.pivot_offset = coins_label.size / 2
	coins_label.scale = Vector2(1.0, 1.0)

	_coins_tween = create_tween()
	_coins_tween.tween_property(coins_label, "scale", Vector2(1.2, 1.2), 0.1) \
		.set_ease(Tween.EASE_OUT)
	_coins_tween.tween_property(coins_label, "scale", Vector2(1.0, 1.0), 0.15) \
		.set_ease(Tween.EASE_IN_OUT)


func _update_depth_display(depth: int) -> void:
	if depth_label:
		# Show depth with current layer name
		var layer_name := GameManager.get_current_layer_name() if GameManager else ""
		if layer_name != "":
			depth_label.text = "%dm (%s)" % [depth, layer_name]
		else:
			depth_label.text = "%dm" % depth


func _on_pause_pressed() -> void:
	if GameManager:
		GameManager.pause_game()


# ============================================
# DEPTH BONUS INDICATOR
# ============================================

func _setup_depth_bonus_indicator() -> void:
	## Create indicator showing depth-based sell bonus when underground
	depth_bonus_label = Label.new()
	depth_bonus_label.name = "DepthBonusLabel"

	# Position below the depth label
	depth_bonus_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	depth_bonus_label.position = Vector2(16, 72)  # Below depth label
	depth_bonus_label.custom_minimum_size = Vector2(200, 20)

	# Style the label
	depth_bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	depth_bonus_label.add_theme_font_size_override("font_size", 14)
	depth_bonus_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))  # Green for bonus
	apply_text_outline(depth_bonus_label)

	add_child(depth_bonus_label)

	# Initial update
	_update_depth_bonus_indicator()


func _on_dive_depth_updated(_depth: int) -> void:
	_update_depth_bonus_indicator()
	_update_quick_sell_button()  # Also update sell button with new multiplier


func _update_depth_bonus_indicator() -> void:
	## Update the depth bonus display
	if depth_bonus_label == null:
		return
	if PlayerData == null:
		depth_bonus_label.visible = false
		return

	var multiplier := PlayerData.get_depth_sell_multiplier()
	if multiplier > 1.0:
		var bonus_pct := int((multiplier - 1.0) * 100)
		depth_bonus_label.text = "Sell Bonus: +%d%%" % bonus_pct
		depth_bonus_label.visible = true
	else:
		depth_bonus_label.visible = false


# ============================================
# QUICK-SELL BUTTON
# ============================================

func _setup_quick_sell_button() -> void:
	## Create and position the quick-sell button
	quick_sell_button = Button.new()
	quick_sell_button.name = "QuickSellButton"
	quick_sell_button.text = "Sell All"
	quick_sell_button.visible = false  # Hidden until items exist

	# Position below inventory label
	quick_sell_button.position = Vector2(16, 170)
	quick_sell_button.custom_minimum_size = Vector2(120, 36)

	# Style the button
	quick_sell_button.add_theme_color_override("font_color", Color.GOLD)

	add_child(quick_sell_button)
	quick_sell_button.pressed.connect(_on_quick_sell_pressed)

	# Initial update
	_update_quick_sell_button()


func _update_quick_sell_button() -> void:
	## Update button visibility and text based on inventory
	if quick_sell_button == null:
		return

	var total_value := _calculate_sellable_value()

	if total_value > 0:
		# Show depth bonus percentage if applicable
		var multiplier := PlayerData.get_depth_sell_multiplier() if PlayerData else 1.0
		if multiplier > 1.0:
			var bonus_pct := int((multiplier - 1.0) * 100)
			quick_sell_button.text = "Sell All ($%d +%d%%)" % [total_value, bonus_pct]
		else:
			quick_sell_button.text = "Sell All ($%d)" % total_value
		quick_sell_button.visible = true
	else:
		quick_sell_button.visible = false


func _calculate_sellable_value() -> int:
	## Calculate total value of sellable items in inventory (with depth multiplier)
	if InventoryManager == null:
		return 0

	var base_total := 0
	for slot in InventoryManager.slots:
		if slot.is_empty() or slot.item == null:
			continue
		if slot.item.category in ["ore", "gem"]:
			base_total += slot.item.sell_value * slot.quantity

	# Apply depth multiplier
	var multiplier := PlayerData.get_depth_sell_multiplier() if PlayerData else 1.0
	return int(base_total * multiplier)


func _on_quick_sell_pressed() -> void:
	## Sell all ore and gems instantly (with depth multiplier)
	if InventoryManager == null or GameManager == null:
		return

	var base_total := 0
	var items_to_remove := []

	for slot in InventoryManager.slots:
		if slot.is_empty() or slot.item == null:
			continue
		if slot.item.category in ["ore", "gem"]:
			base_total += slot.item.sell_value * slot.quantity
			if slot.item not in items_to_remove:
				items_to_remove.append(slot.item)

	# Apply depth multiplier
	var multiplier := PlayerData.get_depth_sell_multiplier() if PlayerData else 1.0
	var total := int(base_total * multiplier)

	if total > 0:
		# Remove all sellable items
		for item in items_to_remove:
			InventoryManager.remove_all_of_item(item)

		# Add coins
		GameManager.add_coins(total)

		# Track for achievements
		if AchievementManager:
			AchievementManager.track_sale(total)

		# Auto-save
		if SaveManager:
			SaveManager.save_game()

		print("[HUD] Quick-sold items for $%d" % total)

	_update_quick_sell_button()


# ============================================
# TOOL INDICATOR
# ============================================

func _setup_tool_indicator() -> void:
	## Create and position the tool indicator label
	tool_label = Label.new()
	tool_label.name = "ToolLabel"

	# Position below the coins label (left side)
	tool_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	tool_label.position = Vector2(16, 96)
	tool_label.custom_minimum_size = Vector2(200, 20)

	# Style the label
	tool_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	tool_label.add_theme_font_size_override("font_size", 16)
	tool_label.add_theme_color_override("font_color", Color.WHITE)
	apply_text_outline(tool_label)

	add_child(tool_label)


func _on_tool_changed(_tool_data) -> void:
	_update_tool_indicator()
	_update_tool_durability()


func _update_tool_indicator() -> void:
	## Update tool indicator with current equipped tool
	if tool_label == null:
		return
	if PlayerData == null:
		tool_label.text = ""
		return

	var tool_data = PlayerData.get_equipped_tool()
	if tool_data != null:
		# Show tool name and damage stat
		var dmg := int(tool_data.damage)
		tool_label.text = "%s (DMG:%d)" % [tool_data.display_name, dmg]
	else:
		tool_label.text = "Tool: None"


# ============================================
# TOOL DURABILITY INDICATOR
# ============================================

func _setup_tool_durability() -> void:
	## Create the tool durability bar
	tool_durability_container = Control.new()
	tool_durability_container.name = "ToolDurabilityContainer"
	tool_durability_container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	tool_durability_container.position = Vector2(-200, 85)
	tool_durability_container.custom_minimum_size = Vector2(184, 20)
	add_child(tool_durability_container)

	# Durability bar
	tool_durability_bar = ProgressBar.new()
	tool_durability_bar.name = "DurabilityBar"
	tool_durability_bar.position = Vector2(0, 0)
	tool_durability_bar.custom_minimum_size = Vector2(140, 12)
	tool_durability_bar.show_percentage = false
	tool_durability_bar.max_value = 100.0
	tool_durability_bar.value = 100.0
	tool_durability_container.add_child(tool_durability_bar)

	# Durability label
	tool_durability_label = Label.new()
	tool_durability_label.name = "DurabilityLabel"
	tool_durability_label.position = Vector2(145, -2)
	tool_durability_label.custom_minimum_size = Vector2(39, 16)
	tool_durability_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tool_durability_label.add_theme_font_size_override("font_size", 12)
	tool_durability_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	apply_text_outline(tool_durability_label)
	tool_durability_container.add_child(tool_durability_label)

	# Hide by default (only show if tool has durability)
	tool_durability_container.visible = false


func _update_tool_durability() -> void:
	## Update tool durability display
	if tool_durability_container == null or tool_durability_bar == null:
		return
	if PlayerData == null:
		tool_durability_container.visible = false
		return

	var tool_data = PlayerData.get_equipped_tool()
	if tool_data == null or tool_data.max_durability == 0:
		# Tool has infinite durability, hide the bar
		tool_durability_container.visible = false
		return

	# Get current durability from PlayerData
	var current_durability: int = PlayerData.get_tool_durability()
	var max_durability: int = tool_data.max_durability

	tool_durability_container.visible = true
	tool_durability_bar.max_value = max_durability
	tool_durability_bar.value = current_durability

	# Update label
	if tool_durability_label:
		tool_durability_label.text = "%d%%" % int(float(current_durability) / float(max_durability) * 100.0)

	# Color based on durability level
	var durability_ratio := float(current_durability) / float(max_durability)
	if durability_ratio <= 0.1:
		tool_durability_bar.modulate = Color.RED
		tool_durability_label.add_theme_color_override("font_color", Color.RED)
	elif durability_ratio <= 0.25:
		tool_durability_bar.modulate = Color.ORANGE
		tool_durability_label.add_theme_color_override("font_color", Color.ORANGE)
	elif durability_ratio <= 0.5:
		tool_durability_bar.modulate = Color.YELLOW
		tool_durability_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		tool_durability_bar.modulate = Color(0.4, 0.8, 0.4)
		tool_durability_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))


# ============================================
# INVENTORY INDICATOR
# ============================================

func _setup_inventory_indicator() -> void:
	## Create and position the inventory slots label
	inventory_label = Label.new()
	inventory_label.name = "InventoryLabel"

	# Position below tool label
	inventory_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	inventory_label.position = Vector2(16, 118)
	inventory_label.custom_minimum_size = Vector2(100, 24)

	# Style the label
	inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	inventory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_label.add_theme_font_size_override("font_size", 20)
	apply_text_outline(inventory_label)

	add_child(inventory_label)

	# Initial update
	_update_inventory_indicator()


func _update_inventory_indicator() -> void:
	## Update inventory slots display (X/Y format)
	if inventory_label == null:
		return
	if InventoryManager == null:
		inventory_label.text = "Bag: 0/8"
		return

	var used := InventoryManager.get_used_slots()
	var total := InventoryManager.get_total_slots()

	inventory_label.text = "Bag: %d/%d" % [used, total]

	# Color code based on fullness
	var fill_ratio := float(used) / float(total) if total > 0 else 0.0
	if fill_ratio >= 1.0:
		inventory_label.add_theme_color_override("font_color", Color.RED)
	elif fill_ratio >= 0.875:  # 7/8
		inventory_label.add_theme_color_override("font_color", Color.ORANGE)
	else:
		inventory_label.add_theme_color_override("font_color", Color.WHITE)


# ============================================
# LEFT PANEL BACKDROP
# ============================================

func _setup_left_panel_backdrop() -> void:
	## Create a dark semi-transparent panel behind the left HUD elements
	left_panel_bg = ColorRect.new()
	left_panel_bg.name = "LeftPanelBackdrop"
	left_panel_bg.set_anchors_preset(Control.PRESET_TOP_LEFT)
	left_panel_bg.position = Vector2(8, 8)
	left_panel_bg.size = Vector2(330, 166)  # Wider to match HP bar, includes all status info
	left_panel_bg.color = HUD_PANEL_COLOR
	left_panel_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left_panel_bg)
	# Move to back so other elements render on top
	move_child(left_panel_bg, 0)


# ============================================
# MILESTONE NOTIFICATIONS
# ============================================

func _setup_milestone_notification() -> void:
	## Create the milestone notification UI
	milestone_notification = MilestoneNotificationScene.instantiate()
	milestone_notification.name = "MilestoneNotification"
	add_child(milestone_notification)


func _on_depth_milestone_reached(depth: int) -> void:
	## Show notification when a depth milestone is reached
	if milestone_notification and milestone_notification.has_method("show_milestone"):
		milestone_notification.show_milestone(depth)
	print("[HUD] Depth milestone notification: %dm" % depth)


func _on_layer_entered(layer_name: String) -> void:
	## Show notification when entering a new layer
	if milestone_notification and milestone_notification.has_method("show_layer_entered"):
		milestone_notification.show_layer_entered(layer_name)
	print("[HUD] Layer entered notification: %s" % layer_name)


func _on_building_unlocked(building_id: String, building_name: String) -> void:
	## Show notification when a building is unlocked
	if milestone_notification and milestone_notification.has_method("show_building_unlocked"):
		milestone_notification.show_building_unlocked(building_name)
	print("[HUD] Building unlocked notification: %s" % building_name)


# ============================================
# NEXT UPGRADE GOAL DISPLAY
# ============================================

func _setup_upgrade_goal_display() -> void:
	## Create the next upgrade goal display container
	upgrade_goal_container = Control.new()
	upgrade_goal_container.name = "UpgradeGoalContainer"
	upgrade_goal_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	upgrade_goal_container.position = Vector2(8, 178)  # Aligned with main panel, closer spacing
	upgrade_goal_container.custom_minimum_size = Vector2(330, 55)
	add_child(upgrade_goal_container)

	# Add dark background to this container
	var upgrade_bg := ColorRect.new()
	upgrade_bg.name = "UpgradeBackground"
	upgrade_bg.position = Vector2(0, 0)
	upgrade_bg.size = Vector2(330, 55)
	upgrade_bg.color = HUD_PANEL_COLOR
	upgrade_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	upgrade_goal_container.add_child(upgrade_bg)

	# Create label for upgrade name and cost
	upgrade_goal_label = Label.new()
	upgrade_goal_label.name = "UpgradeGoalLabel"
	upgrade_goal_label.position = Vector2(8, 4)
	upgrade_goal_label.custom_minimum_size = Vector2(314, 20)
	upgrade_goal_label.add_theme_font_size_override("font_size", 14)
	upgrade_goal_label.add_theme_color_override("font_color", Color.WHITE)
	apply_text_outline(upgrade_goal_label)
	upgrade_goal_container.add_child(upgrade_goal_label)

	# Create progress bar
	upgrade_goal_progress = ProgressBar.new()
	upgrade_goal_progress.name = "UpgradeGoalProgress"
	upgrade_goal_progress.position = Vector2(8, 28)
	upgrade_goal_progress.custom_minimum_size = Vector2(314, 18)
	upgrade_goal_progress.show_percentage = false
	upgrade_goal_container.add_child(upgrade_goal_progress)

	# Create progress value label (shows $current/$goal)
	upgrade_goal_value_label = Label.new()
	upgrade_goal_value_label.name = "UpgradeGoalValueLabel"
	upgrade_goal_value_label.position = Vector2(8, 28)
	upgrade_goal_value_label.custom_minimum_size = Vector2(314, 18)
	upgrade_goal_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrade_goal_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	upgrade_goal_value_label.add_theme_font_size_override("font_size", 11)
	upgrade_goal_value_label.add_theme_color_override("font_color", Color.WHITE)
	apply_text_outline(upgrade_goal_value_label, 2)
	upgrade_goal_container.add_child(upgrade_goal_value_label)

	# Initial update
	_update_upgrade_goal_display()

	# Connect to coin changes
	if GameManager:
		GameManager.coins_changed.connect(_on_coins_changed_for_upgrade)


func _on_coins_changed_for_upgrade(_amount: int) -> void:
	_update_upgrade_goal_display()


func _update_upgrade_goal_display() -> void:
	## Update the next upgrade goal with current progress
	if upgrade_goal_label == null or upgrade_goal_progress == null:
		return
	if PlayerData == null or GameManager == null:
		upgrade_goal_container.visible = false
		return

	# Get the next tool upgrade
	var next_tool = PlayerData.get_next_tool_upgrade()
	if next_tool == null:
		# All tools unlocked
		upgrade_goal_container.visible = false
		return

	upgrade_goal_container.visible = true
	var current_coins := GameManager.get_coins()
	var cost: int = next_tool.cost
	var can_afford := current_coins >= cost
	var depth_ok: bool = PlayerData.max_depth_reached >= next_tool.unlock_depth

	# Update label - show tool name, damage, and requirements
	var next_dmg := int(next_tool.damage)
	if not depth_ok:
		upgrade_goal_label.text = "Next: %s (DMG:%d) - Dig to %dm" % [next_tool.display_name, next_dmg, next_tool.unlock_depth]
		upgrade_goal_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	elif can_afford:
		upgrade_goal_label.text = "Next: %s (DMG:%d) - READY!" % [next_tool.display_name, next_dmg]
		upgrade_goal_label.add_theme_color_override("font_color", Color.GREEN)
		_pulse_upgrade_label()
	else:
		upgrade_goal_label.text = "Next: %s (DMG:%d)" % [next_tool.display_name, next_dmg]
		upgrade_goal_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))

	# Update progress bar
	upgrade_goal_progress.max_value = cost
	upgrade_goal_progress.value = mini(current_coins, cost)

	# Update value label
	if upgrade_goal_value_label:
		upgrade_goal_value_label.text = "$%d / $%d" % [mini(current_coins, cost), cost]

	# Color progress bar
	if can_afford:
		upgrade_goal_progress.modulate = Color.GREEN
	elif float(current_coins) / float(cost) >= 0.75:
		upgrade_goal_progress.modulate = Color.YELLOW
	else:
		upgrade_goal_progress.modulate = Color.WHITE


func _pulse_upgrade_label() -> void:
	## Brief pulse when upgrade becomes affordable
	if upgrade_goal_label == null:
		return
	if SettingsManager and SettingsManager.reduced_motion:
		return

	if _upgrade_goal_tween and _upgrade_goal_tween.is_valid():
		return  # Don't interrupt existing pulse

	upgrade_goal_label.pivot_offset = upgrade_goal_label.size / 2
	_upgrade_goal_tween = create_tween()
	_upgrade_goal_tween.tween_property(upgrade_goal_label, "scale", Vector2(1.1, 1.1), 0.15)
	_upgrade_goal_tween.tween_property(upgrade_goal_label, "scale", Vector2(1.0, 1.0), 0.15)


# ============================================
# TIME SINCE SAVE INDICATOR
# ============================================

func _setup_save_indicator() -> void:
	## Create the save time indicator label
	save_indicator_label = Label.new()
	save_indicator_label.name = "SaveIndicatorLabel"

	# Position below inventory label
	save_indicator_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	save_indicator_label.position = Vector2(16, 142)
	save_indicator_label.custom_minimum_size = Vector2(150, 18)

	# Style
	save_indicator_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	save_indicator_label.add_theme_font_size_override("font_size", 12)
	save_indicator_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))  # Bright green
	apply_text_outline(save_indicator_label)

	add_child(save_indicator_label)

	# Initial update
	_update_save_indicator()


func _update_save_indicator() -> void:
	## Update the save indicator - only show briefly after save to reduce clutter
	if save_indicator_label == null:
		return
	if SaveManager == null or not SaveManager.is_game_loaded():
		save_indicator_label.visible = false
		return

	var seconds := SaveManager.get_seconds_since_last_save()

	# Only show for 10 seconds after save, then hide
	if seconds < 0:
		save_indicator_label.visible = true
		save_indicator_label.text = "Not saved"
		save_indicator_label.add_theme_color_override("font_color", Color.RED)
		save_indicator_label.modulate.a = 1.0
	elif seconds < 5:
		save_indicator_label.visible = true
		save_indicator_label.text = "Saved"
		save_indicator_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		save_indicator_label.modulate.a = 1.0
	elif seconds < 10:
		save_indicator_label.visible = true
		save_indicator_label.text = "Saved"
		save_indicator_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		# Fade out
		save_indicator_label.modulate.a = 1.0 - ((seconds - 5.0) / 5.0)
	else:
		save_indicator_label.visible = false


func _on_save_completed(success: bool) -> void:
	## Flash the save indicator when save completes
	if not success or save_indicator_label == null:
		return

	# Immediate update
	_update_save_indicator()

	# Flash animation
	if SettingsManager and SettingsManager.reduced_motion:
		return

	var tween := create_tween()
	tween.tween_property(save_indicator_label, "modulate", Color(1.5, 1.5, 1.5), 0.1)
	tween.tween_property(save_indicator_label, "modulate", Color.WHITE, 0.2)


# ============================================
# LADDER QUICK-SLOT
# ============================================

const LADDER_ITEM_ID := "ladder"

func _setup_ladder_quickslot() -> void:
	## Create the ladder quick-slot UI
	ladder_quickslot = Control.new()
	ladder_quickslot.name = "LadderQuickSlot"
	ladder_quickslot.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	ladder_quickslot.position = Vector2(-72, 90)
	ladder_quickslot.custom_minimum_size = Vector2(56, 56)
	add_child(ladder_quickslot)

	# Background panel
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = HUD_BUTTON_COLOR
	bg.size = Vector2(56, 56)
	ladder_quickslot.add_child(bg)

	# Ladder icon label
	var icon_label := Label.new()
	icon_label.name = "IconLabel"
	icon_label.text = "LADDER"
	icon_label.position = Vector2(2, 4)
	icon_label.add_theme_font_size_override("font_size", 11)
	icon_label.add_theme_color_override("font_color", Color.WHITE)
	ladder_quickslot.add_child(icon_label)

	# Count label
	ladder_count_label = Label.new()
	ladder_count_label.name = "CountLabel"
	ladder_count_label.position = Vector2(0, 36)
	ladder_count_label.custom_minimum_size = Vector2(56, 18)
	ladder_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ladder_count_label.add_theme_font_size_override("font_size", 14)
	ladder_count_label.add_theme_color_override("font_color", Color.WHITE)
	ladder_quickslot.add_child(ladder_count_label)

	# Touch button (invisible overlay)
	ladder_button = Button.new()
	ladder_button.name = "LadderButton"
	ladder_button.flat = true
	ladder_button.size = Vector2(56, 56)
	ladder_button.pressed.connect(_on_ladder_quickslot_pressed)
	ladder_quickslot.add_child(ladder_button)

	# Quick-buy button (small button below the quickslot)
	ladder_buy_button = Button.new()
	ladder_buy_button.name = "LadderBuyButton"
	ladder_buy_button.text = "+$%d" % LADDER_COST
	ladder_buy_button.position = Vector2(0, 58)  # Below the quickslot
	ladder_buy_button.custom_minimum_size = Vector2(56, 26)
	ladder_buy_button.add_theme_font_size_override("font_size", 11)
	ladder_buy_button.pressed.connect(_on_ladder_quick_buy_pressed)
	ladder_quickslot.add_child(ladder_buy_button)

	# Connect inventory changes
	if InventoryManager:
		InventoryManager.inventory_changed.connect(_update_ladder_quickslot)

	# Connect coin changes to update buy button availability
	if GameManager:
		GameManager.coins_changed.connect(_update_ladder_buy_button)
		GameManager.depth_updated.connect(_on_depth_for_ladder_buy)

	# Initial update
	_update_ladder_quickslot()
	_update_ladder_buy_button()


func _update_ladder_quickslot() -> void:
	## Update ladder count display
	if ladder_count_label == null or ladder_quickslot == null:
		return

	var ladder_count := _get_ladder_count()

	if ladder_count > 0:
		ladder_count_label.text = "x%d" % ladder_count
		ladder_count_label.add_theme_color_override("font_color", Color.WHITE)
		ladder_quickslot.modulate = Color.WHITE
	else:
		ladder_count_label.text = "x0"
		ladder_count_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		ladder_quickslot.modulate = Color(0.7, 0.7, 0.7, 1.0)  # Less dim, still opaque


func _get_ladder_count() -> int:
	## Get the number of ladders in inventory
	if InventoryManager == null:
		return 0

	for slot in InventoryManager.slots:
		if slot.is_empty() or slot.item == null:
			continue
		if slot.item.id == LADDER_ITEM_ID:
			return slot.quantity

	return 0


func _on_ladder_quickslot_pressed() -> void:
	## Attempt to place a ladder at the player's position
	if _get_ladder_count() <= 0:
		return

	# Emit signal for player to handle ladder placement
	# The test_level.gd will connect this to the player
	if has_signal("ladder_place_requested"):
		emit_signal("ladder_place_requested")
	else:
		# Fallback: find player and call place_ladder directly
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("place_ladder_at_position"):
			player.place_ladder_at_position()


## Signal for ladder placement request
signal ladder_place_requested


## Update ladder buy button visibility and state
func _update_ladder_buy_button(_arg = null) -> void:
	if ladder_buy_button == null:
		return

	# Only visible at surface (depth 0) with enough coins
	var at_surface := GameManager.current_depth == 0 if GameManager else false
	var can_afford := GameManager.can_afford(LADDER_COST) if GameManager else false

	if at_surface and can_afford:
		ladder_buy_button.visible = true
		ladder_buy_button.disabled = false
	elif at_surface:
		# At surface but can't afford - show disabled
		ladder_buy_button.visible = true
		ladder_buy_button.disabled = true
	else:
		# Underground - hide completely
		ladder_buy_button.visible = false


func _on_depth_for_ladder_buy(depth: int) -> void:
	## Update buy button when depth changes
	_update_ladder_buy_button()


func _on_ladder_quick_buy_pressed() -> void:
	## Quick-buy a ladder from the HUD
	if GameManager == null or InventoryManager == null or DataRegistry == null:
		return

	# Verify at surface and can afford
	if GameManager.current_depth != 0:
		return
	if not GameManager.can_afford(LADDER_COST):
		return

	# Purchase
	if GameManager.spend_coins(LADDER_COST):
		var ladder_item = DataRegistry.get_item("ladder")
		if ladder_item:
			InventoryManager.add_item(ladder_item, 1)
			print("[HUD] Quick-bought ladder for $%d" % LADDER_COST)

			# Show brief confirmation toast
			show_guidance_toast("+1 Ladder!", "+", 1.5)

			# Update displays
			_update_ladder_quickslot()
			_update_ladder_buy_button()

			# Auto-save
			if SaveManager:
				SaveManager.save_game()


# ============================================
# ROPE QUICK-SLOT
# ============================================

const ROPE_ITEM_ID := "rope"

func _setup_rope_quickslot() -> void:
	## Create the rope quick-slot UI
	rope_quickslot = Control.new()
	rope_quickslot.name = "RopeQuickSlot"
	rope_quickslot.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	rope_quickslot.position = Vector2(-72, 182)  # Below ladder (adjusted for buy button)
	rope_quickslot.custom_minimum_size = Vector2(56, 56)
	add_child(rope_quickslot)

	# Background panel
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = HUD_BUTTON_COLOR
	bg.size = Vector2(56, 56)
	rope_quickslot.add_child(bg)

	# Rope icon (text abbreviation)
	var icon_label := Label.new()
	icon_label.name = "IconLabel"
	icon_label.text = "ROPE"
	icon_label.position = Vector2(4, 8)
	icon_label.add_theme_font_size_override("font_size", 16)
	icon_label.add_theme_color_override("font_color", Color.WHITE)
	rope_quickslot.add_child(icon_label)

	# Count label
	rope_count_label = Label.new()
	rope_count_label.name = "CountLabel"
	rope_count_label.position = Vector2(0, 36)
	rope_count_label.custom_minimum_size = Vector2(56, 18)
	rope_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rope_count_label.add_theme_font_size_override("font_size", 14)
	rope_count_label.add_theme_color_override("font_color", Color.WHITE)
	rope_quickslot.add_child(rope_count_label)

	# Touch button (invisible overlay)
	rope_button = Button.new()
	rope_button.name = "RopeButton"
	rope_button.flat = true
	rope_button.size = Vector2(56, 56)
	rope_button.pressed.connect(_on_rope_quickslot_pressed)
	rope_quickslot.add_child(rope_button)

	# Connect inventory changes
	if InventoryManager:
		InventoryManager.inventory_changed.connect(_update_rope_quickslot)

	# Initial update
	_update_rope_quickslot()


func _update_rope_quickslot() -> void:
	## Update rope count display
	if rope_count_label == null or rope_quickslot == null:
		return

	var rope_count := _get_rope_count()

	if rope_count > 0:
		rope_count_label.text = "x%d" % rope_count
		rope_count_label.add_theme_color_override("font_color", Color.WHITE)
		rope_quickslot.modulate = Color.WHITE
	else:
		rope_count_label.text = "x0"
		rope_count_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		rope_quickslot.modulate = Color(0.7, 0.7, 0.7, 1.0)


func _get_rope_count() -> int:
	## Get the number of ropes in inventory
	if InventoryManager == null:
		return 0
	return InventoryManager.get_item_count_by_id(ROPE_ITEM_ID)


func _on_rope_quickslot_pressed() -> void:
	## Attempt to use a rope
	if _get_rope_count() <= 0:
		return

	# Find player and call use_rope
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("use_rope"):
		player.use_rope()


# ============================================
# TELEPORT SCROLL QUICK-SLOT
# ============================================

const TELEPORT_ITEM_ID := "teleport_scroll"

func _setup_teleport_quickslot() -> void:
	## Create the teleport scroll quick-slot UI
	teleport_quickslot = Control.new()
	teleport_quickslot.name = "TeleportQuickSlot"
	teleport_quickslot.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	teleport_quickslot.position = Vector2(-72, 244)  # Below rope (adjusted for buy button)
	teleport_quickslot.custom_minimum_size = Vector2(56, 56)
	add_child(teleport_quickslot)

	# Background panel
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = HUD_BUTTON_COLOR
	bg.size = Vector2(56, 56)
	teleport_quickslot.add_child(bg)

	# Teleport icon label
	var icon_label := Label.new()
	icon_label.name = "IconLabel"
	icon_label.text = "WARP"
	icon_label.position = Vector2(4, 6)
	icon_label.add_theme_font_size_override("font_size", 14)
	icon_label.add_theme_color_override("font_color", Color.WHITE)
	teleport_quickslot.add_child(icon_label)

	# Count label
	teleport_count_label = Label.new()
	teleport_count_label.name = "CountLabel"
	teleport_count_label.position = Vector2(0, 36)
	teleport_count_label.custom_minimum_size = Vector2(56, 18)
	teleport_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	teleport_count_label.add_theme_font_size_override("font_size", 14)
	teleport_count_label.add_theme_color_override("font_color", Color.WHITE)
	teleport_quickslot.add_child(teleport_count_label)

	# Touch button (invisible overlay)
	teleport_button = Button.new()
	teleport_button.name = "TeleportButton"
	teleport_button.flat = true
	teleport_button.size = Vector2(56, 56)
	teleport_button.pressed.connect(_on_teleport_quickslot_pressed)
	teleport_quickslot.add_child(teleport_button)

	# Connect inventory changes
	if InventoryManager:
		InventoryManager.inventory_changed.connect(_update_teleport_quickslot)

	# Initial update
	_update_teleport_quickslot()


func _update_teleport_quickslot() -> void:
	## Update teleport scroll count display
	if teleport_count_label == null or teleport_quickslot == null:
		return

	var teleport_count := _get_teleport_count()

	if teleport_count > 0:
		teleport_count_label.text = "x%d" % teleport_count
		teleport_count_label.add_theme_color_override("font_color", Color.WHITE)
		teleport_quickslot.modulate = Color.WHITE
	else:
		teleport_count_label.text = "x0"
		teleport_count_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		teleport_quickslot.modulate = Color(0.7, 0.7, 0.7, 1.0)


func _get_teleport_count() -> int:
	## Get the number of teleport scrolls in inventory
	if InventoryManager == null:
		return 0
	return InventoryManager.get_item_count_by_id(TELEPORT_ITEM_ID)


func _on_teleport_quickslot_pressed() -> void:
	## Attempt to use a teleport scroll
	if _get_teleport_count() <= 0:
		return

	# Find player and call use_teleport_scroll
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("use_teleport_scroll"):
		player.use_teleport_scroll()


# ============================================
# MINING PROGRESS INDICATOR
# ============================================

## Mining progress bar (shows current block mining progress)
var mining_progress_container: Control = null
var mining_progress_bar: ProgressBar = null
var mining_progress_label: Label = null

## Reference to player for mining state tracking
var _tracked_player: Node = null
var _mining_fade_tween: Tween = null


func _setup_mining_progress() -> void:
	## Create the mining progress indicator (positioned at bottom-center to avoid overlap)
	mining_progress_container = Control.new()
	mining_progress_container.name = "MiningProgressContainer"
	mining_progress_container.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	mining_progress_container.position = Vector2(-100, -100)  # 100px above bottom
	mining_progress_container.custom_minimum_size = Vector2(200, 40)
	mining_progress_container.modulate.a = 0.0  # Start hidden
	add_child(mining_progress_container)

	# Background panel
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.1, 0.1, 0.1, 0.85)
	bg.size = Vector2(200, 40)
	mining_progress_container.add_child(bg)

	# Label showing "Mining..."
	mining_progress_label = Label.new()
	mining_progress_label.name = "MiningLabel"
	mining_progress_label.text = "Mining..."
	mining_progress_label.position = Vector2(8, 2)
	mining_progress_label.custom_minimum_size = Vector2(184, 16)
	mining_progress_label.add_theme_font_size_override("font_size", 12)
	mining_progress_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	apply_text_outline(mining_progress_label)
	mining_progress_container.add_child(mining_progress_label)

	# Progress bar
	mining_progress_bar = ProgressBar.new()
	mining_progress_bar.name = "MiningProgressBar"
	mining_progress_bar.position = Vector2(8, 20)
	mining_progress_bar.custom_minimum_size = Vector2(184, 14)
	mining_progress_bar.show_percentage = false
	mining_progress_bar.max_value = 1.0
	mining_progress_bar.value = 0.0
	mining_progress_container.add_child(mining_progress_bar)


func track_player_for_mining(player: Node) -> void:
	## Start tracking a player's mining state for the indicator
	_tracked_player = player


func _update_mining_progress() -> void:
	## Update the mining progress indicator based on player state
	if mining_progress_container == null or mining_progress_bar == null:
		return

	if _tracked_player == null:
		_hide_mining_progress()
		return

	# Check if player is mining
	if not _tracked_player.has_method("get") or _tracked_player.current_state != _tracked_player.State.MINING:
		_hide_mining_progress()
		return

	# Get the mining target and progress
	var mining_target: Vector2i = _tracked_player.mining_target
	var dirt_grid = _tracked_player.dirt_grid
	if dirt_grid == null:
		_hide_mining_progress()
		return

	var progress = dirt_grid.get_block_mining_progress(mining_target)
	if progress < 0:
		_hide_mining_progress()
		return

	# Show and update the progress bar
	_show_mining_progress()
	mining_progress_bar.value = progress

	# Color the progress bar based on progress
	if progress < 0.5:
		mining_progress_bar.modulate = Color(0.8, 0.8, 0.8)
	elif progress < 0.8:
		mining_progress_bar.modulate = Color(0.9, 0.9, 0.5)
	else:
		mining_progress_bar.modulate = Color(0.5, 1.0, 0.5)


func _show_mining_progress() -> void:
	## Show the mining progress indicator with fade in
	if mining_progress_container == null:
		return

	if mining_progress_container.modulate.a >= 1.0:
		return  # Already visible

	if _mining_fade_tween and _mining_fade_tween.is_valid():
		_mining_fade_tween.kill()

	_mining_fade_tween = create_tween()
	_mining_fade_tween.tween_property(mining_progress_container, "modulate:a", 1.0, 0.15)


func _hide_mining_progress() -> void:
	## Hide the mining progress indicator with fade out
	if mining_progress_container == null:
		return

	if mining_progress_container.modulate.a <= 0.0:
		return  # Already hidden

	if _mining_fade_tween and _mining_fade_tween.is_valid():
		_mining_fade_tween.kill()

	_mining_fade_tween = create_tween()
	_mining_fade_tween.tween_property(mining_progress_container, "modulate:a", 0.0, 0.2)


# ============================================
# TEXT SIZE ACCESSIBILITY
# ============================================

## Base font sizes for scaling
const BASE_FONT_SIZES := {
	"health_label": 14,
	"coins_label": 24,
	"depth_label": 24,
	"tool_label": 16,
	"durability_label": 12,
	"inventory_label": 20,
	"upgrade_label": 14,
	"save_indicator": 12,
	"ladder_count": 16,
	"mining_label": 12,
}


func _on_text_size_changed(_scale: float) -> void:
	_apply_text_scale()


func _apply_text_scale() -> void:
	## Apply text size scaling to all HUD labels
	if SettingsManager == null:
		return

	var scale := SettingsManager.get_text_scale()

	# Scale health label
	if health_label:
		health_label.add_theme_font_size_override("font_size", int(BASE_FONT_SIZES["health_label"] * scale))

	# Scale coins label
	if coins_label:
		coins_label.add_theme_font_size_override("font_size", int(BASE_FONT_SIZES["coins_label"] * scale))

	# Scale depth label
	if depth_label:
		depth_label.add_theme_font_size_override("font_size", int(BASE_FONT_SIZES["depth_label"] * scale))

	# Scale tool indicator
	if tool_label:
		tool_label.add_theme_font_size_override("font_size", int(BASE_FONT_SIZES["tool_label"] * scale))

	# Scale durability label
	if tool_durability_label:
		tool_durability_label.add_theme_font_size_override("font_size", int(BASE_FONT_SIZES["durability_label"] * scale))

	# Scale inventory label
	if inventory_label:
		inventory_label.add_theme_font_size_override("font_size", int(BASE_FONT_SIZES["inventory_label"] * scale))

	# Scale upgrade goal label
	if upgrade_goal_label:
		upgrade_goal_label.add_theme_font_size_override("font_size", int(BASE_FONT_SIZES["upgrade_label"] * scale))

	# Scale save indicator
	if save_indicator_label:
		save_indicator_label.add_theme_font_size_override("font_size", int(BASE_FONT_SIZES["save_indicator"] * scale))

	# Scale ladder count
	if ladder_count_label:
		ladder_count_label.add_theme_font_size_override("font_size", int(BASE_FONT_SIZES["ladder_count"] * scale))

	# Scale mining progress label
	if mining_progress_label:
		mining_progress_label.add_theme_font_size_override("font_size", int(BASE_FONT_SIZES["mining_label"] * scale))


# ============================================
# GUIDANCE TOAST SYSTEM (Non-blocking Tutorial Hints)
# ============================================

const GUIDANCE_TOAST_DURATION := 4.0  # Seconds to show each toast
const GUIDANCE_TOAST_FADE := 0.3  # Fade in/out duration

func _setup_guidance_toast() -> void:
	## Create the guidance toast container (appears at top-center, below pause button)
	guidance_toast = Control.new()
	guidance_toast.name = "GuidanceToast"
	guidance_toast.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	guidance_toast.position = Vector2(-340, 10)  # 340px from right edge
	guidance_toast.custom_minimum_size = Vector2(280, 50)
	guidance_toast.modulate.a = 0.0  # Start hidden
	add_child(guidance_toast)

	# Background panel with rounded corners feel
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.15, 0.35, 0.15, 0.95)  # Green-tinted background
	bg.size = Vector2(280, 50)
	guidance_toast.add_child(bg)

	# Icon (arrow or indicator)
	guidance_toast_icon = Label.new()
	guidance_toast_icon.name = "Icon"
	guidance_toast_icon.text = "!"
	guidance_toast_icon.position = Vector2(10, 8)
	guidance_toast_icon.add_theme_font_size_override("font_size", 24)
	guidance_toast_icon.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))  # Gold
	guidance_toast.add_child(guidance_toast_icon)

	# Message label
	guidance_toast_label = Label.new()
	guidance_toast_label.name = "MessageLabel"
	guidance_toast_label.position = Vector2(40, 6)
	guidance_toast_label.custom_minimum_size = Vector2(230, 38)
	guidance_toast_label.add_theme_font_size_override("font_size", 13)
	guidance_toast_label.add_theme_color_override("font_color", Color.WHITE)
	guidance_toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	apply_text_outline(guidance_toast_label, 2)
	guidance_toast.add_child(guidance_toast_label)


## Show a guidance toast message (non-blocking tutorial hint)
func show_guidance_toast(message: String, icon: String = "!", duration: float = GUIDANCE_TOAST_DURATION) -> void:
	if guidance_toast == null or guidance_toast_label == null:
		return

	# Add to queue
	_guidance_toast_queue.append({"message": message, "icon": icon, "duration": duration})

	# If not currently showing, start showing
	if not _guidance_toast_visible:
		_show_next_guidance_toast()


func _show_next_guidance_toast() -> void:
	## Show the next toast from the queue
	if _guidance_toast_queue.is_empty():
		_guidance_toast_visible = false
		return

	var toast_data: Dictionary = _guidance_toast_queue.pop_front()
	guidance_toast_label.text = toast_data["message"]
	guidance_toast_icon.text = toast_data["icon"]

	# Fade in
	_guidance_toast_visible = true
	if _guidance_toast_tween and _guidance_toast_tween.is_valid():
		_guidance_toast_tween.kill()

	_guidance_toast_tween = create_tween()
	_guidance_toast_tween.tween_property(guidance_toast, "modulate:a", 1.0, GUIDANCE_TOAST_FADE)
	_guidance_toast_tween.tween_interval(toast_data["duration"])
	_guidance_toast_tween.tween_property(guidance_toast, "modulate:a", 0.0, GUIDANCE_TOAST_FADE)
	_guidance_toast_tween.tween_callback(_show_next_guidance_toast)


func _hide_guidance_toast() -> void:
	## Immediately hide the current toast
	if _guidance_toast_tween and _guidance_toast_tween.is_valid():
		_guidance_toast_tween.kill()

	if guidance_toast:
		guidance_toast.modulate.a = 0.0
	_guidance_toast_visible = false


## Check and trigger guidance prompts based on game state
## Called after inventory or coin changes
func _check_guidance_prompts() -> void:
	# Skip if FTUE already complete or tutorial already done
	if SaveManager and SaveManager.has_first_upgrade_purchased():
		return  # Player already knows the flow

	# Skip if tutorial overlay is handling things
	if GameManager and GameManager.is_tutorial_active():
		return

	# Check inventory fill level (show hint at 50%+)
	if InventoryManager and not _shown_inventory_half_toast:
		var used := InventoryManager.get_used_slots()
		var total := InventoryManager.get_total_slots()
		var fill_ratio := float(used) / float(total) if total > 0 else 0.0

		if fill_ratio >= 0.5 and _last_inventory_check_fill_ratio < 0.5:
			_shown_inventory_half_toast = true
			show_guidance_toast("Inventory filling up!\nReturn to surface to sell.", "^", 5.0)

		_last_inventory_check_fill_ratio = fill_ratio

	# Check if player can afford upgrade (show hint once)
	if PlayerData and GameManager and not _shown_upgrade_affordable_toast:
		var next_tool = PlayerData.get_next_tool_upgrade()
		if next_tool != null:
			var coins := GameManager.get_coins()
			if coins >= next_tool.cost and _last_coin_check_amount < next_tool.cost:
				_shown_upgrade_affordable_toast = true
				show_guidance_toast("You can afford an upgrade!\nVisit the Blacksmith!", "$", 5.0)

			_last_coin_check_amount = coins


## Override inventory change handler to check guidance
func _update_inventory_indicator_with_guidance() -> void:
	_update_inventory_indicator()
	_check_guidance_prompts()
