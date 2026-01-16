# Hazards & Environmental Challenges Research

## Sources
- [SteamWorld Dig Hazard Design](https://www.gamedeveloper.com/design/steamworld-dig-2-level-design)
- [Spelunky Trap Design Philosophy](https://spelunky.fandom.com/wiki/Traps)
- [Terraria Enemy & Hazard Wiki](https://terraria.wiki.gg/wiki/Hazards)

## Design Philosophy

### Hazards vs Enemies
For MVP, focus on **environmental hazards** over enemies:
- Simpler to implement (no AI)
- Fits mining theme better
- Creates predictable challenge
- Enemies can be added in v1.1+

### Hazard Purpose
Hazards should:
1. Create risk/reward decisions
2. Encourage preparation (buy gear)
3. Make depth progression meaningful
4. Add variety to digging experience

Hazards should NOT:
1. Feel cheap or unfair
2. Cause instant death (except deep zones)
3. Block progress permanently
4. Require constant attention

## Hazard Categories

### 1. Fall Damage
**The Core Hazard** - Already in traversal research

| Fall Distance | Damage | Notes |
|---------------|--------|-------|
| 0-3 tiles | None | Safe |
| 4-6 tiles | 10-20% | Warning zone |
| 7-10 tiles | 30-50% | Dangerous |
| 11+ tiles | 60-100% | Critical/lethal |

**Mitigation**
- Boots upgrade reduces damage
- Ladders prevent falls
- Parachute item (late game)
- Landing on soft blocks (dirt vs stone)

### 2. Unstable Blocks (Cave-ins)

**Concept**: Certain blocks fall when unsupported

**Block Types**
- Sand: Falls immediately when block below removed
- Gravel: Falls after 0.5s delay
- Loose stone: Falls if 2+ adjacent blocks removed

**Implementation**
```gdscript
# unstable_block.gd
func _on_adjacent_block_removed():
    if not has_support():
        await get_tree().create_timer(fall_delay).timeout
        start_falling()

func has_support() -> bool:
    return is_block_below() or is_block_left_and_right()
```

**Player Warning**
- Visual: Cracks/dust particles when unstable
- Audio: Creaking/rumbling sound
- Brief delay before fall

### 3. Water & Flooding

**Shallow Water (Early Game)**
- Slows movement by 30%
- No damage
- Can be found in underground pools

**Deep Water (Mid Game)**
- Drowning meter (10 seconds)
- Swim controls replace walk
- Valuable items spawn underwater

**Flooding Events**
- Breaking certain blocks releases water
- Water spreads to fill cavities
- Creates urgency to escape

```gdscript
# water_tile.gd
func _physics_process(delta):
    if can_spread():
        var neighbors = get_empty_neighbors()
        for pos in neighbors:
            if pos.y >= position.y:  # Water flows down/sideways
                spread_to(pos)
```

### 4. Lava & Heat (Deep Zones)

**Lava Tiles**
- Instant death on contact
- Emits light (visible from distance)
- Only in Magma Zone (1000m+)

**Heat Damage**
- Gradual HP drain near lava
- Requires heat-resistant gear
- Creates "danger zones"

**Visual/Audio Cues**
- Screen tint orange near lava
- Ambient crackling sound
- Heat distortion effect

### 5. Gas Pockets

**Concept**: Invisible hazard, detected by sound/effect

**Types**
| Gas Type | Effect | Depth |
|----------|--------|-------|
| Stale Air | Slower movement | 200m+ |
| Poison Gas | Damage over time | 400m+ |
| Explosive Gas | Boom if near torch | 600m+ |

**Detection & Mitigation**
- Canary item (warns of gas)
- Gas mask (negates effects)
- Ventilation upgrade (clears area)

### 6. Pressure & Depth Sickness

**Concept**: Deep mining has physical toll

**Implementation**
- Below 500m: Movement slows slightly
- Below 1000m: Dig speed reduced
- Below 2000m: HP slowly drains

**Mitigation**
- Pressure suit (equipment)
- Depth acclimation (permanent upgrade)
- Return to surface resets

### 7. Darkness & Light

**Light Radius Mechanic**
```gdscript
# player.gd
var base_light_radius = 100  # pixels
var helmet_bonus = 0

func get_light_radius() -> float:
    var depth_penalty = current_depth * 0.02  # Darker deeper
    return max(50, base_light_radius + helmet_bonus - depth_penalty)
```

**Darkness Effects**
- Can't see ores/hazards outside light
- Creates tension in deep zones
- Encourages helmet upgrades

**Light Sources**
- Helmet lamp (player)
- Torches (placeable)
- Glowing ores (environmental)
- Lava (dangerous light)

### 8. Structural Collapse (Rare Event)

**Triggered Events**
- Mining near fault lines
- Too many blocks removed in area
- Explosive gas ignition

**Effects**
- Screen shake
- Multiple blocks fall
- Creates new obstacles
- Potential to trap player

**Player Agency**
- Visual warnings (cracks)
- Sound warnings (rumbling)
- Time to escape

## Depth-Based Hazard Introduction

### Surface (0m)
- None (safe tutorial zone)

### Shallow (0-100m)
- Fall damage only
- Introduces core risk

### Medium (100-300m)
- Unstable blocks (sand)
- Small water pools
- Teaches awareness

### Deep (300-600m)
- Gas pockets (stale air)
- Larger water features
- Gravel cave-ins

### Very Deep (600-1000m)
- Poison gas
- Explosive gas near ore
- Flooding events
- Pressure effects begin

### Abyss (1000m+)
- Lava zones
- Severe pressure
- Extreme darkness
- All hazards combined

## Hazard Feedback Design

### Warning System (3-Stage)
1. **Ambient**: Subtle environmental cues
2. **Proximity**: Obvious warning when close
3. **Imminent**: Clear "danger now" signal

### Example: Cave-in Warning
```
Stage 1: Small dust particles in area
Stage 2: Cracks appear on blocks, rumble sound
Stage 3: Blocks flash, loud crack, begin falling
```

### Death & Recovery

**Not Permadeath**
- Player respawns at surface
- Loses % of carried resources
- Equipment remains intact
- World state preserved

**Death Penalty Scaling**
| Cause | Resource Loss |
|-------|---------------|
| Fall damage | 10% |
| Drowning | 20% |
| Cave-in | 25% |
| Lava | 50% |
| Abyss hazards | 30% |

## Equipment to Counter Hazards

### Protective Gear
| Item | Counters | Unlock Depth |
|------|----------|--------------|
| Sturdy Boots | Fall damage | 50m |
| Gas Mask | All gases | 200m |
| Diving Gear | Drowning | 300m |
| Heat Suit | Lava/heat | 800m |
| Pressure Suit | Depth sickness | 1000m |

### Utility Items
| Item | Effect | Type |
|------|--------|------|
| Torch | Light area | Consumable |
| Flare | Reveals large area briefly | Consumable |
| Canary | Warns of gas | Permanent |
| Grappling Hook | Escape falls | Permanent |
| Teleport Scroll | Emergency escape | Consumable |

## Questions Resolved
- [x] Permadeath option or always respawn? → No permadeath (optional hardcore mode v1.1+)
- [x] How severe should resource loss be on death? → 10-30% inventory based on depth
- [x] Enemies in addition to hazards for v1.0? → No (see combat-enemies-decision.md)
- [x] Can hazards destroy player-placed structures? → No (player structures protected)
- [x] Tutorial for each new hazard type? → Yes (contextual first-encounter popups)

See [death-respawn-decision.md](death-respawn-decision.md) for full details.
