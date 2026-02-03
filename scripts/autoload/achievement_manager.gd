extends Node
## AchievementManager - Tracks and unlocks player achievements.
##
## Monitors game events like depth reached, ore collected, and coins earned.
## Emits signals when achievements are unlocked for UI notification.

signal achievement_unlocked(achievement: Dictionary)

## All available achievements
const ACHIEVEMENTS := {
	# First actions
	"first_dig": {
		"id": "first_dig",
		"name": "First Dig",
		"description": "Break your first block",
		"icon": "pickaxe"
	},
	"first_ore": {
		"id": "first_ore",
		"name": "Strike Gold... or Copper",
		"description": "Collect your first ore",
		"icon": "gem"
	},
	"first_sale": {
		"id": "first_sale",
		"name": "First Sale",
		"description": "Sell something at the shop",
		"icon": "coin"
	},
	"first_death": {
		"id": "first_death",
		"name": "Learning Experience",
		"description": "Die for the first time",
		"icon": "skull"
	},

	# Depth milestones
	"depth_10": {
		"id": "depth_10",
		"name": "Getting Deeper",
		"description": "Reach 10 meters depth",
		"icon": "arrow_down"
	},
	"depth_50": {
		"id": "depth_50",
		"name": "Into the Dark",
		"description": "Reach 50 meters depth",
		"icon": "arrow_down"
	},
	"depth_100": {
		"id": "depth_100",
		"name": "Deep Diver",
		"description": "Reach 100 meters depth",
		"icon": "arrow_down"
	},
	"depth_250": {
		"id": "depth_250",
		"name": "Spelunker",
		"description": "Reach 250 meters depth",
		"icon": "arrow_down"
	},
	"depth_500": {
		"id": "depth_500",
		"name": "Core Explorer",
		"description": "Reach 500 meters depth",
		"icon": "arrow_down"
	},

	# Coin milestones
	"coins_100": {
		"id": "coins_100",
		"name": "Pocket Change",
		"description": "Accumulate 100 coins total",
		"icon": "coin"
	},
	"coins_500": {
		"id": "coins_500",
		"name": "Modest Fortune",
		"description": "Accumulate 500 coins total",
		"icon": "coin"
	},
	"coins_1000": {
		"id": "coins_1000",
		"name": "Wealthy Miner",
		"description": "Accumulate 1000 coins total",
		"icon": "coin"
	},
	"coins_5000": {
		"id": "coins_5000",
		"name": "Mining Tycoon",
		"description": "Accumulate 5000 coins total",
		"icon": "coin"
	},

	# Tool upgrades
	"copper_pickaxe": {
		"id": "copper_pickaxe",
		"name": "Copper Age",
		"description": "Upgrade to Copper Pickaxe",
		"icon": "pickaxe"
	},
	"iron_pickaxe": {
		"id": "iron_pickaxe",
		"name": "Iron Will",
		"description": "Upgrade to Iron Pickaxe",
		"icon": "pickaxe"
	},

	# Collection achievements
	"collect_5_types": {
		"id": "collect_5_types",
		"name": "Diverse Miner",
		"description": "Collect 5 different ore types",
		"icon": "gem"
	},
	"collect_all_ores": {
		"id": "collect_all_ores",
		"name": "Completionist",
		"description": "Collect every type of ore",
		"icon": "gem"
	},

	# Inventory milestones
	"full_inventory": {
		"id": "full_inventory",
		"name": "Pack Rat",
		"description": "Fill your inventory completely",
		"icon": "backpack"
	},
	"first_upgrade": {
		"id": "first_upgrade",
		"name": "Moving Up",
		"description": "Purchase your first upgrade",
		"icon": "star"
	},

	# Close-call achievements
	"narrow_escape": {
		"id": "narrow_escape",
		"name": "Narrow Escape",
		"description": "Return to surface in a close-call situation",
		"icon": "heart"
	},
}

## Unlocked achievement IDs
var unlocked: Array[String] = []

## Total coins earned (lifetime, for tracking)
var lifetime_coins: int = 0

## Ores collected (by ore_id) for tracking unique types
var ores_collected: Dictionary = {}

## Blocks destroyed count
var blocks_destroyed: int = 0


func _ready() -> void:
	call_deferred("_connect_signals")
	print("[AchievementManager] Ready with %d achievements" % ACHIEVEMENTS.size())


func _connect_signals() -> void:
	# Connect to GameManager signals
	if GameManager:
		if GameManager.has_signal("depth_updated"):
			GameManager.depth_updated.connect(_on_depth_updated)
		if GameManager.has_signal("coins_changed"):
			GameManager.coins_changed.connect(_on_coins_changed)

	# Connect to PlayerData signals
	if PlayerData:
		if PlayerData.has_signal("tool_changed"):
			PlayerData.tool_changed.connect(_on_tool_changed)

	# Connect to InventoryManager signals
	if InventoryManager:
		if InventoryManager.has_signal("item_added"):
			InventoryManager.item_added.connect(_on_item_added)
		if InventoryManager.has_signal("inventory_changed"):
			InventoryManager.inventory_changed.connect(_on_inventory_changed)


## Unlock an achievement by ID
func unlock(achievement_id: String) -> void:
	if achievement_id in unlocked:
		return  # Already unlocked

	if achievement_id not in ACHIEVEMENTS:
		push_warning("[AchievementManager] Unknown achievement: %s" % achievement_id)
		return

	unlocked.append(achievement_id)
	var achievement: Dictionary = ACHIEVEMENTS[achievement_id]
	achievement_unlocked.emit(achievement)
	print("[AchievementManager] Unlocked: %s - %s" % [achievement.name, achievement.description])


## Check if an achievement is unlocked
func is_unlocked(achievement_id: String) -> bool:
	return achievement_id in unlocked


## Track a block being destroyed
func track_block_destroyed() -> void:
	blocks_destroyed += 1
	if blocks_destroyed == 1:
		unlock("first_dig")


## Track ore collection
func track_ore_collected(ore_id: String) -> void:
	if ore_id not in ores_collected:
		ores_collected[ore_id] = 0
	ores_collected[ore_id] += 1

	# First ore achievement
	if ores_collected.size() == 1 and ores_collected[ore_id] == 1:
		unlock("first_ore")

	# Diverse miner (5 types)
	if ores_collected.size() == 5:
		unlock("collect_5_types")

	# Completionist (all ore types)
	_check_all_ores_collected()


func _check_all_ores_collected() -> void:
	if DataRegistry == null:
		return
	var all_ores = DataRegistry.get_all_ores()
	if all_ores.size() == 0:
		return

	var collected_count := 0
	for ore in all_ores:
		if ore.id in ores_collected:
			collected_count += 1

	if collected_count >= all_ores.size():
		unlock("collect_all_ores")


## Track a sale
func track_sale(amount: int) -> void:
	if amount > 0:
		unlock("first_sale")


## Track player death
func track_death() -> void:
	unlock("first_death")


## Track upgrade purchase
func track_upgrade() -> void:
	unlock("first_upgrade")


## Event handlers
func _on_depth_updated(depth: int) -> void:
	if depth >= 10:
		unlock("depth_10")
	if depth >= 50:
		unlock("depth_50")
	if depth >= 100:
		unlock("depth_100")
	if depth >= 250:
		unlock("depth_250")
	if depth >= 500:
		unlock("depth_500")


func _on_coins_changed(coins: int) -> void:
	# Track lifetime coins (coins can only go up from mining)
	if coins > lifetime_coins:
		lifetime_coins = coins

	if lifetime_coins >= 100:
		unlock("coins_100")
	if lifetime_coins >= 500:
		unlock("coins_500")
	if lifetime_coins >= 1000:
		unlock("coins_1000")
	if lifetime_coins >= 5000:
		unlock("coins_5000")


func _on_tool_changed(tool_data) -> void:
	if tool_data == null:
		return
	if tool_data.id == "copper_pickaxe":
		unlock("copper_pickaxe")
	elif tool_data.id == "iron_pickaxe":
		unlock("iron_pickaxe")


func _on_item_added(item, _quantity: int) -> void:
	if item == null:
		return
	if item.category in ["ore", "gem"]:
		track_ore_collected(item.id)


func _on_inventory_changed() -> void:
	# Check if inventory is full
	if InventoryManager == null:
		return

	var filled_slots := 0
	for slot in InventoryManager.slots:
		if not slot.is_empty():
			filled_slots += 1

	if filled_slots >= InventoryManager.max_slots:
		unlock("full_inventory")


## Get all achievements with unlock status
func get_all_achievements() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in ACHIEVEMENTS:
		var achievement: Dictionary = ACHIEVEMENTS[id].duplicate()
		achievement["unlocked"] = is_unlocked(id)
		result.append(achievement)
	return result


## Get unlocked count
func get_unlocked_count() -> int:
	return unlocked.size()


## Get total achievement count
func get_total_count() -> int:
	return ACHIEVEMENTS.size()


## Get save data
func get_save_data() -> Dictionary:
	return {
		"unlocked": unlocked.duplicate(),
		"lifetime_coins": lifetime_coins,
		"ores_collected": ores_collected.duplicate(),
		"blocks_destroyed": blocks_destroyed,
	}


## Load save data
func load_save_data(data: Dictionary) -> void:
	unlocked.clear()
	for id in data.get("unlocked", []):
		unlocked.append(id)

	lifetime_coins = data.get("lifetime_coins", 0)
	ores_collected = data.get("ores_collected", {}).duplicate()
	blocks_destroyed = data.get("blocks_destroyed", 0)

	print("[AchievementManager] Loaded - %d/%d achievements unlocked" % [unlocked.size(), ACHIEVEMENTS.size()])


## Reset all progress
func reset() -> void:
	unlocked.clear()
	lifetime_coins = 0
	ores_collected.clear()
	blocks_destroyed = 0
	print("[AchievementManager] Reset")
