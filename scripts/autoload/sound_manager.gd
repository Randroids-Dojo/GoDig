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

# Jackpot discovery sounds (tiered by rarity)
const SOUND_DISCOVERY_UNCOMMON := "res://audio/sfx/discovery_uncommon.wav"
const SOUND_DISCOVERY_RARE := "res://audio/sfx/discovery_rare.wav"
const SOUND_DISCOVERY_EPIC := "res://audio/sfx/discovery_epic.wav"
const SOUND_DISCOVERY_LEGENDARY := "res://audio/sfx/discovery_legendary.wav"

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
	_setup_tension_audio()
	print("[SoundManager] Ready with %d SFX players, %d music players" % [MAX_SFX_PLAYERS, MAX_MUSIC_PLAYERS])


func _process(delta: float) -> void:
	# Update tension audio system
	_update_tension_audio(delta)


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


## Play block break sound with intensity, using tool's audio identity settings
## tool: ToolData resource (optional) - if provided, uses tool's sound_pitch and break_volume_boost
## streak_pitch: Additional pitch multiplier from mining streak (default 1.0)
func play_block_break(hardness: float = 10.0, tool_tier: int = 1, streak_pitch: float = 1.0) -> void:
	var base_volume := clampf(hardness / 50.0, 0.5, 1.5) * -3.0
	var pitch := 1.0
	var volume_boost := 0.0

	# Try to get tool audio settings from PlayerData
	if PlayerData and PlayerData.current_tool:
		var tool = PlayerData.current_tool
		pitch = tool.sound_pitch if "sound_pitch" in tool else 1.0
		volume_boost = tool.break_volume_boost if "break_volume_boost" in tool else 0.0
	else:
		# Fallback: Calculate pitch from tier
		pitch = 1.0 + (tool_tier - 1) * 0.08  # Tier 1=1.0, Tier 2=1.08, Tier 3=1.16...

	# Apply streak pitch multiplier for combo feedback
	pitch *= streak_pitch

	var final_volume := base_volume + volume_boost
	play_sfx_varied(SOUND_BLOCK_BREAK, final_volume, pitch - 0.05, pitch + 0.05)


## Play ore discovery sound - Tier 2 celebration moment
## Higher pitch and sparkle quality distinct from regular mining
func play_ore_found() -> void:
	# Higher pitch range (1.1-1.2) for sparkle feel on discovery
	play_sfx_varied(SOUND_ORE_FOUND, -3.0, 1.1, 1.2)


## Play generic pickup sound
func play_pickup() -> void:
	play_sfx_varied(SOUND_PICKUP_ORE, -6.0)


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


## Play jackpot discovery sound based on rarity tier
## rarity: 0=common, 1=uncommon, 2=rare, 3=epic, 4=legendary
func play_jackpot_discovery(rarity: int) -> void:
	match rarity:
		1:  # Uncommon - subtle chime
			play_sfx(SOUND_DISCOVERY_UNCOMMON, -5.0, 1.0)
		2:  # Rare - exciting discovery
			play_sfx(SOUND_DISCOVERY_RARE, -3.0, 1.0)
		3:  # Epic - dramatic fanfare
			play_sfx(SOUND_DISCOVERY_EPIC, -1.0, 1.0)
		4, _:  # Legendary - full jackpot celebration
			if rarity >= 4:
				play_sfx(SOUND_DISCOVERY_LEGENDARY, 0.0, 1.0)


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


## Play tool upgrade celebration sound - dramatic and satisfying
func play_tool_upgrade() -> void:
	# Play the level up sound with higher pitch for extra impact
	play_sfx(SOUND_LEVEL_UP, -1.0, 1.1)
	# Also play a purchase confirmation for layered audio
	await get_tree().create_timer(0.1).timeout
	play_sfx(SOUND_UI_SUCCESS, -3.0, 1.2)


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


# ============================================
# TENSION AUDIO SYSTEM
# ============================================
# Subtle ambient audio that shifts based on combined risk factors,
# creating subconscious pressure without being annoying.
# Intensity levels:
#   0.0-0.3: Normal ambient (peaceful)
#   0.3-0.5: Slight low rumble
#   0.5-0.7: Heartbeat-like pulse (slow)
#   0.7-0.85: Heartbeat faster, rumble louder
#   0.85-1.0: Urgent, dramatic tension

## Tension audio constants
const TENSION_BUS := "SFX"  # Use SFX bus for tension audio
const TENSION_UPDATE_INTERVAL := 0.5  # Update every 0.5 seconds (not every frame)
const TENSION_CROSSFADE_DURATION := 1.0  # Smooth transitions between intensity levels
const TENSION_MAX_VOLUME := -15.0  # Keep tension audio subtle (low volume)
const TENSION_MIN_VOLUME := -40.0  # Effectively silent

## Risk factor weights for combined score
const RISK_WEIGHT_INVENTORY := 0.4
const RISK_WEIGHT_DEPTH := 0.3
const RISK_WEIGHT_LADDER := 0.3

## Thresholds for safe ladder count (based on depth)
const SAFE_LADDERS_PER_DEPTH := 5  # 1 ladder per 5m of depth is "safe"

## Tension audio state
var _tension_player: AudioStreamPlayer = null
var _tension_rumble_player: AudioStreamPlayer = null
var _tension_heartbeat_player: AudioStreamPlayer = null
var _tension_tween: Tween = null
var _current_risk_score: float = 0.0
var _target_risk_score: float = 0.0
var _tension_update_timer: float = 0.0
var _tension_enabled: bool = true

## Tension audio file paths (placeholder - will use procedural/built-in tones if not available)
const SOUND_TENSION_RUMBLE := "res://audio/sfx/tension_rumble.wav"
const SOUND_TENSION_HEARTBEAT := "res://audio/sfx/tension_heartbeat.wav"

signal tension_level_changed(risk_score: float)


## Initialize tension audio system
func _setup_tension_audio() -> void:
	# Create dedicated audio players for tension layers
	_tension_rumble_player = AudioStreamPlayer.new()
	_tension_rumble_player.bus = TENSION_BUS
	_tension_rumble_player.volume_db = TENSION_MIN_VOLUME
	add_child(_tension_rumble_player)

	_tension_heartbeat_player = AudioStreamPlayer.new()
	_tension_heartbeat_player.bus = TENSION_BUS
	_tension_heartbeat_player.volume_db = TENSION_MIN_VOLUME
	add_child(_tension_heartbeat_player)

	# Connect to settings changes
	if SettingsManager:
		SettingsManager.tension_audio_changed.connect(_on_tension_audio_setting_changed)
		_tension_enabled = SettingsManager.tension_audio_enabled

	print("[SoundManager] Tension audio system initialized")


func _on_tension_audio_setting_changed(enabled: bool) -> void:
	_tension_enabled = enabled
	if not enabled:
		# Fade out all tension audio
		_fade_tension_audio(0.0, 0.5)


## Calculate combined risk score from multiple factors
## Returns value from 0.0 (safe) to 1.0 (maximum danger)
func calculate_risk_score() -> float:
	if not GameManager or not InventoryManager:
		return 0.0

	# Factor 1: Inventory fill percentage (40% weight)
	var used_slots := InventoryManager.get_used_slots()
	var total_slots := InventoryManager.get_total_slots()
	var inventory_fill := float(used_slots) / float(total_slots) if total_slots > 0 else 0.0

	# Factor 2: Current depth risk (30% weight)
	# Depth risk increases gradually, maxing out at 100m
	var depth := GameManager.current_depth
	var depth_risk := clampf(float(depth) / 100.0, 0.0, 1.0)

	# Factor 3: Ladder safety (30% weight)
	# Risk increases when player has fewer ladders than needed for current depth
	var ladder_count := _get_player_ladder_count()
	var safe_ladders := ceili(float(depth) / SAFE_LADDERS_PER_DEPTH)
	var ladder_risk := 0.0
	if safe_ladders > 0:
		ladder_risk = 1.0 - clampf(float(ladder_count) / float(safe_ladders), 0.0, 1.0)

	# Combine factors with weights
	var combined_risk := (inventory_fill * RISK_WEIGHT_INVENTORY) + \
		(depth_risk * RISK_WEIGHT_DEPTH) + \
		(ladder_risk * RISK_WEIGHT_LADDER)

	return clampf(combined_risk, 0.0, 1.0)


## Get player's current ladder count from inventory or player data
func _get_player_ladder_count() -> int:
	# Check if DataRegistry has ladder item data
	if not DataRegistry:
		return 0

	var ladder_item = DataRegistry.get_item("ladder")
	if ladder_item and InventoryManager:
		return InventoryManager.get_item_count(ladder_item)

	# Fallback: check PlayerData consumables
	if PlayerData and PlayerData.consumables_owned.has("ladder"):
		return PlayerData.consumables_owned["ladder"]

	return 0


## Update tension audio based on current risk score
## Called periodically, not every frame
func _update_tension_audio(delta: float) -> void:
	if not _tension_enabled:
		return

	_tension_update_timer += delta
	if _tension_update_timer < TENSION_UPDATE_INTERVAL:
		return
	_tension_update_timer = 0.0

	# Calculate new risk score
	_target_risk_score = calculate_risk_score()

	# Smooth transition to target
	var score_diff := _target_risk_score - _current_risk_score
	_current_risk_score = lerpf(_current_risk_score, _target_risk_score, 0.3)

	# Emit signal if changed significantly
	if absf(score_diff) > 0.05:
		tension_level_changed.emit(_current_risk_score)

	# Apply audio based on risk level
	_apply_tension_audio_levels(_current_risk_score)


## Apply tension audio levels based on risk score
func _apply_tension_audio_levels(risk_score: float) -> void:
	# At surface (depth 0), no tension audio
	if GameManager and GameManager.current_depth <= 0:
		_fade_tension_audio(0.0, 0.5)
		return

	# Determine rumble volume (starts at 0.3 risk, maxes at 0.85)
	var rumble_volume := TENSION_MIN_VOLUME
	if risk_score >= 0.3:
		var rumble_intensity := clampf((risk_score - 0.3) / 0.55, 0.0, 1.0)
		rumble_volume = lerpf(TENSION_MIN_VOLUME, TENSION_MAX_VOLUME, rumble_intensity)

	# Determine heartbeat volume and speed (starts at 0.5 risk)
	var heartbeat_volume := TENSION_MIN_VOLUME
	var heartbeat_pitch := 1.0
	if risk_score >= 0.5:
		var heartbeat_intensity := clampf((risk_score - 0.5) / 0.5, 0.0, 1.0)
		heartbeat_volume = lerpf(TENSION_MIN_VOLUME, TENSION_MAX_VOLUME - 3.0, heartbeat_intensity)
		# Speed up heartbeat as risk increases (1.0 to 1.5 pitch)
		heartbeat_pitch = lerpf(1.0, 1.5, heartbeat_intensity)

	# Apply volumes with smooth transitions
	if _tension_rumble_player:
		_tension_rumble_player.volume_db = rumble_volume
		_start_tension_loop(_tension_rumble_player, SOUND_TENSION_RUMBLE)

	if _tension_heartbeat_player:
		_tension_heartbeat_player.volume_db = heartbeat_volume
		_tension_heartbeat_player.pitch_scale = heartbeat_pitch
		_start_tension_loop(_tension_heartbeat_player, SOUND_TENSION_HEARTBEAT)


## Start looping a tension audio track if not already playing
func _start_tension_loop(player: AudioStreamPlayer, sound_path: String) -> void:
	if player.playing:
		return

	var stream := _get_or_load_sound(sound_path)
	if stream:
		player.stream = stream
		player.play()


## Fade all tension audio to a target volume
func _fade_tension_audio(target_volume_db: float, duration: float) -> void:
	if _tension_tween and _tension_tween.is_valid():
		_tension_tween.kill()

	_tension_tween = create_tween()
	_tension_tween.set_parallel(true)

	if _tension_rumble_player:
		_tension_tween.tween_property(_tension_rumble_player, "volume_db", target_volume_db, duration)
	if _tension_heartbeat_player:
		_tension_tween.tween_property(_tension_heartbeat_player, "volume_db", target_volume_db, duration)

	# Stop playback if fading to silent
	if target_volume_db <= TENSION_MIN_VOLUME + 5.0:
		_tension_tween.tween_callback(_stop_tension_audio).set_delay(duration)


## Stop all tension audio playback
func _stop_tension_audio() -> void:
	if _tension_rumble_player:
		_tension_rumble_player.stop()
	if _tension_heartbeat_player:
		_tension_heartbeat_player.stop()


## Public: Get current risk/tension score
func get_tension_score() -> float:
	return _current_risk_score


## Public: Force recalculation of tension (call after significant state changes)
func update_tension_now() -> void:
	_tension_update_timer = TENSION_UPDATE_INTERVAL  # Force immediate update on next _process
