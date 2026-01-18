extends Node2D
## Test level scene controller.
## Initializes the dirt grid and handles UI updates.

@onready var dirt_grid: Node2D = $DirtGrid
@onready var player: CharacterBody2D = $Player
@onready var depth_label: Label = $UI/DepthLabel
@onready var touch_controls: Control = $UI/TouchControls


func _ready() -> void:
	# Give player reference to dirt grid for mining
	player.dirt_grid = dirt_grid

	# Initialize the dirt grid with the player reference
	dirt_grid.initialize(player, GameManager.SURFACE_ROW)

	# Connect touch controls to player
	touch_controls.direction_pressed.connect(player.set_touch_direction)
	touch_controls.direction_released.connect(player.clear_touch_direction)

	# Start the game
	GameManager.start_game()

	print("[TestLevel] Level initialized")


func _on_player_depth_changed(depth: int) -> void:
	depth_label.text = "Depth: %d" % depth
	GameManager.update_depth(depth)
