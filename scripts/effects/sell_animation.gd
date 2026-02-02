extends CanvasLayer
## Sell animation controller - creates satisfying coin cascade when selling items.
##
## Spawns coin sprites that arc from sell panel toward the coin counter HUD.
## Counter rolls up as coins arrive. Sound pitch builds with cascade.
## This is a KEY REWARD BEAT in the core loop - makes selling feel satisfying.

signal animation_complete(total_value: int)

## Coin fly scene
const CoinFly := preload("res://scripts/effects/coin_fly.gd")

## Animation timing
const COIN_SPAWN_INTERVAL := 0.05  # Seconds between coin spawns
const COIN_FLIGHT_DURATION := 0.4  # How long each coin takes to fly
const MIN_COINS := 3  # Minimum coins even for small sales
const MAX_COINS := 20  # Cap to prevent performance issues
const COUNTER_PAUSE := 0.1  # Brief pause when first coin arrives (Brawl Stars pattern)

## Sound settings
const BASE_COIN_PITCH := 1.0
const MAX_COIN_PITCH := 1.3  # Pitch increases as cascade progresses
const SOUND_COIN_CLINK := "res://audio/sfx/pickup_coin.wav"

## Visual effects thresholds
const MEDIUM_SALE_THRESHOLD := 51
const LARGE_SALE_THRESHOLD := 201
const JACKPOT_THRESHOLD := 500

## Animation state
var _is_animating: bool = false
var _total_value: int = 0
var _value_per_coin: int = 1
var _coins_spawned: int = 0
var _coins_arrived: int = 0
var _target_coins: int = 0
var _spawn_timer: float = 0.0
var _spawn_position: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO
var _first_coin_arrived: bool = false

## Counter rolling state
var _displayed_value: int = 0
var _target_value: int = 0
var _roll_speed: float = 100.0  # Coins per second to add

## HUD reference for counter animation
var _hud: Control = null
var _original_coins: int = 0


func _ready() -> void:
	# CanvasLayer settings
	layer = 50  # Above game, below some UI overlays

	# Find HUD reference
	_find_hud()


func _find_hud() -> void:
	# Try to find HUD in scene tree
	var main = get_tree().get_first_node_in_group("main")
	if main and main.has_node("UI/HUD"):
		_hud = main.get_node("UI/HUD")
	elif main and main.has_node("HUD"):
		_hud = main.get_node("HUD")


func _process(delta: float) -> void:
	if not _is_animating:
		return

	# Spawn coins over time
	if _coins_spawned < _target_coins:
		_spawn_timer -= delta
		if _spawn_timer <= 0:
			_spawn_coin()
			_spawn_timer = COIN_SPAWN_INTERVAL

	# Roll counter toward target
	if _displayed_value < _target_value:
		var roll_amount := _roll_speed * delta
		_displayed_value = mini(_displayed_value + int(roll_amount), _target_value)
		_update_coin_display(_original_coins + _displayed_value)


## Start the sell animation
## items: Array of {item, quantity, value} dictionaries
## total_value: Total coins being added
## source_pos: Global position to spawn coins from
## target_pos: Global position of coin counter (optional, auto-detected)
func play(items: Array, total_value: int, source_pos: Vector2 = Vector2.ZERO, target_pos: Vector2 = Vector2.ZERO) -> void:
	if _is_animating:
		# Don't allow overlapping animations
		return

	_is_animating = true
	_total_value = total_value
	_displayed_value = 0
	_target_value = total_value
	_coins_spawned = 0
	_coins_arrived = 0
	_first_coin_arrived = false
	_original_coins = GameManager.get_coins() if GameManager else 0

	# Calculate number of coins to spawn
	_target_coins = _calculate_coin_count(total_value)
	_value_per_coin = ceili(float(total_value) / float(_target_coins))

	# Set positions
	_spawn_position = source_pos if source_pos != Vector2.ZERO else _get_default_spawn_position()
	_target_position = target_pos if target_pos != Vector2.ZERO else _get_coin_counter_position()

	# Set roll speed based on total value (bigger = faster)
	_roll_speed = maxf(100.0, total_value * 2.0)

	# Start spawning
	_spawn_timer = 0.0

	# Determine animation tier and play start sound
	if total_value >= JACKPOT_THRESHOLD:
		# Jackpot! Extra fanfare
		if SoundManager:
			SoundManager.play_level_up()
	elif total_value >= LARGE_SALE_THRESHOLD:
		# Large sale - play achievement sound
		if SoundManager:
			SoundManager.play_ui_success()


func _calculate_coin_count(value: int) -> int:
	## Determine how many coins to spawn based on sale value
	if value <= 20:
		return MIN_COINS
	elif value <= 100:
		return clampi(value / 10, MIN_COINS, 10)
	elif value <= 500:
		return clampi(value / 30, 8, 15)
	else:
		return MAX_COINS


func _get_default_spawn_position() -> Vector2:
	## Get center of screen as fallback spawn position
	var viewport := get_viewport()
	if viewport:
		return viewport.get_visible_rect().size / 2.0
	return Vector2(200, 400)


func _get_coin_counter_position() -> Vector2:
	## Find the coin counter in the HUD
	if _hud == null:
		_find_hud()

	if _hud and _hud.has_node("CoinsLabel"):
		var coins_label: Label = _hud.get_node("CoinsLabel")
		return coins_label.global_position + coins_label.size / 2.0

	# Fallback to top-left area
	return Vector2(100, 30)


func _spawn_coin() -> void:
	## Spawn a single coin that flies to the counter
	var coin := Node2D.new()
	coin.set_script(CoinFly)
	add_child(coin)

	# Randomize spawn position slightly for spread effect
	var offset := Vector2(randf_range(-30, 30), randf_range(-30, 30))
	var spawn_pos := _spawn_position + offset

	# Stagger flight times for cascade effect
	var delay := _coins_spawned * COIN_SPAWN_INTERVAL * 0.5
	var duration := COIN_FLIGHT_DURATION + randf_range(-0.05, 0.05)

	# Connect arrival signal
	coin.coin_arrived.connect(_on_coin_arrived)
	coin.coin_value = _value_per_coin

	# Start flight
	coin.fly_to(spawn_pos, _target_position, delay, duration)

	_coins_spawned += 1

	# Play coin spawn sound with increasing pitch
	_play_coin_sound(_coins_spawned)


func _on_coin_arrived(value: int) -> void:
	## Handle coin reaching the counter
	_coins_arrived += 1

	# Brief pause when first coin arrives (satisfying moment)
	if not _first_coin_arrived:
		_first_coin_arrived = true
		# Could add a tiny hitstop here if desired

	# Play arrival clink
	_play_coin_clink()

	# Check if animation complete
	if _coins_arrived >= _target_coins:
		_complete_animation()


func _play_coin_sound(coin_index: int) -> void:
	## Play spawn sound with pitch that increases over the cascade
	if SoundManager == null:
		return

	var progress := float(coin_index) / float(_target_coins)
	var pitch := lerpf(BASE_COIN_PITCH, MAX_COIN_PITCH, progress)
	SoundManager.play_sfx(SOUND_COIN_CLINK, -12.0, pitch)


func _play_coin_clink() -> void:
	## Play short clink when coin arrives
	if SoundManager == null:
		return

	# Vary pitch slightly for natural feel
	var pitch := randf_range(1.1, 1.3)
	SoundManager.play_sfx(SOUND_COIN_CLINK, -8.0, pitch)


func _update_coin_display(value: int) -> void:
	## Update the HUD coin counter during animation
	if _hud and _hud.has_node("CoinsLabel"):
		var coins_label: Label = _hud.get_node("CoinsLabel")
		coins_label.text = "$%d" % value


func _complete_animation() -> void:
	## Finish the animation and emit completion signal
	_is_animating = false

	# Ensure final value is displayed
	_update_coin_display(_original_coins + _total_value)

	# Flash effect for large sales
	if _total_value >= LARGE_SALE_THRESHOLD:
		_flash_coin_counter()

	# Actually add the coins now (GameManager)
	if GameManager:
		GameManager.add_coins(_total_value)

	animation_complete.emit(_total_value)

	# Play completion sound based on tier
	if SoundManager:
		if _total_value >= JACKPOT_THRESHOLD:
			SoundManager.play_achievement()
		elif _total_value >= LARGE_SALE_THRESHOLD:
			SoundManager.play_milestone()


func _flash_coin_counter() -> void:
	## Brief flash/pulse on the coin counter
	if _hud == null or not _hud.has_node("CoinsLabel"):
		return

	# Skip if reduced motion
	if SettingsManager and SettingsManager.reduced_motion:
		return

	var coins_label: Label = _hud.get_node("CoinsLabel")
	coins_label.pivot_offset = coins_label.size / 2.0

	var tween := create_tween()
	tween.tween_property(coins_label, "scale", Vector2(1.3, 1.3), 0.1) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(coins_label, "scale", Vector2(1.0, 1.0), 0.2) \
		.set_ease(Tween.EASE_OUT)


## Check if animation is currently playing
func is_playing() -> bool:
	return _is_animating


## Cancel animation and complete immediately
func skip() -> void:
	if not _is_animating:
		return

	# Clean up any flying coins
	for child in get_children():
		if child.has_method("queue_free"):
			child.queue_free()

	# Complete immediately
	_update_coin_display(_original_coins + _total_value)
	if GameManager:
		GameManager.add_coins(_total_value)
	_is_animating = false
	animation_complete.emit(_total_value)
