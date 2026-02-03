extends Node
## EnemyManager - Handles enemy spawning and tracking.
##
## Manages enemy types, spawn conditions, and combat encounters.
## Enemies spawn in caves and deep areas to add challenge to exploration.

signal enemy_spawned(enemy_type: String, position: Vector2i)
signal enemy_defeated(enemy_type: String, reward: int)
signal combat_started(enemy_type: String)
signal combat_ended(victory: bool)

## Enemy type definitions
const ENEMY_TYPES := {
	"cave_bat": {
		"name": "Cave Bat",
		"hp": 10,
		"damage": 5,
		"min_depth": 100,
		"max_depth": 500,
		"spawn_chance": 0.05,
		"reward_coins": 25,
		"description": "A small bat disturbed by your mining.",
	},
	"rock_crawler": {
		"name": "Rock Crawler",
		"hp": 25,
		"damage": 10,
		"min_depth": 200,
		"max_depth": 800,
		"spawn_chance": 0.03,
		"reward_coins": 50,
		"description": "An insect-like creature that feeds on minerals.",
	},
	"crystal_spider": {
		"name": "Crystal Spider",
		"hp": 40,
		"damage": 15,
		"min_depth": 400,
		"max_depth": 1200,
		"spawn_chance": 0.02,
		"reward_coins": 100,
		"description": "A spider with crystalline legs that reflect light.",
	},
	"lava_slug": {
		"name": "Lava Slug",
		"hp": 60,
		"damage": 20,
		"min_depth": 600,
		"max_depth": -1,
		"spawn_chance": 0.015,
		"reward_coins": 200,
		"description": "A heat-resistant creature from the magma zone.",
	},
	"void_wraith": {
		"name": "Void Wraith",
		"hp": 100,
		"damage": 30,
		"min_depth": 1000,
		"max_depth": -1,
		"spawn_chance": 0.01,
		"reward_coins": 500,
		"description": "A shadowy entity from the void depths.",
	},
}

## Active enemies in the world (grid_pos -> enemy_data)
var active_enemies: Dictionary = {}

## Combat state
var in_combat: bool = false
var current_enemy: Dictionary = {}
var current_enemy_hp: int = 0

## Statistics
var enemies_defeated: int = 0
var total_enemy_reward: int = 0

## RNG for spawning
var _spawn_rng := RandomNumberGenerator.new()


func _ready() -> void:
	_spawn_rng.randomize()
	print("[EnemyManager] Ready with %d enemy types" % ENEMY_TYPES.size())


## Check if enemies are enabled (respects peaceful mode)
func enemies_enabled() -> bool:
	if SettingsManager and SettingsManager.peaceful_mode:
		return false
	return true


## Check if an enemy should spawn when breaking a block
func check_enemy_spawn(grid_pos: Vector2i, depth: int) -> String:
	# Respect peaceful mode setting
	if not enemies_enabled():
		return ""

	if in_combat:
		return ""  # Don't spawn during combat

	for enemy_id in ENEMY_TYPES:
		var enemy: Dictionary = ENEMY_TYPES[enemy_id]

		# Check depth range
		if depth < enemy["min_depth"]:
			continue
		if enemy["max_depth"] != -1 and depth > enemy["max_depth"]:
			continue

		# Check spawn chance
		if _spawn_rng.randf() < enemy["spawn_chance"]:
			spawn_enemy(enemy_id, grid_pos)
			return enemy_id

	return ""


## Warning delay before combat starts (no sudden death from RNG)
const ENEMY_WARNING_DELAY := 0.8  # Seconds of warning before combat

## Spawn an enemy at a position
func spawn_enemy(enemy_id: String, grid_pos: Vector2i) -> void:
	if not ENEMY_TYPES.has(enemy_id):
		push_warning("[EnemyManager] Unknown enemy type: %s" % enemy_id)
		return

	var enemy_data: Dictionary = ENEMY_TYPES[enemy_id].duplicate()
	enemy_data["id"] = enemy_id
	enemy_data["grid_pos"] = grid_pos

	active_enemies[grid_pos] = enemy_data
	enemy_spawned.emit(enemy_id, grid_pos)

	print("[EnemyManager] Spawned %s at %s" % [enemy_data["name"], grid_pos])

	# Play warning sound before combat (no sudden death - player has time to react)
	if SoundManager:
		SoundManager.play_ui_error()  # Alert sound

	# Haptic warning for mobile (fair warning principle)
	if HapticFeedback:
		HapticFeedback.on_ui_warning()

	# Delay before auto-starting combat (no beheading rule)
	# Player has time to see the enemy spawn and react
	if GameManager and GameManager.player:
		var player_pos := GameManager.get_player_grid_position()
		if player_pos.distance_to(grid_pos) <= 2:
			_start_combat_delayed(enemy_id, grid_pos)


## Start combat after warning delay (implements "no beheading" rule)
func _start_combat_delayed(enemy_id: String, grid_pos: Vector2i) -> void:
	# Wait for warning delay before starting combat
	# This gives player time to see the enemy and react
	await get_tree().create_timer(ENEMY_WARNING_DELAY).timeout

	# Check if enemy is still there (player might have fled or enemy was removed)
	if not active_enemies.has(grid_pos):
		return

	# Check if player is still nearby (they might have escaped during warning)
	if GameManager and GameManager.player:
		var player_pos := GameManager.get_player_grid_position()
		if player_pos.distance_to(grid_pos) > 2:
			print("[EnemyManager] Player escaped during warning - combat avoided")
			return

	start_combat(enemy_id, grid_pos)


## Start combat with an enemy
func start_combat(enemy_id: String, grid_pos: Vector2i) -> void:
	if in_combat:
		return

	if not active_enemies.has(grid_pos):
		# Create enemy data if not already active
		if not ENEMY_TYPES.has(enemy_id):
			return
		active_enemies[grid_pos] = ENEMY_TYPES[enemy_id].duplicate()
		active_enemies[grid_pos]["id"] = enemy_id
		active_enemies[grid_pos]["grid_pos"] = grid_pos

	current_enemy = active_enemies[grid_pos]
	current_enemy_hp = current_enemy["hp"]
	in_combat = true

	combat_started.emit(enemy_id)
	print("[EnemyManager] Combat started with %s" % current_enemy["name"])


## Attack the current enemy (returns damage dealt to player)
func attack_enemy(player_damage: float) -> int:
	if not in_combat:
		return 0

	# Deal damage to enemy
	current_enemy_hp -= int(player_damage)

	# Check if enemy is defeated
	if current_enemy_hp <= 0:
		return defeat_enemy()

	# Enemy counterattacks
	var enemy_damage: int = current_enemy["damage"]

	# Play sound
	if SoundManager:
		SoundManager.play_damage()

	return enemy_damage


## Defeat the current enemy
func defeat_enemy() -> int:
	if not in_combat:
		return 0

	var reward: int = current_enemy["reward_coins"]
	var enemy_id: String = current_enemy["id"]
	var grid_pos: Vector2i = current_enemy["grid_pos"]

	# Remove from active enemies
	if active_enemies.has(grid_pos):
		active_enemies.erase(grid_pos)

	# Update stats
	enemies_defeated += 1
	total_enemy_reward += reward

	# Give reward
	if GameManager:
		GameManager.add_coins(reward)

	in_combat = false
	current_enemy = {}
	current_enemy_hp = 0

	enemy_defeated.emit(enemy_id, reward)
	combat_ended.emit(true)

	print("[EnemyManager] Defeated %s! Reward: %d coins" % [ENEMY_TYPES[enemy_id]["name"], reward])

	# Play victory sound
	if SoundManager:
		SoundManager.play_coin_pickup()

	return 0  # No damage when enemy is defeated


## Flee from combat (take damage penalty)
func flee_combat() -> int:
	if not in_combat:
		return 0

	var flee_damage: int = current_enemy["damage"] * 2  # Double damage for fleeing

	in_combat = false
	current_enemy = {}
	current_enemy_hp = 0

	combat_ended.emit(false)
	print("[EnemyManager] Fled from combat! Took %d damage" % flee_damage)

	return flee_damage


## Get enemy info by ID
func get_enemy_info(enemy_id: String) -> Dictionary:
	if ENEMY_TYPES.has(enemy_id):
		return ENEMY_TYPES[enemy_id].duplicate()
	return {}


## Get enemies available at a specific depth
func get_enemies_at_depth(depth: int) -> Array:
	var result := []
	for enemy_id in ENEMY_TYPES:
		var enemy: Dictionary = ENEMY_TYPES[enemy_id]
		if depth >= enemy["min_depth"]:
			if enemy["max_depth"] == -1 or depth <= enemy["max_depth"]:
				result.append(enemy_id)
	return result


## Check if currently in combat
func is_in_combat() -> bool:
	return in_combat


## Get current enemy HP
func get_current_enemy_hp() -> int:
	return current_enemy_hp


## Get current enemy data
func get_current_enemy() -> Dictionary:
	return current_enemy


## Get total enemies defeated
func get_enemies_defeated() -> int:
	return enemies_defeated


## Clear all active enemies (for new game/reset)
func clear_enemies() -> void:
	active_enemies.clear()
	in_combat = false
	current_enemy = {}
	current_enemy_hp = 0


## Reset stats (for new game)
func reset() -> void:
	clear_enemies()
	enemies_defeated = 0
	total_enemy_reward = 0


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	return {
		"enemies_defeated": enemies_defeated,
		"total_enemy_reward": total_enemy_reward,
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	enemies_defeated = data.get("enemies_defeated", 0)
	total_enemy_reward = data.get("total_enemy_reward", 0)
	clear_enemies()  # Don't persist active enemies across sessions
	print("[EnemyManager] Loaded - Defeated: %d, Total reward: %d" % [enemies_defeated, total_enemy_reward])
