---
title: "research: Ore spawning integration"
status: done
priority: 0
issue-type: task
created-at: "2026-01-18T23:35:22.628926-06:00"
---

How should ores spawn in blocks? DirtBlock currently uses DataRegistry for hardness/color but doesn't check for ores. Need to decide: Should each block have a chance to BE an ore? Or should ores be separate entities? How does hit_block() integrate with OreData? How should visual appearance change for ore blocks?

## Research Findings (Verified 2026-01-19)

### Current Implementation Status: COMPLETE

Ore spawning is already implemented in `scripts/world/dirt_grid.gd`. The system works as follows:

### Architecture

**1. Ores ARE blocks (not separate entities)**
- Each dirt block position can contain ore
- Ore data stored in `DirtGrid._ore_map: Dictionary[Vector2i, String]`
- Value is the ore ID (e.g., "coal", "ruby")

**2. Spawning Logic (`DirtGrid._determine_ore_spawn()`)**
```gdscript
func _determine_ore_spawn(pos: Vector2i) -> void:
    var depth := pos.y - GameManager.SURFACE_ROW
    if depth < 0:
        return  # No ores above surface

    # Get all ores that can spawn at this depth
    var available_ores := DataRegistry.get_ores_at_depth(depth)

    # Sort by spawn_threshold descending (rarest first)
    available_ores.sort_custom(func(a, b): return a.spawn_threshold > b.spawn_threshold)

    for ore in available_ores:
        var noise_val := _generate_ore_noise(pos, ore.noise_frequency)
        if noise_val > ore.spawn_threshold:
            _ore_map[pos] = ore.id
            _apply_ore_visual(pos, ore)
            return  # Only one ore per block
```

**3. Visual Appearance (`DirtGrid._apply_ore_visual()`)**
- Blends block's layer color with ore color at 50%: `base_color.lerp(ore_color, 0.5)`
- Creates subtle tint distinguishing ore from plain dirt

**4. Drop Integration (`DirtGrid.hit_block()`)**
- When block destroyed, emits `block_dropped(pos, ore_id)` signal
- `ore_id` is empty string for plain dirt blocks
- `TestLevel._on_block_dropped()` receives signal and adds item to inventory

### Data Flow

1. `DirtGrid._generate_row()` calls `_determine_ore_spawn()` for each new block
2. Ore positions stored in `_ore_map` dictionary
3. Visual tint applied immediately via `_apply_ore_visual()`
4. On destruction, `hit_block()` looks up ore from `_ore_map`, emits signal, cleans up entry
5. TestLevel receives signal, looks up item via `DataRegistry.get_item(ore_id)`, adds to inventory

### Identified Gaps

**1. Ore hardness not used**
- DirtBlock gets hardness from layer only (`DataRegistry.get_block_hardness()`)
- OreData has its own `hardness` field that is IGNORED
- Coal blocks and ruby blocks have same hardness if in same layer
- **Creates implement dot**: Use OreData.hardness when ore present

**2. Tool tier gating not enforced**
- OreData has `required_tool_tier` field
- Mining logic doesn't check this
- Player can mine ruby with starter pickaxe
- **Creates implement dot**: Check tool tier before allowing mining

**3. Duplicate data systems**
- OreData and ItemData have duplicated definitions
- **Addressed in**: GoDig-implement-unify-oredata-8388f176

### Created Implementation Dots

- `GoDig-implement-use-ore-7c6502b1`: Use ore hardness in DirtBlock
- `GoDig-implement-tool-tier-cbc16732`: Tool tier gating for ores
