---
title: "implement: Ore generation priority (rarest first)"
status: open
priority: 2
issue-type: task
created-at: "2026-01-16T00:49:21.551835-06:00"
after:
  - GoDig-dev-noise-based-3afe498c
---

## Description

When generating terrain, check ore spawning from rarest to most common. This ensures rare ores are never overwritten by common ones when spawn regions overlap.

## Context

- Multiple ore types may have overlapping depth ranges
- Without priority, common ores could overwrite rare spawn locations
- Checking rarest first guarantees valuable finds aren't lost
- See research: GoDig-research-procedural-gen-d809424b

## Affected Files

- `scripts/world/terrain_generator.gd` - Ore checking order
- `scripts/autoload/data_registry.gd` - Sort ores by rarity on load

## Implementation Notes

### Ore Check Order

```gdscript
# terrain_generator.gd
func _check_ore_at(world_pos: Vector2i, depth: int) -> int:
    # Get ores sorted by rarity (highest first)
    var ores := DataRegistry.get_ores_by_rarity()

    for ore in ores:
        # Skip if outside depth range
        if depth < ore.min_depth:
            continue
        if ore.max_depth > 0 and depth > ore.max_depth:
            continue

        # Check spawn probability using noise
        if _should_spawn_ore(world_pos, ore):
            return ore.tile_type  # Or return ore.id depending on system

    return -1  # No ore at this position
```

### DataRegistry Ore Sorting

```gdscript
# data_registry.gd
var _ores_by_rarity: Array = []

func _load_all_ores() -> void:
    # ... existing load logic ...

    # Sort by rarity (descending - rarest first)
    _ores_by_rarity = ores.values()
    _ores_by_rarity.sort_custom(_compare_ore_rarity)

func _compare_ore_rarity(a: OreData, b: OreData) -> bool:
    # Higher rarity value = rarer = comes first
    return a.rarity > b.rarity

func get_ores_by_rarity() -> Array:
    return _ores_by_rarity
```

### Ore Rarity Tiers

| Tier | Rarity Value | Examples | Notes |
|------|--------------|----------|-------|
| 4 | Legendary | Diamond, Ruby | Extremely rare |
| 3 | Epic | Gold, Emerald | Very rare |
| 2 | Rare | Silver, Sapphire | Uncommon |
| 1 | Uncommon | Iron, Copper | Common progression |
| 0 | Common | Coal, Stone | Very common |

### Check Order Example

At depth 500 (where multiple ores overlap):

```
1. Check Diamond (rarity 4) - depth valid 800-inf? NO, skip
2. Check Gold (rarity 3) - depth valid 300-1200? YES
   - Check noise threshold... MISS
3. Check Silver (rarity 2) - depth valid 200-900? YES
   - Check noise threshold... HIT! Return Silver
   - (Stop checking, silver spawns)
```

### Spawn Probability Check

```gdscript
func _should_spawn_ore(pos: Vector2i, ore: OreData) -> bool:
    var noise := _ore_noises.get(ore.id)
    if noise == null:
        return false

    var noise_value := noise.get_noise_2d(pos.x, pos.y)
    # Normalize from [-1, 1] to [0, 1]
    noise_value = (noise_value + 1.0) / 2.0

    # Higher threshold = rarer spawn
    return noise_value > ore.spawn_threshold
```

### OreData Spawn Properties

```gdscript
# ore_data.gd
@export var rarity: int = 0  # 0=common, 4=legendary
@export var spawn_threshold: float = 0.75  # Higher = rarer
```

### Spawn Threshold by Rarity

| Rarity | Threshold | Approx % Chance |
|--------|-----------|-----------------|
| 0 (Common) | 0.70 | 30% |
| 1 (Uncommon) | 0.80 | 20% |
| 2 (Rare) | 0.88 | 12% |
| 3 (Epic) | 0.93 | 7% |
| 4 (Legendary) | 0.97 | 3% |

## Edge Cases

- Multiple ores at exact threshold: First in rarity order wins
- New ore types added: Re-sort on load
- Same rarity: Secondary sort by depth (deeper = higher priority)
- No matching ore: Return -1, use base terrain

## Verify

- [ ] Build succeeds
- [ ] DataRegistry.get_ores_by_rarity() returns sorted array
- [ ] Diamond checked before Gold before Silver before Copper
- [ ] At overlapping depths, rarer ore can spawn
- [ ] Common ore doesn't overwrite rare ore positions
- [ ] Same seed produces identical ore placement
- [ ] Ore distribution looks balanced (not all rare or all common)
