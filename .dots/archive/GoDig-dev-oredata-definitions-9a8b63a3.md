---
title: "implement: OreData definitions"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:38:18.015267-06:00\""
closed-at: "2026-01-19T19:34:24.893819-06:00"
close-reason: Ore .tres files exist in resources/ores/
---

## Description

Create .tres resource files for each ore type using the OreData resource class. MVP needs 5 ores + 1 gem (6 total). Each ore has specific depth ranges and rarity for progression.

## Context

Ores are depth-gated to create progression. Players discover new ores as they dig deeper, with rarer/more valuable ores appearing further down. This drives the "just one more level" motivation.

## Affected Files

- `resources/ores/coal.tres` - NEW
- `resources/ores/copper.tres` - NEW
- `resources/ores/iron.tres` - NEW
- `resources/ores/silver.tres` - NEW
- `resources/ores/gold.tres` - NEW
- `resources/gems/ruby.tres` - NEW (gem, not ore)
- `scripts/autoload/data_registry.gd` - MODIFY: Add ore loading

## Implementation Notes

### MVP Ore Definitions

| Ore | Depth | Threshold | Frequency | Vein | Value | Tier |
|-----|-------|-----------|-----------|------|-------|------|
| Coal | 0-500m | 0.75 | 0.08 | 3-8 | 1 | 1 |
| Copper | 10-300m | 0.78 | 0.06 | 2-6 | 5 | 1 |
| Iron | 50-600m | 0.82 | 0.05 | 2-5 | 10 | 2 |
| Silver | 200-800m | 0.88 | 0.04 | 2-4 | 25 | 3 |
| Gold | 300-1000m | 0.92 | 0.03 | 1-3 | 100 | 3 |
| Ruby | 500m+ | 0.97 | 0.02 | 1-2 | 500 | 5 |

### coal.tres Example

```gdscript
[gd_resource type="Resource" script_class="OreData"]

[resource]
id = "coal"
display_name = "Coal"
color = Color(0.2, 0.2, 0.2)
tile_atlas_coords = Vector2i(0, 1)
min_depth = 0
max_depth = 500
spawn_threshold = 0.75
noise_frequency = 0.08
vein_size_min = 3
vein_size_max = 8
sell_value = 1
tier = 1
rarity = "common"
hardness = 2
```

### DataRegistry Integration

```gdscript
# In data_registry.gd
var ores: Dictionary = {}

func _ready():
    _load_ores()

func _load_ores():
    var ore_dir = "res://resources/ores/"
    var dir = DirAccess.open(ore_dir)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var ore = load(ore_dir + file_name)
                if ore is OreData:
                    ores[ore.id] = ore
            file_name = dir.get_next()

func get_ore(id: String) -> OreData:
    return ores.get(id)
```

### Rarity Progression

- Tier 1 (common): Coal, Copper - appear immediately
- Tier 2 (uncommon): Iron - appears after 50m
- Tier 3 (rare): Silver, Gold - appear after 200-300m
- Tier 5 (ultra rare): Ruby - appears after 500m

## Edge Cases

- Overlapping depth ranges intentional (creates variety)
- Ruby max_depth = -1 (no ceiling)
- Coal has lowest threshold (most common)
- Gold has largest vein variance (1-3)

## Verify

- [ ] Build succeeds with no errors
- [ ] All 6 .tres files load without errors
- [ ] DataRegistry.ores contains all 6 entries
- [ ] DataRegistry.get_ore("coal") returns coal data
- [ ] Ore depth ranges match specification table
- [ ] Sell values match specification table
