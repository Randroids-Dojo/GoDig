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

## Cached values for comparison
var _last_hp: int = -1
var _last_max_hp: int = -1

## Animation state
var _vignette_pulse_time: float = 0.0
const VIGNETTE_PULSE_SPEED: float = 3.0
const VIGNETTE_MIN_ALPHA: float = 0.1
const VIGNETTE_MAX_ALPHA: float = 0.4


func _ready() -> void:
	# Initialize display
	_update_health_display(100, 100)
	low_health_vignette.visible = false

	# Connect to GameManager signals
	if GameManager:
		GameManager.coins_changed.connect(_on_coins_changed)
		GameManager.depth_updated.connect(_on_depth_updated)
		_update_coins_display(GameManager.get_coins())
		_update_depth_display(0)

	# Connect pause button
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)


func _process(delta: float) -> void:
	# Pulse the low health vignette
	if low_health_vignette.visible:
		_vignette_pulse_time += delta * VIGNETTE_PULSE_SPEED
		var pulse := (sin(_vignette_pulse_time) + 1.0) / 2.0  # 0 to 1
		var alpha := lerpf(VIGNETTE_MIN_ALPHA, VIGNETTE_MAX_ALPHA, pulse)
		low_health_vignette.modulate.a = alpha


## Connect to a player's HP signals
func connect_to_player(player: Node) -> void:
	if player.has_signal("hp_changed"):
		player.hp_changed.connect(_on_player_hp_changed)
	if player.has_signal("player_died"):
		player.player_died.connect(_on_player_died)


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
