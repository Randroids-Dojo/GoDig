---
title: "implement: OreData resource class"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:42:53.968501-06:00"
---

## Description

Create the OreData resource class that defines ore type properties. Each ore type (coal, copper, iron, etc.) will be a .tres file using this class. Used by OreGenerator for placement logic and by inventory/shop for values.

## Context

Ores are the core collectible. The OreData class must contain all properties needed for:
- Generation (depth range, spawn threshold, vein size, noise frequency)
- Display (name, icon, color, tile coordinates)
- Economy (sell value, rarity tier)

## Affected Files

- `resources/ores/ore_data.gd` - NEW: OreData resource class

## Implementation Notes

```gdscript
class_name OreData extends Resource

## Unique identifier (coal, copper, iron, etc.)
@export var id: String = ""

## Display name shown to player
@export var display_name: String = ""

## Icon texture for inventory/shop UI
@export var icon: Texture2D

## Color for tinting or UI borders
@export var color: Color = Color.WHITE

## TileSet atlas coordinates for this ore block
@export var tile_atlas_coords: Vector2i = Vector2i.ZERO

## Generation parameters
@export_group("Generation")
## Minimum depth (y-coordinate) where this ore can spawn
@export var min_depth: int = 0
## Maximum depth (-1 for no limit)
@export var max_depth: int = -1
## Noise threshold (0.0-1.0, higher = rarer). 0.75 common, 0.95+ rare
@export var spawn_threshold: float = 0.75
## Noise frequency (controls cluster spread). Lower = bigger clusters
@export var noise_frequency: float = 0.05
## Vein size range [min, max] blocks
@export var vein_size_min: int = 2
@export var vein_size_max: int = 6

## Economy parameters
@export_group("Economy")
## Base sell value in coins
@export var sell_value: int = 1
## Maximum stack size in inventory
@export var max_stack: int = 99
## Rarity tier (1-8, affects border colors in UI)
@export var tier: int = 1
## Rarity name: common, uncommon, rare, epic, legendary
@export var rarity: String = "common"

## Mining parameters
@export_group("Mining")
## Hardness (hits to break with base pickaxe)
@export var hardness: int = 2
## Minimum tool tier required to mine (0 = any)
@export var required_tool_tier: int = 0
```

## Edge Cases

- max_depth = -1 means ore spawns at any depth below min_depth
- spawn_threshold near 1.0 makes ore extremely rare (use 0.97+ for gems)
- vein_size_min == vein_size_max creates consistent vein sizes

## Verify

- [ ] Build succeeds with no errors
- [ ] OreData class has all required exported properties
- [ ] Properties have appropriate default values
- [ ] Properties are grouped logically in Inspector
- [ ] Can create .tres files from OreData class
