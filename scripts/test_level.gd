extends Node2D
## Test level scene controller.
## Initializes the dirt grid and handles UI updates.
## Connects mining drops to inventory system.

const FloatingTextScene := preload("res://scenes/ui/floating_text.tscn")
const BlockParticlesScene := preload("res://scenes/effects/block_particles.tscn")
const FTUEOverlayScene := preload("res://scenes/ui/ftue_overlay.tscn")
const JackpotBurstScene := preload("res://scenes/effects/jackpot_burst.tscn")
const ScreenFlashScene := preload("res://scenes/effects/screen_flash.tscn")

## FTUE (First Time User Experience) overlay reference
var ftue_overlay: CanvasLayer = null
var _ftue_active: bool = false

# Particle pool for block break effects
const PARTICLE_POOL_SIZE := 12
var _particle_pool: Array = []

# Jackpot burst particle pool for rare ore discoveries
const JACKPOT_POOL_SIZE := 4
var _jackpot_pool: Array = []

# Screen flash effect instance (reused)
var _screen_flash: CanvasLayer = null

# Cooldown for inventory full notification (prevent spam)
var _inventory_full_cooldown: float = 0.0
const INVENTORY_FULL_COOLDOWN_DURATION := 2.0

# Notification stacking system to prevent overlap
var _active_pickup_count: int = 0
const NOTIFICATION_STACK_OFFSET := 40.0  # Vertical spacing between stacked notifications
const MAX_STACKED_NOTIFICATIONS := 5  # Limit to prevent too many on screen

# Achievement notification queue (shows one at a time)
var _achievement_queue: Array = []
var _achievement_showing: bool = false

@onready var surface: Node2D = $Surface
@onready var dirt_grid: Node2D = $DirtGrid
@onready var player: CharacterBody2D = $Player
@onready var depth_label: Label = $UI/HUD/DepthLabel
@onready var touch_controls: Control = $UI/TouchControls
@onready var coins_label: Label = $UI/HUD/CoinsLabel
@onready var shop_button: Button = $UI/ShopButton
@onready var shop: Control = $UI/Shop
@onready var pause_button: Button = $UI/HUD/PauseButton
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var death_screen: CanvasLayer = $DeathScreen
@onready var hud: Control = $UI/HUD
@onready var floating_text_layer: CanvasLayer = $FloatingTextLayer


func _process(delta: float) -> void:
	# Update cooldowns
	if _inventory_full_cooldown > 0:
		_inventory_full_cooldown -= delta


func _ready() -> void:
	# Add to group for easy lookup (e.g., from shop)
	add_to_group("test_level")

	# Position player at surface spawn point
	if surface:
		player.position = surface.get_spawn_position()
		player.grid_position = GameManager.world_to_grid(player.position)

	# Give player reference to dirt grid for mining
	player.dirt_grid = dirt_grid

	# Initialize the dirt grid with the player reference
	dirt_grid.initialize(player, GameManager.SURFACE_ROW)

	# Connect mining drops to inventory
	dirt_grid.block_dropped.connect(_on_block_dropped)

	# Connect block destroy for particle effects
	dirt_grid.block_destroyed.connect(_on_block_destroyed)
	dirt_grid.block_hit.connect(_on_block_hit)
	_init_particle_pool()
	_init_jackpot_effects()

	# Connect touch controls to player
	touch_controls.direction_pressed.connect(player.set_touch_direction)
	touch_controls.direction_released.connect(player.clear_touch_direction)
	touch_controls.jump_pressed.connect(player.trigger_jump)
	touch_controls.inventory_pressed.connect(_on_inventory_pressed)

	# Connect depth tracking
	player.depth_changed.connect(_on_player_depth_changed)

	# Connect coins display
	GameManager.coins_changed.connect(_on_coins_changed)

	# Connect HUD to player HP
	if hud:
		hud.connect_to_player(player)
		# Connect death signal for game over handling
		player.player_died.connect(_on_player_died)

	# Connect death screen signals
	if death_screen:
		death_screen.respawn_requested.connect(_on_death_screen_respawn)
		death_screen.reload_requested.connect(_on_death_screen_reload)
		if death_screen.has_signal("dive_again_requested"):
			death_screen.dive_again_requested.connect(_on_death_screen_dive_again)
		if death_screen.has_signal("quick_retry_requested"):
			death_screen.quick_retry_requested.connect(_on_death_screen_quick_retry)

	# Connect item pickup for floating text
	InventoryManager.item_added.connect(_on_item_added)

	# Connect depth milestone notifications
	GameManager.depth_milestone_reached.connect(_on_depth_milestone_reached)

	# Connect layer transition notifications
	GameManager.layer_entered.connect(_on_layer_entered)

	# Connect save/load signals for placed object persistence
	if SaveManager:
		SaveManager.save_started.connect(_on_save_started)
		SaveManager.load_completed.connect(_on_load_completed)

	# Connect achievement unlock notifications
	if AchievementManager:
		AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)

	# Connect shop building proximity signals
	_connect_shop_building()

	# Start the game
	GameManager.start_game()

	# Update initial coins display
	_on_coins_changed(GameManager.get_coins())

	# Show control hint for new players (legacy - FTUE takes over for new players)
	_show_first_time_hint()

	# Initialize FTUE for brand new players
	_init_ftue()

	print("[TestLevel] Level initialized")


func _show_first_time_hint() -> void:
	## Show a control hint for new players who haven't mined any blocks yet
	## NOTE: This is now secondary to FTUE - only shows if FTUE is completed but no blocks mined
	if SaveManager.current_save == null:
		return

	# Skip if FTUE is active (FTUE has its own hints)
	if _ftue_active:
		return

	# Only show hint if player hasn't mined anything yet
	if SaveManager.current_save.blocks_mined > 0:
		return

	# Wait a moment before showing hint
	await get_tree().create_timer(1.5).timeout

	if floating_text_layer == null:
		return

	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	# Position at top of screen
	var viewport_size := get_viewport().get_visible_rect().size
	var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 4.0)

	# Use a subtle color for hints
	var color := Color(0.8, 0.9, 1.0)  # Light blue

	var text := "TAP blocks to dig!"
	floating.show_pickup(text, color, screen_pos)
	print("[TestLevel] Showing first-time hint")


# ============================================
# FTUE (First Time User Experience)
# ============================================

func _init_ftue() -> void:
	## Initialize FTUE overlay for brand new players
	if SaveManager == null or SaveManager.current_save == null:
		return

	# Skip if FTUE already completed
	if SaveManager.is_ftue_completed():
		print("[TestLevel] FTUE already completed, skipping")
		return

	# Check if this is a new player who should see FTUE
	if not SaveManager.is_brand_new_player():
		print("[TestLevel] Not a brand new player, skipping FTUE")
		return

	# Create and add FTUE overlay
	ftue_overlay = FTUEOverlayScene.instantiate()
	add_child(ftue_overlay)
	_ftue_active = true

	# Connect FTUE completion signal
	ftue_overlay.ftue_completed.connect(_on_ftue_completed)

	# Start the FTUE flow
	ftue_overlay.start_ftue()
	print("[TestLevel] FTUE started for new player")


func _on_ftue_completed() -> void:
	## Called when FTUE is complete - clean up overlay
	print("[TestLevel] FTUE completed!")
	_ftue_active = false

	# Show a brief celebration
	if floating_text_layer:
		var floating := FloatingTextScene.instantiate()
		floating_text_layer.add_child(floating)

		var viewport_size := get_viewport().get_visible_rect().size
		var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 3.0)

		floating.show_achievement("WELL DONE!", Color.GOLD, screen_pos)


func _notify_ftue_block_mined() -> void:
	## Notify FTUE that player mined their first block
	if not _ftue_active or ftue_overlay == null:
		return

	if not SaveManager.has_ftue_first_dig():
		SaveManager.set_ftue_first_dig()
		ftue_overlay.on_first_block_mined()


func _notify_ftue_ore_found() -> void:
	## Notify FTUE that player found their first ore
	if not _ftue_active or ftue_overlay == null:
		return

	ftue_overlay.on_first_ore_found()


func _notify_ftue_surface_with_ore() -> void:
	## Notify FTUE that player reached surface with ore in inventory
	if not _ftue_active or ftue_overlay == null:
		return

	ftue_overlay.on_reached_surface_with_ore()


func _notify_ftue_first_sale() -> void:
	## Notify FTUE that player made their first sale
	if not _ftue_active or ftue_overlay == null:
		return

	if not SaveManager.has_ftue_first_sell():
		SaveManager.set_ftue_first_sell()
		ftue_overlay.on_first_sale_complete()


func _check_ftue_surface_arrival() -> void:
	## Check if player arrived at surface with ore (for FTUE hint)
	if not _ftue_active:
		return

	# Check if player has any sellable items
	var has_ore := false
	for slot in InventoryManager.slots:
		if slot.item != null and slot.item.category in ["ore", "gem"]:
			has_ore = true
			break

	if has_ore:
		_notify_ftue_surface_with_ore()


func _on_player_depth_changed(depth: int) -> void:
	depth_label.text = "Depth: %d" % depth
	GameManager.update_depth(depth)

	# Check for FTUE surface arrival with ore
	if depth <= 0:
		_check_ftue_surface_arrival()


func _on_block_dropped(grid_pos: Vector2i, item_id: String) -> void:
	## Handle block destruction drops - add to inventory if ore
	if item_id.is_empty():
		return  # Plain dirt, no drop

	var item = DataRegistry.get_item(item_id)
	if item == null:
		push_warning("[TestLevel] Unknown item dropped: %s" % item_id)
		return

	# Check for FIRST ORE DISCOVERY - special celebration for new players
	if SaveManager and not SaveManager.has_first_ore_been_collected():
		_show_first_ore_celebration(item)
		SaveManager.set_first_ore_collected()

	# Check for PER-ORE-TYPE first discovery (separate from first ore ever)
	var is_new_discovery := false
	if PlayerData and not PlayerData.has_discovered_ore(item_id):
		is_new_discovery = PlayerData.discover_ore(item_id)
		if is_new_discovery:
			_show_new_ore_type_discovery(item)

	# Check for lucky strike (bonus ore)
	var amount := 1
	if MiningBonusManager:
		var multiplier := MiningBonusManager.check_lucky_strike(item_id)
		if multiplier > 1.0:
			# Lucky strike! Add bonus ore
			amount += MiningBonusManager.get_lucky_strike_ore_bonus()
			_show_lucky_strike_notification(item)

		# Track ore for vein bonus
		MiningBonusManager.on_ore_collected(item_id)

	var leftover := InventoryManager.add_item(item, amount)
	if leftover > 0:
		# Inventory full - item was not fully added
		print("[TestLevel] Inventory full, could not add %s" % item.display_name)
		_show_inventory_full_notification()
	else:
		print("[TestLevel] Added %d x %s to inventory" % [amount, item.display_name])


func _on_item_added(item, amount: int) -> void:
	## Show floating text when items are added to inventory
	## Uses tiered celebration based on item rarity
	if floating_text_layer == null:
		return

	# Limit stacked notifications
	if _active_pickup_count >= MAX_STACKED_NOTIFICATIONS:
		return

	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	# Get screen position from player world position with stacking offset
	var screen_pos := get_viewport().get_canvas_transform() * player.global_position
	var stack_offset := _active_pickup_count * NOTIFICATION_STACK_OFFSET
	# Offset upward from player center, stacking upward
	screen_pos.y -= 64.0 + stack_offset

	# Track active notification
	_active_pickup_count += 1
	floating.tree_exited.connect(func(): _active_pickup_count = maxi(0, _active_pickup_count - 1))

	# Get color and rarity from item data
	var color := Color.WHITE
	var rarity := 0  # 0=common, 1=uncommon, 2=rare, 3=epic, 4=legendary
	var ore = DataRegistry.get_ore(item.id)
	if ore != null:
		color = ore.color
		# Ensure the color is visible (lighten very dark colors)
		if color.v < 0.3:
			color = color.lightened(0.4)
		# Get rarity from ore data
		rarity = _get_rarity_level(item)

	# Format the text
	var text: String
	var rarity_prefix := _get_rarity_prefix(item)
	if rarity_prefix.is_empty():
		text = "+%d %s" % [amount, item.display_name]
	else:
		text = "%s +%d %s" % [rarity_prefix, amount, item.display_name]
		# Override color for rare+ items
		color = _get_rarity_color(item)

	# Use tiered ore discovery celebration
	floating.show_ore_discovery(text, color, screen_pos, rarity)

	# Apply rarity-based effects with ore color for visual effects
	_apply_ore_discovery_effects(rarity, color)


func _on_coins_changed(new_amount: int) -> void:
	coins_label.text = "$%d" % new_amount


func _on_depth_milestone_reached(depth: int) -> void:
	## Show floating notification when player reaches a depth milestone
	if floating_text_layer == null:
		return

	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	# Center the notification on screen
	var viewport_size := get_viewport().get_visible_rect().size
	var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 3.0)

	# Gold color for milestone notifications
	var color := Color.GOLD

	# Format the milestone message
	var text := "DEPTH MILESTONE: %dm!" % depth
	floating.show_pickup(text, color, screen_pos)
	print("[TestLevel] Depth milestone notification shown: %dm" % depth)


func _on_layer_entered(layer_name: String) -> void:
	## Show floating notification when player enters a new layer
	if floating_text_layer == null:
		return

	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	# Center the notification on screen
	var viewport_size := get_viewport().get_visible_rect().size
	var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 4.0)

	# Cyan color for layer notifications
	var color := Color.CYAN

	# Format the layer message
	var text := "Entering: %s" % layer_name
	floating.show_pickup(text, color, screen_pos)
	print("[TestLevel] Layer notification shown: %s" % layer_name)


func _on_achievement_unlocked(achievement: Dictionary) -> void:
	## Queue achievement notification (shows one at a time)
	_achievement_queue.append(achievement)
	_process_achievement_queue()
	print("[TestLevel] Achievement unlocked: %s" % achievement.name)


func _process_achievement_queue() -> void:
	## Process the achievement queue, showing one at a time
	if _achievement_showing or _achievement_queue.is_empty():
		return

	if floating_text_layer == null:
		return

	_achievement_showing = true
	var achievement: Dictionary = _achievement_queue.pop_front()

	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	# Position in upper-middle area of screen (below HUD elements)
	var viewport_size := get_viewport().get_visible_rect().size
	var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y * 0.25)

	# Purple/magenta color for achievement notifications
	var color := Color(0.9, 0.6, 1.0)  # Light purple

	# Format the achievement message
	var text := "ACHIEVEMENT: %s" % achievement.name

	# Connect to know when this one finishes so we can show the next
	floating.animation_finished.connect(_on_achievement_animation_finished)

	floating.show_achievement(text, color, screen_pos)


func _on_achievement_animation_finished() -> void:
	## Called when an achievement notification finishes, process next in queue
	_achievement_showing = false
	# Small delay before showing next
	await get_tree().create_timer(0.3).timeout
	_process_achievement_queue()


func _show_first_ore_celebration(item) -> void:
	## Show special celebration for the player's FIRST ore discovery!
	## This is a critical retention moment - make it feel amazing.
	if floating_text_layer == null:
		return

	# Play special discovery sound
	if SoundManager:
		SoundManager.play_milestone()  # Use milestone sound for extra impact

	# Trigger haptic feedback for mobile
	if HapticFeedback:
		HapticFeedback.on_ore_collected()

	# Create celebratory floating text
	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	# Center the celebration on screen
	var viewport_size := get_viewport().get_visible_rect().size
	var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 3.0)

	# Golden color for discovery celebration
	var color := Color.GOLD

	# Get ore color for extra visual punch
	var ore = DataRegistry.get_ore(item.id)
	if ore != null:
		color = Color.GOLD.lerp(ore.color, 0.3)

	var text := "FIRST ORE FOUND!"
	floating.show_achievement(text, color, screen_pos)

	# Notify FTUE about first ore discovery
	_notify_ftue_ore_found()

	# Add secondary hint about selling (skip if FTUE is active - it has its own hints)
	if not _ftue_active:
		await get_tree().create_timer(1.0).timeout
		if floating_text_layer:
			var hint := FloatingTextScene.instantiate()
			floating_text_layer.add_child(hint)
			hint.show_pickup("Sell at the General Store!", Color.WHITE, Vector2(viewport_size.x / 2.0, viewport_size.y * 0.45))

	print("[TestLevel] First ore celebration shown for: %s" % item.display_name)


func _show_new_ore_type_discovery(item) -> void:
	## Show celebration for discovering a new type of ore!
	## Different from first ore ever - this triggers for each NEW ore type.
	## Awards bonus coins (50% of sell value) to reward exploration.
	if floating_text_layer == null:
		return

	# Calculate bonus coins (50% of item's sell value)
	var bonus_coins := 0
	var ore = DataRegistry.get_ore(item.id)
	if ore != null and "sell_value" in item:
		bonus_coins = int(item.sell_value * 0.5)
		if bonus_coins < 1:
			bonus_coins = 1  # Minimum 1 coin bonus

	# Award the discovery bonus
	if bonus_coins > 0 and GameManager:
		GameManager.add_coins(bonus_coins)

	# Play special discovery fanfare sound
	if SoundManager:
		SoundManager.play_milestone()

	# Trigger haptic feedback for mobile
	if HapticFeedback:
		HapticFeedback.on_ore_collected()

	# Create celebratory floating text
	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	# Position in upper portion of screen
	var viewport_size := get_viewport().get_visible_rect().size
	var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 3.5)

	# Get ore color for visual impact
	var color := Color(0.2, 1.0, 0.6)  # Bright green for discovery
	if ore != null:
		color = Color(0.2, 1.0, 0.6).lerp(ore.color, 0.4)

	# Show NEW DISCOVERY text with ore name
	var text := "NEW DISCOVERY!"
	floating.show_achievement(text, color, screen_pos)

	# Show bonus coins notification after a brief delay
	if bonus_coins > 0:
		await get_tree().create_timer(0.4).timeout
		if floating_text_layer:
			var bonus_floating := FloatingTextScene.instantiate()
			floating_text_layer.add_child(bonus_floating)

			var bonus_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 2.8)
			bonus_floating.show_pickup("+$%d Discovery Bonus!" % bonus_coins, Color.GOLD, bonus_pos)

	print("[TestLevel] New ore type discovered: %s (+%d bonus coins)" % [item.display_name, bonus_coins])


func _show_inventory_full_notification() -> void:
	## Show floating notification when inventory is full (with cooldown)
	if floating_text_layer == null:
		return
	if _inventory_full_cooldown > 0:
		return  # Still in cooldown, don't spam

	_inventory_full_cooldown = INVENTORY_FULL_COOLDOWN_DURATION

	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	# Position above player
	var screen_pos := get_viewport().get_canvas_transform() * player.global_position
	screen_pos.y -= 96.0

	# Red color for warning
	var color := Color.RED

	var text := "INVENTORY FULL!"
	floating.show_pickup(text, color, screen_pos)


func _show_lucky_strike_notification(item) -> void:
	## Show floating notification for lucky strike bonus
	if floating_text_layer == null:
		return

	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	# Position above player
	var screen_pos := get_viewport().get_canvas_transform() * player.global_position
	screen_pos.y -= 128.0  # Higher than normal pickups

	# Gold color for lucky strike
	var color := Color(1.0, 0.85, 0.2)  # Gold

	var text := "LUCKY STRIKE! +%s" % item.display_name
	floating.show_pickup(text, color, screen_pos)

	# Play a sound effect if available
	if SoundManager and SoundManager.has_method("play_milestone"):
		SoundManager.play_milestone()


func _on_shop_button_pressed() -> void:
	shop.open(_current_shop_type)
	shop_button.visible = false  # Hide button while shop is open


func _on_shop_closed() -> void:
	# Shop was closed, check if player is still near shop building
	var shop_building := surface.get_node_or_null("ShopBuilding")
	if shop_building and shop_building.is_player_nearby():
		shop_button.visible = true


# ============================================
# SHOP BUILDING INTERACTION
# ============================================

## Currently active shop type when player is near a shop
var _current_shop_type: int = -1

func _connect_shop_building() -> void:
	## Connect shop building proximity signals to show/hide shop button
	if not surface:
		return

	# Connect all shop buildings
	for child in surface.get_children():
		if child.has_method("get_shop_type"):
			child.player_entered.connect(_on_shop_building_entered)
			child.player_exited.connect(_on_shop_building_exited)
			print("[TestLevel] Connected shop: %s" % child.get_shop_type_name())


func _on_shop_building_entered(shop_type: int) -> void:
	## Player entered shop area - show the shop button and track shop type
	_current_shop_type = shop_type
	if not shop.visible:  # Only show if shop UI isn't already open
		shop_button.visible = true
		# Update button text to show shop name
		var shop_name := _get_shop_display_name(shop_type)
		shop_button.text = shop_name


func _on_shop_building_exited(_shop_type: int) -> void:
	## Player left shop area - hide the shop button
	_current_shop_type = -1
	shop_button.visible = false


func _get_shop_display_name(shop_type: int) -> String:
	## Get display name for shop type
	const ShopType = preload("res://scripts/surface/shop_building.gd").ShopType
	match shop_type:
		ShopType.GENERAL_STORE:
			return "General Store"
		ShopType.SUPPLY_STORE:
			return "Supply Store"
		ShopType.BLACKSMITH:
			return "Blacksmith"
		ShopType.EQUIPMENT_SHOP:
			return "Equipment"
		ShopType.GEM_APPRAISER:
			return "Appraiser"
		ShopType.WAREHOUSE:
			return "Warehouse"
	return "Shop"


func _on_inventory_pressed() -> void:
	# Toggle inventory UI (placeholder - will be implemented with inventory UI)
	print("[TestLevel] Inventory button pressed")
	# For now, just toggle shop as a placeholder
	if shop.visible:
		shop.close()
	else:
		shop.open()


# ============================================
# PAUSE MENU HANDLERS
# ============================================

func _on_pause_button_pressed() -> void:
	pause_menu.show_menu()


func _on_pause_menu_resumed() -> void:
	print("[TestLevel] Game resumed from pause")


func _on_pause_menu_rescue(cargo_lost_count: int = 0) -> void:
	## Emergency rescue: teleport player back to surface
	## cargo_lost_count: number of items lost as rescue fee (depth-proportional)
	print("[TestLevel] Emergency rescue requested (lost %d cargo)" % cargo_lost_count)

	# Teleport player to surface spawn point
	if surface:
		player.position = surface.get_spawn_position()
		player.grid_position = GameManager.world_to_grid(player.position)
	else:
		# Fallback if surface scene is not available
		var surface_y := GameManager.SURFACE_ROW * 128 - 128  # One row above dirt
		var center_x := GameManager.GRID_WIDTH / 2
		var spawn_pos := GameManager.grid_to_world(Vector2i(center_x, GameManager.SURFACE_ROW - 1))
		player.position = spawn_pos
		player.grid_position = GameManager.world_to_grid(spawn_pos)

	player.current_state = player.State.IDLE
	player.velocity = Vector2.ZERO

	# Update depth display
	GameManager.update_depth(0)

	# Show toast about rescue fee (if any items were lost)
	if cargo_lost_count > 0 and floating_text_layer:
		var floating := FloatingTextScene.instantiate()
		floating_text_layer.add_child(floating)
		var viewport_size := get_viewport().get_visible_rect().size
		var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 3.0)
		floating.show_pickup("Rescue Fee: Lost %d item(s)" % cargo_lost_count, Color(1.0, 0.6, 0.2), screen_pos)
	elif floating_text_layer:
		var floating := FloatingTextScene.instantiate()
		floating_text_layer.add_child(floating)
		var viewport_size := get_viewport().get_visible_rect().size
		var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 3.0)
		floating.show_pickup("Rescued!", Color(0.5, 1.0, 0.5), screen_pos)

	print("[TestLevel] Player rescued to surface")


func _on_pause_menu_reload() -> void:
	## Reload the last save
	print("[TestLevel] Reload save requested")

	if SaveManager.current_slot >= 0:
		# Load the save which will reset player position, inventory, etc.
		var success := SaveManager.load_game(SaveManager.current_slot)
		if success:
			print("[TestLevel] Save reloaded")
		else:
			push_warning("[TestLevel] Failed to reload save")
	else:
		push_warning("[TestLevel] No save slot to reload from")


func _on_pause_menu_quit() -> void:
	## Return to main menu
	print("[TestLevel] Quit to main menu requested")

	# Save before quitting
	if SaveManager.is_game_loaded():
		SaveManager.save_game()

	# End the game session
	GameManager.end_game()

	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


# ============================================
# PLAYER DEATH HANDLER
# ============================================

func _respawn_player() -> void:
	## Respawn player at surface with full health - optimized for quick restart
	print("[TestLevel] Respawning player at surface")

	# Revive the player with full HP
	player.revive(player.MAX_HP)

	# Teleport to surface spawn position (use surface spawn point if available)
	if surface:
		player.position = surface.get_spawn_position()
		player.grid_position = GameManager.world_to_grid(player.position)
	else:
		# Fallback if surface scene is not available
		var center_x := GameManager.GRID_WIDTH / 2
		var spawn_pos := GameManager.grid_to_world(Vector2i(center_x, GameManager.SURFACE_ROW - 1))
		player.position = spawn_pos
		player.grid_position = GameManager.world_to_grid(spawn_pos)

	player.current_state = player.State.IDLE
	player.velocity = Vector2.ZERO

	# Reset depth
	GameManager.update_depth(0)

	# Show respawn dust effect at player position
	_spawn_respawn_particles()

	# Save the respawn
	if SaveManager.is_game_loaded():
		SaveManager.save_game()

	print("[TestLevel] Player respawned successfully")


func _spawn_respawn_particles() -> void:
	## Spawn dust particles at player position on respawn
	# Create a simple GPUParticles2D for respawn effect
	var particles := GPUParticles2D.new()
	particles.position = player.position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 12
	particles.lifetime = 0.5
	particles.explosiveness = 0.9

	# Create simple particle material
	var material := ParticleProcessMaterial.new()
	material.direction = Vector3(0, -1, 0)
	material.spread = 45.0
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	material.gravity = Vector3(0, 200, 0)
	material.scale_min = 0.5
	material.scale_max = 1.0
	material.color = Color(0.9, 0.85, 0.7, 0.8)
	particles.process_material = material

	add_child(particles)

	# Auto-remove after effect completes
	await get_tree().create_timer(1.0).timeout
	particles.queue_free()


func _on_player_died(cause: String) -> void:
	## Handle player death - show death screen with options
	print("[TestLevel] Player died from: %s" % cause)

	# Calculate depth at death
	var depth: int = player.grid_position.y - GameManager.SURFACE_ROW
	if depth < 0:
		depth = 0

	# Track for achievements
	if AchievementManager:
		AchievementManager.track_death()

	# FTUE: Instant respawn with no penalty during first-time experience
	if _ftue_active:
		print("[TestLevel] FTUE active - instant respawn, no penalty")
		_instant_ftue_respawn()
		return

	# Show death screen
	if death_screen and death_screen.has_method("show_death"):
		death_screen.show_death(cause, depth)
	else:
		# Fallback to old behavior if death screen not available
		_legacy_death_handler(cause)


func _instant_ftue_respawn() -> void:
	## Instant respawn during FTUE with no penalty - keep the player engaged
	# Revive player with full HP
	player.revive(player.MAX_HP)

	# Teleport to surface spawn position
	if surface:
		player.position = surface.get_spawn_position()
		player.grid_position = GameManager.world_to_grid(player.position)
	else:
		# Fallback
		var center_x := 4
		var spawn_pos := GameManager.grid_to_world(Vector2i(center_x, GameManager.SURFACE_ROW - 1))
		player.position = spawn_pos
		player.grid_position = GameManager.world_to_grid(spawn_pos)

	player.current_state = player.State.IDLE
	player.velocity = Vector2.ZERO

	# Reset depth
	GameManager.update_depth(0)

	# Show encouraging message
	if floating_text_layer:
		var floating := FloatingTextScene.instantiate()
		floating_text_layer.add_child(floating)

		var viewport_size := get_viewport().get_visible_rect().size
		var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 3.0)

		floating.show_pickup("TRY AGAIN!", Color(0.5, 0.9, 1.0), screen_pos)

	print("[TestLevel] FTUE respawn complete")


func _legacy_death_handler(cause: String) -> void:
	## Legacy death handler for when death screen is not available
	# Record death in save data
	if SaveManager.current_save:
		SaveManager.current_save.increment_deaths()

	# Apply death penalty: lose some random items
	_apply_death_penalty()

	# Pause game temporarily
	get_tree().paused = true

	# Show death message and wait before respawning
	print("[TestLevel] Respawning in 2 seconds...")
	await get_tree().create_timer(2.0, true, false, true).timeout

	# Respawn player at surface
	_respawn_player()

	# Unpause game
	get_tree().paused = false


func _on_death_screen_respawn() -> void:
	## Handle respawn request from death screen
	print("[TestLevel] Respawn requested from death screen")

	# Record death in save data
	if SaveManager.current_save:
		SaveManager.current_save.increment_deaths()

	# Respawn player at surface with toast
	_respawn_player()
	_show_respawn_toast("Respawned. Cargo lost.")


func _on_death_screen_dive_again() -> void:
	## Handle dive again request from death screen - quick restart flow
	print("[TestLevel] Dive again requested from death screen")

	# Record death in save data
	if SaveManager.current_save:
		SaveManager.current_save.increment_deaths()

	# Respawn player at surface
	_respawn_player()
	_show_respawn_toast("Ready to dive!")

	# Optional: Auto-start dive toward mine entrance
	# (Player still needs to walk to mine entrance manually for now)


func _on_death_screen_quick_retry() -> void:
	## Handle quick retry request - ultra-fast respawn path
	## Optimized for minimum time: no toast, no messages, just respawn
	print("[TestLevel] Quick retry requested - instant respawn")

	# Record death in save data (already incremented by death_screen)
	# (Death screen handles this to avoid double-counting)

	# Respawn player at surface immediately
	_respawn_player()

	# Minimal feedback - just a subtle color flash instead of toast
	if player:
		# Brief flash to confirm respawn without blocking
		var flash_tween := create_tween()
		flash_tween.tween_property(player, "modulate", Color(0.5, 1.0, 0.5), 0.1)
		flash_tween.tween_property(player, "modulate", Color.WHITE, 0.2)


func _show_respawn_toast(message: String) -> void:
	## Show a brief toast message after respawn
	if floating_text_layer == null:
		return

	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	var viewport_size := get_viewport().get_visible_rect().size
	var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 3.0)

	floating.show_pickup(message, Color(1.0, 0.9, 0.7), screen_pos)


func _on_death_screen_reload() -> void:
	## Handle reload request from death screen
	print("[TestLevel] Reload requested from death screen")

	if SaveManager.current_slot >= 0:
		var success := SaveManager.load_game(SaveManager.current_slot)
		if success:
			print("[TestLevel] Save reloaded from death screen")
		else:
			push_warning("[TestLevel] Failed to reload save from death screen")


func _apply_death_penalty() -> void:
	## Apply death penalty: lose a portion of inventory items
	if InventoryManager == null:
		return

	var total_items := InventoryManager.get_total_item_count()
	if total_items == 0:
		return  # Nothing to lose

	# Lose 25% of items (minimum 1, rounded up)
	var items_to_lose := maxi(1, ceili(float(total_items) * 0.25))

	# Remove random items
	var lost := InventoryManager.remove_random_items(items_to_lose)
	if lost > 0:
		print("[TestLevel] Death penalty: Lost %d item(s)" % lost)

		# Show notification about lost items
		if floating_text_layer:
			var floating := FloatingTextScene.instantiate()
			floating_text_layer.add_child(floating)

			var viewport_size := get_viewport().get_visible_rect().size
			var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0)

			var text := "Lost %d item(s)!" % lost
			floating.show_pickup(text, Color.RED, screen_pos)


# ============================================
# PARTICLE EFFECTS
# ============================================

func _init_particle_pool() -> void:
	## Initialize pool of particle emitters for block break effects
	for i in PARTICLE_POOL_SIZE:
		var p := BlockParticlesScene.instantiate()
		p.visible = false
		add_child(p)
		_particle_pool.append(p)


func _init_jackpot_effects() -> void:
	## Initialize jackpot burst particle pool and screen flash effect
	# Create jackpot burst particle pool
	for i in JACKPOT_POOL_SIZE:
		var p := JackpotBurstScene.instantiate()
		p.visible = false
		add_child(p)
		_jackpot_pool.append(p)

	# Create single screen flash instance (reused)
	_screen_flash = ScreenFlashScene.instantiate()
	_screen_flash.visible = false
	add_child(_screen_flash)


func _get_available_particle() -> CPUParticles2D:
	## Get an available particle emitter from the pool
	for p in _particle_pool:
		if p.is_available():
			return p
	# All in use - return first (will interrupt its animation)
	return _particle_pool[0] if not _particle_pool.is_empty() else null


func _get_available_jackpot_burst() -> CPUParticles2D:
	## Get an available jackpot burst emitter from the pool
	for p in _jackpot_pool:
		if p.is_available():
			return p
	# All in use - return first (will interrupt its animation)
	return _jackpot_pool[0] if not _jackpot_pool.is_empty() else null


func _on_block_hit(world_pos: Vector2, color: Color, hardness: float = 10.0) -> void:
	## Spawn small particle puff when a block is hit (not destroyed)
	var p := _get_available_particle()
	if p:
		p.puff(world_pos, color, hardness)


func _on_block_destroyed(world_pos: Vector2, color: Color, hardness: float = 10.0) -> void:
	## Spawn particle effect when a block is destroyed
	var p := _get_available_particle()
	if p:
		p.burst(world_pos, color, hardness)

	# Screen shake for hard blocks (stone+, hardness >= 25)
	# Shake intensity scales with hardness: stone(25-40)=2px, granite(50-80)=3px, obsidian(100+)=5px
	if hardness >= 25.0 and player and player.camera:
		var shake_intensity := clampf(hardness / 20.0, 1.5, 5.0)
		player.camera.shake(shake_intensity)

	# Track for statistics
	if SaveManager.current_save:
		SaveManager.current_save.increment_blocks_mined()

	# Track for achievements
	if AchievementManager:
		AchievementManager.track_block_destroyed()

	# Notify FTUE of first block mined
	_notify_ftue_block_mined()


# ============================================
# RARITY HELPERS
# ============================================

func _get_rarity_prefix(item) -> String:
	## Get a prefix string for rare+ item notifications
	if item == null or not "rarity" in item:
		return ""

	var rarity: String = item.rarity if item.rarity is String else ""
	match rarity:
		"rare":
			return "[RARE]"
		"epic":
			return "[EPIC]"
		"legendary":
			return "[LEGENDARY]"
		_:
			return ""


func _get_rarity_color(item) -> Color:
	## Get the display color for rare+ items
	if item == null or not "rarity" in item:
		return Color.WHITE

	var rarity: String = item.rarity if item.rarity is String else ""
	match rarity:
		"rare":
			return Color(0.3, 0.6, 1.0)  # Blue
		"epic":
			return Color(0.8, 0.4, 1.0)  # Purple
		"legendary":
			return Color(1.0, 0.7, 0.2)  # Orange/Gold
		_:
			return Color.WHITE


func _get_rarity_level(item) -> int:
	## Get numeric rarity level: 0=common, 1=uncommon, 2=rare, 3=epic, 4=legendary
	if item == null or not "rarity" in item:
		return 0

	var rarity: String = item.rarity if item.rarity is String else ""
	match rarity:
		"common":
			return 0
		"uncommon":
			return 1
		"rare":
			return 2
		"epic":
			return 3
		"legendary":
			return 4
		_:
			return 0


func _apply_ore_discovery_effects(rarity: int, ore_color: Color = Color.WHITE) -> void:
	## Apply screen shake, haptics, particles, and screen flash based on ore rarity
	## Called when ore is collected to create tiered celebration feedback
	## rarity: 0=common, 1=uncommon, 2=rare, 3=epic, 4=legendary

	# Screen shake scales with rarity
	if player and player.camera:
		var shake_intensity: float
		match rarity:
			0:  # Common - no shake (or minimal)
				shake_intensity = 0.0
			1:  # Uncommon - subtle
				shake_intensity = 1.5
			2:  # Rare - noticeable
				shake_intensity = 3.0
			3:  # Epic - strong
				shake_intensity = 5.0
			_:  # Legendary - dramatic
				shake_intensity = 8.0

		if shake_intensity > 0:
			player.camera.shake(shake_intensity)

	# Haptic feedback scales with rarity using jackpot discovery
	if HapticFeedback:
		HapticFeedback.on_jackpot_discovery(rarity)

	# Sound effects using tiered discovery sounds
	if SoundManager:
		if rarity >= 1:  # Uncommon and above get special sounds
			SoundManager.play_jackpot_discovery(rarity)
		else:  # Common - basic pickup sound
			SoundManager.play_pickup()

	# Screen flash for rare+ finds (creates dramatic jackpot moment)
	if rarity >= 2 and _screen_flash and not (SettingsManager and SettingsManager.reduced_motion):
		var tier := clampi(rarity - 2, 0, 2)  # 0=rare, 1=epic, 2=legendary
		_screen_flash.flash(tier, ore_color)

	# Jackpot burst particles for rare+ finds
	if rarity >= 2:
		var burst := _get_available_jackpot_burst()
		if burst:
			# Get screen position from player world position
			var screen_pos := get_viewport().get_canvas_transform() * player.global_position
			screen_pos.y -= 48.0  # Slightly above player
			var tier := clampi(rarity - 2, 0, 2)  # 0=rare, 1=epic, 2=legendary
			burst.burst_at_screen(screen_pos, tier, ore_color)

	# Brief hitstop for rare+ ore (adds weight to the discovery)
	if rarity >= 2 and not (SettingsManager and SettingsManager.reduced_motion):
		var pause_duration := 0.03 + (rarity - 2) * 0.02  # 30-70ms
		Engine.time_scale = 0.1
		await get_tree().create_timer(pause_duration, true, false, true).timeout
		Engine.time_scale = 1.0


# ============================================
# TRAVERSAL ITEM PERSISTENCE
# ============================================

func _on_save_started() -> void:
	## Save placed objects (ladders, torches) to the current save
	if dirt_grid and SaveManager.current_save:
		var placed_data: Dictionary = dirt_grid.get_placed_objects_dict()
		SaveManager.current_save.placed_objects = placed_data
		print("[TestLevel] Saved %d placed objects" % placed_data.size())


func _on_load_completed(success: bool) -> void:
	## Load placed objects from the save when game loads
	if not success:
		return

	if dirt_grid and SaveManager.current_save:
		var placed_data = SaveManager.current_save.placed_objects
		if placed_data and not placed_data.is_empty():
			dirt_grid.load_placed_objects_dict(placed_data)
			print("[TestLevel] Loaded %d placed objects from save" % placed_data.size())
