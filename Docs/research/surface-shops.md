# Surface Shop & Building Research

## Sources
- [SteamWorld Build Guide](https://www.mejoress.com/a-comprehensive-steamworld-build-guide-optimize-your-town-and-underground/)
- [Mining Games on Steam](https://blog.mrmine.com/mining-games-steam-favorites-idle-sandbox-and-co-op/)
- [Blacksmith Master](https://store.steampowered.com/app/2292800/Blacksmith_Master/)
- [Space Miner - Idle Adventures](https://store.steampowered.com/app/2679860/Space_Miner__Idle_Adventures/)

## Shop Categories

### 1. Trading/Selling Shops
**General Store / Merchant**
- Sell raw ores and gems
- Basic prices, always available
- First building, no unlock required

**Gem Appraiser**
- Higher prices for gems specifically
- Requires discovery of first gem
- Adds collection/museum feature?

**Precious Metals Exchange**
- Better rates for gold, silver, platinum
- Unlocks after reaching certain depth
- Fluctuating prices for risk/reward?

### 2. Upgrade Shops
**Blacksmith / Forge**
- Upgrade pickaxe damage
- Upgrade pickaxe speed
- Upgrade durability
- Craft new tool types (drill, dynamite)

**Equipment Shop**
- Helmet (light radius)
- Boots (move speed)
- Gloves (dig speed)
- Backpack (inventory size)
- Armor (hazard protection)

**Gadget Shop**
- Lantern upgrades
- Compass (shows ore nearby)
- Detector (beeps for rare finds)
- Grappling hook
- Teleporter

### 3. Consumable Shops
**Supply Store**
- Ladders (stackable)
- Ropes
- Torches
- Dynamite/Bombs
- Healing items

**Food/Energy Shop**
- Energy drinks (stamina)
- Food (health regen)
- Potions (temporary buffs)

### 4. Infrastructure Buildings
**Elevator Shaft**
- Fast travel to reached depths
- Requires reaching depth milestones
- Expensive to build/extend

**Warehouse**
- Expand storage capacity
- Auto-sort resources
- Overflow protection

**Bank / Vault**
- Store excess currency
- Interest over time (idle mechanic)
- Protect from... something?

### 5. Automation Buildings
**Auto-Miner Station**
- Hire workers to mine for you
- Generates resources while idle
- Requires fuel/maintenance

**Refinery**
- Process raw ore into ingots
- Higher sell value
- Passive processing

**Merchant Caravan**
- Auto-sell resources
- Travels to surface periodically
- Upgradeable capacity

### 6. Special Buildings
**Museum / Collection Hall**
- Display rare finds
- Bonuses for completing sets
- Achievement tracking

**Research Lab**
- Tech tree unlocks
- Spend resources to research
- Permanent upgrades

**Portal/Teleporter**
- Fast travel between surface and depths
- Unlocks at certain progression
- Major quality-of-life upgrade

## Building Unlock Progression

### Starting Buildings (Always Available)
1. General Store - Sell resources
2. Supply Store - Buy basics

### Early Unlocks (Depth 50-200m)
3. Blacksmith - First tool upgrades
4. Equipment Shop - Basic gear
5. Warehouse - Storage expansion

### Mid-Game Unlocks (Depth 200-500m)
6. Gem Appraiser - Gem specialization
7. Gadget Shop - Utility items
8. Elevator Shaft - Fast travel

### Late-Game Unlocks (Depth 500m+)
9. Refinery - Resource processing
10. Research Lab - Tech tree
11. Museum - Collection bonuses

### End-Game Unlocks (Depth 1000m+)
12. Auto-Miner Station - Automation
13. Portal - Deep teleportation
14. Precious Metals Exchange - Premium trading

## Shop UI/UX Patterns

### Enter Shop → Tab Categories
```
[Buy] [Sell] [Upgrade]
```

### Upgrade Display
```
Pickaxe Damage: Level 3 → 4
Current: 15 damage
Next: 20 damage (+33%)
Cost: 500 coins
[UPGRADE]
```

### Progressive Unlocks
- Gray out unavailable items
- Show unlock requirements
- "Reach depth 500m to unlock"

## Building Placement System

### Endless Horizontal Surface
- Surface scrolls left/right infinitely
- Buildings placed on valid ground tiles
- Spacing requirements between buildings?

### Building Slots vs Free Placement
**Option A: Predetermined Slots**
- Simpler implementation
- Clear progression path
- Less player agency

**Option B: Free Placement**
- More sandbox feel
- Building size matters
- Collision/spacing logic needed

### Visual Progression
- Buildings can be upgraded visually
- Level 1 = small shack
- Level 5 = grand establishment
- Shows player progress at a glance

## Questions to Resolve
- [x] How many total buildings? → 15 building types total
- [x] Slot-based or free placement? → Slot-based for MVP
- [x] Building upgrade levels? → 3 levels MVP, 5 levels v1.0
- [x] Auto-sell / idle mechanics? → v1.1+ feature
- [x] NPCs inside buildings? → v1.1+ (cosmetic)
- [x] Day/night affect shops? → No, always open
