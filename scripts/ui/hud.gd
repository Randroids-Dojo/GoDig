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
var _upgrade_goal_tween: Tween = null

## Time since save indicator (created programmatically)
var save_indicator_label: Label = null
var _save_timer: float = 0.0
const SAVE_UPDATE_INTERVAL: float = 1.0  # Update every second

## Ladder quick-slot (created programmatically)
var ladder_quickslot: Control = null
var ladder_count_label: Label = null
var ladder_button: Button = null


func _ready() -> void:
	# Initialize display
	_update_health_display(100, 100)
	low_health_vignette.visible = false

	# Connect to GameManager signals
	if GameManager:
		GameManager.coins_changed.connect(_on_coins_changed)
		GameManager.depth_updated.connect(_on_depth_updated)
		GameManager.depth_milestone_reached.connect(_on_depth_milestone_reached)
		GameManager.layer_entered.connect(_on_layer_entered)
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

	# Connect tool changes to update tool indicator
	if PlayerData:
		PlayerData.tool_changed.connect(_on_tool_changed)
		_update_tool_indicator()

	# Create next upgrade goal display
	_setup_upgrade_goal_display()

	# Create time since save indicator
	_setup_save_indicator()

	# Create ladder quick-slot
	_setup_ladder_quickslot()

	# Create mining progress indicator
	_setup_mining_progress()

	# Connect save events
	if SaveManager:
		SaveManager.save_completed.connect(_on_save_completed)


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
		health_label.text = "%d/%d" % [current_hp, max_hp]

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


func _on_depth_updated(depth_meters: int) -> void:
	_update_depth_display(depth_meters)


func _update_coins_display(amount: int) -> void:
	if coins_label:
		coins_label.text = "Coins: %d" % amount

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
# QUICK-SELL BUTTON
# ============================================

func _setup_quick_sell_button() -> void:
	## Create and position the quick-sell button
	quick_sell_button = Button.new()
	quick_sell_button.name = "QuickSellButton"
	quick_sell_button.text = "Sell All"
	quick_sell_button.visible = false  # Hidden until items exist

	# Position below coins label
	quick_sell_button.position = Vector2(16, 100)
	quick_sell_button.custom_minimum_size = Vector2(100, 40)

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
		quick_sell_button.text = "Sell All ($%d)" % total_value
		quick_sell_button.visible = true
	else:
		quick_sell_button.visible = false


func _calculate_sellable_value() -> int:
	## Calculate total value of sellable items in inventory
	if InventoryManager == null:
		return 0

	var total := 0
	for slot in InventoryManager.slots:
		if slot.is_empty() or slot.item == null:
			continue
		if slot.item.category in ["ore", "gem"]:
			total += slot.item.sell_value * slot.quantity

	return total


func _on_quick_sell_pressed() -> void:
	## Sell all ore and gems instantly
	if InventoryManager == null or GameManager == null:
		return

	var total := 0
	var items_to_remove := []

	for slot in InventoryManager.slots:
		if slot.is_empty() or slot.item == null:
			continue
		if slot.item.category in ["ore", "gem"]:
			total += slot.item.sell_value * slot.quantity
			if slot.item not in items_to_remove:
				items_to_remove.append(slot.item)

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

	# Position below the depth label (right side)
	tool_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	tool_label.position = Vector2(-200, 60)
	tool_label.custom_minimum_size = Vector2(184, 30)

	# Style the label
	tool_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tool_label.add_theme_font_size_override("font_size", 16)
	tool_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))

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
		tool_label.text = "Tool: %s" % tool_data.display_name
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
	tool_durability_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
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

	# Position below coins label, next to quick-sell button area
	inventory_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	inventory_label.position = Vector2(130, 100)
	inventory_label.custom_minimum_size = Vector2(80, 40)

	# Style the label
	inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	inventory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_label.add_theme_font_size_override("font_size", 20)

	add_child(inventory_label)

	# Initial update
	_update_inventory_indicator()


func _update_inventory_indicator() -> void:
	## Update inventory slots display (X/Y format)
	if inventory_label == null:
		return
	if InventoryManager == null:
		inventory_label.text = "0/8"
		return

	var used := InventoryManager.get_used_slots()
	var total := InventoryManager.get_total_slots()

	inventory_label.text = "%d/%d" % [used, total]

	# Color code based on fullness
	var fill_ratio := float(used) / float(total) if total > 0 else 0.0
	if fill_ratio >= 1.0:
		inventory_label.add_theme_color_override("font_color", Color.RED)
	elif fill_ratio >= 0.875:  # 7/8
		inventory_label.add_theme_color_override("font_color", Color.ORANGE)
	else:
		inventory_label.add_theme_color_override("font_color", Color.WHITE)


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


# ============================================
# NEXT UPGRADE GOAL DISPLAY
# ============================================

func _setup_upgrade_goal_display() -> void:
	## Create the next upgrade goal display container
	upgrade_goal_container = Control.new()
	upgrade_goal_container.name = "UpgradeGoalContainer"
	upgrade_goal_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	upgrade_goal_container.position = Vector2(16, 150)
	upgrade_goal_container.custom_minimum_size = Vector2(200, 50)
	add_child(upgrade_goal_container)

	# Create label for upgrade name and cost
	upgrade_goal_label = Label.new()
	upgrade_goal_label.name = "UpgradeGoalLabel"
	upgrade_goal_label.position = Vector2(0, 0)
	upgrade_goal_label.custom_minimum_size = Vector2(200, 20)
	upgrade_goal_label.add_theme_font_size_override("font_size", 14)
	upgrade_goal_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	upgrade_goal_container.add_child(upgrade_goal_label)

	# Create progress bar
	upgrade_goal_progress = ProgressBar.new()
	upgrade_goal_progress.name = "UpgradeGoalProgress"
	upgrade_goal_progress.position = Vector2(0, 22)
	upgrade_goal_progress.custom_minimum_size = Vector2(180, 16)
	upgrade_goal_progress.show_percentage = false
	upgrade_goal_container.add_child(upgrade_goal_progress)

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

	# Update label
	if not depth_ok:
		upgrade_goal_label.text = "Next: %s (Reach %dm)" % [next_tool.display_name, next_tool.unlock_depth]
		upgrade_goal_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	elif can_afford:
		upgrade_goal_label.text = "Next: %s - READY!" % next_tool.display_name
		upgrade_goal_label.add_theme_color_override("font_color", Color.GREEN)
		_pulse_upgrade_label()
	else:
		upgrade_goal_label.text = "Next: %s ($%d)" % [next_tool.display_name, cost]
		upgrade_goal_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))

	# Update progress bar
	upgrade_goal_progress.max_value = cost
	upgrade_goal_progress.value = mini(current_coins, cost)

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

	# Position in top-right area, below pause button
	save_indicator_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	save_indicator_label.position = Vector2(-150, 90)
	save_indicator_label.custom_minimum_size = Vector2(134, 20)

	# Style
	save_indicator_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	save_indicator_label.add_theme_font_size_override("font_size", 12)
	save_indicator_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))

	add_child(save_indicator_label)

	# Initial update
	_update_save_indicator()


func _update_save_indicator() -> void:
	## Update the save indicator with time since last save
	if save_indicator_label == null:
		return
	if SaveManager == null or not SaveManager.is_game_loaded():
		save_indicator_label.text = ""
		return

	var seconds := SaveManager.get_seconds_since_last_save()

	if seconds < 0:
		save_indicator_label.text = "Not saved"
		save_indicator_label.add_theme_color_override("font_color", Color.RED)
	elif seconds < 10:
		save_indicator_label.text = "Saved just now"
		save_indicator_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	elif seconds < 60:
		save_indicator_label.text = "Saved %ds ago" % seconds
		save_indicator_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	elif seconds < 120:
		save_indicator_label.text = "Saved 1m ago"
		save_indicator_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.4))
	elif seconds < 300:
		save_indicator_label.text = "Saved %dm ago" % (seconds / 60)
		save_indicator_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.4))
	else:
		save_indicator_label.text = "Saved %dm ago" % (seconds / 60)
		save_indicator_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))


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
	ladder_quickslot.position = Vector2(-80, 120)
	ladder_quickslot.custom_minimum_size = Vector2(64, 64)
	add_child(ladder_quickslot)

	# Background panel
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.2, 0.2, 0.2, 0.8)
	bg.size = Vector2(64, 64)
	ladder_quickslot.add_child(bg)

	# Ladder icon (placeholder - text for now)
	var icon_label := Label.new()
	icon_label.name = "IconLabel"
	icon_label.text = "🪜"
	icon_label.position = Vector2(8, 4)
	icon_label.add_theme_font_size_override("font_size", 28)
	ladder_quickslot.add_child(icon_label)

	# Count label
	ladder_count_label = Label.new()
	ladder_count_label.name = "CountLabel"
	ladder_count_label.position = Vector2(40, 40)
	ladder_count_label.custom_minimum_size = Vector2(24, 20)
	ladder_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ladder_count_label.add_theme_font_size_override("font_size", 16)
	ladder_count_label.add_theme_color_override("font_color", Color.WHITE)
	ladder_quickslot.add_child(ladder_count_label)

	# Touch button (invisible overlay)
	ladder_button = Button.new()
	ladder_button.name = "LadderButton"
	ladder_button.flat = true
	ladder_button.size = Vector2(64, 64)
	ladder_button.pressed.connect(_on_ladder_quickslot_pressed)
	ladder_quickslot.add_child(ladder_button)

	# Connect inventory changes
	if InventoryManager:
		InventoryManager.inventory_changed.connect(_update_ladder_quickslot)

	# Initial update
	_update_ladder_quickslot()


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
		ladder_count_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		ladder_quickslot.modulate = Color(0.5, 0.5, 0.5, 0.8)


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
	## Create the mining progress indicator
	mining_progress_container = Control.new()
	mining_progress_container.name = "MiningProgressContainer"
	mining_progress_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	mining_progress_container.position = Vector2(-100, 200)
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
	mining_progress_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
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

	var progress := dirt_grid.get_block_mining_progress(mining_target)
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
