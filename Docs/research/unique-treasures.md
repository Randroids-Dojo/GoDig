# Unique Treasures & Artifacts Research

## Sources
- [Motherload Special Items](https://motherload.fandom.com/wiki/Items)
- [Spelunky Treasure System](https://spelunky.fandom.com/wiki/Treasure)
- [Collection Games Psychology](https://www.gamedeveloper.com/design/the-psychology-of-collection-mechanics)

## Treasure Philosophy

### Beyond Basic Ores
While ores provide steady income, **unique treasures** create:
- Memorable moments ("I found a diamond!")
- Collection goals
- Story/lore elements
- High-value rewards
- Sense of discovery

### Treasure vs Resource
| Aspect | Resources (Ores) | Treasures |
|--------|------------------|-----------|
| Frequency | Common | Rare |
| Value | Predictable | High/variable |
| Purpose | Steady income | Milestones |
| Feeling | Routine | Exciting |

## Treasure Categories

### 1. Gems (Rare Resources)

**Higher-tier than ores, still stackable**

| Gem | Min Depth | Rarity | Base Value |
|-----|-----------|--------|------------|
| Amethyst | 100m | Uncommon | 100 |
| Topaz | 200m | Uncommon | 200 |
| Sapphire | 400m | Rare | 500 |
| Ruby | 600m | Rare | 800 |
| Emerald | 800m | Very Rare | 1,500 |
| Diamond | 1000m | Epic | 5,000 |
| Black Opal | 1500m | Legendary | 15,000 |
| Void Crystal | 2000m | Mythic | 50,000 |

**Gem Quality Variants**
- Flawed: 50% value
- Normal: 100% value  
- Perfect: 200% value
- Prismatic (ultra-rare): 500% value

### 2. Artifacts (Unique Finds)

**One-time discoveries, not stackable**

**Historical Artifacts**
| Artifact | Depth | Value | Museum Bonus |
|----------|-------|-------|--------------|
| Ancient Coin | 50m | 500 | +5% sell price |
| Fossil Fragment | 100m | 800 | +1% dig speed |
| Clay Tablet | 200m | 1,500 | Lore unlock |
| Bronze Idol | 300m | 3,000 | +10% gem spawn |
| Crystal Skull | 500m | 8,000 | Light +20% |
| Golden Scepter | 700m | 15,000 | +15% coin gain |
| Dragon Tooth | 1000m | 30,000 | Damage -10% |
| Void Heart | 2000m | 100,000 | Prestige bonus |

**Implementation**
```gdscript
# artifact_data.gd
class_name ArtifactData

const ARTIFACTS = {
    "ancient_coin": {
        "name": "Ancient Coin",
        "description": "A weathered coin from a forgotten civilization.",
        "min_depth": 50,
        "spawn_chance": 0.001,  # Per tile at valid depth
        "value": 500,
        "museum_bonus": {"type": "sell_price", "value": 0.05}
    },
    # ... more artifacts
}
```

### 3. Treasure Chests

**Containers with random loot**

**Chest Types**
| Chest | Depth | Contents |
|-------|-------|----------|
| Wooden | 50m+ | 2-5 common ores, small coins |
| Iron | 200m+ | 3-6 ores, chance of gem |
| Golden | 500m+ | Gems, artifacts, large coins |
| Ancient | 1000m+ | Rare artifacts, legendary gems |
| Void | 2000m+ | Mythic items, unique rewards |

**Chest Mechanics**
- Visual glow when nearby
- Click/tap to open
- Opening animation + reveal
- Can be trapped (later feature)

### 4. Fossils & Specimens

**Collection-focused items**

**Fossil Categories**
- Shells (shallow): Complete set = 5 fossils
- Bones (medium): Complete set = 8 fossils
- Creatures (deep): Complete set = 6 fossils
- Plants (all depths): Complete set = 10 fossils

**Set Completion Rewards**
```
Complete Shells → +5% shallow dig speed
Complete Bones → Bone pickaxe unlock
Complete Creatures → Museum display + 10,000 coins
Complete Plants → Garden building unlock
Complete ALL → "Paleontologist" title + prestige bonus
```

### 5. Blueprint Fragments

**Unlock new items/buildings**

| Blueprint | Pieces | Unlocks |
|-----------|--------|---------|
| Auto-Miner | 3 | Auto-Miner building |
| Drill | 4 | Drill tool (dig up) |
| Teleporter | 5 | Teleporter building |
| Rocket Boots | 4 | Anti-fall equipment |
| Ore Scanner | 3 | Reveals nearby ores |

**Fragment Distribution**
- Spread across depth ranges
- One piece per 500m band
- Encourages deep exploration

## Discovery Experience

### Finding Treasures

**Visual Design**
- Sparkle effect on treasure tiles
- Distinct from regular ores
- Glow increases with value

**Audio Design**
- Musical sting on discovery
- Rarity affects sound intensity
- Voice line? ("Incredible find!")

**UI Treatment**
```
┌─────────────────────────────┐
│    ★ RARE DISCOVERY ★       │
│                             │
│    [Sapphire Icon]          │
│    Perfect Sapphire         │
│    Value: 1,000 coins       │
│                             │
│    [COLLECT]                │
└─────────────────────────────┘
```

### First-Time Discovery Bonus
```gdscript
func on_treasure_collected(treasure_id: String):
    var data = TreasureData.get(treasure_id)
    var value = data.base_value

    if not PlayerData.has_discovered(treasure_id):
        # First time bonus!
        PlayerData.mark_discovered(treasure_id)
        value *= 2
        show_first_discovery_popup(treasure_id)
        Analytics.track("first_discovery", treasure_id)

    add_to_inventory(treasure_id, value)
```

## Museum / Collection System

### Collection Hall Building
Unlocks at depth 200m, allows displaying finds

**Display Benefits**
- Each displayed item = permanent bonus
- Complete sets = larger bonuses
- Visual showcase of progress

**UI Concept**
```
┌─────────────────────────────────────┐
│  MUSEUM - Your Collection           │
├─────────────────────────────────────┤
│  GEMS        [████████░░] 8/10      │
│  ARTIFACTS   [███░░░░░░░] 3/12      │
│  FOSSILS     [██████░░░░] 15/25     │
│  BLUEPRINTS  [████░░░░░░] 2/5       │
├─────────────────────────────────────┤
│  Collection Bonus: +12% coin gain   │
│  Next milestone: 30 items (+5%)     │
└─────────────────────────────────────┘
```

### Collection Progress Rewards
| Items Collected | Reward |
|-----------------|--------|
| 10 | +5% coin gain |
| 25 | Unlock Gem Appraiser shop |
| 50 | +10% rare spawn rate |
| 100 | "Collector" title |
| ALL | "Completionist" + prestige tier |

## Spawn Mechanics

### Treasure Generation
```gdscript
# treasure_spawner.gd
func should_spawn_treasure(pos: Vector2i) -> String:
    var depth = pos.y

    # Check each treasure type
    for treasure_id in TreasureData.TREASURES:
        var data = TreasureData.TREASURES[treasure_id]

        if depth < data.min_depth:
            continue

        # Already found unique artifact?
        if data.unique and PlayerData.has_found(treasure_id):
            continue

        # Roll for spawn
        var chance = data.spawn_chance
        chance *= get_depth_modifier(depth, data.min_depth)
        chance *= get_luck_bonus()

        if randf() < chance:
            return treasure_id

    return ""  # No treasure
```

### Guaranteed Spawns
To prevent bad luck streaks:
- First gem guaranteed within 100m
- First artifact guaranteed within 300m
- At least 1 treasure per 500m explored

### Luck Stat
```gdscript
func get_luck_bonus() -> float:
    var base = 1.0
    base += PlayerData.luck_level * 0.1  # +10% per level
    base += get_equipment_bonus("luck")
    base += get_museum_bonus("luck")
    return base
```

## Questions to Resolve
- [x] Unique artifacts → 50 collectibles across all layers
- [x] Artifact handling → Keep forever, display in museum
- [x] Museum → Optional building, v1.0 feature
- [x] Luck stat → Hidden, affects rare drop rates
- [x] Treasure maps → v1.0 feature, mark dig spots
