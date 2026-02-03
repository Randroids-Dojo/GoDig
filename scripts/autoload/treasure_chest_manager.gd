extends Node
## TreasureChestManager - Manages treasure chest spawning and loot in caves.
##
## Spawns treasure chests in cave spaces with randomized loot.
## Chests contain coins, items, ores, or rare artifacts.
## Creates loot-box-style excitement without monetization concerns.

signal chest_spawned(grid_pos: Vector2i, chest_tier: String)
signal chest_opened(grid_pos: Vector2i, loot: Array)
signal chest_collected(grid_pos: Vector2i)

## Chest spawn constants
const CAVE_CHEST_SPAWN_CHANCE := 0.10  # 10% of cave tiles get a chest
const CHEST_MIN_DEPTH := 25  # Chests start appearing at 25m depth

## Chest tier definitions (determines loot quality)
enum ChestTier {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
}

## Loot table configuration by chest tier
## Each tier has different loot pools and quantities
const CHEST_LOOT_TABLES := {
	ChestTier.COMMON: {
		"name": "Wooden Chest",
		"spawn_weight": 60,
		"coin_min": 25,
		"coin_max": 100,
		"loot_count_min": 1,
		"loot_count_max": 2,
		"loot_pool": ["coal", "copper", "ladder"],
	},
	ChestTier.UNCOMMON: {
		"name": "Iron Chest",
		"spawn_weight": 25,
		"coin_min": 75,
		"coin_max": 200,
		"loot_count_min": 2,
		"loot_count_max": 3,
		"loot_pool": ["iron", "silver", "rope", "ladder"],
	},
	ChestTier.RARE: {
		"name": "Golden Chest",
		"spawn_weight": 12,
		"coin_min": 150,
		"coin_max": 400,
		"loot_count_min": 2,
		"loot_count_max": 4,
		"loot_pool": ["gold", "ruby", "sapphire", "fossil_rare"],
	},
	ChestTier.EPIC: {
		"name": "Ancient Chest",
		"spawn_weight": 3,
		"coin_min": 300,
		"coin_max": 800,
		"loot_count_min": 3,
		"loot_count_max": 5,
		"loot_pool": ["platinum", "diamond", "emerald", "artifact_ancient_coin", "artifact_crystal_skull"],
	},
}

## Depth-based tier weight modifiers (deeper = better chests)
## At depth 500+, rare chests become more common
const DEPTH_TIER_BONUS := {
	100: {ChestTier.UNCOMMON: 1.2},
	200: {ChestTier.UNCOMMON: 1.5, ChestTier.RARE: 1.3},
	400: {ChestTier.RARE: 1.5, ChestTier.EPIC: 1.5},
	600: {ChestTier.RARE: 2.0, ChestTier.EPIC: 2.0},
}

## Active chests in the world (grid_pos -> chest_data)
var _chests: Dictionary = {}

## Opened chests (grid_pos -> bool) - persisted across sessions
var _opened_chests: Dictionary = {}

## RNG for spawning and loot
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	print("[TreasureChestManager] Ready with %d chest tiers" % CHEST_LOOT_TABLES.size())


## Check if a cave tile should spawn a chest
## Called during chunk generation for each cave position
func should_spawn_chest(grid_pos: Vector2i, depth: int, world_seed: int) -> bool:
	# Don't spawn too shallow
	if depth < CHEST_MIN_DEPTH:
		return false

	# Don't spawn if already opened
	if _opened_chests.has(grid_pos):
		return false

	# Deterministic RNG based on position and world seed
	_rng.seed = world_seed + grid_pos.x * 198491317 + grid_pos.y * 6542989

	# Slightly increase spawn chance with depth
	var depth_bonus := minf(depth * 0.0001, 0.05)  # Max +5% at deep depths
	var spawn_chance := CAVE_CHEST_SPAWN_CHANCE + depth_bonus

	return _rng.randf() < spawn_chance


## Spawn a chest at a cave position
func spawn_chest(grid_pos: Vector2i, depth: int, world_seed: int) -> void:
	if _chests.has(grid_pos):
		return  # Already exists

	if _opened_chests.has(grid_pos):
		return  # Already opened this session

	# Determine chest tier based on depth
	var tier := _select_chest_tier(depth, world_seed, grid_pos)
	var tier_data: Dictionary = CHEST_LOOT_TABLES[tier]

	# Generate loot for this chest
	var loot := _generate_loot(tier, depth, world_seed, grid_pos)

	# Create chest data
	var chest_data := {
		"grid_pos": grid_pos,
		"tier": tier,
		"tier_name": tier_data["name"],
		"loot": loot,
		"depth": depth,
		"opened": false,
	}

	_chests[grid_pos] = chest_data
	chest_spawned.emit(grid_pos, tier_data["name"])


## Select chest tier based on depth with weighted random
func _select_chest_tier(depth: int, world_seed: int, grid_pos: Vector2i) -> int:
	_rng.seed = world_seed + grid_pos.x * 73856093 + grid_pos.y * 19349663 + 12345

	# Calculate adjusted weights based on depth
	var weights: Dictionary = {}
	var total_weight := 0.0

	for tier in CHEST_LOOT_TABLES:
		var base_weight: float = CHEST_LOOT_TABLES[tier]["spawn_weight"]
		var modifier := 1.0

		# Apply depth bonuses
		for threshold in DEPTH_TIER_BONUS:
			if depth >= threshold and DEPTH_TIER_BONUS[threshold].has(tier):
				modifier *= DEPTH_TIER_BONUS[threshold][tier]

		weights[tier] = base_weight * modifier
		total_weight += weights[tier]

	# Weighted selection
	var roll := _rng.randf() * total_weight
	var cumulative := 0.0

	for tier in weights:
		cumulative += weights[tier]
		if roll <= cumulative:
			return tier

	return ChestTier.COMMON  # Fallback


## Generate loot for a chest
func _generate_loot(tier: int, depth: int, world_seed: int, grid_pos: Vector2i) -> Array:
	_rng.seed = world_seed + grid_pos.x * 314159265 + grid_pos.y * 271828182

	var tier_data: Dictionary = CHEST_LOOT_TABLES[tier]
	var loot: Array = []

	# Add coins
	var coin_amount := _rng.randi_range(tier_data["coin_min"], tier_data["coin_max"])
	# Depth multiplier for coins
	var depth_multiplier := 1.0 + (depth * 0.002)  # +0.2% per depth level
	coin_amount = int(coin_amount * depth_multiplier)
	loot.append({"type": "coins", "amount": coin_amount})

	# Add items from loot pool
	var loot_count := _rng.randi_range(tier_data["loot_count_min"], tier_data["loot_count_max"])
	var loot_pool: Array = tier_data["loot_pool"]

	for i in range(loot_count):
		var item_idx := _rng.randi() % loot_pool.size()
		var item_id: String = loot_pool[item_idx]

		# Check if item exists in registry (ore, gem, or item)
		var is_valid := false
		if DataRegistry:
			is_valid = DataRegistry.get_ore(item_id) != null or DataRegistry.get_item(item_id) != null

		if is_valid:
			# Check if already in loot (stack it)
			var found := false
			for existing in loot:
				if existing.get("item_id", "") == item_id:
					existing["amount"] = existing.get("amount", 1) + 1
					found = true
					break

			if not found:
				loot.append({"type": "item", "item_id": item_id, "amount": 1})

	return loot


## Open a chest at a position (player interaction)
func open_chest(grid_pos: Vector2i) -> Array:
	if not _chests.has(grid_pos):
		return []

	var chest_data: Dictionary = _chests[grid_pos]
	if chest_data["opened"]:
		return []

	# Mark as opened
	chest_data["opened"] = true
	_opened_chests[grid_pos] = true

	var loot: Array = chest_data["loot"]

	# Give loot to player
	_apply_loot(loot)

	chest_opened.emit(grid_pos, loot)
	print("[TreasureChestManager] Opened %s at %s - %d items" % [
		chest_data["tier_name"],
		str(grid_pos),
		loot.size()
	])

	return loot


## Apply loot to player (add to inventory/coins)
func _apply_loot(loot: Array) -> void:
	for item in loot:
		match item.get("type", ""):
			"coins":
				var amount: int = item.get("amount", 0)
				if GameManager:
					GameManager.add_coins(amount)
			"item":
				var item_id: String = item.get("item_id", "")
				var amount: int = item.get("amount", 1)
				if InventoryManager and item_id != "":
					InventoryManager.add_item_by_id(item_id, amount)


## Check if a chest exists at position
func has_chest(grid_pos: Vector2i) -> bool:
	return _chests.has(grid_pos) and not _chests[grid_pos]["opened"]


## Check if a chest was already opened at position
func was_chest_opened(grid_pos: Vector2i) -> bool:
	return _opened_chests.has(grid_pos)


## Get chest data at position
func get_chest_data(grid_pos: Vector2i) -> Dictionary:
	return _chests.get(grid_pos, {})


## Get all active (unopened) chest positions
func get_active_chest_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for pos in _chests:
		if not _chests[pos]["opened"]:
			positions.append(pos)
	return positions


## Remove a chest from tracking (e.g., chunk unload)
func remove_chest(grid_pos: Vector2i) -> void:
	_chests.erase(grid_pos)


## Clear all chests (for new game)
func reset() -> void:
	_chests.clear()
	_opened_chests.clear()
	print("[TreasureChestManager] Reset for new game")


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	# Convert opened chests to serializable format
	var opened_list: Array = []
	for pos in _opened_chests:
		opened_list.append([pos.x, pos.y])

	return {
		"opened_chests": opened_list,
	}


## Load from save data
func load_save_data(data: Dictionary) -> void:
	_opened_chests.clear()

	var opened_list = data.get("opened_chests", [])
	for item in opened_list:
		if item is Array and item.size() == 2:
			_opened_chests[Vector2i(item[0], item[1])] = true

	print("[TreasureChestManager] Loaded - %d opened chests" % _opened_chests.size())


# ============================================
# STATISTICS
# ============================================

## Get chest statistics for achievements/tracking
func get_stats() -> Dictionary:
	var total_opened := _opened_chests.size()
	var active_chests := 0
	var chest_tiers := {}

	for pos in _chests:
		if not _chests[pos]["opened"]:
			active_chests += 1
			var tier: int = _chests[pos]["tier"]
			chest_tiers[tier] = chest_tiers.get(tier, 0) + 1

	return {
		"total_opened": total_opened,
		"active_chests": active_chests,
		"chest_tiers": chest_tiers,
	}
