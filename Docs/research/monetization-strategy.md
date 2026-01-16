# Monetization Strategy Research

## Revenue Model Options

### 1. Premium (Paid Upfront)

#### Model
- One-time purchase ($2.99 - $6.99)
- Full game access
- No ads, no IAP

#### Pros
- Clean player experience
- No design compromises
- Builds trust/reputation
- Simpler implementation

#### Cons
- Lower total revenue potential
- Harder to acquire users
- No recurring revenue
- Must compete with free games

#### Best For
- Quality-focused games
- Niche audiences
- Building reputation

### 2. Free-to-Play with Ads

#### Model
- Free download
- Interstitial ads between sessions
- Optional rewarded ads for bonuses
- Banner ads during gameplay

#### Pros
- Large user acquisition
- Low barrier to try
- Passive revenue

#### Cons
- Ads interrupt experience
- Lower revenue per user
- Can feel cheap/annoying
- Banner ads hurt UI

#### Best For
- Casual games
- High volume, low engagement

### 3. Free-to-Play with IAP

#### Model
- Free download
- In-app purchases for:
  - Premium currency
  - Cosmetics
  - Convenience items
  - Remove ads

#### Pros
- Large user base
- Whales drive revenue
- Recurring purchases possible

#### Cons
- Risk of pay-to-win perception
- Design must support IAP
- Complex economy balance
- Ethical concerns

#### Best For
- Games with cosmetic depth
- Long-term engagement games

### 4. Hybrid Models

#### Freemium
- Free base game
- Premium unlock ($2.99) removes ads + bonus content

#### Free + Cosmetic IAP
- Free gameplay
- IAP only for cosmetics (skins, effects)
- No gameplay advantage

#### Ad-Supported + IAP Remove Ads
- Free with ads
- Single IAP to remove ads permanently

---

## Recommended Model for GoDig

### Primary: Freemium Hybrid

```
FREE TIER:
- Full gameplay
- Ads between sessions (not during)
- Standard cosmetics
- All content accessible

PREMIUM UNLOCK ($3.99 one-time):
- Remove all ads permanently
- Bonus cosmetic pack
- "Supporter" badge
- Offline progress boost
- No gameplay advantage
```

### Secondary: Cosmetic IAP

```
COSMETIC PACKS ($0.99 - $2.99):
- Miner skins
- Pickaxe skins
- Building themes
- Particle effects
- UI themes
```

### Rationale
1. **No pay-to-win**: Maintains game integrity
2. **Respects players**: Free players can access everything
3. **Sustainable**: Multiple small revenue streams
4. **Ethical**: No dark patterns, no FOMO

---

## Ad Implementation Guidelines

### Types of Ads

#### Interstitial (Between Sessions)
- Show after returning to surface
- Maximum 1 per surface visit
- Skip button after 5 seconds
- Never during active gameplay

#### Rewarded Video (Optional)
- Player chooses to watch
- Clear value exchange:
  - "Watch ad for 2x sell value"
  - "Watch ad for free ladder"
  - "Watch ad to continue (on death)"
- Limit 3-5 per day to prevent abuse

#### Banner Ads (AVOID)
- Hurts UI on mobile
- Low revenue
- Cheapens aesthetic

### Ad Frequency Rules
```gdscript
const MAX_INTERSTITIAL_PER_HOUR = 4
const MAX_REWARDED_PER_DAY = 5
const MIN_TIME_BETWEEN_ADS = 180  # 3 minutes

func should_show_interstitial() -> bool:
    if is_premium_user:
        return false
    if time_since_last_ad < MIN_TIME_BETWEEN_ADS:
        return false
    if interstitials_this_hour >= MAX_INTERSTITIAL_PER_HOUR:
        return false
    return true
```

---

## IAP Catalog Design

### Remove Ads ($3.99)
- Permanent ad removal
- Best value proposition
- One-time purchase

### Starter Pack ($1.99) - First purchase discount
- 1000 coins
- 10 ladders
- Copper pickaxe
- "New Miner" skin
- Only available first 7 days

### Cosmetic Packs ($0.99 - $2.99)
```
MINER SKINS:
- Classic Miner (free)
- Space Suit ($0.99)
- Viking ($0.99)
- Robot ($1.99)
- Dragon Knight ($2.99)

PICKAXE SKINS:
- Standard (free)
- Crystal Pick ($0.99)
- Fire Pick ($0.99)
- Rainbow Pick ($1.99)

BUILDING THEMES:
- Western Town ($1.99)
- Futuristic ($1.99)
- Fantasy Castle ($2.99)
```

### Currency Pack (CAREFUL)
If implementing premium currency:
- Small: 500 gems ($0.99)
- Medium: 1200 gems ($1.99)
- Large: 3000 gems ($4.99)
- Best Value: 7000 gems ($9.99)

**WARNING**: Premium currency can feel predatory. Consider cosmetic-only IAP instead.

---

## What NOT to Sell

### Never Sell
- Pickaxe upgrades (pay-to-win)
- Faster dig speed (pay-to-win)
- More inventory slots (pay-to-win)
- Skip content
- Exclusive ores/resources
- Required progression items

### Why This Matters
- Player trust is paramount
- Bad monetization = negative reviews
- Sustainable games respect players
- Word-of-mouth requires goodwill

---

## Ethical Monetization Principles

### 1. No Dark Patterns
- No fake "limited time" offers
- No artificial scarcity
- No guilt-tripping
- No confusing currencies

### 2. Clear Value
- Players know exactly what they're buying
- No loot boxes / gacha
- No hidden costs

### 3. Full Game Free
- All content accessible without paying
- Paying = convenience/cosmetics only
- No paywalls blocking content

### 4. Respect Time
- No energy systems blocking play
- No "wait or pay" mechanics
- Play as much as you want

---

## Revenue Projections

### Conservative Estimates

| Metric | Value |
|--------|-------|
| Daily Active Users (DAU) | 10,000 |
| Ad Revenue per DAU | $0.01 |
| Monthly Ad Revenue | $3,000 |
| Premium Conversion Rate | 2% |
| Premium Price | $3.99 |
| Monthly Premium Revenue | $800 |
| IAP Conversion Rate | 1% |
| Average IAP | $2.00 |
| Monthly IAP Revenue | $200 |
| **Total Monthly Revenue** | **~$4,000** |

### Growth Targets
- Month 1-3: Build user base, iterate
- Month 3-6: Optimize monetization
- Month 6-12: Scale marketing
- Year 1 target: $50,000 total revenue

---

## Implementation Phases

### MVP (No Monetization)
- Focus on fun gameplay
- No ads, no IAP
- Validate core loop first

### v1.0 (Basic Monetization)
- Interstitial ads (light)
- Remove Ads IAP ($3.99)
- 2-3 cosmetic packs

### v1.1 (Expanded)
- Rewarded video ads
- More cosmetic options
- Starter pack
- Analytics integration

### v2.0 (Mature)
- Season passes?
- Battle pass? (if adding challenges)
- Community features

---

## Questions to Resolve
- [ ] Premium price point ($2.99 vs $3.99 vs $4.99)?
- [ ] Rewarded ads: what bonuses are fair?
- [ ] Premium currency: include or avoid?
- [ ] Regional pricing strategy?
- [ ] Launch promotion discounts?

## Ad Networks to Consider
- Google AdMob (largest)
- Unity Ads (game-focused)
- AppLovin (high eCPM)
- IronSource (mediation)

## Analytics Integration
- Track IAP conversion funnels
- A/B test price points
- Monitor ad frequency impact on retention
- Identify optimal premium nudge timing
