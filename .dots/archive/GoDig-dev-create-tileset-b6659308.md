---
title: "implement: Create TileSet with block types"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-16T00:37:43.113016-06:00\""
closed-at: "2026-01-19T12:07:34.818790-06:00"
close-reason: "TileSet implemented: terrain.tres, terrain_atlas.png, and tileset_setup.gd (162 lines) for programmatic setup. Used by GameManager."
---

## Description

Create a TileSet resource containing all terrain block types (dirt, stone, ores) with proper physics and visual properties. This is the visual foundation for the entire mining world.

## Context

All terrain in GoDig is tile-based. The TileSet defines the visual appearance and physics (collision) for each block type. ChunkManager uses this TileSet to render the world. Block size is 128x128 pixels (same as player).

## Affected Files

- `resources/tileset/terrain.tres` - NEW: Main TileSet resource
- `resources/tileset/terrain_atlas.png` - NEW: Sprite atlas for all tiles
- Temporary placeholder art acceptable for MVP

## Implementation Notes

### Tile Atlas Layout

Create a sprite atlas (PNG) with 128x128 tiles arranged in a grid:

```
Row 0: Base terrain
  [0,0] Dirt      [1,0] Clay       [2,0] Stone
  [3,0] Granite   [4,0] Basalt     [5,0] Obsidian

Row 1: Ores
  [0,1] Coal      [1,1] Copper     [2,1] Iron
  [3,1] Silver    [4,1] Gold       [5,1] Diamond

Row 2: Special
  [0,2] Ladder    [1,2] Air/Empty  [2,2] (reserved)
```

### Godot 4 TileSet Setup

1. Create new TileSet resource
2. Add TileSetAtlasSource pointing to terrain_atlas.png
3. Configure tile size: 128x128
4. For each tile:
   - Set up physics layer (collision for solid blocks)
   - Set up custom data layer for tile type metadata

### TileSet Configuration

```
Physics Layer 0: "Ground"
- Used for collision detection
- All solid tiles have this

Custom Data Layer 0: "tile_type"
- Type: int
- Maps to TileTypes.Type enum values

Custom Data Layer 1: "hardness"
- Type: int
- Mining time multiplier
```

### Programmatic Setup (Alternative)

If setting up manually in editor is complex, use code:

```gdscript
# scripts/setup/tileset_setup.gd
extends Node

func setup_tileset() -> TileSet:
    var tileset := TileSet.new()
    tileset.tile_size = Vector2i(128, 128)

    # Add physics layer
    tileset.add_physics_layer()

    # Add custom data layers
    tileset.add_custom_data_layer()
    tileset.set_custom_data_layer_name(0, "tile_type")
    tileset.set_custom_data_layer_type(0, TYPE_INT)

    tileset.add_custom_data_layer()
    tileset.set_custom_data_layer_name(1, "hardness")
    tileset.set_custom_data_layer_type(1, TYPE_INT)

    # Add atlas source
    var atlas := TileSetAtlasSource.new()
    atlas.texture = preload("res://resources/tileset/terrain_atlas.png")
    atlas.texture_region_size = Vector2i(128, 128)
    tileset.add_source(atlas)

    # Configure each tile
    _setup_tile(atlas, Vector2i(0, 0), TileTypes.Type.DIRT, 1)
    _setup_tile(atlas, Vector2i(1, 0), TileTypes.Type.CLAY, 2)
    _setup_tile(atlas, Vector2i(2, 0), TileTypes.Type.STONE, 3)
    # ... etc

    return tileset

func _setup_tile(atlas: TileSetAtlasSource, coords: Vector2i,
                 tile_type: int, hardness: int) -> void:
    atlas.create_tile(coords)
    var tile_data := atlas.get_tile_data(coords, 0)

    # Physics (collision)
    var collision := tile_data.get_collision_polygon_points(0, 0)
    tile_data.add_collision_polygon(0)
    tile_data.set_collision_polygon_points(0, 0, [
        Vector2(0, 0), Vector2(128, 0),
        Vector2(128, 128), Vector2(0, 128)
    ])

    # Custom data
    tile_data.set_custom_data("tile_type", tile_type)
    tile_data.set_custom_data("hardness", hardness)
```

### Placeholder Art Guidelines

For MVP, simple colored squares work:
- Dirt: Brown (#8B4513)
- Clay: Orange-brown (#CD853F)
- Stone: Gray (#808080)
- Granite: Dark gray (#404040)
- Basalt: Very dark (#202020)
- Obsidian: Black with purple tint (#1A0A2E)
- Coal: Black speckled (#1A1A1A)
- Copper: Orange (#B87333)
- Iron: Silver (#A0A0A0)
- Gold: Yellow (#FFD700)
- Diamond: Light blue (#ADD8E6)

### TileMap Layer Usage

Single TileMap layer for terrain:
- Layer 0: Ground (all solid blocks)
- Air/empty = no tile (erased cell)

## Edge Cases

- Empty cells: No tile set, represents air/dug space
- Ladder tiles: Need different collision (no full block, climbable)
- Out-of-atlas coords: Handle gracefully, return dirt

## Verify

- [ ] Build succeeds with no errors
- [ ] terrain.tres loads without errors
- [ ] All tile types have corresponding atlas positions
- [ ] Physics collision works for solid tiles
- [ ] Custom data (tile_type, hardness) retrieves correctly
- [ ] TileMap renders tiles at correct positions
- [ ] 128x128 tile size matches player and grid system
