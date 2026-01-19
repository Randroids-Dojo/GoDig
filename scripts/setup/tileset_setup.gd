class_name TileSetSetup
## Helper class to programmatically configure the terrain TileSet.
## Run this in the editor or during game initialization.

## Static dictionary for atlas coords - initialized lazily to avoid class load order issues
static var _atlas_coords: Dictionary = {}
static var _coords_to_type: Dictionary = {}


## Get the atlas coords dictionary (initializes on first access)
static func get_atlas_coords_map() -> Dictionary:
	if _atlas_coords.is_empty():
		_init_atlas_coords()
	return _atlas_coords


## Initialize atlas coordinates mapping
static func _init_atlas_coords() -> void:
	_atlas_coords = {
		# Base terrain (Row 0)
		TileTypes.Type.DIRT: Vector2i(0, 0),
		TileTypes.Type.CLAY: Vector2i(1, 0),
		TileTypes.Type.STONE: Vector2i(2, 0),
		TileTypes.Type.GRANITE: Vector2i(3, 0),
		TileTypes.Type.BASALT: Vector2i(4, 0),
		TileTypes.Type.OBSIDIAN: Vector2i(5, 0),

		# Ores (Row 1)
		TileTypes.Type.COAL: Vector2i(0, 1),
		TileTypes.Type.COPPER: Vector2i(1, 1),
		TileTypes.Type.IRON: Vector2i(2, 1),
		TileTypes.Type.SILVER: Vector2i(3, 1),
		TileTypes.Type.GOLD: Vector2i(4, 1),
		TileTypes.Type.DIAMOND: Vector2i(5, 1),

		# Special (Row 2)
		TileTypes.Type.LADDER: Vector2i(0, 2),
		# AIR has no tile (1, 2 is left empty)
		TileTypes.Type.RUBY: Vector2i(2, 2),
		TileTypes.Type.EMERALD: Vector2i(3, 2),
		TileTypes.Type.SAPPHIRE: Vector2i(4, 2),
		TileTypes.Type.AMETHYST: Vector2i(5, 2),
	}


## Initialize the reverse lookup table
static func _init_coords_lookup() -> void:
	if _coords_to_type.is_empty():
		var atlas_coords := get_atlas_coords_map()
		for tile_type in atlas_coords:
			_coords_to_type[atlas_coords[tile_type]] = tile_type


## Get atlas coordinates for a tile type
static func get_atlas_coords(tile_type: int) -> Vector2i:
	return get_atlas_coords_map().get(tile_type, Vector2i(0, 0))


## Get tile type from atlas coordinates
static func get_tile_type(coords: Vector2i) -> int:
	_init_coords_lookup()
	return _coords_to_type.get(coords, TileTypes.Type.DIRT)


## Create and configure a new TileSet resource
static func create_tileset() -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(128, 128)

	# Add physics layer for collision
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)  # Layer 1 for ground
	tileset.set_physics_layer_collision_mask(0, 0)   # No mask needed

	# Add custom data layers
	tileset.add_custom_data_layer()
	tileset.set_custom_data_layer_name(0, "tile_type")
	tileset.set_custom_data_layer_type(0, TYPE_INT)

	tileset.add_custom_data_layer()
	tileset.set_custom_data_layer_name(1, "hardness")
	tileset.set_custom_data_layer_type(1, TYPE_FLOAT)

	# Load the atlas texture
	var atlas_texture := load("res://resources/tileset/terrain_atlas.png") as Texture2D
	if not atlas_texture:
		push_error("Failed to load terrain atlas texture!")
		return tileset

	# Add atlas source
	var atlas := TileSetAtlasSource.new()
	atlas.texture = atlas_texture
	atlas.texture_region_size = Vector2i(128, 128)
	var source_id := tileset.add_source(atlas)

	# Configure each tile
	var atlas_coords := get_atlas_coords_map()
	for tile_type in atlas_coords:
		var coords: Vector2i = atlas_coords[tile_type]
		_setup_tile(atlas, coords, tile_type)

	print("TileSet created with ", atlas_coords.size(), " tiles")
	return tileset


## Configure a single tile in the atlas
static func _setup_tile(atlas: TileSetAtlasSource, coords: Vector2i, tile_type: int) -> void:
	# Create the tile at these coordinates
	atlas.create_tile(coords)
	var tile_data := atlas.get_tile_data(coords, 0)

	if tile_data == null:
		push_error("Failed to get tile data for ", coords)
		return

	# Set custom data
	tile_data.set_custom_data("tile_type", tile_type)
	tile_data.set_custom_data("hardness", TileTypes.get_hardness(tile_type))

	# Set up physics collision for solid tiles
	if TileTypes.is_solid(tile_type):
		# Create a rectangular collision polygon
		var collision_points := PackedVector2Array([
			Vector2(0, 0),
			Vector2(128, 0),
			Vector2(128, 128),
			Vector2(0, 128)
		])
		tile_data.add_collision_polygon(0)
		tile_data.set_collision_polygon_points(0, 0, collision_points)

	# Ladder tiles need special collision (climbable, not solid wall)
	if tile_type == TileTypes.Type.LADDER:
		# Remove any existing collision and set up ladder-specific
		tile_data.set_collision_polygons_count(0, 0)
		# Ladders have no collision - player can pass through but climb


## Save the TileSet to a resource file
static func save_tileset(tileset: TileSet, path: String = "res://resources/tileset/terrain.tres") -> Error:
	var error := ResourceSaver.save(tileset, path)
	if error != OK:
		push_error("Failed to save TileSet to ", path, " - error: ", error)
	else:
		print("TileSet saved to ", path)
	return error


## Load or create the terrain TileSet
static func get_or_create_tileset() -> TileSet:
	var path := "res://resources/tileset/terrain.tres"

	# Try to load existing
	if ResourceLoader.exists(path):
		var tileset := load(path) as TileSet
		if tileset:
			return tileset

	# Create new and save
	var tileset := create_tileset()
	save_tileset(tileset, path)
	return tileset
