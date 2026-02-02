extends Node2D
## Greybox Mining Test Scene
##
## Tests the core mining feel with NO progression systems.
## Use this to validate that tap-to-mine is satisfying before adding complexity.
##
## Playtest Checklist:
## 1. Does breaking a single block feel satisfying?
## 2. After 30 seconds of mining, does it feel repetitive?
## 3. Is there any 'one more block' urge?
## 4. Does movement between blocks feel good?
## 5. Is the timing of block destruction right?

const BLOCK_SIZE := 128

@onready var grid: Node2D = $GreyboxGrid
@onready var player: CharacterBody2D = $GreyboxPlayer
@onready var blocks_label: Label = $UI/BlocksLabel
@onready var time_label: Label = $UI/TimeLabel
@onready var hint_label: Label = $UI/HintLabel

var blocks_destroyed := 0
var test_time := 0.0
var test_running := false


func _ready() -> void:
	# Connect player to grid
	player.set_dirt_grid(grid)

	# Connect grid signals
	grid.block_destroyed.connect(_on_block_destroyed)

	# Position player above terrain
	player.position = Vector2(10 * BLOCK_SIZE, 4 * BLOCK_SIZE)

	# Start test
	test_running = true

	# Update labels
	_update_labels()

	print("[GreyboxTest] Test scene ready - TAP BLOCKS TO MINE")
	print("[GreyboxTest] Evaluate: Does the core mining feel satisfying?")


func _process(delta: float) -> void:
	if test_running:
		test_time += delta
		_update_labels()


func _update_labels() -> void:
	if blocks_label:
		blocks_label.text = "Blocks: %d" % blocks_destroyed
	if time_label:
		time_label.text = "Time: %.1fs" % test_time
	if hint_label:
		if blocks_destroyed == 0:
			hint_label.text = "TAP BLOCKS TO MINE"
		elif blocks_destroyed < 10:
			hint_label.text = "Keep mining..."
		elif blocks_destroyed < 30:
			hint_label.text = "How does it feel?"
		else:
			hint_label.text = "30+ blocks! Still fun?"


func _on_block_destroyed(block_pos: Vector2i) -> void:
	blocks_destroyed += 1
	print("[GreyboxTest] Block %d destroyed at %s (%.1fs)" % [blocks_destroyed, str(block_pos), test_time])


func _input(event: InputEvent) -> void:
	# R to restart
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()

	# ESC to quit
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
