extends Node
## DataRegistry - Central repository for game data resources.
##
## Loads and provides access to all layer and ore definitions at startup.
## Use DataRegistry.get_layer(), get_ore(), get_ores_at_depth() to access.
##
## NOTE: Resources are explicitly preloaded for web export compatibility.
## DirAccess doesn't work in web builds (files are packed into .pck).

const LayerData = preload("res://resources/layers/layer_data.gd")
const OreData = preload("res://resources/ores/ore_data.gd")
const ItemData = preload("res://resources/items/item_data.gd")
const ToolData = preload("res://resources/tools/tool_data.gd")
const EquipmentData = preload("res://resources/equipment/equipment_data.gd")

# Explicit resource preloads for web export compatibility
const LAYER_RESOURCES := [
	preload("res://resources/layers/topsoil.tres"),
	preload("res://resources/layers/subsoil.tres"),
	preload("res://resources/layers/clay.tres"),
	preload("res://resources/layers/stone.tres"),
	preload("res://resources/layers/granite.tres"),
	preload("res://resources/layers/deep_stone.tres"),
	preload("res://resources/layers/crystal_caves.tres"),
	preload("res://resources/layers/obsidian_core.tres"),
	preload("res://resources/layers/magma_zone.tres"),
	preload("res://resources/layers/void_depths.tres"),
]

const ORE_RESOURCES := [
	preload("res://resources/ores/coal.tres"),
	preload("res://resources/ores/copper.tres"),
	preload("res://resources/ores/iron.tres"),
	preload("res://resources/ores/silver.tres"),
	preload("res://resources/ores/gold.tres"),
	preload("res://resources/ores/platinum.tres"),
	preload("res://resources/ores/titanium.tres"),
	preload("res://resources/ores/obsidian.tres"),
	preload("res://resources/ores/void_crystal.tres"),
]

const GEM_RESOURCES := [
	preload("res://resources/gems/ruby.tres"),
	preload("res://resources/gems/sapphire.tres"),
	preload("res://resources/gems/emerald.tres"),
	preload("res://resources/gems/diamond.tres"),
]

const ITEM_RESOURCES := [
	preload("res://resources/items/rope.tres"),
	preload("res://resources/items/ladder.tres"),
	preload("res://resources/items/teleport_scroll.tres"),
	preload("res://resources/items/fossil_common.tres"),
	preload("res://resources/items/fossil_rare.tres"),
	preload("res://resources/items/fossil_legendary.tres"),
	preload("res://resources/items/fossil_amber.tres"),
	preload("res://resources/items/artifact_ancient_coin.tres"),
	preload("res://resources/items/artifact_crystal_skull.tres"),
	preload("res://resources/items/artifact_fossilized_crown.tres"),
	preload("res://resources/items/artifact_obsidian_tablet.tres"),
]

const TOOL_RESOURCES := [
	preload("res://resources/tools/rusty_pickaxe.tres"),
	preload("res://resources/tools/copper_pickaxe.tres"),
	preload("res://resources/tools/iron_pickaxe.tres"),
	preload("res://resources/tools/steel_pickaxe.tres"),
	preload("res://resources/tools/silver_pickaxe.tres"),
	preload("res://resources/tools/gold_pickaxe.tres"),
	preload("res://resources/tools/diamond_pickaxe.tres"),
	preload("res://resources/tools/mythril_pickaxe.tres"),
	preload("res://resources/tools/void_pickaxe.tres"),
]

const EQUIPMENT_RESOURCES := [
	preload("res://resources/equipment/leather_boots.tres"),
	preload("res://resources/equipment/iron_boots.tres"),
	preload("res://resources/equipment/steel_boots.tres"),
	preload("res://resources/equipment/obsidian_boots.tres"),
	preload("res://resources/equipment/basic_headlamp.tres"),
	preload("res://resources/equipment/miners_helmet.tres"),
	preload("res://resources/equipment/engineers_helmet.tres"),
	preload("res://resources/equipment/crystal_helm.tres"),
	preload("res://resources/equipment/mining_drill.tres"),
]

## All loaded layer definitions, sorted by min_depth
var layers: Array[LayerData] = []

## Dictionary for quick ID-based lookup
var _layers_by_id: Dictionary = {}

## All loaded ore definitions
var ores: Dictionary = {}

## Ores sorted by min_depth for efficient depth queries
var _ores_by_depth: Array = []

## All loaded item definitions
var items: Dictionary = {}

## All loaded tool definitions
var tools: Dictionary = {}

## Tools sorted by tier for ordered display
var _tools_by_tier: Array = []

## All loaded equipment definitions
var equipment: Dictionary = {}

## Equipment sorted by tier for ordered display
var _equipment_by_tier: Array = []

## Equipment grouped by slot type
var _equipment_by_slot: Dictionary = {}  # EquipmentSlot -> Array[EquipmentData]


func _ready() -> void:
	_load_all_layers()
	_load_all_ores()
	_load_all_items()
	_load_all_tools()
	_load_all_equipment()
	print("[DataRegistry] Loaded %d layers, %d ores, %d items, %d tools, %d equipment" % [layers.size(), ores.size(), items.size(), tools.size(), equipment.size()])


func _load_all_layers() -> void:
	## Load all layer resources from preloaded array
	## NOTE: We don't use "is LayerData" check because it fails in web exports
	for resource in LAYER_RESOURCES:
		if resource == null:
			push_error("[DataRegistry] Layer resource is null!")
			continue
		if not resource.has_method("get_hardness_at"):
			push_error("[DataRegistry] Layer resource missing get_hardness_at method")
			continue
		layers.append(resource)
		_layers_by_id[resource.id] = resource

	# Sort by min_depth for proper depth lookup
	layers.sort_custom(func(a, b): return a.min_depth < b.min_depth)


## Get a layer by its ID
func get_layer(layer_id: String) -> LayerData:
	if _layers_by_id.has(layer_id):
		return _layers_by_id[layer_id]
	push_warning("[DataRegistry] Layer not found: %s" % layer_id)
	return null


## Get the layer at a specific depth (in grid rows from surface)
func get_layer_at_depth(depth: int) -> LayerData:
	for layer in layers:
		if depth >= layer.min_depth and depth < layer.max_depth:
			return layer

	# Return deepest layer for anything beyond max defined depth
	if layers.size() > 0:
		return layers[layers.size() - 1]

	return null


## Get block hardness at a grid position, accounting for depth-based layer
func get_block_hardness(grid_pos: Vector2i) -> float:
	var depth := grid_pos.y - GameManager.SURFACE_ROW
	if depth < 0:
		depth = 0

	var layer := get_layer_at_depth(depth)
	if layer == null:
		return 10.0  # Default hardness

	return layer.get_hardness_at(grid_pos)


## Get the color for a block at a grid position
## Uses the layer's full palette for natural variation
func get_block_color(grid_pos: Vector2i) -> Color:
	var depth := grid_pos.y - GameManager.SURFACE_ROW
	if depth < 0:
		depth = 0

	var layer := get_layer_at_depth(depth)
	if layer == null:
		return Color.BROWN

	# In transition zones, blend with next layer's colors
	if layer.is_transition_zone(depth):
		var next_layer := get_layer_at_depth(depth + 15)  # Look ahead
		if next_layer != null and next_layer != layer:
			# Blend colors in transition zone
			var seed_value := grid_pos.x * 1000 + grid_pos.y
			var rng := RandomNumberGenerator.new()
			rng.seed = seed_value
			if rng.randf() < 0.4:  # 40% chance for next layer's colors
				return next_layer.get_color_at(grid_pos)

	# Use layer's palette-based color selection
	return layer.get_color_at(grid_pos)


## Check if a position is in a transition zone between layers
func is_transition_zone(grid_pos: Vector2i) -> bool:
	var depth := grid_pos.y - GameManager.SURFACE_ROW
	if depth < 0:
		return false

	var layer := get_layer_at_depth(depth)
	if layer == null:
		return false

	return layer.is_transition_zone(depth)


# ============================================
# ORE DATA LOADING AND ACCESS
# ============================================

func _load_all_ores() -> void:
	## Load all ore and gem resources from preloaded arrays
	## NOTE: We don't use "is OreData" check because it fails in web exports
	for resource in ORE_RESOURCES:
		if resource != null and resource.has_method("can_spawn_at_depth"):
			ores[resource.id] = resource

	for resource in GEM_RESOURCES:
		if resource != null and resource.has_method("can_spawn_at_depth"):
			ores[resource.id] = resource

	# Also register ores as items for inventory/shop compatibility
	# OreData extends ItemData, so ores can be used directly as items
	for ore_id in ores:
		items[ore_id] = ores[ore_id]

	# Sort by min_depth for efficient depth queries
	_ores_by_depth = ores.values()
	_ores_by_depth.sort_custom(func(a, b): return a.min_depth < b.min_depth)


## Get an ore by its ID
func get_ore(ore_id: String) -> OreData:
	if ores.has(ore_id):
		return ores[ore_id]
	return null


## Get all ores that can spawn at a given depth
func get_ores_at_depth(depth: int) -> Array:
	var result := []
	for ore in _ores_by_depth:
		if ore.can_spawn_at_depth(depth):
			result.append(ore)
	return result


## Get all ores sorted by min_depth
func get_all_ores() -> Array:
	return _ores_by_depth.duplicate()


## Get all loaded ore IDs
func get_all_ore_ids() -> Array:
	return ores.keys()


# ============================================
# ITEM DATA LOADING AND ACCESS
# ============================================

func _load_all_items() -> void:
	## Load all item resources from preloaded array
	## NOTE: We don't use "is ItemData" check because it fails in web exports
	for resource in ITEM_RESOURCES:
		if resource != null and "id" in resource and "display_name" in resource:
			items[resource.id] = resource


## Get an item by its ID
func get_item(item_id: String) -> ItemData:
	if items.has(item_id):
		return items[item_id]
	return null


## Get all loaded item IDs
func get_all_item_ids() -> Array:
	return items.keys()


## Get all loaded items as an array
func get_all_items() -> Array:
	return items.values()


## Get all artifacts (items with category "artifact")
func get_all_artifacts() -> Array:
	var result: Array = []
	for item in items.values():
		if item.category == "artifact":
			result.append(item)
	return result


# ============================================
# TOOL DATA LOADING AND ACCESS
# ============================================

func _load_all_tools() -> void:
	## Load all tool resources from preloaded array
	## NOTE: We don't use "is ToolData" check because it fails in web exports
	for resource in TOOL_RESOURCES:
		if resource != null and "tier" in resource and "damage" in resource:
			tools[resource.id] = resource

	# Sort tools by tier for ordered display
	_tools_by_tier = tools.values()
	_tools_by_tier.sort_custom(func(a, b): return a.tier < b.tier)


## Get a tool by its ID
func get_tool(tool_id: String) -> ToolData:
	if tools.has(tool_id):
		return tools[tool_id]
	return null


## Get all tools sorted by tier
func get_all_tools() -> Array:
	return _tools_by_tier.duplicate()


## Get all tool IDs
func get_all_tool_ids() -> Array:
	return tools.keys()


## Get tools available at a given depth (unlocked but not necessarily owned)
func get_tools_at_depth(depth: int) -> Array:
	var result := []
	for tool in _tools_by_tier:
		if tool.unlock_depth <= depth:
			result.append(tool)
	return result


# ============================================
# TEST HELPER METHODS (for PlayGodot tests)
# ============================================
# These methods return primitive types (strings, ints, floats)
# since Resource objects can't be serialized over RPC.

## Check if a layer ID exists
func has_layer(layer_id: String) -> bool:
	return _layers_by_id.has(layer_id)


## Get layer ID at a specific depth
func get_layer_id_at_depth(depth: int) -> String:
	var layer := get_layer_at_depth(depth)
	if layer == null:
		return ""
	return layer.id


## Get layer display name by ID
func get_layer_display_name(layer_id: String) -> String:
	var layer := get_layer(layer_id)
	if layer == null:
		return ""
	return layer.display_name


## Get layer min_depth by ID
func get_layer_min_depth(layer_id: String) -> int:
	var layer := get_layer(layer_id)
	if layer == null:
		return -1
	return layer.min_depth


## Get layer max_depth by ID
func get_layer_max_depth(layer_id: String) -> int:
	var layer := get_layer(layer_id)
	if layer == null:
		return -1
	return layer.max_depth


## Get layer base_hardness by ID
func get_layer_base_hardness(layer_id: String) -> float:
	var layer := get_layer(layer_id)
	if layer == null:
		return -1.0
	return layer.base_hardness


## Get the number of loaded layers
func get_layer_count() -> int:
	return layers.size()


## Get all layer IDs
func get_all_layer_ids() -> Array:
	return _layers_by_id.keys()


# ============================================
# EQUIPMENT DATA LOADING AND ACCESS
# ============================================

func _load_all_equipment() -> void:
	## Load all equipment resources from preloaded array
	## NOTE: We don't use "is EquipmentData" check because it fails in web exports
	for resource in EQUIPMENT_RESOURCES:
		if resource != null and "slot" in resource and "tier" in resource:
			equipment[resource.id] = resource

	# Sort equipment by tier for ordered display
	_equipment_by_tier = equipment.values()
	_equipment_by_tier.sort_custom(func(a, b): return a.tier < b.tier)

	# Group by slot type
	_equipment_by_slot.clear()
	for eq in _equipment_by_tier:
		var slot: int = eq.slot
		if not _equipment_by_slot.has(slot):
			_equipment_by_slot[slot] = []
		_equipment_by_slot[slot].append(eq)


## Get an equipment by its ID
func get_equipment(equipment_id: String) -> EquipmentData:
	if equipment.has(equipment_id):
		return equipment[equipment_id]
	return null


## Get all equipment sorted by tier
func get_all_equipment() -> Array:
	return _equipment_by_tier.duplicate()


## Get all equipment IDs
func get_all_equipment_ids() -> Array:
	return equipment.keys()


## Get equipment by slot type
func get_equipment_by_slot(slot: int) -> Array:
	if _equipment_by_slot.has(slot):
		return _equipment_by_slot[slot].duplicate()
	return []


## Get boots (slot 0) sorted by tier
func get_all_boots() -> Array:
	return get_equipment_by_slot(EquipmentData.EquipmentSlot.BOOTS)


## Get helmets (slot 1) sorted by tier
func get_all_helmets() -> Array:
	return get_equipment_by_slot(EquipmentData.EquipmentSlot.HELMET)


## Get equipment available at a given depth
func get_equipment_at_depth(depth: int) -> Array:
	var result := []
	for eq in _equipment_by_tier:
		if eq.unlock_depth <= depth:
			result.append(eq)
	return result
