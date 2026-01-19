---
title: "implement: Terrain tileset sprites"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:39:51.705359-06:00"
after:
  - GoDig-decision-fantasy-vs-cfeb07a3
---

## Description

Create terrain tileset sprites for dirt, stone, ore tiles with visual variants for each underground layer.

## Context

The world is built of 128x128 pixel blocks. Each layer type (topsoil, subsoil, stone, deep_stone) has different visual appearance. Ores need distinct colors/textures to be recognizable at a glance. Currently using solid color rectangles from TileSetSetup.

## Affected Files

- `assets/tilesets/terrain_atlas.png` - NEW: Combined tileset image
- `resources/tilesets/terrain.tres` - Update existing or new TileSet resource
- `scripts/setup/tileset_setup.gd` - Update to use texture instead of solid colors

## Implementation Notes

### Tile Specifications

- Size: 128x128 pixels per tile (matches BLOCK_SIZE)
- Atlas layout organized by tile type

### Tile Types Needed

From TileTypes enum:
1. AIR (no sprite - transparent)
2. DIRT (brown, earthy texture)
3. STONE (gray, rocky texture)
4. GRANITE (darker gray, speckled)
5. CLAY (orange-brown)
6. COAL (black with shiny bits)
7. COPPER (copper/orange veins in stone)
8. IRON (gray-blue metallic)
9. SILVER (bright silver veins)
10. GOLD (gold veins, sparkly)
11. DIAMOND (blue crystals in stone)

### Layer Color Palettes

Reference from research:
- Topsoil: Browns (#8B7355, #A0522D)
- Subsoil: Orange-browns (#CD853F, #D2691E)
- Stone: Grays (#808080, #696969)
- Deep Stone: Dark grays (#4A4A4A, #363636)

### Placeholder Approach (MVP)

Current solid colors work for MVP. This task is for visual polish. Can create simple textured versions using:
- Noise patterns
- Simple pixel art borders
- Color variations within tiles

## Verify

- [ ] Tileset loads without errors
- [ ] Each tile type has distinct visual appearance
- [ ] Ores are clearly distinguishable from base rock
- [ ] Layer colors match expected palette
- [ ] No visible seams when tiles are placed adjacently
- [ ] TileMap renders correctly with new sprites
