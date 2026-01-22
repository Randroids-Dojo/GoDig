---
title: "implement: Surface area scene"
status: active
priority: 0
issue-type: task
created-at: "\"2026-01-16T00:47:11.629318-06:00\""
---

The above-ground area where player starts, returns to sell, and accesses shops. Safe zone (no digging). Shop interaction points. Initial spawn point.

## Description

Create the surface area that serves as the game's hub. This is where the player spawns, returns to sell resources, and interacts with shops. The surface is a safe zone where no digging is possible.

## Context

- Current test level goes directly to dirt grid at row 7
- No visual surface/sky area above the dirt
- Shop building and mine entrance need a home
- Player needs a clear "home base" to return to

## Affected Files

- `scenes/surface.tscn` - NEW: Surface scene with sky, ground, buildings
- `scripts/surface.gd` - NEW: Surface scene controller
- `scenes/test_level.tscn` - Update to include surface area
- `scenes/surface/shop_building.tscn` - Building to place on surface
- `scenes/surface/mine_entrance.tscn` - Entrance to underground (optional visual)

## Implementation Notes

### Scene Structure

```
Surface (Node2D)
├─ Sky (ColorRect or ParallaxBackground)
│   └─ Simple gradient blue to light blue
├─ Ground (ColorRect or TileMap)
│   └─ Green/brown grass on top of dirt
├─ ShopBuilding (instance of shop_building.tscn)
│   └─ Positioned on surface, accessible to player
├─ MineEntrance (visual indicator of where digging starts)
│   └─ Could be a hole/cave opening sprite
└─ SpawnPoint (Marker2D)
    └─ Where player starts and respawns
```

### Visual Layout (Portrait 720x1280)

```
┌──────────────────────────────────────┐
│                                      │
│               SKY                    │  Rows 0-3
│          (Blue gradient)             │
│                                      │
├──────────────────────────────────────┤
│  [SHOP]         [SPAWN]              │  Row 4-5 (surface)
│  ┌─────┐                             │
│  │ $ $ │    ●    ┌────┐              │  Player spawns at SPAWN
│  │Shop │   (P)   │Mine│              │  Mine entrance visual
│  └─────┘         └────┘              │
├──────────────────────────────────────┤
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│  Row 6 (grass/surface layer)
├──────────────────────────────────────┤
│  DIRT STARTS (existing DirtGrid)     │  Row 7+ (underground)
│                                      │
└──────────────────────────────────────┘
```

### Integration with Existing DirtGrid

The surface exists above row 7 (SURFACE_ROW in GameManager). DirtGrid already starts generating at SURFACE_ROW, so the surface scene fills the space above.

```gdscript
# surface.gd
extends Node2D

const BLOCK_SIZE := 128

@onready var spawn_point: Marker2D = $SpawnPoint

func get_spawn_position() -> Vector2:
    return spawn_point.global_position

func _ready() -> void:
    # Position surface elements based on SURFACE_ROW
    var surface_y := GameManager.SURFACE_ROW * BLOCK_SIZE
    # Ground strip sits just above dirt
    $Ground.position.y = surface_y - BLOCK_SIZE
```

### No-Dig Zone

Player should not be able to dig on the surface. Options:
1. Player.gd checks if target_y < SURFACE_ROW before mining
2. DirtGrid doesn't have blocks above SURFACE_ROW (already true)
3. Add invisible collision for surface ground

Current architecture: Option 2 is already in effect - DirtGrid only generates blocks at SURFACE_ROW and below.

## Verify

- [ ] Surface scene loads with sky and ground visuals
- [ ] Shop building is visible and positioned correctly
- [ ] Player spawns at spawn point on surface
- [ ] Player can walk left/right on surface
- [ ] Player cannot dig blocks on surface (none exist)
- [ ] Mine entrance/hole visual shows where underground starts
- [ ] Jumping off surface into mine works correctly
- [ ] Surface visuals don't interfere with underground camera
