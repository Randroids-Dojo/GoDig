extends Node2D
## Test level scene controller.
## Initializes the dirt grid and handles UI updates.
## Connects mining drops to inventory system.

@onready var dirt_grid: Node2D = $DirtGrid
@onready var player: CharacterBody2D = $Player
@onready var depth_label: Label = $UI/DepthLabel
@onready var touch_controls: Control = $UI/TouchControls
@onready var coins_label: Label = $UI/CoinsLabel
@onready var shop_button: Button = $UI/ShopButton
@onready var shop: Control = $UI/Shop


func _ready() -> void:
	# Give player reference to dirt grid for mining
	player.dirt_grid = dirt_grid

	# Initialize the dirt grid with the player reference
	dirt_grid.initialize(player, GameManager.SURFACE_ROW)

	# Connect mining drops to inventory
	dirt_grid.block_dropped.connect(_on_block_dropped)

	# Connect touch controls to player
	touch_controls.direction_pressed.connect(player.set_touch_direction)
	touch_controls.direction_released.connect(player.clear_touch_direction)
	touch_controls.jump_pressed.connect(player.trigger_jump)

	# Connect coins display
	GameManager.coins_changed.connect(_on_coins_changed)

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


func _on_coins_changed(new_amount: int) -> void:
	coins_label.text = "$%d" % new_amount


func _on_shop_button_pressed() -> void:
	shop.open()


func _on_shop_closed() -> void:
	# Shop was closed, resume game if needed
	pass
