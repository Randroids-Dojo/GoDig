# Mining Mechanics Research

## Sources
- [Game Design Deep Dive: SteamWorld Dig](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-)
- [Motherload Wiki](https://motherload.fandom.com/wiki/Motherload)

## Core Loop Analysis

### The Fundamental Loop
1. **Dig down** - Mine resources, break blocks
2. **Collect** - Fill inventory with ores/gems
3. **Return** - Navigate back to surface
4. **Sell** - Exchange resources for currency
5. **Upgrade** - Buy better tools, expand capacity
6. **Repeat** - Go deeper, find rarer resources

### Key Design Insights

#### Grid-Based Digging
- Tiles should be approximately player-sized
- Simple square grid creates predictable, readable gameplay
- Players can plan routes visually

#### Risk vs Reward Tension
- The core tension: **risk of getting stuck**
- Digging down is easy, getting back up is the challenge
- This creates natural strategic thinking about routes

#### Avoiding Binary Failure States
- Don't make "stuck" = game over
- Wall-jumping transforms stuck from binary to "gray zone"
- Players feel clever when they escape a tight spot
- Sweet spot: "testers fell down a hole, sweated a bit, then found a clever way of getting back up again, feeling awesome"

#### Movement Mechanics Matter
- Jump height dramatically affects dig patterns
- SteamWorld Dig doubled jump from 1 to 2 tiles - huge impact
- Wall-jumping was the breakthrough mechanic
- Consider: run-jumping, wall-jumping, later abilities

#### Restriction Creates Depth
- No mid-air pickaxe attacks in SteamWorld Dig
- Simplifies animation AND creates puzzle depth
- Constraints create interesting decisions

## Motherload vs SteamWorld Dig Comparison

| Aspect | Motherload | SteamWorld Dig |
|--------|------------|----------------|
| Return mechanic | Fuel (depletes over time) | Lantern/water (cave refills) |
| Inventory | Limited space | Limited space |
| Vertical movement | Strict, can't dig up | Wall-jump, abilities |
| Challenge source | Time pressure, fuel management | Enemies, puzzle areas |
| Progression | Gadgets, upgrades | Metroidvania abilities |

## Design Decisions for GoDig

### Block Breaking
- **Grid-based**: Yes, tiles ~player sized
- **Dig directions**: Down, left, right (no digging up initially?)
- **Break time**: Varies by material hardness
- **Tool matters**: Better pickaxe = faster breaks

### Getting Unstuck
Options to consider:
1. Wall-jumping (proven effective)
2. Ladders (player-placed)
3. Ropes (consumable or permanent)
4. Teleport back to surface (resource cost?)
5. Dig-anywhere upgrades (late game)

### Resource Scarcity
- Limited inventory forces return trips
- Fuel/energy mechanic? Or just inventory pressure?
- Consider: deeper = more inventory needed = upgrade driver

## Questions to Resolve
- [ ] Fuel mechanic or not?
- [ ] How punishing is "stuck"?
- [ ] Can player dig up at all?
- [ ] Block hardness progression curve
- [ ] Tool swing speed vs damage
