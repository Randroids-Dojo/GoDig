extends Node
## DataRegistry - Central repository for game data resources.
##
## Loads and provides access to all layer definitions at startup.
## Use DataRegistry.get_layer() and DataRegistry.get_layer_at_depth() to access.

const LayerData = preload("res://resources/layers/layer_data.gd")

## All loaded layer definitions, sorted by min_depth
var layers: Array[LayerData] = []

## Dictionary for quick ID-based lookup
var _layers_by_id: Dictionary = {}


func _ready() -> void:
	_load_all_layers()
	print("[DataRegistry] Loaded %d layer types" % layers.size())


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
