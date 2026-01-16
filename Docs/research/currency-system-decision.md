# Currency System Design Decision

## Overview
Should GoDig use a single currency (coins only) or multiple currencies? Should there be crafting, or pure buy/sell economy?

## Option Analysis

### Currency Options

#### Option A: Single Currency (Coins Only)

**How It Works:**
- All resources sell for coins
- All purchases use coins
- Simple, universal economy

**Pros:**
- Easy to understand
- No conversion confusion
- Clear value comparison
- Simpler UI
- Mobile-friendly simplicity

**Cons:**
- Less depth
- May feel too simple long-term
- No "special" currencies for rare items

**Games Using This:**
- Motherload
- Most casual mobile games

#### Option B: Multi-Currency

**How It Works:**
- Coins (basic currency from selling)
- Gems (premium/rare drops)
- Ore fragments (crafting material)

**Pros:**
- More economic depth
- Premium items feel special
- Multiple progression tracks
- Monetization flexibility

**Cons:**
- Conversion complexity
- UI clutter
- Mobile unfriendly
- Pay-to-win concerns

**Games Using This:**
- Most F2P mobile games
- Terraria (coins + rare materials)

#### Option C: Single Currency + Specific Materials

**How It Works:**
- Coins for general purchases
- Specific ores required for upgrades
- "Need 5 Iron Ore + 500 coins for Iron Pickaxe"

**Pros:**
- Coins remain simple
- Ores have purpose beyond selling
- Encourages exploration for materials
- No confusing currency conversion

**Cons:**
- Inventory pressure (save ores for crafting)
- May feel grindy if materials rare

---

### Crafting vs Buy/Sell

#### Option A: Pure Buy/Sell

**How It Works:**
- Find resources → sell at shop → buy upgrades
- No crafting, just commerce

**Pros:**
- Simple and clear
- No recipe hunting
- Faster progression
- Less menu navigation

**Cons:**
- Ores have no intrinsic value beyond coins
- Less reason to seek specific resources

#### Option B: Full Crafting System

**How It Works:**
- Combine materials to create items
- Recipes unlocked via progression
- Crafting stations on surface

**Pros:**
- Deep engagement
- Resources feel meaningful
- Crafting progression layer

**Cons:**
- Significant complexity
- More UI needed
- Recipe management
- Not mobile-friendly

#### Option C: Hybrid (Buy + Material Requirements)

**How It Works:**
- Upgrades cost coins AND materials
- "Steel Pickaxe: 2000 coins + 10 Iron Ore"
- No complex crafting UI, just requirements

**Pros:**
- Materials have purpose
- Simple interface
- No recipe system needed
- Best of both approaches

**Cons:**
- Must balance material requirements
- Inventory management for "keeper" items

---

## Decision Factors

### Mobile Considerations
- Simpler is better
- Multiple currencies confuse casual players
- Inventory space is premium
- Quick sessions don't suit complex crafting

### Progression Feel
| System | "Wow" Moments | Grind Feel |
|--------|---------------|------------|
| Coins only | Constant small wins | Can feel same-y |
| Multi-currency | Big milestone purchases | Currency confusion |
| Coins + materials | Meaningful upgrades | May delay purchases |

### Economic Balance
- Single currency: Easy to balance
- Multi-currency: Requires careful conversion rates
- Materials: Need drop rates that feel fair

---

## Recommendation: **Coins + Material Requirements (Option C)**

### System Design:

#### Primary Currency
- **Coins** - Universal currency
- Earned by selling ALL resources
- Used for most purchases

#### Material Requirements
- **Upgrades require coins + specific ores**
- "Copper Pickaxe: 500 coins + 5 Copper Ore"
- Creates reason to seek specific resources
- Player decides: sell ore or save for upgrade?

### Example Upgrade Costs:

| Upgrade | Coins | Materials |
|---------|-------|-----------|
| Copper Pickaxe | 500 | 5 Copper Ore |
| Iron Pickaxe | 2,000 | 10 Iron Ore |
| Steel Pickaxe | 8,000 | 20 Iron + 5 Coal |
| Silver Pickaxe | 25,000 | 15 Silver Ore |
| Gold Pickaxe | 50,000 | 10 Gold Ore |
| Diamond Pickaxe | 300,000 | 5 Diamonds |

### No Full Crafting System
- Upgrades purchased at shops (with requirements)
- No crafting tables or recipe unlocks
- Simple "Can Afford?" check includes materials
- Materials auto-checked from inventory

---

## Implementation

### Shop Purchase Flow:
```gdscript
func can_afford_upgrade(upgrade: UpgradeData) -> bool:
    if PlayerData.coins < upgrade.coin_cost:
        return false

    for material in upgrade.materials:
        if not Inventory.has_item(material.id, material.amount):
            return false

    return true

func purchase_upgrade(upgrade: UpgradeData):
    PlayerData.coins -= upgrade.coin_cost
    for material in upgrade.materials:
        Inventory.remove_item(material.id, material.amount)
    PlayerData.unlock_upgrade(upgrade.id)
```

### Inventory Management:
- **Mark as "Keep"** - Prevent accidental selling
- **Quick-sell** - Sell all except "Keep" items
- **Material preview** - Show what upgrades need which ores

### UI Display:
```
┌─────────────────────────────────────┐
│  STEEL PICKAXE                      │
│  ────────────────────────           │
│  +55 Damage  |  1.1x Speed          │
│                                     │
│  Cost:                              │
│  💰 8,000 coins  [✓]                │
│  ⚙️ 20 Iron Ore  [✓]                │
│  ite 5 Coal       [✗] (need 3 more) │
│                                     │
│  [PURCHASE - LOCKED]                │
└─────────────────────────────────────┘
```

---

## Questions Resolved
- [x] Single or multi-currency? → **Single (coins) + materials**
- [x] Crafting system? → **No** (buy with requirements)
- [x] Premium currency? → **No** (avoid P2W concerns)
- [x] Material requirements? → **Yes** (adds purpose to resources)

---

## Summary

**Decision: Single currency (coins) with material requirements for upgrades**

This approach:
- Keeps economy simple and understandable
- Gives resources purpose beyond selling
- Avoids complex crafting systems
- Creates meaningful decisions (sell vs save)
- Mobile-friendly simplicity
- No confusing currency conversions

Players will:
1. Mine resources
2. Decide what to sell vs keep
3. Save materials for desired upgrades
4. Purchase upgrades with coins + materials
5. Progress deeper with better tools
