extends Node
## DataRegistry - Central repository for game data resources.
##
## Loads and provides access to all layer and ore definitions at startup.
## Use DataRegistry.get_layer(), get_ore(), get_ores_at_depth() to access.

const LayerData = preload("res://resources/layers/layer_data.gd")
const OreData = preload("res://resources/ores/ore_data.gd")
const ItemData = preload("res://resources/items/item_data.gd")
const ToolData = preload("res://resources/tools/tool_data.gd")

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


func _ready() -> void:
	_load_all_layers()
	_load_all_ores()
	_load_all_items()
	_load_all_tools()
	print("[DataRegistry] Loaded %d layers, %d ores, %d items, %d tools" % [layers.size(), ores.size(), items.size(), tools.size()])


func _load_all_layers() -> void:
	## Load all .tres files from the layers directory
	var layers_path := "res://resources/layers/"
	var dir := DirAccess.open(layers_path)

	if dir == null:
		push_error("[DataRegistry] Cannot open layers directory: %s" % layers_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var resource_path := layers_path + file_name
			var resource = load(resource_path)
			if resource is LayerData:
				layers.append(resource)
				_layers_by_id[resource.id] = resource
		file_name = dir.get_next()

	dir.list_dir_end()

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
func get_block_color(grid_pos: Vector2i) -> Color:
	var depth := grid_pos.y - GameManager.SURFACE_ROW
	if depth < 0:
		depth = 0

	var layer := get_layer_at_depth(depth)
	if layer == null:
		return Color.BROWN

	# In transition zones, potentially blend or show accent color
	if layer.is_transition_zone(depth):
		# Use position for deterministic variation
		var seed_value := grid_pos.x * 1000 + grid_pos.y
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		if rng.randf() < 0.3:  # 30% chance for accent color in transition
			return layer.color_accent

	return layer.color_primary


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
	## Load all .tres files from ores and gems directories
	_load_ores_from_directory("res://resources/ores/")
	_load_ores_from_directory("res://resources/gems/")

	# Sort by min_depth for efficient depth queries
	_ores_by_depth = ores.values()
	_ores_by_depth.sort_custom(func(a, b): return a.min_depth < b.min_depth)


func _load_ores_from_directory(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("[DataRegistry] Cannot open directory: %s" % path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var resource_path := path + file_name
			var resource = load(resource_path)
			if resource is OreData:
				ores[resource.id] = resource
		file_name = dir.get_next()

	dir.list_dir_end()


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


## Get all loaded ore IDs
func get_all_ore_ids() -> Array:
	return ores.keys()


# ============================================
# ITEM DATA LOADING AND ACCESS
# ============================================

func _load_all_items() -> void:
	## Load all .tres files from items directory
	var items_path := "res://resources/items/"
	var dir := DirAccess.open(items_path)

	if dir == null:
		push_warning("[DataRegistry] Cannot open items directory: %s" % items_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var resource_path := items_path + file_name
			var resource = load(resource_path)
			if resource is ItemData:
				items[resource.id] = resource
		file_name = dir.get_next()

	dir.list_dir_end()


## Get an item by its ID
func get_item(item_id: String) -> ItemData:
	if items.has(item_id):
		return items[item_id]
	return null


## Get all loaded item IDs
func get_all_item_ids() -> Array:
	return items.keys()


# ============================================
# TOOL DATA LOADING AND ACCESS
# ============================================

func _load_all_tools() -> void:
	## Load all .tres files from tools directory
	var tools_path := "res://resources/tools/"
	var dir := DirAccess.open(tools_path)

	if dir == null:
		push_warning("[DataRegistry] Cannot open tools directory: %s" % tools_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var resource_path := tools_path + file_name
			var resource = load(resource_path)
			if resource is ToolData:
				tools[resource.id] = resource
		file_name = dir.get_next()

	dir.list_dir_end()

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
