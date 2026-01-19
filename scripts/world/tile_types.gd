class_name TileTypes
## Constants and enums for tile types used in the chunk-based world system.
## Defines all block types, ores, placed objects, and their hardness values.

## Tile type enumeration for chunk storage
enum Type {
	# Empty / dug out
	AIR = -1,

	# Base terrain types (0-9)
	DIRT = 0,
	CLAY = 1,
	STONE = 2,
	GRANITE = 3,
	BASALT = 4,
	OBSIDIAN = 5,

	# Ore types (10-29)
	COAL = 10,
	COPPER = 11,
	IRON = 12,
	SILVER = 13,
	GOLD = 14,
	DIAMOND = 15,
	RUBY = 16,
	EMERALD = 17,
	SAPPHIRE = 18,
	AMETHYST = 19,

	# Placed objects (100+)
	LADDER = 100,
	SUPPORT_BEAM = 101,
	TORCH = 102,
}

## Hardness values - hits to break with base tool
const HARDNESS := {
	# Terrain - scales with depth
	Type.DIRT: 1.0,
	Type.CLAY: 2.0,
	Type.STONE: 3.0,
	Type.GRANITE: 5.0,
	Type.BASALT: 8.0,
	Type.OBSIDIAN: 12.0,

	# Ores - slightly harder than surrounding terrain
	Type.COAL: 2.0,
	Type.COPPER: 3.0,
	Type.IRON: 4.0,
	Type.SILVER: 5.0,
	Type.GOLD: 6.0,
	Type.DIAMOND: 10.0,
	Type.RUBY: 8.0,
	Type.EMERALD: 8.0,
	Type.SAPPHIRE: 8.0,
	Type.AMETHYST: 6.0,

	# Placed objects - easier to remove
	Type.LADDER: 1.0,
	Type.SUPPORT_BEAM: 2.0,
	Type.TORCH: 1.0,
}

## Colors for each tile type (used when no tileset)
const COLORS := {
	Type.AIR: Color.TRANSPARENT,

	Type.DIRT: Color(0.545, 0.353, 0.169),  # Brown
	Type.CLAY: Color(0.698, 0.467, 0.329),  # Light brown
	Type.STONE: Color(0.502, 0.502, 0.502),  # Gray
	Type.GRANITE: Color(0.376, 0.376, 0.376),  # Dark gray
	Type.BASALT: Color(0.251, 0.251, 0.251),  # Very dark gray
	Type.OBSIDIAN: Color(0.098, 0.078, 0.118),  # Near black with purple tint

	Type.COAL: Color(0.129, 0.129, 0.129),  # Black
	Type.COPPER: Color(0.722, 0.451, 0.2),  # Copper orange
	Type.IRON: Color(0.596, 0.588, 0.576),  # Iron gray
	Type.SILVER: Color(0.753, 0.753, 0.753),  # Silver
	Type.GOLD: Color(1.0, 0.843, 0.0),  # Gold yellow
	Type.DIAMOND: Color(0.529, 0.808, 0.922),  # Diamond blue
	Type.RUBY: Color(0.878, 0.067, 0.373),  # Ruby red
	Type.EMERALD: Color(0.314, 0.784, 0.471),  # Emerald green
	Type.SAPPHIRE: Color(0.059, 0.322, 0.729),  # Sapphire blue
	Type.AMETHYST: Color(0.6, 0.4, 0.8),  # Purple

	Type.LADDER: Color(0.545, 0.271, 0.075),  # Wood brown
	Type.SUPPORT_BEAM: Color(0.4, 0.263, 0.129),  # Dark wood
	Type.TORCH: Color(1.0, 0.647, 0.0),  # Orange glow
}

## Static helper to check if a type is solid (blocks movement)
static func is_solid(tile_type: int) -> bool:
	return tile_type != Type.AIR and tile_type < Type.LADDER


## Static helper to check if a type is an ore
static func is_ore(tile_type: int) -> bool:
	return tile_type >= Type.COAL and tile_type < Type.LADDER


## Static helper to check if a type is a placed object
static func is_placed_object(tile_type: int) -> bool:
	return tile_type >= Type.LADDER


## Static helper to check if a type is terrain
static func is_terrain(tile_type: int) -> bool:
	return tile_type >= Type.DIRT and tile_type < Type.COAL


## Get hardness for a tile type, returns 0 for air/unknown
static func get_hardness(tile_type: int) -> float:
	return HARDNESS.get(tile_type, 0.0)


## Get color for a tile type
static func get_color(tile_type: int) -> Color:
	return COLORS.get(tile_type, Color.MAGENTA)
