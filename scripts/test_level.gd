extends Node2D
## Test level scene controller.
## Initializes the dirt grid and handles UI updates.
## Connects mining drops to inventory system.

const FloatingTextScene := preload("res://scenes/ui/floating_text.tscn")

@onready var dirt_grid: Node2D = $DirtGrid
@onready var surface_area: Node2D = $SurfaceArea
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


func _ready() -> void:
	# Give player reference to dirt grid for mining
	player.dirt_grid = dirt_grid

	# Initialize the dirt grid with the player reference
	dirt_grid.initialize(player, GameManager.SURFACE_ROW)

	# Initialize the surface area with the player reference
	surface_area.initialize(player)

	# Connect mining drops to inventory
	dirt_grid.block_dropped.connect(_on_block_dropped)

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

	# Start the game
	GameManager.start_game()

	# Update initial coins display
	_on_coins_changed(GameManager.get_coins())

	print("[TestLevel] Level initialized")


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


func _on_shop_button_pressed() -> void:
	shop.open()


func _on_shop_closed() -> void:
	# Shop was closed, resume game if needed
	pass


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

	# Teleport player to starting position
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
	## Quit to main menu (or quit game if no main menu)
	print("[TestLevel] Quit requested")

	# For now, just quit the game
	# TODO: Return to main menu when implemented
	get_tree().quit()


# ============================================
# PLAYER DEATH HANDLER
# ============================================

func _on_player_died(cause: String) -> void:
	## Handle player death - will be expanded by death/respawn system
	print("[TestLevel] Player died from: %s" % cause)
	# For now, just log it - full death/respawn system will handle this later
