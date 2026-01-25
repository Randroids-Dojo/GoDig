extends Node2D
## Test level scene controller.
## Initializes the dirt grid and handles UI updates.
## Connects mining drops to inventory system.

const FloatingTextScene := preload("res://scenes/ui/floating_text.tscn")
const BlockParticlesScene := preload("res://scenes/effects/block_particles.tscn")

# Particle pool for block break effects
const PARTICLE_POOL_SIZE := 12
var _particle_pool: Array = []

# Cooldown for inventory full notification (prevent spam)
var _inventory_full_cooldown: float = 0.0
const INVENTORY_FULL_COOLDOWN_DURATION := 2.0

@onready var surface: Node2D = $Surface
@onready var dirt_grid: Node2D = $DirtGrid
@onready var player: CharacterBody2D = $Player
@onready var depth_label: Label = $UI/DepthLabel
@onready var touch_controls: Control = $UI/TouchControls
@onready var coins_label: Label = $UI/CoinsLabel
@onready var shop_button: Button = $UI/ShopButton
@onready var shop: Control = $UI/Shop
@onready var pause_button: Button = $UI/PauseButton
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var hud: Control = $UI/HUD
@onready var floating_text_layer: CanvasLayer = $FloatingTextLayer


func _process(delta: float) -> void:
	# Update cooldowns
	if _inventory_full_cooldown > 0:
		_inventory_full_cooldown -= delta


func _ready() -> void:
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
	_init_particle_pool()

	# Connect touch controls to player
	touch_controls.direction_pressed.connect(player.set_touch_direction)
	touch_controls.direction_released.connect(player.clear_touch_direction)
	touch_controls.jump_pressed.connect(player.trigger_jump)
	touch_controls.dig_pressed.connect(player.trigger_dig)
	touch_controls.dig_released.connect(player.stop_dig)
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

	# Connect item pickup for floating text
	InventoryManager.item_added.connect(_on_item_added)

	# Connect depth milestone notifications
	GameManager.depth_milestone_reached.connect(_on_depth_milestone_reached)

	# Connect layer transition notifications
	GameManager.layer_entered.connect(_on_layer_entered)

	# Connect achievement unlock notifications
	if AchievementManager:
		AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)

	# Connect shop building proximity signals
	_connect_shop_building()

	# Start the game
	GameManager.start_game()

	# Update initial coins display
	_on_coins_changed(GameManager.get_coins())

	# Show control hint for new players
	_show_first_time_hint()

	print("[TestLevel] Level initialized")


func _show_first_time_hint() -> void:
	## Show a control hint for new players who haven't mined any blocks yet
	if SaveManager.current_save == null:
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


func _on_player_depth_changed(depth: int) -> void:
	depth_label.text = "Depth: %d" % depth
	GameManager.update_depth(depth)


func _on_block_dropped(grid_pos: Vector2i, item_id: String) -> void:
	## Handle block destruction drops - add to inventory if ore
	if item_id.is_empty():
		return  # Plain dirt, no drop

	var item = DataRegistry.get_item(item_id)
	if item == null:
		push_warning("[TestLevel] Unknown item dropped: %s" % item_id)
		return

	var leftover := InventoryManager.add_item(item, 1)
	if leftover > 0:
		# Inventory full - item was not fully added
		print("[TestLevel] Inventory full, could not add %s" % item.display_name)
		_show_inventory_full_notification()
	else:
		print("[TestLevel] Added %s to inventory" % item.display_name)


func _on_item_added(item, amount: int) -> void:
	## Show floating text when items are added to inventory
	if floating_text_layer == null:
		return

	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	# Get screen position from player world position
	var screen_pos := get_viewport().get_canvas_transform() * player.global_position
	# Offset slightly upward from player center
	screen_pos.y -= 64.0

	# Get color from ore data if available, otherwise use white
	var color := Color.WHITE
	var ore = DataRegistry.get_ore(item.id)
	if ore != null:
		color = ore.color
		# Ensure the color is visible (lighten very dark colors)
		if color.v < 0.3:
			color = color.lightened(0.4)

	# Format the text
	var text := "+%d %s" % [amount, item.display_name]
	floating.show_pickup(text, color, screen_pos)


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
	## Show floating notification when an achievement is unlocked
	if floating_text_layer == null:
		return

	var floating := FloatingTextScene.instantiate()
	floating_text_layer.add_child(floating)

	# Center the notification on screen, slightly higher than other notifications
	var viewport_size := get_viewport().get_visible_rect().size
	var screen_pos := Vector2(viewport_size.x / 2.0, viewport_size.y / 5.0)

	# Purple/magenta color for achievement notifications
	var color := Color(0.9, 0.6, 1.0)  # Light purple

	# Format the achievement message
	var text := "ACHIEVEMENT: %s" % achievement.name
	floating.show_pickup(text, color, screen_pos)
	print("[TestLevel] Achievement unlocked: %s" % achievement.name)


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


func _on_pause_menu_rescue() -> void:
	## Emergency rescue: teleport player back to surface
	print("[TestLevel] Emergency rescue requested")

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
	## Respawn player at surface with full health
	print("[TestLevel] Respawning player at surface")

	# Revive the player with full HP
	player.revive(player.MAX_HP)

	# Teleport to surface spawn position
	var center_x := GameManager.GRID_WIDTH / 2
	var spawn_pos := GameManager.grid_to_world(Vector2i(center_x, GameManager.SURFACE_ROW - 1))
	player.position = spawn_pos
	player.grid_position = GameManager.world_to_grid(spawn_pos)
	player.current_state = player.State.IDLE
	player.velocity = Vector2.ZERO

	# Reset depth
	GameManager.update_depth(0)

	# Save the respawn
	if SaveManager.is_game_loaded():
		SaveManager.save_game()

	print("[TestLevel] Player respawned successfully")


func _on_player_died(cause: String) -> void:
	## Handle player death - respawn at surface after delay
	print("[TestLevel] Player died from: %s" % cause)

	# Record death in save data
	if SaveManager.current_save:
		SaveManager.current_save.increment_deaths()

	# Track for achievements
	if AchievementManager:
		AchievementManager.track_death()

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


func _get_available_particle() -> CPUParticles2D:
	## Get an available particle emitter from the pool
	for p in _particle_pool:
		if p.is_available():
			return p
	# All in use - return first (will interrupt its animation)
	return _particle_pool[0] if not _particle_pool.is_empty() else null


func _on_block_destroyed(world_pos: Vector2, color: Color) -> void:
	## Spawn particle effect when a block is destroyed
	var p := _get_available_particle()
	if p:
		p.burst(world_pos, color)

	# Track for statistics
	if SaveManager.current_save:
		SaveManager.current_save.increment_blocks_mined()

	# Track for achievements
	if AchievementManager:
		AchievementManager.track_block_destroyed()
