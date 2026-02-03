extends Node
## SecretLayerManager - Manages the 3-tier layered secret system.
##
## Inspired by Animal Well's approach to layered discovery:
## - Layer 1 (All Players): Normal progression, obvious rewards
## - Layer 2 (Explorers): Hidden rooms, environmental clues, rare finds
## - Layer 3 (Hardcore): Community puzzles, ARG elements (v1.1+)
##
## Trust players to discover mechanics through play rather than tutorials.
## Players feel smart discovering secrets rather than being told.

signal secret_wall_detected(grid_pos: Vector2i, hint_type: String)
signal secret_wall_broken(grid_pos: Vector2i, room_type: String)
signal layer2_discovery(discovery_type: String, grid_pos: Vector2i, reward_value: int)
signal rare_secret_found(secret_id: String, grid_pos: Vector2i)
signal secret_hint_shown(hint_text: String, grid_pos: Vector2i)

## Secret discovery layers
enum SecretLayer {
	LAYER_1,  # Normal gameplay - no secrets
	LAYER_2,  # Explorer secrets - hidden rooms, environmental clues
	LAYER_3,  # Hardcore secrets - ARG, community puzzles (future)
}

## Secret wall types and their visual hints
const SECRET_WALL_CONFIG := {
	"weak_spot": {
		"spawn_chance": 0.05,  # 5% of solid walls in caves become weak spots
		"min_depth": 30,
		"hint_type": "shimmer",  # Subtle shimmer effect
		"room_behind_chance": 0.4,  # 40% chance of hidden room behind
		"description": "This wall looks slightly different..."
	},
	"cracked": {
		"spawn_chance": 0.03,  # 3% chance
		"min_depth": 75,
		"hint_type": "crack_lines",  # Visible cracks
		"room_behind_chance": 0.6,
		"description": "Cracks run through this wall."
	},
	"hollow": {
		"spawn_chance": 0.02,  # 2% chance
		"min_depth": 150,
		"hint_type": "sound",  # Makes different sound when hit
		"room_behind_chance": 0.8,
		"description": "This wall sounds hollow..."
	},
	"ancient": {
		"spawn_chance": 0.01,  # 1% chance
		"min_depth": 300,
		"hint_type": "glow",  # Faint glow at edges
		"room_behind_chance": 1.0,
		"description": "Faint light seeps from the edges."
	},
}

## Hidden room rewards by depth tier
const HIDDEN_ROOM_REWARDS := {
	"shallow": {  # 30-100m
		"min_depth": 30,
		"max_depth": 100,
		"rewards": [
			{"type": "ore", "id": "copper", "amount": [5, 10]},
			{"type": "ore", "id": "iron", "amount": [3, 6]},
			{"type": "item", "id": "ladder", "amount": [2, 4]},
			{"type": "coins", "amount": [50, 150]},
		]
	},
	"medium": {  # 100-250m
		"min_depth": 100,
		"max_depth": 250,
		"rewards": [
			{"type": "ore", "id": "silver", "amount": [4, 8]},
			{"type": "ore", "id": "gold", "amount": [2, 5]},
			{"type": "item", "id": "rope", "amount": [1, 2]},
			{"type": "coins", "amount": [150, 400]},
		]
	},
	"deep": {  # 250-500m
		"min_depth": 250,
		"max_depth": 500,
		"rewards": [
			{"type": "ore", "id": "platinum", "amount": [3, 6]},
			{"type": "ore", "id": "ruby", "amount": [2, 4]},
			{"type": "ore", "id": "emerald", "amount": [2, 4]},
			{"type": "coins", "amount": [400, 1000]},
		]
	},
	"abyssal": {  # 500m+
		"min_depth": 500,
		"max_depth": 99999,
		"rewards": [
			{"type": "ore", "id": "diamond", "amount": [2, 5]},
			{"type": "ore", "id": "void_crystal", "amount": [1, 3]},
			{"type": "artifact", "id": "ancient_relic", "amount": [1, 1]},
			{"type": "coins", "amount": [1000, 3000]},
		]
	},
}

## Chunk size for calculations
const CHUNK_SIZE := 16

## Active secret walls (grid_pos -> wall_data)
var _secret_walls: Dictionary = {}

## Broken secret walls (grid_pos -> bool) - persisted
var _broken_walls: Dictionary = {}

## Layer 2 discoveries made (discovery_id -> bool) - persisted
var _layer2_discoveries: Dictionary = {}

## Player statistics for adaptive secrets
var _walls_broken_count: int = 0
var _hidden_rooms_found: int = 0

## RNG for generation
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	print("[SecretLayerManager] Ready - Animal Well-inspired 3-tier secret system")


## Check if a solid wall position should become a secret wall during generation
## Returns: {"is_secret": bool, "wall_type": String, "has_room": bool}
func check_secret_wall_spawn(grid_pos: Vector2i, depth: int, world_seed: int, is_cave_adjacent: bool) -> Dictionary:
	var result := {
		"is_secret": false,
		"wall_type": "",
		"has_room": false,
	}

	# Only walls adjacent to caves can be secret walls
	if not is_cave_adjacent:
		return result

	# Deterministic RNG for this position
	_rng.seed = world_seed + grid_pos.x * 123456789 + grid_pos.y * 987654321

	# Check each wall type (rarer types first)
	for wall_type in ["ancient", "hollow", "cracked", "weak_spot"]:
		var config: Dictionary = SECRET_WALL_CONFIG[wall_type]

		# Check depth requirement
		if depth < config["min_depth"]:
			continue

		# Roll for spawn
		if _rng.randf() < config["spawn_chance"]:
			result["is_secret"] = true
			result["wall_type"] = wall_type
			result["has_room"] = _rng.randf() < config["room_behind_chance"]
			break

	return result


## Register a secret wall (called during chunk generation)
func register_secret_wall(grid_pos: Vector2i, wall_type: String, has_room: bool, depth: int) -> void:
	# Skip if already broken
	if _broken_walls.has(grid_pos):
		return

	_secret_walls[grid_pos] = {
		"wall_type": wall_type,
		"has_room": has_room,
		"depth": depth,
		"discovered": false,  # Player hasn't noticed the hint yet
	}


## Check if a position is a secret wall
func is_secret_wall(grid_pos: Vector2i) -> bool:
	return _secret_walls.has(grid_pos) and not _broken_walls.has(grid_pos)


## Get secret wall data at position
func get_secret_wall(grid_pos: Vector2i) -> Dictionary:
	if _secret_walls.has(grid_pos) and not _broken_walls.has(grid_pos):
		return _secret_walls[grid_pos]
	return {}


## Get the hint type for a secret wall (for visual effects)
func get_wall_hint_type(grid_pos: Vector2i) -> String:
	var wall_data: Dictionary = get_secret_wall(grid_pos)
	if wall_data.is_empty():
		return ""

	var wall_type: String = wall_data.get("wall_type", "")
	if wall_type in SECRET_WALL_CONFIG:
		return SECRET_WALL_CONFIG[wall_type].get("hint_type", "")
	return ""


## Called when player is near a secret wall - show hint
func player_near_secret(grid_pos: Vector2i, player_pos: Vector2i) -> void:
	var wall_data: Dictionary = get_secret_wall(grid_pos)
	if wall_data.is_empty():
		return

	if wall_data.get("discovered", false):
		return  # Already discovered

	# Mark as discovered (player noticed the hint)
	_secret_walls[grid_pos]["discovered"] = true

	var wall_type: String = wall_data.get("wall_type", "")
	if wall_type in SECRET_WALL_CONFIG:
		var config: Dictionary = SECRET_WALL_CONFIG[wall_type]
		var hint_type: String = config.get("hint_type", "shimmer")
		secret_wall_detected.emit(grid_pos, hint_type)


## Called when a secret wall is broken
func on_secret_wall_broken(grid_pos: Vector2i) -> void:
	var wall_data: Dictionary = get_secret_wall(grid_pos)
	if wall_data.is_empty():
		return

	# Mark as broken
	_broken_walls[grid_pos] = true
	_walls_broken_count += 1

	var wall_type: String = wall_data.get("wall_type", "")
	var has_room: bool = wall_data.get("has_room", false)
	var depth: int = wall_data.get("depth", 0)

	# Emit signal
	secret_wall_broken.emit(grid_pos, wall_type)

	# If there's a room behind, trigger the reward
	if has_room:
		_hidden_rooms_found += 1
		_spawn_hidden_room_rewards(grid_pos, depth)

	# Celebration feedback
	if SoundManager:
		SoundManager.play_milestone()
	if HapticFeedback:
		HapticFeedback.impact_medium()

	# Check achievements
	_check_explorer_achievements()

	print("[SecretLayerManager] Secret wall broken at %s - room: %s" % [str(grid_pos), str(has_room)])


## Spawn rewards when a hidden room is discovered
func _spawn_hidden_room_rewards(grid_pos: Vector2i, depth: int) -> void:
	# Get reward tier
	var reward_tier := _get_reward_tier(depth)
	if reward_tier.is_empty():
		return

	var rewards: Array = reward_tier.get("rewards", [])
	if rewards.is_empty():
		return

	# Seed RNG for deterministic rewards
	_rng.seed = grid_pos.x * 456789123 + grid_pos.y * 321654987

	# Pick a random reward from the tier
	var reward: Dictionary = rewards[_rng.randi() % rewards.size()]

	var reward_type: String = reward.get("type", "")
	var reward_id: String = reward.get("id", "")
	var amount_range: Array = reward.get("amount", [1, 1])
	var amount := _rng.randi_range(amount_range[0], amount_range[1])

	# Calculate reward value for statistics
	var reward_value := _calculate_reward_value(reward_type, reward_id, amount)

	# Apply reward
	match reward_type:
		"ore":
			_give_ore_reward(reward_id, amount)
		"item":
			_give_item_reward(reward_id, amount)
		"coins":
			_give_coin_reward(amount)
		"artifact":
			_give_artifact_reward(reward_id)

	# Emit discovery signal
	layer2_discovery.emit("hidden_room", grid_pos, reward_value)


## Get reward tier for depth
func _get_reward_tier(depth: int) -> Dictionary:
	for tier_id in HIDDEN_ROOM_REWARDS:
		var tier: Dictionary = HIDDEN_ROOM_REWARDS[tier_id]
		if depth >= tier["min_depth"] and depth < tier["max_depth"]:
			return tier
	return {}


## Calculate reward value for statistics
func _calculate_reward_value(reward_type: String, reward_id: String, amount: int) -> int:
	match reward_type:
		"coins":
			return amount
		"ore":
			# Estimate ore value
			var base_values := {
				"copper": 5, "iron": 10, "silver": 20, "gold": 50,
				"platinum": 80, "ruby": 100, "emerald": 100, "diamond": 200,
				"void_crystal": 500
			}
			return base_values.get(reward_id, 10) * amount
		"item":
			var base_values := {"ladder": 15, "rope": 25}
			return base_values.get(reward_id, 20) * amount
		"artifact":
			return 1000  # Artifacts are very valuable
		_:
			return amount * 10


## Give ore reward to player
func _give_ore_reward(ore_id: String, amount: int) -> void:
	if not InventoryManager:
		return

	for i in range(amount):
		InventoryManager.add_item_by_id(ore_id, 1)

	print("[SecretLayerManager] Gave %d %s" % [amount, ore_id])


## Give item reward to player
func _give_item_reward(item_id: String, amount: int) -> void:
	if not InventoryManager:
		return

	InventoryManager.add_item_by_id(item_id, amount)
	print("[SecretLayerManager] Gave %d %s" % [amount, item_id])


## Give coin reward to player
func _give_coin_reward(amount: int) -> void:
	if GameManager:
		GameManager.add_coins(amount)
		print("[SecretLayerManager] Gave %d coins" % amount)


## Give artifact reward to player
func _give_artifact_reward(artifact_id: String) -> void:
	if not InventoryManager:
		return

	# Try to add the artifact
	InventoryManager.add_item_by_id(artifact_id, 1)

	# This is a rare find - extra celebration
	rare_secret_found.emit(artifact_id, Vector2i.ZERO)

	if HapticFeedback:
		HapticFeedback.on_milestone_reached()

	print("[SecretLayerManager] Found rare artifact: %s" % artifact_id)


## Check explorer achievements
func _check_explorer_achievements() -> void:
	if not AchievementManager:
		return

	# First secret wall
	if _walls_broken_count >= 1:
		AchievementManager.unlock_achievement("first_secret")

	# Hidden room finder
	if _hidden_rooms_found >= 5:
		AchievementManager.unlock_achievement("secret_seeker")

	# Master explorer
	if _hidden_rooms_found >= 25:
		AchievementManager.unlock_achievement("master_explorer")


## Generate secret wall hints for a chunk (visual effects)
## Returns list of positions with hint types
func get_secret_hints_in_chunk(chunk_pos: Vector2i) -> Array:
	var hints: Array = []

	var start_x := chunk_pos.x * CHUNK_SIZE
	var start_y := chunk_pos.y * CHUNK_SIZE

	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var grid_pos := Vector2i(start_x + x, start_y + y)
			if is_secret_wall(grid_pos):
				var hint_type := get_wall_hint_type(grid_pos)
				if hint_type != "":
					hints.append({
						"pos": grid_pos,
						"hint_type": hint_type,
					})

	return hints


## Unload secrets for a chunk
func unload_chunk(chunk_pos: Vector2i) -> void:
	var start_x := chunk_pos.x * CHUNK_SIZE
	var start_y := chunk_pos.y * CHUNK_SIZE

	var to_remove: Array[Vector2i] = []
	for pos in _secret_walls:
		if pos.x >= start_x and pos.x < start_x + CHUNK_SIZE:
			if pos.y >= start_y and pos.y < start_y + CHUNK_SIZE:
				to_remove.append(pos)

	for pos in to_remove:
		_secret_walls.erase(pos)


## Reset for new game
func reset() -> void:
	_secret_walls.clear()
	_broken_walls.clear()
	_layer2_discoveries.clear()
	_walls_broken_count = 0
	_hidden_rooms_found = 0
	print("[SecretLayerManager] Reset for new game")


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	# Convert positions to serializable format
	var broken_list: Array = []
	for pos in _broken_walls:
		broken_list.append([pos.x, pos.y])

	return {
		"broken_walls": broken_list,
		"layer2_discoveries": _layer2_discoveries.duplicate(),
		"walls_broken_count": _walls_broken_count,
		"hidden_rooms_found": _hidden_rooms_found,
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	_broken_walls.clear()
	_layer2_discoveries.clear()

	# Load broken walls
	var broken_list = data.get("broken_walls", [])
	for item in broken_list:
		if item is Array and item.size() == 2:
			_broken_walls[Vector2i(item[0], item[1])] = true

	# Load discoveries
	var discoveries = data.get("layer2_discoveries", {})
	for key in discoveries:
		_layer2_discoveries[key] = discoveries[key]

	_walls_broken_count = data.get("walls_broken_count", 0)
	_hidden_rooms_found = data.get("hidden_rooms_found", 0)

	print("[SecretLayerManager] Loaded - %d broken walls, %d rooms found" % [
		_broken_walls.size(),
		_hidden_rooms_found
	])


# ============================================
# STATISTICS
# ============================================

## Get statistics for debugging
func get_stats() -> Dictionary:
	return {
		"active_secrets": _secret_walls.size(),
		"broken_walls": _broken_walls.size(),
		"walls_broken_total": _walls_broken_count,
		"hidden_rooms_found": _hidden_rooms_found,
		"layer2_discoveries": _layer2_discoveries.size(),
	}


## Check if position should show a visual hint (for DirtGrid rendering)
func should_show_hint(grid_pos: Vector2i) -> bool:
	var wall_data: Dictionary = get_secret_wall(grid_pos)
	if wall_data.is_empty():
		return false

	# Show hint if the wall type has a visual hint
	var wall_type: String = wall_data.get("wall_type", "")
	if wall_type in SECRET_WALL_CONFIG:
		var hint_type: String = SECRET_WALL_CONFIG[wall_type].get("hint_type", "")
		return hint_type in ["shimmer", "crack_lines", "glow"]

	return false
