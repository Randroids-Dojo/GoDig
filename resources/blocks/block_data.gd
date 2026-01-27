class_name BlockData extends Resource
## Resource class for special block definitions.
## Defines placeable blocks like ladders, torches, and future machines.
##
## Note: Regular terrain blocks (dirt, stone) use LayerData.
## This class is for player-placed and special blocks.

enum BlockType { TERRAIN, LADDER, TORCH, MACHINE, DECORATIVE }
enum BlockPlacement { GROUND, WALL, CEILING, ANY }

## Unique identifier for this block type
@export var id: String = ""

## Display name shown to the player
@export var display_name: String = ""

## Block category for grouping/filtering
@export var block_type: BlockType = BlockType.TERRAIN

## Where this block can be placed
@export var placement: BlockPlacement = BlockPlacement.GROUND

## Icon texture for UI/inventory display
@export var icon: Texture2D

## Texture/sprite for world display (if not using atlas)
@export var world_texture: Texture2D

## TileSet atlas coordinates (if using TileMap)
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO

## Block hardness (0 = instant break, higher = harder)
@export var hardness: float = 5.0

## Is this block solid (blocks movement)?
@export var is_solid: bool = true

## Is this block climbable (like ladders)?
@export var is_climbable: bool = false

## Is this block a light source?
@export var is_light_source: bool = false

## Light radius if light source (0 = no light)
@export var light_radius: float = 0.0

## Light color if light source
@export var light_color: Color = Color.WHITE

## Can player walk through this block?
@export var is_walkable: bool = false

## Does this block support other blocks above it?
@export var supports_blocks: bool = true

## Minimum tool tier required to break (0 = any)
@export var required_tool_tier: int = 0

## Item dropped when broken (empty string = nothing)
@export var drop_item_id: String = ""

## Chance to drop item (0.0-1.0)
@export var drop_chance: float = 1.0

## Description text for tooltips
@export var description: String = ""


## Check if this block can be placed at the given position context
func can_place_at(context: Dictionary) -> bool:
	## context expected keys: has_ground_below, has_wall_adjacent, has_ceiling_above
	match placement:
		BlockPlacement.GROUND:
			return context.get("has_ground_below", false)
		BlockPlacement.WALL:
			return context.get("has_wall_adjacent", false)
		BlockPlacement.CEILING:
			return context.get("has_ceiling_above", false)
		BlockPlacement.ANY:
			return true
	return true


## Check if player can break this block with given tool tier
func can_break_with_tool(tool_tier: int) -> bool:
	return tool_tier >= required_tool_tier


## Get the effective light intensity
func get_light_intensity() -> float:
	if not is_light_source:
		return 0.0
	return light_radius
