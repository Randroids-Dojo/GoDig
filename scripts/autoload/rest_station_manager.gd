extends Node
## RestStationManager autoload singleton for underground rest stations.
##
## Manages underground shop/rest stations that reduce the tedium of
## returning to surface on deep dives. Based on Motherload's design
## where "stations at various levels underground" offer convenience.
##
## Stations charge a "convenience tax" (prices inflated vs surface)
## to preserve surface shop relevance while reducing tedium.

signal station_unlocked(depth: int)
signal station_used(depth: int, service_type: String)

## Depths where rest stations can exist
## Must be unlocked first via depth milestone or surface building upgrade
const STATION_DEPTHS := [100, 250, 500, 750, 1000]

## Price multipliers (convenience tax)
const SELL_PRICE_MULTIPLIER := 0.8   # 80% of surface price (20% tax)
const BUY_PRICE_MULTIPLIER := 1.2    # 120% of surface price (20% markup)
const HEAL_COST_PER_HP := 5          # Coins per HP healed

## Unlocked stations (depths that player can use)
var _unlocked_stations: Array[int] = []

## Whether the station hub building is unlocked on surface
var _hub_unlocked: bool = false


func _ready() -> void:
	# Connect to GameManager for depth milestone tracking
	if GameManager:
		GameManager.max_depth_updated.connect(_on_max_depth_updated)
	print("[RestStationManager] Ready")


## Called when player reaches a new max depth
func _on_max_depth_updated(max_depth: int) -> void:
	# Check if any new stations should be unlocked
	for station_depth in STATION_DEPTHS:
		if max_depth >= station_depth and station_depth not in _unlocked_stations:
			# Station becomes visible but may need hub upgrade to use
			pass  # Station visibility handled separately


## Unlock the hub building (required for stations to function)
func unlock_hub() -> void:
	if _hub_unlocked:
		return
	_hub_unlocked = true
	print("[RestStationManager] Hub unlocked - stations now usable")


## Unlock a specific rest station at depth
func unlock_station(depth: int) -> bool:
	if depth not in STATION_DEPTHS:
		push_warning("[RestStationManager] Invalid station depth: %d" % depth)
		return false

	if depth in _unlocked_stations:
		return false  # Already unlocked

	_unlocked_stations.append(depth)
	_unlocked_stations.sort()
	station_unlocked.emit(depth)
	print("[RestStationManager] Station unlocked at %dm" % depth)
	return true


## Check if a station is unlocked at a specific depth
func is_station_unlocked(depth: int) -> bool:
	return depth in _unlocked_stations and _hub_unlocked


## Get the nearest unlocked station to a given depth
func get_nearest_station(from_depth: int) -> int:
	if _unlocked_stations.is_empty():
		return -1

	var nearest := -1
	var nearest_distance := 999999

	for station_depth in _unlocked_stations:
		var distance := absi(station_depth - from_depth)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = station_depth

	return nearest


## Get all unlocked station depths
func get_unlocked_stations() -> Array[int]:
	return _unlocked_stations.duplicate()


## Get all possible station depths
func get_all_station_depths() -> Array:
	return STATION_DEPTHS.duplicate()


## Check if player is at a rest station depth
func is_at_station(current_depth: int) -> bool:
	for depth in _unlocked_stations:
		# Allow some tolerance (within 3 blocks)
		if absi(depth - current_depth) <= 3:
			return true
	return false


# ============================================
# STATION SERVICES
# ============================================

## Get sell price for an item at a rest station (80% of surface)
func get_station_sell_price(base_price: int) -> int:
	return int(base_price * SELL_PRICE_MULTIPLIER)


## Get buy price for an item at a rest station (120% of surface)
func get_station_buy_price(base_price: int) -> int:
	return int(base_price * BUY_PRICE_MULTIPLIER)


## Calculate heal cost at a rest station
func get_heal_cost(hp_to_heal: int) -> int:
	return hp_to_heal * HEAL_COST_PER_HP


## Sell items at a rest station (returns coins earned)
func sell_at_station(depth: int, item_id: String, quantity: int) -> int:
	if not is_station_unlocked(depth):
		return 0

	# Get item data
	var item = DataRegistry.get_item(item_id) if DataRegistry else null
	if item == null:
		return 0

	# Calculate price with convenience tax
	var price_per_item := get_station_sell_price(item.sell_value)
	var total := price_per_item * quantity

	# Remove items and add coins
	if InventoryManager and InventoryManager.remove_item_by_id(item_id, quantity):
		GameManager.add_coins(total)
		station_used.emit(depth, "sell")
		print("[RestStationManager] Sold %dx %s at %dm for $%d" % [quantity, item_id, depth, total])
		return total

	return 0


## Buy ladders at a rest station
func buy_ladders_at_station(depth: int, quantity: int) -> bool:
	if not is_station_unlocked(depth):
		return false

	# Base ladder cost is 8 coins
	var base_cost := 8
	var inflated_cost := get_station_buy_price(base_cost)
	var total_cost := inflated_cost * quantity

	if not GameManager.can_afford(total_cost):
		return false

	if not GameManager.spend_coins(total_cost):
		return false

	# Add ladders to inventory
	var ladder_item = DataRegistry.get_item("ladder") if DataRegistry else null
	if ladder_item and InventoryManager:
		InventoryManager.add_item(ladder_item, quantity)
	elif PlayerData:
		PlayerData.add_consumable("ladder", quantity)

	station_used.emit(depth, "buy_ladder")
	print("[RestStationManager] Bought %d ladders at %dm for $%d" % [quantity, depth, total_cost])
	return true


## Heal at a rest station
func heal_at_station(depth: int, player: Node) -> int:
	if not is_station_unlocked(depth):
		return 0

	if player == null or not player.has_method("heal"):
		return 0

	# Calculate missing HP
	var current_hp: int = player.current_hp
	var max_hp: int = player.MAX_HP
	var missing_hp := max_hp - current_hp

	if missing_hp <= 0:
		return 0

	var heal_cost := get_heal_cost(missing_hp)

	if not GameManager.can_afford(heal_cost):
		# Partial heal with available coins
		var available := GameManager.get_coins()
		var hp_affordable := available / HEAL_COST_PER_HP
		if hp_affordable <= 0:
			return 0
		missing_hp = hp_affordable
		heal_cost = get_heal_cost(missing_hp)

	if GameManager.spend_coins(heal_cost):
		player.heal(missing_hp)
		station_used.emit(depth, "heal")
		print("[RestStationManager] Healed %d HP at %dm for $%d" % [missing_hp, depth, heal_cost])
		return missing_hp

	return 0


## Get quick heal cost for UI display
func get_full_heal_cost(current_hp: int, max_hp: int) -> int:
	var missing_hp := max_hp - current_hp
	return get_heal_cost(missing_hp)


# ============================================
# STATION UNLOCK COSTS
# ============================================

## Cost to unlock a station at a given depth
func get_station_unlock_cost(depth: int) -> int:
	# Base cost scales with depth
	# 100m = 5000, 250m = 10000, 500m = 20000, etc.
	return int(depth * 50)


## Unlock a station by spending coins
func purchase_station_unlock(depth: int) -> bool:
	if depth not in STATION_DEPTHS:
		return false

	if depth in _unlocked_stations:
		return false  # Already unlocked

	var cost := get_station_unlock_cost(depth)
	if not GameManager.can_afford(cost):
		return false

	if not GameManager.spend_coins(cost):
		return false

	return unlock_station(depth)


# ============================================
# SAVE/LOAD
# ============================================

## Get save data
func get_save_data() -> Dictionary:
	return {
		"hub_unlocked": _hub_unlocked,
		"unlocked_stations": _unlocked_stations.duplicate(),
	}


## Load save data
func load_save_data(data: Dictionary) -> void:
	_hub_unlocked = data.get("hub_unlocked", false)

	_unlocked_stations.clear()
	var saved_stations = data.get("unlocked_stations", [])
	if saved_stations is Array:
		for depth in saved_stations:
			if depth is int and depth in STATION_DEPTHS:
				_unlocked_stations.append(depth)
	_unlocked_stations.sort()


## Reset (for new game)
func reset() -> void:
	_hub_unlocked = false
	_unlocked_stations.clear()
