extends Node
## GoDig Sound Manager
##
## Central audio manager for sound effects and music playback.
## Handles volume control, audio bus routing, and sound pooling.

# ============================================
# CONSTANTS
# ============================================

const MAX_SFX_PLAYERS := 8  # Pool size for concurrent sound effects
const MAX_MUSIC_PLAYERS := 2  # For crossfading between tracks

# ============================================
# SOUND POOLS
# ============================================

var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_index: int = 0

var _music_players: Array[AudioStreamPlayer] = []
var _current_music_index: int = 0

# ============================================
# LOADED SOUNDS
# ============================================

# Sound effects (loaded on demand, cached)
var _sound_cache: Dictionary = {}

# Sound categories with their audio bus
const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"

# ============================================
# SOUND DEFINITIONS
# ============================================

# Dig/mining sounds
const SOUND_DIG_SOFT := "res://audio/sfx/dig_soft.wav"
const SOUND_DIG_MEDIUM := "res://audio/sfx/dig_medium.wav"
const SOUND_DIG_HARD := "res://audio/sfx/dig_hard.wav"
const SOUND_BLOCK_BREAK := "res://audio/sfx/block_break.wav"
const SOUND_ORE_FOUND := "res://audio/sfx/ore_found.wav"

# Pickup sounds
const SOUND_PICKUP_COIN := "res://audio/sfx/pickup_coin.wav"
const SOUND_PICKUP_ORE := "res://audio/sfx/pickup_ore.wav"
const SOUND_PICKUP_ITEM := "res://audio/sfx/pickup_item.wav"
const SOUND_PICKUP_RARE := "res://audio/sfx/pickup_rare.wav"

# UI sounds
const SOUND_UI_CLICK := "res://audio/sfx/ui_click.wav"
const SOUND_UI_HOVER := "res://audio/sfx/ui_hover.wav"
const SOUND_UI_OPEN := "res://audio/sfx/ui_open.wav"
const SOUND_UI_CLOSE := "res://audio/sfx/ui_close.wav"
const SOUND_UI_ERROR := "res://audio/sfx/ui_error.wav"
const SOUND_UI_SUCCESS := "res://audio/sfx/ui_success.wav"
const SOUND_UI_PURCHASE := "res://audio/sfx/ui_purchase.wav"

# Player sounds
const SOUND_PLAYER_HURT := "res://audio/sfx/player_hurt.wav"
const SOUND_PLAYER_DEATH := "res://audio/sfx/player_death.wav"
const SOUND_PLAYER_LAND := "res://audio/sfx/player_land.wav"
const SOUND_PLAYER_JUMP := "res://audio/sfx/player_jump.wav"

# Achievement/milestone sounds
const SOUND_ACHIEVEMENT := "res://audio/sfx/achievement.wav"
const SOUND_MILESTONE := "res://audio/sfx/milestone.wav"
const SOUND_LEVEL_UP := "res://audio/sfx/level_up.wav"

# Music tracks
const MUSIC_MENU := "res://audio/music/menu_theme.ogg"
const MUSIC_SURFACE := "res://audio/music/surface_theme.ogg"
const MUSIC_UNDERGROUND := "res://audio/music/underground_theme.ogg"
const MUSIC_DEEP := "res://audio/music/deep_theme.ogg"
const MUSIC_DANGER := "res://audio/music/danger_theme.ogg"

# ============================================
# SIGNALS
# ============================================

signal music_changed(track_path: String)
signal sound_played(sound_path: String)


func _ready() -> void:
	_setup_audio_pools()
	_setup_audio_buses()
	print("[SoundManager] Ready with %d SFX players, %d music players" % [MAX_SFX_PLAYERS, MAX_MUSIC_PLAYERS])


func _setup_audio_pools() -> void:
	# Create SFX player pool
	for i in range(MAX_SFX_PLAYERS):
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		_sfx_pool.append(player)

	# Create music players for crossfading
	for i in range(MAX_MUSIC_PLAYERS):
		var player := AudioStreamPlayer.new()
		player.bus = MUSIC_BUS
		add_child(player)
		_music_players.append(player)


func _setup_audio_buses() -> void:
	# Ensure audio buses exist (created via default_bus_layout.tres or programmatically)
	# The SettingsManager handles volume levels for these buses
	pass


# ============================================
# SOUND EFFECT PLAYBACK
# ============================================

## Play a sound effect with optional volume and pitch variation
func play_sfx(sound_path: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not SettingsManager or SettingsManager.sfx_volume <= 0:
		return

	var stream := _get_or_load_sound(sound_path)
	if stream == null:
		return

	var player := _get_next_sfx_player()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()

	sound_played.emit(sound_path)


## Play a sound with random pitch variation for natural feel
func play_sfx_varied(sound_path: String, volume_db: float = 0.0, pitch_min: float = 0.95, pitch_max: float = 1.05) -> void:
	var pitch := randf_range(pitch_min, pitch_max)
	play_sfx(sound_path, volume_db, pitch)


func _get_next_sfx_player() -> AudioStreamPlayer:
	var player := _sfx_pool[_sfx_pool_index]
	_sfx_pool_index = (_sfx_pool_index + 1) % MAX_SFX_PLAYERS
	return player


func _get_or_load_sound(sound_path: String) -> AudioStream:
	if _sound_cache.has(sound_path):
		return _sound_cache[sound_path]

	if not ResourceLoader.exists(sound_path):
		# Sound file doesn't exist - this is expected until audio files are added
		return null

	var stream = load(sound_path)
	if stream is AudioStream:
		_sound_cache[sound_path] = stream
		return stream

	return null


# ============================================
# CONVENIENCE METHODS FOR GAME EVENTS
# ============================================

## Play dig sound based on material hardness
func play_dig(hardness: float) -> void:
	if hardness < 20:
		play_sfx_varied(SOUND_DIG_SOFT, -3.0)
	elif hardness < 50:
		play_sfx_varied(SOUND_DIG_MEDIUM, -2.0)
	else:
		play_sfx_varied(SOUND_DIG_HARD, 0.0)


## Play block break sound with intensity
func play_block_break(hardness: float = 10.0) -> void:
	var volume := clampf(hardness / 50.0, 0.5, 1.5) * -3.0
	play_sfx_varied(SOUND_BLOCK_BREAK, volume)


## Play ore discovery sound
func play_ore_found() -> void:
	play_sfx(SOUND_ORE_FOUND, -5.0)


## Play coin pickup sound
func play_coin_pickup() -> void:
	play_sfx_varied(SOUND_PICKUP_COIN, -8.0)


## Play ore pickup sound based on rarity
func play_ore_pickup(rarity: String = "common") -> void:
	match rarity:
		"legendary", "epic":
			play_sfx(SOUND_PICKUP_RARE, -3.0)
		_:
			play_sfx_varied(SOUND_PICKUP_ORE, -5.0)


## Play item pickup sound
func play_item_pickup() -> void:
	play_sfx_varied(SOUND_PICKUP_ITEM, -5.0)


## Play UI button click
func play_ui_click() -> void:
	play_sfx(SOUND_UI_CLICK, -10.0)


## Play UI hover sound
func play_ui_hover() -> void:
	play_sfx(SOUND_UI_HOVER, -15.0)


## Play UI panel open
func play_ui_open() -> void:
	play_sfx(SOUND_UI_OPEN, -8.0)


## Play UI panel close
func play_ui_close() -> void:
	play_sfx(SOUND_UI_CLOSE, -8.0)


## Play UI error sound
func play_ui_error() -> void:
	play_sfx(SOUND_UI_ERROR, -5.0)


## Play UI success sound
func play_ui_success() -> void:
	play_sfx(SOUND_UI_SUCCESS, -5.0)


## Play purchase sound
func play_purchase() -> void:
	play_sfx(SOUND_UI_PURCHASE, -5.0)


## Play player hurt sound
func play_player_hurt() -> void:
	play_sfx_varied(SOUND_PLAYER_HURT, -3.0)


## Play player death sound
func play_player_death() -> void:
	play_sfx(SOUND_PLAYER_DEATH, 0.0)


## Play landing sound based on fall intensity
func play_land(intensity: float = 1.0) -> void:
	var volume := clampf(intensity, 0.3, 1.0) * -5.0
	play_sfx_varied(SOUND_PLAYER_LAND, volume)


## Play jump sound
func play_jump() -> void:
	play_sfx_varied(SOUND_PLAYER_JUMP, -8.0)


## Play achievement unlock sound
func play_achievement() -> void:
	play_sfx(SOUND_ACHIEVEMENT, -3.0)


## Play depth milestone sound
func play_milestone() -> void:
	play_sfx(SOUND_MILESTONE, -3.0)


## Play level up / upgrade sound
func play_level_up() -> void:
	play_sfx(SOUND_LEVEL_UP, -3.0)


# ============================================
# MUSIC PLAYBACK
# ============================================

var _current_music_path: String = ""
var _music_tween: Tween = null

## Play a music track with optional crossfade
func play_music(music_path: String, crossfade_duration: float = 1.0) -> void:
	if not SettingsManager or SettingsManager.music_volume <= 0:
		return

	if music_path == _current_music_path:
		return  # Already playing

	var stream := _get_or_load_sound(music_path)
	if stream == null:
		return

	var old_player := _music_players[_current_music_index]
	_current_music_index = (_current_music_index + 1) % MAX_MUSIC_PLAYERS
	var new_player := _music_players[_current_music_index]

	# Setup new player
	new_player.stream = stream
	new_player.volume_db = -40.0  # Start quiet
	new_player.play()

	# Crossfade
	if _music_tween:
		_music_tween.kill()

	_music_tween = create_tween()
	_music_tween.set_parallel(true)

	# Fade out old track
	if old_player.playing:
		_music_tween.tween_property(old_player, "volume_db", -40.0, crossfade_duration)
		_music_tween.tween_callback(old_player.stop).set_delay(crossfade_duration)

	# Fade in new track
	_music_tween.tween_property(new_player, "volume_db", 0.0, crossfade_duration)

	_current_music_path = music_path
	music_changed.emit(music_path)


## Stop all music with optional fade out
func stop_music(fade_duration: float = 1.0) -> void:
	if _music_tween:
		_music_tween.kill()

	_music_tween = create_tween()
	_music_tween.set_parallel(true)

	for player in _music_players:
		if player.playing:
			_music_tween.tween_property(player, "volume_db", -40.0, fade_duration)
			_music_tween.tween_callback(player.stop).set_delay(fade_duration)

	_current_music_path = ""


## Play music based on current depth/location
func update_music_for_depth(depth: int) -> void:
	var track: String
	if depth <= 0:
		track = MUSIC_SURFACE
	elif depth < 200:
		track = MUSIC_UNDERGROUND
	elif depth < 500:
		track = MUSIC_DEEP
	else:
		track = MUSIC_DANGER

	play_music(track, 2.0)


## Play menu music
func play_menu_music() -> void:
	play_music(MUSIC_MENU, 1.0)


## Check if music is currently playing
func is_music_playing() -> bool:
	for player in _music_players:
		if player.playing:
			return true
	return false


## Get current music track path
func get_current_music() -> String:
	return _current_music_path


# ============================================
# VOLUME CONTROL
# ============================================

## Set master volume (0.0 to 1.0)
func set_master_volume(volume: float) -> void:
	var bus_idx := AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))


## Set SFX volume (0.0 to 1.0)
func set_sfx_volume(volume: float) -> void:
	var bus_idx := AudioServer.get_bus_index(SFX_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))


## Set music volume (0.0 to 1.0)
func set_music_volume(volume: float) -> void:
	var bus_idx := AudioServer.get_bus_index(MUSIC_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))


# ============================================
# CLEANUP
# ============================================

## Stop all sounds
func stop_all() -> void:
	for player in _sfx_pool:
		player.stop()
	stop_music(0.0)


## Clear sound cache (for memory management)
func clear_cache() -> void:
	_sound_cache.clear()
