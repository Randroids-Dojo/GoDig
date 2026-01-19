---
title: "research: Monetization without frustration"
status: closed
priority: 3
issue-type: task
created-at: "\"\\\"2026-01-18T23:42:38.023968-06:00\\\"\""
closed-at: "2026-01-19T09:55:52.215911-06:00"
close-reason: "Researched ethical monetization: premium, cosmetics, hybrid ad models. Documented 4 options with pros/cons. Recommended premium demo or rewarded-ads-only approaches."
---

Research ethical monetization for mobile games. No pay-to-win, no energy timers, no predatory IAP. What works? Cosmetics, ad removal, tip jar, expansion packs? Look at successful indie mobile games. How do we sustain development without alienating players?

## Research Session: 2026-01-19

### Successful Monetization Models

#### 1. Premium (One-Time Purchase)
**Best For**: Games with established reputation or unique value proposition

**Success Stories**:
- **Stardew Valley**: $1M revenue in 3 weeks on mobile at $8 price point
  - 41M copies sold lifetime without microtransactions
  - Over half of lifetime sales came in last 3 years
  - No ads, no IAP, complete package upfront
- **Balatro**: 2024 breakout hit, nominated for Game of the Year
- **Crashlands 2**: $9.99 premium pricing

**Pros**:
- No ongoing monetization pressure
- Builds loyal audience willing to pay for quality
- No ads interrupting gameplay
- Players prefer complete experience

**Cons**:
- $8+ is "huge entry barrier" for mobile where free-to-try is expected
- Smaller user base than freemium
- Works best with established reputation

#### 2. Cosmetic-Only Microtransactions
**Best For**: Free-to-play games that want to monetize without affecting gameplay

**Key Principle**: Items must not affect gameplay mechanics or provide competitive advantage

**Success Stories**:
- **Fortnite**: Benchmark for ethical cosmetic monetization
- **Among Us**: Low upfront cost + optional cosmetics
- **Path of Exile**: Cosmetics + storage only
- **DOTA 2 / League of Legends**: Core gameplay unaffected by spending

**Player Acceptance**: 81% of US gamers (13-45) aware of cosmetics would pay for them

**Best Practices**:
- Transparency about what purchases contain
- Optional and value-driven purchases
- Community involvement in cosmetic design
- Fair pricing (not $20 for a single manager)

#### 3. Hybrid: Free + Ad Removal IAP
**Best For**: Games wanting broad reach with optional premium upgrade

**Implementation**:
- Match ad removal price to what "premium" version would cost
- Offer subscription OR one-time IAP (both work)
- Keep rewarded video ads even for subscribers (opt-in, not interruptive)
- 74% of US mobile gamers accept video ads if rewarded

**Revenue Stats**:
- IAPs generate 48.2% of total app revenue
- 95% of player spending is through IAP
- Top apps use hybrid (ads + IAP together)

### Monetization Options for GoDig

Based on research, here are ethical monetization approaches ranked by fit:

#### Option A: Premium with Free Demo
- **Price**: $4.99-$7.99 one-time
- **Demo**: Free first layer (0-50m depth), pay to unlock full game
- **Pros**: No ongoing monetization pressure, complete experience
- **Cons**: Smaller audience, harder discovery

#### Option B: Cosmetic Skins
- **Free**: Core gameplay, all ores, all tools
- **Paid**: Character skins, drill skins, trail effects, UI themes
- **Example items**:
  - Robot miner skin pack: $1.99
  - Seasonal event skins (Halloween pickaxe, etc.)
  - Mining trail effects (sparkles, flames)
- **Pros**: Non-gameplay affecting, broad appeal
- **Cons**: Requires ongoing content creation

#### Option C: Ad-Supported with Removal
- **Free**: Full game with opt-in rewarded video ads
  - Watch ad = double ore value for 5 minutes
  - Watch ad = instant surface teleport
- **Paid**: $2.99 ad removal + permanent 2x ore bonus
- **Pros**: Accessible, fair value exchange
- **Cons**: Ads can still feel intrusive

#### Option D: Expansion Packs (Post-Launch)
- **Base Game**: Free or $2.99
- **Expansions**: $1.99-$3.99 each
  - "The Magma Depths" - new layer type + ores
  - "Surface Empire" - building system expansion
- **Pros**: Sustained revenue, content players want
- **Cons**: Requires ongoing development

### Recommendation

For GoDig MVP, start with **Option A (Premium with Demo)** OR **Option C (Ad-Supported + Removal)**:

**If going Premium**:
- Price at $4.99 (lower barrier than $8)
- Free demo with first 50m depth
- All content included
- Consider cosmetics later for sustained revenue

**If going Ad-Supported**:
- NO interstitial ads (too disruptive)
- Rewarded videos only (player chooses)
- Meaningful rewards (not required to progress)
- Fair ad removal price ($2.99-$3.99)

### What to NEVER Do

1. Energy/timer systems ("universally hated")
2. Pay-to-win (faster digging, exclusive ores)
3. Interstitial ads without player control
4. Rigged reward wheels or loot boxes
5. "VIP" tiers that create two classes of players
6. Punishing players for not spending

### Tasks to Create

- [ ] implement: Cosmetic system architecture (if cosmetics chosen)
- [ ] implement: IAP integration (Apple/Google)
- [ ] implement: Rewarded video ad integration (if ad-supported)
- [ ] implement: Demo depth limit with unlock prompt
