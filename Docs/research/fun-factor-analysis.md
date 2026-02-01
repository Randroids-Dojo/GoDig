# Fun Factor Analysis - Mining Game Core Loop

> Research compilation from game design analysis, forums, and similar games.
> Last updated: 2026-02-01 (Session 22: DRG:RC, Over-Juicing, Push-Your-Luck, Dome Keeper Feedback)

## Core Loop Summary

```
1. DIG DOWN   -> Mine resources, discover ores (dopamine hits)
2. COLLECT    -> Fill inventory (accumulation satisfaction)
3. TENSION    -> Risk of getting stuck, distance from safety
4. RETURN     -> Navigate back to surface (challenge/relief)
5. SELL       -> Exchange resources (reward realization)
6. UPGRADE    -> Buy better tools (power fantasy)
7. REPEAT     -> Go deeper for rarer resources
```

## What Makes Mining Games Fun (Research Findings)

### 1. The Discovery Loop
- **Variable Ratio Reinforcement**: Unpredictable rewards are more engaging than predictable ones
- Each block broken reveals what's underneath - constant micro-discoveries
- "What's behind this block?" creates anticipation
- Rare finds create memorable "jackpot" moments

**Implementation Priority**: Ore distribution should create surprise, not predictable patterns.

### 2. Risk vs Reward Tension
- Deeper = more danger but better rewards
- Players should choose their risk tolerance
- The fear of losing collected resources drives strategic thinking
- Getting "stuck" should feel like a challenge, not a failure

**Key Insight from SteamWorld Dig**: Wall-jumping transformed "stuck" from binary failure to recoverable predicaments. Players who fell into holes initially panicked, then discovered clever escape routes - creating satisfaction through problem-solving.

### 3. Investment Protection
- "I've collected so much, must get back safely"
- Creates natural tension and stakes
- Makes safe return feel like victory
- Full inventory = immediate goal to return

**Design Implication**: Inventory size directly controls session pacing.

### 4. Upgrade Satisfaction
- Slow pickaxe -> fast pickaxe should be FELT
- Visual upgrade differences matter
- Speed improvements are immediately noticeable
- Power fantasy fulfillment

**Dome Keeper Finding**: "This immediately provides visible feedback in the form of faster digging, and passive feedback in that future upgrades come sooner. This kind of tangible feedback feels great."

### 5. Home Base Comfort
- Surface represents safety
- Shops provide upgrade satisfaction
- Contrast makes surface feel rewarding
- Cycle between danger and comfort creates satisfying rhythm

### 6. Session Design
- Target: 5-15 minute sessions with natural stopping points
- Inventory full is most natural break point
- Should happen every 3-8 minutes early game
- "Just fill inventory then stop" mindset

## Critical Early Game Requirements

1. **First upgrade in 2-5 minutes** - Critical retention moment
2. **Starting ladders available** - Teaches mechanic safely
3. **Supply Store at 0m** - Players need escape items before getting stuck
4. **Clear feedback loops** - Every action has visible reaction

## Juice/Game Feel Priorities

| Element | Priority | Impact |
|---------|----------|--------|
| Ore discovery sound/visual | High | Core dopamine trigger |
| Upgrade celebration | High | Milestone moment |
| Screen shake on hard blocks | Medium | Satisfying feedback |
| Combo/streak sounds | Medium | Rhythm building |
| Inventory warnings | High | Creates return tension |
| Depth milestones | Medium | Progress celebration |

## Anti-Patterns to Avoid

1. **Getting truly stuck with no escape** - Always provide recovery options
2. **Dead zones without meaningful upgrades** - Something new every 10-15 min
3. **Loss that erases too much progress** - Death should sting, not devastate
4. **Artificial waiting/timers** - Respect player time
5. **Tedious return trips** - Elevator unlocks help late game

## Variable Reward & Discovery Psychology (Session 2 Research)

### Variable Ratio Reinforcement - Why It Works

From [Number Analytics](https://www.numberanalytics.com/blog/mastering-reward-schedules-game-design) and [PMC Research](https://pmc.ncbi.nlm.nih.gov/articles/PMC7882574/):

- **Anticipation produces dopamine**: Counter-intuitively, dopamine is released during ANTICIPATION, not just reward receipt
- **Uncertainty is compelling**: "Dopamine cells are most active when there is maximum uncertainty"
- **The perfect trifecta**: Games succeed because they provide anticipation + unpredictability + immediate feedback
- **Variable > Fixed**: Unpredictable rewards are more engaging than predictable schedules

### Near-Miss Psychology

From [Psychology of Games](https://www.psychologyofgames.com/2016/09/the-near-miss-effect-and-game-rewards/):

- Near-misses activate the same reward systems as actual wins
- May be MORE motivating than winning or losing
- Design implication: "Engineer more chances to almost win"
- In mining context: blocks near ore veins could shimmer subtly

### Return Trip Tension - Similar Games

**Deep Rock Galactic**:
- "Delightfully tense" extraction phase
- Limited time to return while fighting enemies
- Risk/reward dynamic praised by reviewers

**Dome Keeper**:
- "Mining is meditative, but tension hangs in background"
- "Each wave forces meaningful decisions - do you push your luck and mine deeper, or play it safe?"
- Enemy is time itself, not monsters

### Roguelike "One More Run" Psychology

From [Hearthstone](https://hearthstone-decks.net/one-more-run-the-most-addictive-roguelike-pc-games/):

- "Every failure feels like a lesson, every win feels like a triumph"
- Meta-progression (Rogue Legacy style) reduces sting of death
- "Just one more run" itch from death + immediate retry

## Session 3 Research: Return Trip Tension & Sell Satisfaction

### Extraction Phase Design - Deep Rock Galactic

From [TheSixthAxis](https://www.thesixthaxis.com/2020/05/13/deep-rock-galactic-review-pc-steam-xbox-early-access/) and [Gaming Trend](https://gamingtrend.com/reviews/deep-rock-galactic-review-rock-solid/):

- "Most missions end in a delightfully tense fashion"
- Limited time to return while fighting enemies creates urgency
- "Working against the clock to get back in time feels incredible"
- If you don't prepare escape routes (tunnels, ziplines), you get stranded

**GoDig Application**: The return trip must feel like an achievement, not tedium. Ladders placed earlier become your escape route. Running low on ladders while deep = tension.

### The Dome Keeper Lift Pattern

From [Steam Community](https://steamcommunity.com/sharedfiles/filedetails/?id=2869939597):

- Lift gadget automates part of the return trip
- "As you dig further deep, this gadget becomes all the more useful"
- Secondary function: Movement speed boost toward dome
- "Can cut down time to go from mines to dome exponentially"

**GoDig Application**: Late-game should reduce return tedium. Elevator building serves this purpose. Consider: ladder express lanes (rapid climb upgrade)?

### Sell Screen "Juice" - Currency Animations

From [Game Economist Consulting](https://www.gameeconomistconsulting.com/the-best-currency-animations-of-all-time/):

- Currency animations play thousands of times; benefits compound
- "A well-designed coin animation is genuinely satisfying"
- "Coins flip and spin, reflecting light when they enter balance" (Beatstar)
- Flow must be tight: "Players should hit main menu after receiving gold so connection between reward and balance is tight"

**Critical Insight**: The sell moment is where all mining effort becomes tangible. This must be satisfying or the loop fails.

### Early Game Hook - Onboarding Psychology

From [Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/best-idle-games) and [Felgo](https://blog.felgo.com/mobile-game-development/10-simple-tips-that-will-boost-your-player-retention):

- "First few minutes determine whether user stays or churns"
- Give "easy victory early" to activate sense of accomplishment
- "Generous rewards - even if mostly cosmetic" in first session
- "Positive reinforcement animations (sparkles, sound effects, confetti)"
- "This isn't just dopamine - it's anchoring a positive emotional memory"

**GoDig Application**: First ore discovery needs to feel amazing. First upgrade needs celebration. These moments hook the player.

### Power Fantasy Through Permanent Progression

From [Indiecator](https://indiecator.org/2022/03/30/on-roguelikes-and-progression-systems/) and [Eneba](https://www.eneba.com/hub/games/best-roguelite-games/):

- Rogue Legacy "injected character-building power fantasy into roguelikes"
- "Players get stronger and struggle less - bosses that brought them close to death appear like normal enemies later"
- The appeal: "Not only getting better at playing, but entering with a more capable character"

**GoDig Application**: Pickaxe upgrades must be dramatic. Tier 1 vs Tier 3 should feel like night and day. This is the reward for the grind.

### Inventory as Decision Pressure

From [Number Analytics](https://www.numberanalytics.com/blog/ultimate-guide-inventory-management-game-design):

- "Limiting inventory slots forces decisions about what to keep"
- "Every choice is important" (Darkest Dungeon)
- Resident Evil 4: briefcase system added "puzzle-like mechanic, rewarding players who maximized space"

**GoDig Application**: 8 starting slots is correct. Players must choose: keep 3 coal or drop for 1 gold? This is meaningful decision-making.

### Game Feel / Juice Best Practices (Session 3 Deep Dive)

From [Wayline](https://www.wayline.io/blog/the-perils-of-over-juicing) and [Wardrome](https://wardrome.com/game-feel-the-secret-sauce-behind-addictive-indie-gameplay/):

**Core Techniques**:
- **Screen shake**: Adds impact weight (block break, damage)
- **Particles**: Dust, sparkles, debris give motion feedback
- **Squash/stretch**: Makes characters/UI feel organic
- **Sound variation**: Randomize pitch/volume to avoid repetition

**Critical Warning - Over-Juicing**:
- "Constant visual stimulation leads to sensory overload"
- "Reserve intense effects for special occasions"
- "Responsiveness should always come first" - tight controls > flashy effects
- "Juice can't fix bad design" - core loop must be fun without any juice

**GoDig Application**:
- Mining is CONSTANT - effects must not fatigue players
- Save big celebrations for rare finds (jackpot moments)
- Ensure controls feel tight before adding juice

### Game Feel / Juice Best Practices (Original)

From [GameAnalytics](https://www.gameanalytics.com/blog/squeezing-more-juice-out-of-your-game-design):

- Juicing = taking working game and adding layers of satisfaction
- Shooting games: make player feel powerful (larger bullets, recoil, screen shake)
- Level-up sounds provide "slower-burning feedback on satisfying progress"
- Synchronized audio-visual cues enhance perceived fairness and satisfaction

## Sources

### Session 1-2 Sources
- [Game Design Deep Dive: SteamWorld Dig](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-)
- [Design Dive: Dome Keeper](https://joshanthony.info/2023/05/24/design-dive-dome-keeper/)
- [The Psychology Behind Idle Game Addictiveness](https://artifexterra.com/the-psychology-behind-idle-game-addictiveness/)
- [Risk-Reward Cycles in Modern Game Design](https://playercounter.com/blog/why-risk-reward-cycles-dominate-modern-game-design/)
- [Core Gameplay Loop Design](https://blog.gamedistribution.com/core-gameplay-loop-design-small-tweaks-big-engagement/)
- [Mining in Games Analysis](http://gamedesignreviews.com/scrapbook/mining-in-games/)
- [Number Analytics: Mastering Reward Schedules](https://www.numberanalytics.com/blog/mastering-reward-schedules-game-design)
- [PMC: Loot Boxes and Arousal](https://pmc.ncbi.nlm.nih.gov/articles/PMC7882574/)
- [Psychology of Games: Near Miss Effect](https://www.psychologyofgames.com/2016/09/the-near-miss-effect-and-game-rewards/)
- [Gamedeveloper: Compulsion Loops & Dopamine](https://www.gamedeveloper.com/design/compulsion-loops-dopamine-in-games-and-gamification)

### Session 3 Sources
- [Deep Rock Galactic Review - TheSixthAxis](https://www.thesixthaxis.com/2020/05/13/deep-rock-galactic-review-pc-steam-xbox-early-access/)
- [Deep Rock Galactic Review - Gaming Trend](https://gamingtrend.com/reviews/deep-rock-galactic-review-rock-solid/)
- [Dome Keeper Strategy Guide - Steam](https://steamcommunity.com/sharedfiles/filedetails/?id=2869939597)
- [Best Currency Animations - Game Economist](https://www.gameeconomistconsulting.com/the-best-currency-animations-of-all-time/)
- [Idle Games Player Retention - Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/best-idle-games)
- [Boost Player Retention - Felgo](https://blog.felgo.com/mobile-game-development/10-simple-tips-that-will-boost-your-player-retention)
- [Roguelikes and Progression - Indiecator](https://indiecator.org/2022/03/30/on-roguelikes-and-progression-systems/)
- [Inventory Management Guide - Number Analytics](https://www.numberanalytics.com/blog/ultimate-guide-inventory-management-game-design)
- [Motherload vs SteamWorld - Steam Discussions](https://steamcommunity.com/app/252410/discussions/0/666828126470686482/)

## Implementation Checklist for Fun Factor

### Phase 1: Critical Path (P1)
- [ ] Supply Store unlock at 0m depth
- [ ] 3 starting ladders on new game
- [ ] First upgrade achievable in under 5 minutes
- [ ] Quick-buy ladder button in HUD
- [ ] Basic ore discovery feedback

### Phase 2: Core Polish (P2)
- [ ] Upgrade celebration effects
- [ ] Depth milestone celebrations
- [ ] Inventory tension indicators (60%/80%/100%)
- [ ] Forfeit Cargo escape option
- [ ] Enhanced ore discovery (haptics, sounds)

### Phase 3: Refinement (P3)
- [ ] Mining combo/streak feedback
- [ ] Surface home base comfort signals
- [ ] Risk indicator for deep dives
- [ ] Rare ladder drops from blocks

### Phase 4: Discovery Polish (P4 - New from Session 2)
- [ ] Near-miss ore hints (shimmer on blocks adjacent to veins)
- [ ] Jackpot celebration for rare/legendary finds
- [ ] First-discovery bonus system
- [ ] Cave treasure chests
- [ ] Deep dive tension meter (unified indicator)

### Phase 5: Satisfaction Polish (P5 - New from Session 3)
- [ ] Sell animation with coin arc + rolling counter
- [ ] First ore discovery celebration (sparkles, sound)
- [ ] Pickaxe upgrade "before/after" comparison UI
- [ ] Ladder count warning when low (<3 while deep)
- [ ] "Safe return" celebration when reaching surface with full inventory

## Core Loop Tension Model

```
                    TENSION
                       ^
                       |     *** Full inventory, deep, few ladders
                       |   **
                       |  *
                       | *       Inventory filling
                       |*
        Surface -------|-----------------------> DEPTH
                       |
                       |   Safe with ladders
                       v
                    COMFORT
```

The ideal experience oscillates: comfort at surface, rising tension underground, relief on safe return, satisfaction when selling, empowerment after upgrade, then back down with new confidence.

## Session 4 Research: Core Loop Polish & First 5 Minutes

### The Critical First 5 Minutes

From [Tentuplay](https://blog.tentuplay.io/blog/analyze-first-5-minutes-of-game) and [Google Play Dev](https://medium.com/googleplaydev/why-the-first-ten-minutes-is-crucial-if-you-want-to-keep-players-coming-back-to-your-mobile-game-4a89031b6308):

- **Worst performing games lose 46% of installs by minute 5**
- Top performers only lose 17% by minute 5
- Tutorial should be under 5 minutes
- Give option to skip or fast-forward
- Core loop (action + reward + progression) should complete within 3-5 minutes
- "88% of users return after experiencing a satisfying cycle"

**GoDig Application**: New players must complete dig -> collect -> return -> sell -> see upgrade within first 5 minutes. Starting with 5 ladders + Supply Store at 0m enables this.

### Dome Keeper's Risk-Reward Masterclass

From [Gamedeveloper](https://www.gamedeveloper.com/business/how-dome-keeper-focuses-on-systems-that-feed-into-one-another):

- **"Do you risk digging deeper for that juicy cobalt vein, or hightail it back?"** This is THE core tension
- Carrying capacity affects movement speed - heavier = slower
- Digging larger caves delays enemy waves (incentivizes exploration)
- "Hundreds of micro-decisions" make simple mechanics feel complex
- Systems feed into each other: mining funds upgrades, upgrades fund deeper mining

**GoDig Application**: Consider adding weight-based movement penalty for loaded inventory. Larger excavated areas could provide buffs (light? stability?).

### SteamWorld Dig's Stuck-Avoidance Design

From [Gamedeveloper](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-):

- Original intent: constant risk of getting stuck as main tension source
- Developers SOFTENED this for accessibility
- Anti-frustration: bonus rooms allow infinite deaths with no penalty
- Risk/reward: die = lose half money + loot drops where you died
- "Do you risk your life for that last gem?"

**GoDig Application**: Forfeit Cargo is the right middle-ground between death (too harsh) and reload (feels like cheating). Players lose cargo but keep tools and traversal items.

### Motherload's Addictive Core Loop

From [Playstation Blog](https://blog.playstation.com/2013/11/08/super-motherload-on-ps4-exploring-the-story-and-game-modes/) and [Steam Reviews](https://steamcommunity.com/app/269110/reviews/):

- Four years of concepting and refinement
- Core loop: dig -> collect -> sell -> refuel/repair -> upgrade -> dig deeper
- "Getting money to get more stuff, which you then use to get more money"
- "True fear when low on fuel flying up to the surface"
- Players report 5-hour sessions in one sitting

**GoDig Application**: Fuel mechanic was deliberately excluded (design decision), but the "fear of running low on escape resources" maps directly to ladder count. Low ladder warning is critical.

### Currency Animation Psychology

From [Game Economist](https://www.gameeconomistconsulting.com/the-best-currency-animations-of-all-time/):

- Animations play thousands of times; benefits compound
- "Classically conditioned reward triggers"
- Coins should flip, spin, reflect light
- Counter should roll up like slot machine
- Connection between reward and balance must be tight

**GoDig Application**: Sell screen needs coin arc + rolling counter. Brief pause when coins reach balance (Brawl Stars pattern).

### Idle Game Psychology (Applicable Lessons)

From [Artifex Terra](https://artifexterra.com/the-psychology-behind-idle-game-addictiveness/):

- **Return rewards**: Offline progress makes coming back feel good
- **Loss aversion**: Pain of losing hurts 2x joy of gaining
- **Accumulation desire**: Constantly gaining, minimal loss
- **Fading pendulum problem**: Progression slows until it stops = motivation loss

**GoDig Application**: While not an idle game, GoDig should never punish returning players. Auto-save at good moments. Clear stopping points prevent burnout.

### Game Juice Best Practices (Expanded)

From [Blood Moon Interactive](https://www.bloodmooninteractive.com/articles/juice.html) and [Design Lab Blog](https://thedesignlab.blog/2025/01/06/making-gameplay-irresistibly-satisfying-using-game-juice/):

- **Reserve intense effects for special occasions** - Mining is constant, don't fatigue players
- **Squash/stretch on UI elements** (buttons, counters) makes them feel organic
- **Sound variation**: Randomize pitch/volume to avoid repetition
- **"Juice can't fix bad design"** - Core loop must work without any juice first

**GoDig Application**: Ore discovery and upgrades get full juice treatment. Regular block breaking gets subtle, varied feedback. Test core loop with placeholder audio/visuals first.

## Implementation Priority Refinement (Session 4)

Based on accumulated research, here's the refined priority order for maximum fun factor impact:

### P0 - Absolute First (Enable Core Loop)
1. **Supply Store at 0m** - Must exist before first dive
2. **5 Starting Ladders** - Enables first profitable trip
3. **First Upgrade < 5 Minutes** - Critical retention gate

### P1 - Core Tension (Make Loop Feel Good)
4. **Low Ladder Warning** - Creates "fear of getting stuck"
5. **Forfeit Cargo Option** - Accessible alternative to death
6. **Quick-Buy Ladder Button** - Don't break flow to shop

### P2 - Reward Satisfaction (Sell/Upgrade Moments)
7. **Sell Animation with Coin Arc** - Makes reward tangible
8. **First Ore Discovery Celebration** - Hook the player early
9. **Upgrade Celebration + Comparison** - Show the power fantasy

### P3 - Tension Feedback (Background Awareness)
10. **Deep Dive Tension Meter** - Unified risk indicator
11. **Safe Return Celebration** - Complete the relief arc
12. **Inventory Fill Warnings** - Natural return triggers

### P4 - Discovery Delight (Variable Rewards)
13. **Jackpot Celebration** - Memorable rare finds
14. **Near-Miss Ore Hints** - "Almost found it" feeling
15. **Rare Ladder Drops** - Unexpected help

## Key Insight Summary

| Moment | Emotion Target | Mechanic |
|--------|----------------|----------|
| Start dive | Confidence | 5 ladders + knowledge of shop |
| Find first ore | Excitement | Sound + sparkle + toast |
| Inventory filling | Growing tension | HUD warnings at 60/80/100% |
| Low on ladders | Anxiety (good) | Pulsing warning + heartbeat |
| Surface reached | Relief | "Cargo secured!" celebration |
| Sell resources | Satisfaction | Coin arc + rolling counter |
| Buy upgrade | Empowerment | Before/after comparison + fanfare |
| Start next dive | Renewed confidence | Faster pickaxe = immediately felt |

## Sources (Session 4)

- [Core Loop Design - GameDistribution](https://blog.gamedistribution.com/core-gameplay-loop-design-small-tweaks-big-engagement/)
- [Dome Keeper Systems Design - Gamedeveloper](https://www.gamedeveloper.com/business/how-dome-keeper-focuses-on-systems-that-feed-into-one-another)
- [SteamWorld Dig Deep Dive - Gamedeveloper](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-)
- [First 5 Minutes Analysis - Tentuplay](https://blog.tentuplay.io/blog/analyze-first-5-minutes-of-game)
- [First 10 Minutes - Google Play Dev](https://medium.com/googleplaydev/why-the-first-ten-minutes-is-crucial-if-you-want-to-keep-players-coming-back-to-your-mobile-game-4a89031b6308)
- [Currency Animations - Game Economist](https://www.gameeconomistconsulting.com/the-best-currency-animations-of-all-time/)
- [Idle Game Psychology - Artifex Terra](https://artifexterra.com/the-psychology-behind-idle-game-addictiveness/)
- [Game Juice Guide - Blood Moon Interactive](https://www.bloodmooninteractive.com/articles/juice.html)

## Session 5 Research: Quick Restart & Compulsion Loop Design

### The "Just One More" Psychology

From [GameDeveloper](https://www.gamedeveloper.com/design/compulsion-loop-is-withdrawal-driven) and [Medium](https://medium.com/@luc_chaoui/understanding-game-design-the-psychology-of-addiction-41128565305f):

- **Core loop completable in 30 seconds to 3 minutes** - This range maximizes the "just one more" effect
- **Compulsion is withdrawal-driven** - Game degrades tool efficiency, creating need to restore reward schedule
- **Variable Ratio Reinforcement** - Unpredictable rewards (like loot boxes) are more motivating than fixed rewards
- **"This will be the time it pays off"** mentality keeps players engaged

**GoDig Application**: Each mining trip should complete in 3-8 minutes. Full inventory = natural completion. The variability of ore discovery (not every block has treasure) creates the slot-machine psychology.

### Quick Restart Mechanics (Roguelike Lessons)

From [RetroStyleGames](https://retrostylegames.com/blog/why-are-roguelike-games-so-engaging/) and [GameDeveloper](https://www.gamedeveloper.com/design/death-in-gaming-roguelikes-and-quot-rogue-legacy-quot-):

- **Near-instant restart after failure** - Menus getting in the way antagonizes frustrated players
- **Permadeath creates meaningful stakes** - Every decision significant, victories more satisfying
- **Meta-progression softens the blow** - Rogue Legacy: death is part of narrative AND necessity for progress
- **"Always another chance" feeling** - Each failure is learning experience, success feels valuable

**GoDig Application**:
- After death/forfeit: Instant respawn at surface with shop visible
- After selling: "Quick Dive" button returns to last depth instantly
- After upgrade: Show before/after comparison, immediate urge to test new power

### Dome Keeper's Systems Feeding Each Other

From [Gamedeveloper](https://www.gamedeveloper.com/business/how-dome-keeper-focuses-on-systems-that-feed-into-one-another):

- Mining needed to survive battles, battles constrain mining time
- **"Do you risk digging deeper for that juicy cobalt vein, or hightail it back?"** - THE core tension
- Carrying capacity affects transport efficiency (visible progress)
- Developer: "I wanted real gameplay reason to go mining. The monsters create that pressure."

**GoDig Application**: Our pressure is ladder scarcity + distance from surface. Unlike Dome Keeper's external time pressure (waves), ours is internal resource pressure (ladders). Both create the "push your luck" decision.

### SteamWorld Dig's Accessibility Compromise

From [Gamedeveloper](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-):

- Original intent: Constant risk of getting stuck as MAIN tension source
- Reality: Most players didn't want to play that way
- **Wall-jumping transformed "stuck" from binary to gray zone** - Players use wits to escape
- Sweet spot: Testers fell into holes, sweated, found clever escape, felt awesome
- No mid-air digging for balance reasons (would allow zig-zag upward tunnels)

**GoDig Application**: Wall-jumping is critical for converting "stuck = frustration" into "stuck = challenge". Our wall-jump must be reliable and learnable. Forfeit Cargo is the safety valve for truly stuck situations.

### Mobile Onboarding Critical Metrics

From [Medium/Adrian Crook](https://adriancrook.com/best-practices-for-mobile-game-onboarding/) and [Segwise](https://segwise.ai/blog/boost-mobile-game-retention-strategies):

- **40% session length increase** when players master controls within 5 minutes
- **"Keep it balanced"** - Too long = bored, too short = confused
- **Marvel Snap**: Complex CCG showcased in under 4 minutes
- **Candy Crush**: Immediate rewards (free boosters, easy matches) boost confidence

**GoDig Application**: Tutorial must be under 5 minutes. By minute 5, player should have: mined ore, returned to surface, sold resources, seen upgrade possibility. Starting with 5 ladders enables this.

### Resource Management as Decision Pressure

From [Smoothie Wars](https://www.smoothiewars.com/blog/resource-management-mechanics-guide):

- **Opportunity cost is crucial** - Choosing one option prevents others
- **"I can't do everything" creates tension** - This is where fun lives
- **Good tension**: "I wish I could do both, but I must choose"
- **Bad frustration**: "I can't do anything meaningful; I'm just blocked"
- **Scarcity should feel like "never quite enough"** - Drives decisions

**GoDig Application**: 8 inventory slots + limited ladders = constant decisions. "Do I pick up this coal or save space for gold?" and "Do I place a ladder here or save it for deeper?"

## Session 5 Implementation Insights

### Quick Restart Cycle Design

After player death or forfeit cargo:
1. Instant fade to black (0.5s)
2. Respawn at surface (no loading screen)
3. Shop building visible immediately
4. Notification: "Cargo lost. Ready for another dive?"
5. Player can start digging within 3 seconds

After selling resources:
1. Coin animation plays (satisfying)
2. If upgrade affordable: "New pickaxe available!" prompt
3. "Quick Dive" button appears: returns to last depth marker
4. Player can restart loop within 5 seconds

### The Tension Curve Per Session

```
TENSION
   ^
   |                    * Inventory 100%, deep, 1 ladder
   |                  **
   |                 *    Low ladder warning
   |               *
   |             *   Inventory 60%
   |           *
   |         *
   |       *
   |     *   First ore found (excitement spike)
   |   *
   | *   Start dive (5 ladders = confidence)
---+----------------------------------------> TIME
   |
   |  * Back on surface (relief)
   v
RELIEF
```

### Missing Implementation Specs Identified

1. **Quick Dive Button** - Return to last depth after selling (already spec'd: implement-quick-dive-0cb05828)
2. **Instant Respawn Flow** - No loading screen between death and surface
3. **Upgrade Prompt After Sell** - If player can afford upgrade, nudge them
4. **Controls Mastery in 5 Minutes** - Tutorial timing verification

## Session 6: Player Feedback Analysis

### What Players Love in Mining Games (Community Analysis)

From [Steam Reviews](https://steamcommunity.com/app/1637320/reviews/) and [Dome Keeper Analysis](https://retrostylegames.com/blog/why-dome-keeper-so-good/):

**Compelling Core Loop**:
- "Very replayable game with a compelling gameplay loop"
- "Addicting mix of tower defence and Dig Dug in rogue-lite flavour"
- Players appreciate clear resource -> upgrade -> progress cycle

**Accessible Entry**:
- "Easy to jump into for 20-45 mins"
- "Simple enough to master quickly"
- Works well on mobile (Steam Deck references)

**Strategic Unlocks**:
- "New unlockables keeps this game fresh for a long time"
- Upgrades that "actually affect gameplay, not just make the game easier"
- Variety through unlocked content

### What Players Dislike (Avoid These Mistakes)

**Repetitiveness Concerns**:
- "Way too slow, repetitive, and grindy"
- "Fairly small amount of content"
- Runs feeling "very similar to each other"

**GoDig Mitigation**: Procedural variety, depth milestones with unique events, biome transitions

**Predictable Mining Strategy**:
- "Obvious winning digging strategy removes the joy of exploration"
- "Takes one minute to realize the ideal pattern. And then what?"

**GoDig Mitigation**: Our vertical-only digging is different from Dome Keeper's free-form. The challenge is route planning for return trip, not optimal mining pattern. This is BETTER for variety.

**Interface Inefficiency**:
- "Tediously inefficient input requirements"
- "Excessively slow to acquire or move resources"

**GoDig Mitigation**: Auto-pickup, quick-sell, streamlined HUD. Every action should be ONE tap.

### SteamWorld Dig Player Feedback

From [Steam Discussions](https://steamcommunity.com/app/252410/discussions/0/666828126638941484/):

**What Worked**:
- "Best platforming mechanics not made by Nintendo"
- "Wall-jump mechanic couldn't be easier"
- "Coherence - digging is not a sideshow but the main focus"

**What Players Wanted More**:
- "Expected additional layers like lava layer or underground jungle"
- "More content before credits"
- Deeper exploration depth

**GoDig Opportunity**: Our infinite procedural depth + 7 layers addresses the "wanted more content" feedback directly.

### Key Design Lessons for GoDig

| Player Complaint | Our Solution |
|-----------------|--------------|
| "Too short" | Infinite depth, prestige system |
| "Predictable mining" | Route planning for return trip is the strategy |
| "Repetitive runs" | Depth biomes, layer transitions, treasure chests |
| "Slow interface" | One-tap actions, auto-pickup, quick-sell |
| "No plot progression" | Depth milestones, building unlocks, achievements |

## Sources (Session 5)

- [Compulsion Loop is Withdrawal-Driven - GameDeveloper](https://www.gamedeveloper.com/design/compulsion-loop-is-withdrawal-driven)
- [Psychology of Addiction in Games - Medium](https://medium.com/@luc_chaoui/understanding-game-design-the-psychology-of-addiction-41128565305f)
- [Why Roguelikes Are Addictive - RetroStyleGames](https://retrostylegames.com/blog/why-are-roguelike-games-so-engaging/)
- [Roguelikes and Rogue Legacy - GameDeveloper](https://www.gamedeveloper.com/design/death-in-gaming-roguelikes-and-quot-rogue-legacy-quot-)
- [Dome Keeper Systems Design - Gamedeveloper](https://www.gamedeveloper.com/business/how-dome-keeper-focuses-on-systems-that-feed-into-one-another)
- [SteamWorld Dig Deep Dive - Gamedeveloper](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-)
- [Mobile Onboarding Best Practices - Adrian Crook](https://adriancrook.com/best-practices-for-mobile-game-onboarding/)
- [Boost Mobile Retention - Segwise](https://segwise.ai/blog/boost-mobile-game-retention-strategies)
- [Resource Management Guide - Smoothie Wars](https://www.smoothiewars.com/blog/resource-management-mechanics-guide)
- [Designing for Mastery in Roguelikes - Grid Sage Games](https://www.gridsagegames.com/blog/2025/08/designing-for-mastery-in-roguelikes-w-roguelike-radio/)

## Sources (Session 6)

- [Dome Keeper Steam Reviews](https://steamcommunity.com/app/1637320/reviews/)
- [Why Was Dome Keeper So Good - RetroStyleGames](https://retrostylegames.com/blog/why-dome-keeper-so-good/)
- [SteamWorld Dig vs Terraria Discussion](https://steamcommunity.com/app/252410/discussions/0/666828126638941484/)
- [Dome Keeper Reviews - Steambase](https://steambase.io/games/dome-keeper/reviews)

## Session 7 Research: Push-Your-Luck & Quick Restart Design

### The Motherload Core Loop - Why It's Addictive

From [Meeple Mountain](https://www.meeplemountain.com/reviews/super-motherload/) and [PlayStation Blog](https://blog.playstation.com/2013/11/08/super-motherload-on-ps4-exploring-the-story-and-game-modes/):

- Core feedback loop: dig -> collect -> sell -> refuel/repair -> upgrade -> dig deeper
- "Getting money to get more stuff, which you then use to get more money" - the dopamine loop
- The further you dig, the more difficult to progress - upgradeable mining pod suits play style
- Initially, vehicle can't travel far - must resurface frequently (natural session pacing)
- "Four years of concepting, experimentation, and refinement" - iteration matters

**GoDig Application**: Our ladder system replaces fuel as the limiting resource. Similar tension: can't go far without supplies, must return frequently. Key difference: ladders are reusable infrastructure, fuel is consumed.

### Push-Your-Luck Mechanics from Board Games

From [BoardGameGeek](https://boardgamegeek.com/boardgamemechanic/2661/push-your-luck) and [Board Game Design Course](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/):

- **Definition**: Decide between settling for existing gains OR risking them for further rewards
- **Distinct from pure luck**: Push-your-luck gives players meaningful CHOICES
- "The thrill of potentially enormous success, and the devastation of losing it all"
- **Can't Stop** (Sid Sackson): Simple mechanics, feels like gambling
- **Zombie Dice**: "3 strikes and you're out" - clear bust threshold
- **Quacks of Quedlinburg**: Bag-building with white chips = bust risk

**Self-Balancing Insight** (Incan Gold): Deck reshuffles each round - fewer players staying in = greater potential reward. Risk naturally increases as rewards do.

**GoDig Application**: Our inventory fill + depth creates the push-your-luck pressure. At 80% inventory, player weighs: "One more vein?" vs "Lose all this if I die." Ladders are the escape hatch that makes the gamble feel fair.

### Quick Restart - Roguelike Best Practices

From [PCGamesN](https://www.pcgamesn.com/best-roguelike-games) and [RetroStyleGames](https://retrostylegames.com/blog/why-are-roguelike-games-so-engaging/):

- "Just one more turn. Next time, I'll get it right."
- **Dead Cells** pattern: Carry certain upgrades across runs - progress doesn't fully reset
- **Rogue Legacy 2**: Death spawns as heir - family manor progression
- Key principle: "Getting to know characters a bit more after every run makes death less disheartening"
- Procedural generation = fresh experiences, no repetitive replays

**Critical Design Point**: Death should feel like an opportunity, not punishment. The faster players can restart, the more likely they try again.

### Compulsion Loop Psychology

From [GameDeveloper](https://www.gamedeveloper.com/design/compulsion-loops-dopamine-in-games-and-gamification) and [Superscale](https://superscale.com/resources/what-is-a-core-loop/):

- **Dopamine during anticipation**: Counter-intuitively, dopamine is released BEFORE reward
- Core loop simplified: PLAY -> GET resources -> UPGRADE -> repeat
- Mobile games use multiple interlocking loops (Clash Royale example)
- "Increase difficulty gradually, allow player to 'fix' it with progression systems"

**GoDig Application**: Our core loop is tight (3-8 minutes). Upgrades "fix" the difficulty. The anticipation of "what ore is behind this block?" triggers dopamine before discovery.

### Tension and Release Cycle

From [GameDeveloper](https://www.gamedeveloper.com/design/addressing-conflict-tension-and-release-in-games):

- "Right amount of peril = fear combined with knowledge of safety"
- Players enjoy scary places AS LONG AS they feel secure
- Perfect balance: player confidence in mechanics + underlying anxiety
- **Half-Life 2 Antlions**: Struggle against foes, then gain control of them = emotional release
- **Oblivion's Opening**: Dank prison -> vast colorful landscape = environmental release

**GoDig Application**: Underground is tension (darkness, limited resources, distance from safety). Surface is release (bright, shops, HP regen). The contrast makes both feel meaningful.

### Mobile Retention Critical Insights

From [Segwise](https://segwise.ai/blog/boost-mobile-game-retention-strategies) and [Felgo](https://blog.felgo.com/mobile-game-development/10-simple-tips-that-will-boost-your-player-retention):

- Keep tutorials under 5 minutes, with skip option
- 70% challenge / 30% reward ratio prevents frustration
- Players who master controls in 5 minutes: +40% session length
- **Candy Crush pattern**: Immediate rewards (free boosters) build confidence
- Marvel Snap: Complex CCG showcased in under 4 minutes

**GoDig Application**: First complete loop (dig -> sell -> see upgrade) must happen in under 5 minutes. Starting with 5 ladders + Supply Store at 0m enables this.

## Implementation Priority Update (Session 7)

### Critical Path for Fun (Must-Have for Launch)

| Priority | Feature | Impact |
|----------|---------|--------|
| P0 | Supply Store at 0m | Enables core loop |
| P0 | 5 Starting Ladders | Enables safe first trip |
| P0 | First upgrade < 5 min | Retention gate |
| P1 | Low ladder warning | Creates tension |
| P1 | Forfeit Cargo option | Recovery without full loss |
| P1 | One-tap ladder placement | Reduces friction |
| P1 | Instant respawn | Quick restart flow |
| P1 | Quick-buy ladder from HUD | Seamless economy |

### High-Value Polish (Should-Have)

| Priority | Feature | Impact |
|----------|---------|--------|
| P2 | Sell animation with coins | Reward satisfaction |
| P2 | First ore celebration | Hook moment |
| P2 | Upgrade power feel | Power fantasy |
| P2 | Safe return celebration | Tension release |
| P2 | Close-call recognition | Near-miss excitement |

### Nice-to-Have (v1.1+)

| Priority | Feature | Impact |
|----------|---------|--------|
| P3 | Mining combo/streak | Flow state |
| P3 | Surface comfort signals | Contrast building |
| P3 | Near-miss ore hints | Variable reward |
| P3 | Depth record tracking | Personal goals |

## Sources (Session 7)

- [Super Motherload Review - Meeple Mountain](https://www.meeplemountain.com/reviews/super-motherload/)
- [Super Motherload on PS4 - PlayStation Blog](https://blog.playstation.com/2013/11/08/super-motherload-on-ps4-exploring-the-story-and-game-modes/)
- [Push Your Luck Mechanic - BoardGameGeek](https://boardgamegeek.com/boardgamemechanic/2661/push-your-luck)
- [Push Your Luck Games - Board Game Design Course](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/)
- [Best Roguelike Games - PCGamesN](https://www.pcgamesn.com/best-roguelike-games)
- [Why Roguelikes Are Engaging - RetroStyleGames](https://retrostylegames.com/blog/why-are-roguelikes-so-engaging/)
- [Compulsion Loops - GameDeveloper](https://www.gamedeveloper.com/design/compulsion-loops-dopamine-in-games-and-gamification)
- [What is a Core Loop - Superscale](https://superscale.com/resources/what-is-a-core-loop/)
- [Tension and Release - GameDeveloper](https://www.gamedeveloper.com/design/addressing-conflict-tension-and-release-in-games)
- [Mobile Game Retention - Segwise](https://segwise.ai/blog/boost-mobile-game-retention-strategies)
- [Player Retention Tips - Felgo](https://blog.felgo.com/mobile-game-development/10-simple-tips-that-will-boost-your-player-retention)
- [Dome Keeper Reviews - TheXboxHub](https://www.thexboxhub.com/dome-keeper-review/)

## Session 8 Research: Ladder Economy & Risk-Reward Decision Timing

### The "Venture Deeper or Return" Decision

From [Playercounter](https://playercounter.com/blog/why-risk-reward-cycles-dominate-modern-game-design/) and [Game Wisdom](https://game-wisdom.com/general/games-retain-players-using-risk-reward):

- "Do we venture deeper or return to safety?" - THE core question our game must pose
- This decision triggers "anticipation, tension, and satisfaction" - the emotional trifecta
- **Balance is critical**: If odds of success are too low or penalties too high, players abandon
- **Player perception of fairness matters**: Outcomes must feel justified, not arbitrary
- **Timing is everything**: Skilled players reduce exposure to bad outcomes while maximizing gains

### Ladder as "Risk Budget"

Our ladder system creates a unique risk-reward dynamic:
- **Each ladder placed is a sunk cost**: Can't get it back
- **But each ladder also reduces future risk**: Creates escape route
- **Decision point every ~5-10 blocks**: "Do I place one here or save it?"
- **Key insight**: Unlike fuel (Motherload) which depletes passively, ladders require ACTIVE decisions

This is BETTER than fuel because:
1. Player feels agency in every ladder placement
2. Ladders are visible infrastructure - player sees their safety net
3. Creates "I made this escape route" ownership feeling
4. Reusable (can climb back down) unlike consumed fuel

### SteamWorld Dig Core Loop Excellence

From [Medium Review](https://medium.com/@KlaraMelinaca/steam-world-dig-review-3558033741b8) and [Gold-Plated Games](https://goldplatedgames.com/2022/06/03/review-steamworld-dig/):

- Core: "mine down, return topside, sell, upgrade" - identical to ours
- "Right amount of simple" - complexity in route decisions, not mechanics
- **Perfect length**: 3-4 hours before formula wears welcome - pacing matters
- "Best platforming mechanics not made by Nintendo" - wall-jump must feel AMAZING
- Drilling powerup "cuts digging to a fraction of time" - upgrades must be dramatic

### Dome Keeper 2024-2025 Player Feedback

From [Indiecator Review](https://indiecator.org/2024/11/29/indietail-dome-keeper/):

- Hit 1 million players - validates the mining + resource management loop
- **What players love**: "Terrific sci-fi aesthetic, satisfying risk-reward system"
- **What players hate**: "Too slow, repetitive, grindy" and "back and forth tedium"

**GoDig Mitigation for Tedium**:
- Quick-buy ladder button (no shop visit needed)
- Future: Elevator for express return
- Procedural variety prevents pattern recognition

### Mobile Onboarding Critical Window

From [Plotline](https://www.plotline.so/blog/boost-player-retention-in-mobile-games) and [Medium](https://medium.com/@amol346bhalerao/mobile-game-onboarding-top-ux-strategies-that-boost-retention-6ef266f433cb):

- "First few minutes often determine whether player continues or uninstalls"
- **Poor onboarding = major Day 1 retention killer**
- Onboarding must create "first win" ensuring players feel rewarded
- Too long = bored, too short = confused
- **5 minutes max** for tutorial, with skip option
- Core loop (action -> reward -> progression) should complete in 3-5 minutes

### Push-Your-Luck Board Game Insights

From [Board Game Design Course](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/) and [Game Ideas](https://www.gameideas.net/push-your-luck):

- **Distinct from pure luck**: Push-your-luck gives players meaningful CHOICES
- **Incan Gold**: Self-balancing - fewer players staying in = greater potential reward
- **Zombie Dice**: "3 strikes and you're out" - clear bust threshold
- **Deep Sea Adventure**: Shared oxygen supply - interesting twist where greed affects all players

**GoDig Application**: Our "bust threshold" is running out of ladders while deep. Unlike sudden bust, it's a slow, insidious pressure like Deep Sea Adventure - you feel it building.

### Implementation Priority Refinement (Session 8)

Based on accumulated research, the CRITICAL PATH for fun factor:

#### P0 - Core Loop Enablers (BLOCKING)
These features MUST exist for the game to function:

| Feature | Status | Blocker For |
|---------|--------|-------------|
| Supply Store at 0m | Spec exists | First ladder purchase |
| 5 Starting Ladders | Spec exists | Profitable first trip |
| First upgrade < 5 min | Need economy tuning | Retention gate |

#### P1 - Core Tension Mechanics
These features create the risk-reward feeling:

| Feature | Impact | Notes |
|---------|--------|-------|
| Low ladder warning | Creates anxiety | Visual + audio cue |
| Forfeit Cargo option | Accessible recovery | Middle-ground between death and reload |
| One-tap ladder placement | Reduces friction | Touch-friendly action |
| Instant respawn | Quick restart | Under 3 seconds death-to-dig |
| Quick-buy ladder | Seamless economy | Don't break flow |

#### P2 - Reward Satisfaction
These features make rewards feel good:

| Feature | Impact | Notes |
|---------|--------|-------|
| First ore celebration | Hook moment | Extra sparkles, special sound |
| Sell animation (coin arc) | Tangible reward | Rolling counter, satisfying |
| Upgrade comparison UI | Power fantasy | Before/after numbers |
| Safe return celebration | Relief arc | "Cargo secured!" |

### Missing Spec Identified: Upgrade Economy Tuning

Research reveals first upgrade timing is CRITICAL for retention. Currently no spec addresses the actual NUMBERS for:
- Starting coins (0?)
- Ore sell values in first 50m
- Copper Pickaxe cost (currently 500)
- Expected time to first upgrade

**Need new spec**: Economy balance pass for first 5 minutes.

## Sources (Session 8)

- [Risk-Reward Cycles Dominate Game Design - Playercounter](https://playercounter.com/blog/why-risk-reward-cycles-dominate-modern-game-design/)
- [Risk and Reward Shape Game Strategies - Minifiniti](https://minifiniti.com/blogs/game-talk/how-risk-and-reward-shape-game-strategies)
- [Games Retain Players Using Risk Reward - Game Wisdom](https://game-wisdom.com/general/games-retain-players-using-risk-reward)
- [SteamWorld Dig Review - Medium](https://medium.com/@KlaraMelinaca/steam-world-dig-review-3558033741b8)
- [Review SteamWorld Dig - Gold Plated Games](https://goldplatedgames.com/2022/06/03/review-steamworld-dig/)
- [Indietail Dome Keeper 2024 - Indiecator](https://indiecator.org/2024/11/29/indietail-dome-keeper/)
- [Mobile Game Onboarding UX - Medium](https://medium.com/@amol346bhalerao/mobile-game-onboarding-top-ux-strategies-that-boost-retention-6ef266f433cb)
- [Boost Player Retention - Plotline](https://www.plotline.so/blog/boost-player-retention-in-mobile-games)
- [Push Your Luck - Game Ideas](https://www.gameideas.net/push-your-luck)
- [Ladder Mechanics in Games - Pav Creations](https://pavcreations.com/climbing-ladders-mechanic-in-unity-2d-platformer-games/)
- [Video Games vs Ladders Analysis - Parry Everything](https://parryeverything.com/2023/01/31/video-games-vs-ladders/)

## Session 8 Continued: Mr. Mine and Idle Mining Analysis

### What Makes Mr. Mine Addictive

From [Mr. Mine Blog](https://blog.mrmine.com/what-are-idle-mining-games-and-why-are-they-soaddictive/) and [Genre Analysis](https://blog.mrmine.com/mining-game-spotlight-mr-mine-and-the-reinvention-of-the-idle-genre/):

**The "Click, Earn, Boost" Loop**:
- Initial active engagement (clicking/digging)
- Automation tools that accumulate resources passively
- Upgrades that boost production dramatically
- Creates satisfying optimization gameplay

**Depth-Based Surprises**:
- Mr. Mine ties major features to specific depth milestones
- "Surprises trigger at specific depths" - caves, rare minerals, creatures
- Unlike games that just "increase numbers," new CONTENT unlocks
- Each layer adds NEW mechanics, not just harder versions

**Fast Satisfaction Curve**:
- "Feels satisfying right away within minutes"
- "You don't need to wait long to see results"
- This fast start keeps new players interested
- Matches our 5-minute first upgrade target

### Hybrid Active/Passive Design

Mr. Mine's key differentiator:
- Can actively click to speed up mining
- Can also automate and walk away
- "Does both" - appeals to different play styles

**GoDig Application**:
- Core: Active mining (not idle)
- Future (v1.1+): Automation buildings for passive income
- Current: Offline earnings already implemented (1 coin/min)

### Idle Miner Tycoon's Progression Design

From [Mr. Mine Comparison](https://blog.mrmine.com/idle-miner-tycoon-vs-mr-mine/):

- 5 mines per continent, 8 continents total = 40 progression goals
- "Unlocking new levels step by step brings satisfaction"
- Encourages effort to see business grow gradually

**GoDig Application**: Our 7 layers + biome variations provides similar progression structure. Each layer should feel like a new "continent" with unique challenges.

### Key Insight: Depth Milestones as Content Gates

Mr. Mine succeeds because depth isn't just a number - it's a **content unlock system**:
- 100m: First cave system
- 250m: New enemy type
- 500m: Special ore unlocks
- etc.

**GoDig Implementation Gap**: We have layer transitions, but need more "surprise" moments between layers. Consider:
- Hidden treasure chests at random depths
- First encounter with new ore type = celebration
- Cave discovery = mini-event
- Depth records = personal achievement

### Sources (Session 8 Continued)

- [What Are Idle Mining Games and Why Are They Addictive - Mr. Mine](https://blog.mrmine.com/what-are-idle-mining-games-and-why-are-they-soaddictive/)
- [Mr. Mine Genre Reinvention - Mr. Mine](https://blog.mrmine.com/mining-game-spotlight-mr-mine-and-the-reinvention-of-the-idle-genre/)
- [Top Idle Mining Games 2026 - Mr. Mine](https://blog.mrmine.com/top-idle-mining-clicker-games-to-play-in-2025/)
- [Idle Miner Tycoon vs Mr. Mine - Mr. Mine](https://blog.mrmine.com/idle-miner-tycoon-vs-mr-mine/)

## Session 9 Research: Spelunky Risk Design & Mobile Onboarding Excellence

### Spelunky's Information-Based Decision Making

From [Gamedeveloper Spelunky Analysis](https://www.gamedeveloper.com/design/a-spelunky-game-design-analysis---pt-2) and [Fairness, Discovery & Spelunky](https://www.gamedeveloper.com/design/fairness-discovery-spelunky):

**The Core Insight**: "Spelunky looks like a game of execution, but it's really a game about information and decision-making. How good are you at looking at a situation and understanding what it means?"

**Risk-Based Micro-Decisions**:
- Do I deliberately trigger the dart trap below me in advance?
- Do I throw the urn against the wall, risking a monster breaking out?
- Do I wait for one more cycle of enemy movement or act now?
- Every decision is subject to constant time pressure

**Risk Management vs. Execution**: Risk management is what separates Spelunky from Super Mario Bros. Once you beat a Mario game, you can do so any time without much trouble. But Spelunky is never truly beaten.

**Player Decision Framework**: Players can blitz towards the finish (minimizing death risk but missing upgrades) OR explore thoroughly (better tools but more danger). Players can even attack shopkeepers - is it worth angering NPCs that can kill you for a good item?

**GoDig Application**: Our ladder placement is similar - do you place one here (using a resource) or save it (risking being stuck)? Unlike Spelunky's time pressure, ours is resource pressure. Both create meaningful decisions.

### The "One More Run" Psychology Deep Dive

From [Hearthstone Guest Post](https://hearthstone-decks.net/one-more-run-the-most-addictive-roguelike-pc-games/) and [Pocket-lint Analysis](https://www.pocket-lint.com/roguelike-games/):

**Why Players Restart Immediately**:
- You fight tooth and nail for survival
- Make it just a little further than last time
- Lose it all in a single misstep
- Hit "retry" immediately
- This endless loop of defeat and determination is addictive

**The Growth Thrill**: The thrill isn't just about survival - it's about growth. Every run teaches you something new - enemy patterns, loot strategies, best times to risk everything.

**Meta-Progression is Critical**: Rogue Legacy established the winning formula - invest gold into upgrades, unlock new characters, gain new buffs. Prior to this, most roguelikes had nothing carry over.

**GoDig Application**:
- Our meta-progression: pickaxe upgrades, building unlocks, equipment
- Death loses some resources but NEVER tools or buildings
- Every run should teach the player about efficient ladder placement
- Quick restart is essential - no loading screens between death and surface

### Push-Your-Luck as Board Game Design Philosophy

From [BoardGameGeek](https://boardgamegeek.com/boardgamemechanic/2661/push-your-luck) and [Board Game Design Course](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/):

**Definition**: Players decide between settling for existing gains OR risking them for further rewards. Distinct from pure luck because it gives players meaningful CHOICES.

**Emotional Appeal**: "The thrill of potentially enormous success, and the devastation of losing it all."

**Self-Balancing Mechanism (Incan Gold)**: Fewer players staying in = greater potential reward. Risk naturally increases as rewards do.

**Mathematical Balancing**: If targeting 50% bust rate across a whole game with 3 push-your-luck moments, each moment needs ~80% success rate. The cumulative bust risk creates tension.

**GoDig Application**:
- Our "bust" = running out of ladders while deep
- Unlike sudden bust (card draw), ours is gradual (ladder count depleting)
- This is BETTER for tension - you feel it building like Deep Sea Adventure
- Self-balancing: deeper = better ore but more ladders needed

### Mobile Onboarding Excellence (2025 Best Practices)

From [Adrian Crook](https://adriancrook.com/best-practices-for-mobile-game-onboarding/) and [Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/mobile-game-tutorial):

**Progressive Onboarding Framework**:
1. Launch & Instant Play - Game opens directly into first action
2. Core Control Tutorial - Teach one mechanic in under 10 seconds
3. Quick Win & Reward - Give players an easy victory
4. Story Hook - Show glimpse of game's world
5. Second Mechanic Introduction - Add complexity gradually

**The One-Minute Rule**: In mobile gaming, you often have less than a minute to win a player's heart. Onboarding is your best opportunity.

**Successful Examples**:
- **Clash Royale**: Five short tutorials, each introducing new elements building on previous
- **Candy Crush**: Tutorial levels that ARE fun gameplay, early wins, colorful feedback
- **Pokemon GO**: Integrates tutorial into actual gameplay with immediate objectives

**Critical Mistake - Forcing Monetization**: Never ask for purchases before players feel invested. This kills retention.

**GoDig Application**:
- Frame 1: Player on surface, shop visible, "Tap to dig"
- First ore in under 30 seconds
- First sell transaction by minute 2
- First upgrade offer by minute 4
- NO monetization until after first upgrade

### Dome Keeper 2025-2026 Update Analysis

From [Steam Community](https://steamcommunity.com/app/1637320/allnews/) and [Dome Keeper Wiki](https://domekeeper.wiki.gg/wiki/Version_History):

**What's Working (1M+ Players)**:
- "Terrific sci-fi aesthetic, satisfying risk-reward system"
- New dome types (Artillery, Tesla) add strategic variety
- Dome Supplements system allows customization

**What's Being Fixed**:
- Multiplayer mode in development (competing teams, shared mine)
- Quality-of-life improvements from community feedback
- Drilling difficulty being rebalanced

**Community Complaints Being Addressed**:
- "Randomness of gadgets impacts runs too much" - Adding guaranteed category options
- "Drilling feels unnecessarily hard" - Rebalancing

**GoDig Learning**: Even successful games need ongoing balancing. Plan for post-launch economy tuning based on player feedback.

### Terraria Underground Exploration Lessons

From [Carl's Guides](https://www.carlsguides.com/terraria/walkthrough/exploring-underground-caverns.php) and [Terraria Wiki](https://terraria.wiki.gg/wiki/Guide:Mining_techniques):

**Cave System Design**: "Why dig holes yourself when nature has dug them for you?" Finding cave systems and following them is recommended.

**Lighting as Progress Marker**: Lighting explored areas helps return later AND allows players to see ore behind walls.

**Hellevator Pattern**: A vertical shaft to deep areas becomes essential infrastructure. Once created, reveals many new areas.

**GoDig Application**:
- Our ladder columns serve as "hellevators" - player-built infrastructure
- Consider: shimmer effect on blocks adjacent to ore (like Spelunker Potion)
- Cave systems could have pre-placed ladders or shortcuts

### Idle Game Dopamine Loop Mechanics

From [GameDeveloper](https://www.gamedeveloper.com/design/compulsion-loops-dopamine-in-games-and-gamification) and [Gamers Heart](https://videogameheart.com/the-dopamine-loop-how-game-design-keeps-players-hooked/):

**The Three-Part Cycle**:
1. Anticipation of reward (dopamine created)
2. Activity to earn reward
3. Obtaining reward (dopamine released)

**Key Finding**: Dopamine is created during ANTICIPATION, not just receipt. The uncertainty is what drives engagement.

**Variable Ratio Reinforcement**: Loot boxes work because unpredictable rewards cause higher dopamine production than fixed rewards.

**GoDig Application**:
- Each block broken is a micro-anticipation moment
- Ore distribution should be unpredictable enough to maintain anticipation
- Near-miss mechanics (shimmer on adjacent blocks) extend anticipation phase

### New Implementation Priorities Identified (Session 9)

Based on this research, the following gaps need implementation specs:

| Gap | Priority | Impact |
|-----|----------|--------|
| Tutorial teaches one mechanic at a time | P0 | Retention gate |
| First ore in under 30 seconds | P0 | Early hook |
| No monetization until after first upgrade | P0 | Trust building |
| Shimmer on blocks adjacent to ore | P2 | Anticipation extension |
| Pre-placed ladders in early caves | P2 | Teaches mechanic safely |
| Quick restart after death (under 3 sec) | P1 | "One more run" psychology |

### Sources (Session 9)

- [Spelunky Game Design Analysis - Gamedeveloper](https://www.gamedeveloper.com/design/a-spelunky-game-design-analysis---pt-2)
- [Fairness, Discovery & Spelunky - Gamedeveloper](https://www.gamedeveloper.com/design/fairness-discovery-spelunky)
- [One More Run Roguelikes - Hearthstone](https://hearthstone-decks.net/one-more-run-the-most-addictive-roguelike-pc-games/)
- [Addictive Roguelike Games - Pocket-lint](https://www.pocket-lint.com/roguelike-games/)
- [Push Your Luck Mechanic - BoardGameGeek](https://boardgamegeek.com/boardgamemechanic/2661/push-your-luck)
- [Push Your Luck Design - Board Game Design Course](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/)
- [Mobile Game Onboarding - Adrian Crook](https://adriancrook.com/best-practices-for-mobile-game-onboarding/)
- [Mobile Game Tutorial Design - Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/mobile-game-tutorial)
- [Dome Keeper Updates - Steam Community](https://steamcommunity.com/app/1637320/allnews/)
- [Terraria Mining Guide - Carl's Guides](https://www.carlsguides.com/terraria/walkthrough/exploring-underground-caverns.php)
- [Compulsion Loops & Dopamine - Gamedeveloper](https://www.gamedeveloper.com/design/compulsion-loops-dopamine-in-games-and-gamification)

## Session 10 Research: Balatro, Haptics, One-Hand Controls, Hades 2

### Balatro's Variable Reward System (GDCA 2025 Game of the Year)

From [Cubix](https://www.cubix.co/blog/balatro-card-game-a-blueprint-for-indie-success/) and [Oreate AI](https://www.oreateai.com/blog/the-allure-of-balatro-why-this-minimalist-game-captivates-players/):

**Why It Works**:
- Exponential growth through multipliers: "making numbers go up" satisfaction
- Variable ratio reinforcement: uncertainty keeps players engaged
- "You cannot pay to win here. You have to learn how to use the chaos, manipulate it, and eventually master it."
- Meta-progression: even failures yield permanent rewards (coins for unlocks)
- Sold 5M+ copies by January 2025

**Randomness + Player Agency Balance**:
- Shops rotate unpredictably, Jokers appear without warning
- Many runs collapse through no fault of the player
- BUT: "The game never removes randomness, but it allows you to shape it—to stabilize the chaos"
- Randomness becomes strategy, not barrier

**GoDig Application**:
- Each block mined is a micro-uncertainty moment (like card draw)
- Ore discovery parallels finding the right Joker
- Players can't control ore placement but CAN control route planning
- Our ladder system gives agency over randomness

### Cozy Mining Games & Casual Market Trends (2025)

From [Plarium](https://plarium.com/en/blog/best-cozy-games/), [GameRant](https://gamerant.com/best-relaxing-mining-games/), and [The Cozy Gaming Nook](https://thecozygamingnook.com/mining-games/):

**Market Size**:
- Casual games: $24.2 billion in 2025
- 31% of global downloads (over 31 billion)
- 1.3 billion monthly players
- 45+ demographic (21%) is fastest growing - drawn to cozy simulations

**Successful Cozy Mining Examples**:
- **Forager**: "Simple controls and a fast-paced loop that makes mining feel like a satisfying part of a bigger cozy puzzle. Perfect for short, sweet play sessions packed with progress."
- **Dinkum**: Blends cozy farming with chill mining
- **My Time at Portia**: Mining as material gathering for building/bonding

**Key Design Pattern**:
- Mining as relaxation, not just extraction
- 70% likelihood upcoming mining games will blend mining + management
- Pacing matters: progress should feel constant, not grindy

**GoDig Application**:
- Our active mining differentiates from idle games
- Surface visits should feel like "cozy home base" relief
- Consider adding more management depth (building upgrades) for cozy appeal

### Haptic Feedback Best Practices (iOS/Android)

From [Interhaptics](https://interhaptics.medium.com/enhance-player-immersion-with-haptics-for-ios-and-android-games-using-interhaptics-for-mobile-d01b2f160543), [Saropa](https://saropa-contacts.medium.com/2025-guide-to-haptics-enhancing-mobile-ux-with-tactile-feedback-676dd5937774), and [XDA Developers (Marvel Snap)](https://www.xda-developers.com/marvel-snap-mobile-game-haptics/):

**Platform Reality**:
- iOS significantly outperforms Android for haptic quality/control
- Separate development often required for each platform
- "Users will have a much more satisfying experience on iPhones"

**Marvel Snap Example**:
- "Thunderous boom when a card slammed down"
- "Feel a blade slicing through a card to eliminate it"
- "Feel the weight of each move and how there's purpose behind it"
- Vibrations created for "distinct and memorable interactions"

**Best Practices**:
- Reserve custom haptic patterns for high-value scenarios (not every action)
- Transient events (taps) for quick feedback, continuous events (textures) for sustained actions
- Haptics must sync precisely with visuals - even small delays feel unnatural
- Don't use haptics in isolation - integrate with what user sees and hears

**GoDig Implementation Plan**:
| Event | Haptic Type | Intensity |
|-------|-------------|-----------|
| Ore discovery | Transient burst | Medium-high |
| Upgrade purchase | Continuous rumble (0.3s) | High |
| Ladder placement | Subtle tap | Low |
| Block break | Light tap | Very low (varies) |
| Danger warning | Pulse pattern | Medium |

### One-Hand Mobile Controls (UX Research)

From [Mobile Free To Play](https://mobilefreetoplay.com/control-mechanics/), [Smashing Magazine](https://www.smashingmagazine.com/2020/02/design-mobile-apps-one-hand-usage/), and [Punchev](https://punchev.com/blog/designing-for-mobile-ux-considerations-for-mobile-game-development):

**Usage Statistics**:
- 49-75% of smartphone users operate phones one-handed
- Majority use thumb to navigate and interact
- 59% will disengage if controls are physically uncomfortable

**The "Subway Thumb" Grip**:
- Most casual of all orientations
- Player holds phone in one hand, uses only that thumb
- Common when walking or holding subway rail
- Game must be playable in this mode

**Screen Zone Design**:
- Green zone (easy): Bottom corners, within thumb arc
- Yellow zone (manageable): Middle areas
- Red zone (hard): Top corners, opposite side from thumb
- Zones flip horizontally for left-handed users

**Research Findings**:
- One-handed gesture interface more effective and satisfying
- Full-page menus should be flyout menus from bottom
- Simple layouts for one-handed play improve usability without sacrificing depth

**GoDig Application**:
- Dig controls (tap-based) already work one-handed
- HUD elements must be in green/yellow zones
- Quick-buy ladder button: bottom-right corner
- Inventory/shop access: bottom of screen
- Avoid critical buttons in top corners

### Hades 2 Progression Pacing (Metacritic 94/100)

From [GameRant](https://gamerant.com/hades-2-1-0-release-best-route-underworld-why/), [The Flagship Eclipse](https://www.theflagshipeclipse.com/2025/09/25/4-biggest-changes-hades-2s-1-0-launch-makes-to-the-early-access-version-how-its-so-much-better/), and [Supergiant](https://www.supergiantgames.com/blog/hades-ii-development-update/):

**Early Access Strategy**:
- Released when "far enough along that player feedback wouldn't mostly consist of stuff they already knew wasn't there yet, but wasn't so far along that it was too late to act on feedback"
- 2M+ copies sold in Early Access alone

**Balance Iteration**:
- "Satisfying progression curve where boons should make players feel strong enough but not too overpowered"
- Several boons replaced, others rebalanced
- "Rare and Epic boons feel even more special now than they did in Early Access"
- Combat feels challenging but boon impact is felt

**Addressing Staleness**:
- After a few dozen runs, areas became "a bit too easy"
- Solution: New, tougher foes spawn in completed areas
- Keeps skills sharp, maintains challenge

**Player Feedback Response**:
- Ending reworked after examining player reactions
- "Some fans felt the story's original ending didn't land as intended"
- Community feedback integral to development

**GoDig Lesson**:
- Plan for post-launch economy tuning
- Start with generous progression, tighten later if needed
- Monitor for "staleness" in early areas
- Consider difficulty scaling after mastery

### Idle Game Monetization Patterns (2025)

From [Gamigion](https://www.gamigion.com/idle/), [ContextSDK](https://contextsdk.com/blogposts/monetization-trends-in-mobile-gaming-whats-shaping-2025), and [Adjoe](https://adjoe.io/glossary/idle-games-mobile/):

**Revenue Split**:
- In-app advertising: 60-70% of idle game revenue
- Rewarded videos most effective format
- Hybrid models (ads + IAPs + passes) now mainstream

**Critical Mistake to Avoid**:
- "One key mistake many idle games still make: they front-load monetization"
- Players asked to spend before they feel anything
- Top performers wait until Day 3 when players chase rare drops

**Making Ads Helpful**:
- Pizza Ready example: 42% ad engagement rate (vs 25-30% average)
- Secret: "Players feel like the ads are bailing them out, not slowing them down"
- Productive frustration: bottleneck + solution = acceptable ad

**Frequency Balance**:
- Overloading ads leads to churn
- Frequency caps essential
- Offer ad-free experience through IAP

**GoDig Application**:
- NO monetization until after first upgrade (trust building)
- Day 1-2: onboarding and unlock systems
- Day 3+: optional ads for ladder bundles, time boosts
- Rewarded video: "Watch ad for 3 free ladders" when stuck

### Dome Keeper 2025 Community Feedback

From [Steam Community](https://steamcommunity.com/app/1637320/discussions/0/) and [Steambase](https://steambase.io/games/dome-keeper/reviews):

**Key Complaints**:
- Assessor character: "needs time in the oven"
- Costs too high for time management game
- "Downtime when waiting for orbs to recharge"
- Basic controls questions persist

**Pacing Feedback**:
- "Think about the rhythm of pressure"
- "At the moment, pressure is always high with no moment to relax"
- "If the pressure is always max, it's just exhausting and not that fun"

**Developer Response**:
- "Community feedback integral to why Dome Keeper became a good game"
- Committed to faster charge-up, letting abilities work at 100%
- Versus mode in development (competing teams on shared mine)

**GoDig Learning**:
- Surface visits MUST provide genuine relief
- Vary tension rhythm - not constant high pressure
- Plan for community-driven balance iteration

### New Implementation Priorities (Session 10)

Based on this research, these gaps need attention:

| Gap | Priority | Impact |
|-----|----------|--------|
| Haptic feedback for ore discovery | P2 | Mobile game feel |
| One-hand friendly HUD layout | P1 | Accessibility |
| Surface as genuine relief (cozy signals) | P2 | Tension rhythm |
| Post-launch economy tuning plan | P0 | Long-term retention |
| Day 3 monetization gate | P1 | Trust building |
| Difficulty scaling after mastery | P3 | Replayability |

### Sources (Session 10)

- [Balatro Blueprint for Indie Success - Cubix](https://www.cubix.co/blog/balatro-card-game-a-blueprint-for-indie-success/)
- [The Allure of Balatro - Oreate AI](https://www.oreateai.com/blog/the-allure-of-balatro-why-this-minimalist-game-captivates-players/)
- [GDCA 2025 Awards - GD Magazine](https://www.gamedeveloper.com/design/-balatro-plays-winning-hand-at-gdca-2025-receiving-game-of-the-year)
- [Best Cozy Games 2025 - Plarium](https://plarium.com/en/blog/best-cozy-games/)
- [Best Relaxing Mining Games - GameRant](https://gamerant.com/best-relaxing-mining-games/)
- [Mining Games Hidden Gems - The Cozy Gaming Nook](https://thecozygamingnook.com/mining-games/)
- [Haptics for Mobile Games - Interhaptics](https://interhaptics.medium.com/enhance-player-immersion-with-haptics-for-ios-and-android-games-using-interhaptics-for-mobile-d01b2f160543)
- [2025 Guide to Haptics - Saropa](https://saropa-contacts.medium.com/2025-guide-to-haptics-enhancing-mobile-ux-with-tactile-feedback-676dd5937774)
- [Marvel Snap Haptics - XDA Developers](https://www.xda-developers.com/marvel-snap-mobile-game-haptics/)
- [Touch Control Design - Mobile Free To Play](https://mobilefreetoplay.com/control-mechanics/)
- [Design for One-Hand Usage - Smashing Magazine](https://www.smashingmagazine.com/2020/02/design-mobile-apps-one-hand-usage/)
- [Hades 2 Best Route - GameRant](https://gamerant.com/hades-2-1-0-release-best-route-underworld-why/)
- [Hades 2 1.0 Changes - The Flagship Eclipse](https://www.theflagshipeclipse.com/2025/09/25/4-biggest-changes-hades-2s-1-0-launch-makes-to-the-early-access-version-how-its-so-much-better/)
- [Idle Game Engagement 2025 - Gamigion](https://www.gamigion.com/idle/)
- [Mobile Monetization Trends 2025 - ContextSDK](https://contextsdk.com/blogposts/monetization-trends-in-mobile-gaming-whats-shaping-2025)
- [Dome Keeper Feedback - Steam Community](https://steamcommunity.com/app/1637320/discussions/0/)

## Session 11 Research: Vampire Survivors Psychology, Grindiness Balance, Session Design

### Vampire Survivors - Gambling Psychology Applied to Games

From [The Conversation](https://theconversation.com/vampire-survivors-how-developers-used-gambling-psychology-to-create-a-bafta-winning-game-203613) and [GameDeveloper](https://www.gamedeveloper.com/design/vampire-survivors-development-sounds-like-an-open-source-fueled-fever-dream):

**Creator's Background**:
- Luca Galante applied previous gambling industry experience to game design
- Result: "distils the essence of compelling, just-one-more-go game design"
- Foundation for an entire new sub-genre ("survivors-like")

**The PENS Model - Player Needs Satisfaction**:
- Games fulfill psychological needs: Competence, Autonomy, Relatedness
- Vampire Survivors efficiently addresses two: competence (power/mastery) and autonomy (freedom)
- "Built around multilayered rewards" - constant drip of satisfaction

**Minimal Input, Maximum Feedback**:
- Only requires directional controls - attacking is automatic
- Yet the screen is constantly filled with feedback (enemies dying, numbers flying)
- "Deceptively simple structure creates a dance between player and enemy hordes"

**GoDig Application**:
- Our core input is simple too (tap to dig)
- But feedback should be rich: particles, sounds, ore discovery toasts
- Competence: getting better at ladder placement and route planning
- Autonomy: choosing when to return, what to mine, how to upgrade

### Mining Game Grindiness: The Player Feedback Spectrum

From [AllGameNoFilter](https://allgamenofilter.com/2025/08/02/game-review-keep-on-mining-a-chill-grind-that-eventually-hits-bedrock/), [Steam Discussions](https://steamcommunity.com/app/2830150/discussions/0/4695657936515530098/), and [ResetEra](https://www.resetera.com/threads/more-satisfying-mining-in-games.1128900/):

**Keep on Mining Feedback (2025)**:
- Early game: "dopamine-inducing unlocks and upgrades"
- Mid-game problem: "repetitive and grind-heavy, limited strategic depth"
- Design flaw: "Some talents increase rock durability, effectively weakening the player"
- Learning: Never make upgrades feel like downgrades

**Deep Rock Galactic: Survivor**:
- "One of the best game loops mechanically" - mining, shooting, extraction
- Early game "feels very satisfying til 10 to 15 finished goals"
- Problem: "Special minerals increase massively per stat level"
- Result: "Very annoying and boring grind slowly destroying the fantastic game loop"

**Super Mining Mechs**:
- "The game is very grindy indeed, that's the nature of the core gameplay loop"
- Key insight: "If you don't feel that the digging aspect of the game is satisfying or fun by itself, I don't think the game is for you"
- Our core digging MUST be satisfying before adding any systems on top

**Hytale Mining Rework**:
- Developer publicly stated he is "dissatisfied with the current experience"
- Goal: "More fun, more satisfying, and less grindy"
- Key quote: "If mining isn't fun, the entire gameplay loop starts feeling like a repetitive grind instead of an adventure"

**What Makes Mining Satisfying (Forum Consensus)**:
- Deep Rock Galactic: "digging away and finding caverns etc is so much fun"
- Stardew Valley: "time limit, enemies to battle, shortcuts, better loot deeper"
- Stardew bombs: "blowing up massive amounts of rocks at once is always satisfying"
- SteamWorld Dig 2: "frequently mentioned as standout"
- Astroneer: "digging and finding caverns" - exploration discovery

**GoDig Application**:
- Mining must be inherently satisfying BEFORE upgrades
- Avoid exponential scaling that makes late-game feel grindy
- Each upgrade should feel like power increase, never weakening
- Discovery (finding ores, caves) is what makes digging fun

### Cult of the Lamb - Roguelite Retention Through Base Building

From [Escapist Magazine](https://www.escapistmagazine.com/cult-of-the-lamb-review-in-3-minutes-a-delightful-roguelite-base-managing-hybrid/), [Inverse](https://www.inverse.com/gaming/cult-of-the-lamb-review), and [GameRant](https://gamerant.com/roguelites-best-progression-systems-respect-your-free-time/):

**Two-Loop Design**:
- Dungeon crawling (roguelite combat) + cult management (town building)
- "Joy of watching the cult expand cleverly hooks into the core loop"
- Players go into dungeons to gather materials for cult buildings/upgrades

**Forgiving Death**:
- "Dying in roguelites is usually a massive pain point"
- Cult of the Lamb: deity resurrects you, only lose "a little bit of dungeon progress"
- Materials partially retained - "still plenty to go around when managing cult"

**Accessibility Praised**:
- "Brilliant entry point to roguelites"
- Base management gives purpose to combat runs
- Combat gives resources for base management
- Neither loop works without the other

**GoDig Application**:
- Our surface buildings parallel the cult base
- Forfeit Cargo = forgiving death (lose cargo, keep tools)
- Mining gives resources for upgrades/buildings
- Upgrades give tools for deeper mining
- Two loops feed each other

### Push-Your-Luck: Creating Tension Through Decision Points

From [Board Game Design Course](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/) and [BoardGameGeek](https://boardgamegeek.com/boardgamemechanic/2661/push-your-luck):

**The Core Mechanic**:
- "Decide between settling for existing gains OR risking them for further rewards"
- Key distinction: This is NOT pure luck - it's meaningful CHOICES
- "The thrill of potentially enormous success, and the devastation of losing it all"

**Self-Balancing Design (Incan Gold)**:
- Fewer players staying = greater potential reward
- Risk naturally increases as rewards do
- Players self-regulate based on risk tolerance

**Creating Tension Without Fatigue**:
- "Grant bonus points based on number of players already dropped out"
- Race mechanics or "wall of doom closing in" ratchets up tension
- But constant max pressure is exhausting (Dome Keeper feedback)

**Deep Sea Adventure - Shared Resource Model**:
- Players share a single submarine with single oxygen tank
- "Unique blend of cooperation and competition"
- Taking treasure = slowing return + draining shared oxygen
- Creates "incredible moment of anticipation" when decisions are revealed

**GoDig Application**:
- Our "bust" = running out of ladders while deep
- Unlike sudden bust (dice roll), ours is gradual (ladder count depleting)
- This is BETTER for tension - feel it building like oxygen depleting
- Surface visits must break the tension (unlike Dome Keeper's constant pressure)

### Mobile Session Design: The 4-6 Minute Reality

From [GameRefinery](https://www.gamerefinery.com/3-things-to-know-about-session-length-restriction-when-designing-a-free2play-game/), [GameDeveloper](https://www.gamedeveloper.com/business/how-first-session-length-impacts-game-performance), and [BestAppsToday](https://bestappstoday.com/trending/mobile-gaming-trends/):

**Actual Session Length Data (2025)**:
- Median session: ~4 min casual, ~5 min mid-core, ~6 min classic/puzzle
- Top 25% achieve 7-9 minutes per session
- Most mobile gaming happens in brief 5-15 min sessions
- "Way to pass time in a bus or queue, not whole afternoon"

**Session Frequency**:
- Mobile gamers average 4-6 sessions daily
- Typical: 3-5 sessions of 3-6 minutes each per day
- Total daily play: 15-30 minutes spread across sessions

**First Session Critical**:
- Most games lose 20% of installs within 2 minutes from first launch
- Ensuring first session is 10-20 minutes is vital for F2P success
- Median Day-1 retention only 18-20% (80% churn!)
- Day 7: 3-6%, Day 30: under 1-2%

**GoDig Application**:
- Design for 5-minute complete loops (dig -> sell -> upgrade consideration)
- Full inventory should trigger natural stopping point at ~4-6 minutes
- First session must hook within 2 minutes
- Provide satisfying stopping points, don't trap players in long sessions

### Motherload's Enduring Design Lessons

From [TVTropes](https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/Motherload), [PlayStation Blog](https://blog.playstation.com/2013/11/08/super-motherload-on-ps4-exploring-the-story-and-game-modes/), and [Game Informer](https://gameinformer.com/games/super_motherload/b/playstation4/archive/2013/11/22/digging-deep-shallow-play.aspx):

**Core Loop Excellence**:
- "Dig -> Collect -> Sell -> Refuel/Repair -> Upgrade -> Dig Deeper"
- "Getting money to get more stuff, which you then use to get more money"
- Four years of concepting and refinement

**Tension Through Resources**:
- "True fear when low on fuel flying up to the surface"
- Fuel tank upgrades: "On Hardcore this is a matter of life and death"
- Players report 5-hour sessions despite simple mechanics

**The Tedium Problem**:
- "Repetition of going up and down so many times gets increasingly tedious"
- "Little changes about the gameplay over time"
- "Best part is fun of upgrading, everything in between is a grind"

**Mitigation - Stations**:
- "Stations at various levels underground so you don't have to go all the way back up"
- They charge more (justified as transport cost)
- Teleportation items: cheap + risky vs expensive + safe

**GoDig Application**:
- Our ladder system replaces fuel as limiting resource
- Unlike fuel (depletes passively), ladders require ACTIVE decisions
- This is BETTER: player feels agency in every placement
- Need later-game infrastructure (elevator) to prevent tedium
- Consider underground shop outposts for convenience (at premium)

### SteamWorld Dig 2's Addictive Progression

From [ResetEra](https://www.resetera.com/threads/steamworld-dig-2-why-is-it-so-addicting.33518/), [Game Informer](https://gameinformer.com/games/steamworld_dig_2/b/switch/archive/2017/09/28/steamworld-dig-2-review.aspx), and [VideoChums](https://videochums.com/review/steamworld-dig-2):

**Why It's Addicting**:
- "Gameplay loop of a dungeon crawler like Diablo or Etrian Odyssey"
- "Only make a little bit of progress in each outing, but every time you gather rewards"
- "Price/benefits of items are well-tuned"
- "Bite-sized forays that always bring you closer to some objective or purchase"

**Upgrade Feel**:
- "Progression feels great and equipment upgrades have real weight"
- "Considerable impact on gameplay and controls"
- Drilling powerup "cuts digging to a fraction of time"
- "Tier 1 vs Tier 3 should feel like night and day"

**The "Just One More Trip" Feeling**:
- Players regularly making trips "not necessarily to make progress"
- But "because they were getting really close to a new upgrade"
- The anticipation of the upgrade drives continued play

**Pacing Excellence**:
- "Impeccably paced, with new powers opening up just when comfortable"
- "World is fun to move around, characters charming"
- "Process of gradually increasing efficiency is airtight"

**GoDig Application**:
- Our upgrade pricing must create this "just a few more coins" feeling
- Each trip should feel like progress toward next purchase
- Upgrades must have dramatic gameplay impact
- Pacing: new abilities/unlocks should arrive before boredom

### Implementation Priority Refinement (Session 11)

Based on accumulated research, these are the KEY insights for fun factor:

#### Core Loop Fundamentals (Non-Negotiable)
| Principle | Implementation |
|-----------|----------------|
| Mining must be fun WITHOUT upgrades | Test core digging satisfaction first |
| Upgrades must feel like power increases | Never make player feel weaker |
| Session target: 4-6 minutes complete loop | Inventory size controls pacing |
| Tension rhythm: vary high/low | Surface visits = genuine relief |
| First upgrade in < 5 minutes | Critical retention gate |

#### The Tension Curve Model
```
TENSION
   ^
   |                    * Full inventory, deep, 1 ladder
   |                  **
   |                 *    Low ladder warning
   |               *
   |             *   Inventory 60%
   |           *
   |         *
   |       *
   |     *   First ore found (excitement spike)
   |   *
   | *   Start dive (5 ladders = confidence)
---+----------------------------------------> TIME
   |
   |  * Back on surface (RELIEF - this must be real)
   v
RELIEF
```

Key Insight: Unlike Dome Keeper where "pressure is always max," GoDig must have genuine relief moments on surface. The contrast makes both states meaningful.

#### New Gaps Identified

| Gap | Priority | Rationale |
|-----|----------|-----------|
| Core mining feel validation | P0 | "If digging isn't satisfying, loop fails" |
| Underground shop outpost | P3 | Reduces late-game tedium (v1.1) |
| Upgrade power feel test | P1 | "Tier 1 vs Tier 3 = night and day" |
| Anti-grind economy balance | P1 | Avoid exponential scaling trap |

### Sources (Session 11)

- [Vampire Survivors Gambling Psychology - The Conversation](https://theconversation.com/vampire-survivors-how-developers-used-gambling-psychology-to-create-a-bafta-winning-game-203613)
- [Vampire Survivors Development - GameDeveloper](https://www.gamedeveloper.com/design/vampire-survivors-development-sounds-like-an-open-source-fueled-fever-dream)
- [Keep on Mining Review - AllGameNoFilter](https://allgamenofilter.com/2025/08/02/game-review-keep-on-mining-a-chill-grind-that-eventually-hits-bedrock/)
- [Super Mining Mechs Grind Discussion - Steam](https://steamcommunity.com/app/2830150/discussions/0/4695657936515530098/)
- [Satisfying Mining Discussion - ResetEra](https://www.resetera.com/threads/more-satisfying-mining-in-games.1128900/)
- [Cult of the Lamb Review - Escapist](https://www.escapistmagazine.com/cult-of-the-lamb-review-in-3-minutes-a-delightful-roguelite-base-managing-hybrid/)
- [Push Your Luck Design - Board Game Design Course](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/)
- [Deep Sea Adventure - BoardGameTips](https://boardgame.tips/deep-sea-adventure)
- [Mobile Session Length Data - GameRefinery](https://www.gamerefinery.com/3-things-to-know-about-session-length-restriction-when-designing-a-free2play-game/)
- [First Session Impact - GameDeveloper](https://www.gamedeveloper.com/business/how-first-session-length-impacts-game-performance)
- [Motherload Analysis - TVTropes](https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/Motherload)
- [SteamWorld Dig 2 Addiction - ResetEra](https://www.resetera.com/threads/steamworld-dig-2-why-is-it-so-addicting.33518/)
- [Mobile Onboarding - Adrian Crook](https://adriancrook.com/best-practices-for-mobile-game-onboarding/)
- [FTUE Definition - Mobile Game Doctor](https://mobilegamedoctor.com/2025/05/30/ftue-onboarding-whats-in-a-name/)

## Session 12 Research: Metrics-Driven Design, Mining Feel, Economy Fundamentals

### Slay the Spire's Metrics-Driven Development (GDC Vault)

From [GDC Vault](https://www.gdcvault.com/play/1025731/-Slay-the-Spire-Metrics) and [Gamedeveloper](https://www.gamedeveloper.com/design/how-i-slay-the-spire-i-s-devs-use-data-to-balance-their-roguelike-deck-builder):

**The Data-Driven Approach**:
- Sold 1M+ copies in first year, now 3M+ on Steam with 97% positive rating
- "Metrics-driven design and balance from early development"
- Heavy use of data throughout 14-month Early Access
- Weekly updates - consistent iteration is key
- Community feedback integral but filtered through data

**Design Philosophy**:
- "Allowing for combos and strong synergies is definitely a hallmark"
- Designed thousands of cards, cut "chaff down to designs with most impact"
- 10-card starting deck (mostly Strikes/Defends) ensures approachable start
- Easy to learn new characters because foundation is familiar

**GoDig Application**:
- Our tools function like Slay the Spire's cards - start simple, unlock complexity
- Each upgrade tier should enable new "combos" (grappling hook + deep dive, etc.)
- Track metrics: time to first upgrade, death locations, ladder usage patterns

### Loop Hero's Retention Through Commit-or-Retreat

From [Gamedeveloper Postmortem](https://www.gamedeveloper.com/design/postmortem-loop-hero) and [Medium Analysis](https://medium.com/@sacitsivri/game-design-breakdown-loop-hero-4a86d55142b8):

**The Brilliant Hybrid**:
- "Straddles the line between roguelike and idle game"
- "Deceptively increases necessary grind while making every decision important"
- Resource retention varies by exit method: die=30%, retreat early=60%, camp=100%
- Creates "commit or retreat" decision at natural stopping points

**What Worked**:
- Idle design with roguelite persistence
- "Mental training on how to make idle games more engaging"
- Won 2025 Pegases Award for Best Foreign Mobile Game

**What Players Criticized**:
- "On the hard side due to RNG and idle combat"
- "Grinding required for major buildings is very high"
- "Feels like one right way to play each class"

**GoDig Application**:
- Our Forfeit Cargo option parallels Loop Hero's retreat system
- Forfeit = lose 100% of cargo but keep ladders/tools (similar to retreat penalty)
- Death = lose some cargo + tool durability (harsher but not devastating)
- This creates meaningful "commit or retreat" decisions

### Vertical Slice Playtesting (GDC 2025)

From [GDC Schedule 2025](https://schedule.gdconf.com/session/building-the-perfect-vertical-slice-essential-strategies-for-developers/907576) and [Indie Bandits](https://indiebandits.com/2023/02/13/why-your-indie-game-needs-a-vertical-slice/):

**Why Vertical Slices Matter**:
- "Becoming more important than ever" for publisher attention
- "Standing out in increasingly crowded market is biggest challenge"
- Publishers want polished demonstration of final game feel

**Best Practices**:
- "Make First 10 Seconds Count" - bold visual, set tone with sound, give control quickly
- "Polish Core Mechanic" - focus on ONE mechanic that defines your game
- Core mechanic must "produce repeatable fun across multiple playtests"
- Show player validation: "ran three playtests with 200 players, 30-40% completed surveys"

**What Publishers Look For**:
- A polished 10-30 minute vertical slice
- Pitch deck with clear budget and timeline
- Player validation data - "real feedback, not assumptions"
- Studios that "iterate based on data, not just gut feeling"

**GoDig Application**:
- Our MVP IS the vertical slice - core loop must be fun before any expansion
- Test: Does mining feel satisfying without any systems?
- Test: Does return-trip tension work with just ladders?
- Gather real playtest data before adding complexity

### What Makes Mining Satisfying (2025 Forum Consensus)

From [ResetEra](https://www.resetera.com/threads/more-satisfying-mining-in-games.1128900/) and [Gfinity Hytale](https://www.gfinityesports.com/article/hytale-creator-says-mining-isnt-fun-enough-and-notes-thousands-of-feedback-based-changes):

**The Core Insight (Hytale)**:
- Developer publicly stated mining "isn't fun enough"
- Goal: "More fun, more satisfying, and less grindy"
- Key: "If mining isn't fun, the entire loop feels like repetitive grind"

**What Players Cite as Satisfying**:
- Deep Rock Galactic: "digging away and finding caverns is so much fun"
- Stardew Valley: "time limit, enemies, shortcuts, bombs, better loot deeper"
- SteamWorld Dig: "best platforming mechanics not made by Nintendo"
- Astroneer: "digging and finding caverns" - the exploration discovery

**Common Thread**:
- **Discovery and exploration**, not just extraction
- Finding hidden things (caves, ore veins, treasures)
- Variety in what you find (not just "more of same")
- Ability to create shortcuts (Stardew bombs, SteamWorld drill)

**GoDig Application**:
- Mining MUST be inherently satisfying before any upgrades
- Cave discovery should be a mini-event (special sound, brief celebration)
- Each layer needs visually distinct ores - not just "harder version of same"
- Consider: explosive items for late-game satisfaction

### Mobile Economy Design: The First 5 Minutes

From [Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/balanced-mobile-game-economy) and [GameAnalytics](https://www.gameanalytics.com/):

**Critical Statistics**:
- 62% of players abandon due to lack of currency/resources
- Dual currency systems in 78% of successful titles
- 30% increase in engagement from steady reward tapering

**The Balance Challenge**:
- "Too generous = blast through content, get bored"
- "Too stingy = frustrated, quit"
- Goal: "Never quite enough" feeling that drives decisions

**Layered Approach**:
- "Perfect for mobile" - meaningful play in 5 min OR 1 hour
- Core loop completable in 3-5 minutes
- 88% of users return after experiencing satisfying cycle
- Top performers lose only 17% by minute 5 (worst lose 46%)

**GoDig Economy Implications**:
- First ore discovery: under 30 seconds
- First sale: under 2 minutes
- First upgrade visible: under 4 minutes
- First upgrade purchase: under 5 minutes
- After first upgrade: player should FEEL the difference immediately

### Motherload's Underground Stations Pattern

From [TVTropes](https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/Motherload) and [GameFAQs Guide](https://gamefaqs.gamespot.com/flash/933421-motherload/faqs/53229):

**The Tedium Problem**:
- "Going up and down so many times gets increasingly tedious"
- First "screw this game" moment: realizing trips get longer and longer
- "Best part is upgrading, everything in between is grind"

**The Solution - Underground Stations**:
- "Stations at various levels so don't have to go all the way back up"
- They charge more (justified as transport cost)
- Appear as REWARD: "Make a few more boring trips and... underground outpost appears"

**Key Design Insight**:
- The relief of finding a station turns tedium into reward
- Player anticipates stations at certain depths
- Creates milestone feelings beyond just "went deeper"

**GoDig Application**:
- Elevator unlock should feel like ACHIEVEMENT, not just purchase
- Consider: rare pre-placed ladder clusters as "discovery rewards"
- Deep stations could sell ladders at premium (convenience tax)
- Station discovery = mini-celebration + save point

### The First Upgrade Hook

From [NuMuKi Analysis](https://www.numuki.com/games/upgrade/) and [Udonis Progression](https://www.blog.udonis.co/mobile-marketing/mobile-games/progression-systems):

**The Psychology**:
- "First few rounds feel tedious as characters move slowly"
- "Players who prove patience won't go unrewarded"
- "Satisfaction of seeing hero improve keeps players glued"

**Mobile Validation**:
- 40% session length increase when controls mastered in 5 min
- First upgrade is THE retention gate
- If player doesn't feel progression, they quit

**The Moment of Truth**:
- First upgrade must be FELT immediately
- Not just "numbers went up" but "this plays differently"
- Visual, audio, and mechanical feedback all matter

**GoDig First Upgrade Design**:
- Copper Pickaxe (Tier 2) must feel notably faster than Rusty Pickaxe
- Show before/after comparison UI
- Play celebratory sound + screen effect
- First block mined with new pickaxe should feel satisfying

### Risk vs Reward: Board Game Insights Applied

From [Board Game Design Course](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/) and [Brain Games](https://brain-games.com/en-us/blogs/board-game-explorer/risk-vs-reward-balancing-strategies-in-board-games):

**Push-Your-Luck vs Pure Luck**:
- Distinct mechanics: Push-your-luck requires meaningful CHOICES
- "Thrill of potentially enormous success, devastation of losing all"
- Self-balancing: risk naturally increases as rewards do (Incan Gold)

**Good Tension vs Bad Frustration**:
- Good: "I wish I could do both but must choose"
- Bad: "I can't do anything meaningful, just blocked"
- Scarcity should feel like "never quite enough," not "impossible"

**Mathematical Balancing**:
- For 50% bust rate overall with 3 push-your-luck moments: each needs ~80% success
- Cumulative risk creates tension without individual moments feeling unfair

**GoDig Application**:
- Each ladder placement is a meaningful choice (not pure luck)
- At any moment, player has ~80% confidence they can return
- But cumulative risk builds: 3 ladders left + deep = real tension
- Unlike sudden bust (dice roll), our tension is gradual (ladder count depleting)

## Implementation Checklist Update (Session 12)

Based on accumulated research, prioritized implementation needs:

### P0 - Core Loop Validation (Before Any Polish)
- [ ] Test: Is mining satisfying with placeholder audio/visuals?
- [ ] Test: Does ladder tension create meaningful decisions?
- [ ] Test: Does first upgrade feel like power increase?
- [ ] Metric: Time to first ore discovery (<30 sec target)
- [ ] Metric: Time to first upgrade (<5 min target)

### P1 - First Session Flow
- [ ] Supply Store at 0m depth
- [ ] 5 starting ladders (or Supply Store sells them immediately)
- [ ] First ore visible within 3 blocks of surface
- [ ] Sell transaction completes by minute 2
- [ ] Upgrade prompt visible by minute 4

### P2 - Tension/Relief Cycle
- [ ] Low ladder warning (visual + audio)
- [ ] Surface arrival celebration
- [ ] Genuine relief signals on surface (music change, lighting)
- [ ] Forfeit Cargo option for recovery

### P3 - Reward Satisfaction
- [ ] Ore discovery celebration (sparkles, sound, toast)
- [ ] Sell animation with coin arc
- [ ] Upgrade comparison UI (before/after)
- [ ] Immediate power feel after upgrade

## Sources (Session 12)

- [Slay the Spire Metrics Driven Design - GDC Vault](https://www.gdcvault.com/play/1025731/-Slay-the-Spire-Metrics)
- [How Slay the Spire Uses Data - Gamedeveloper](https://www.gamedeveloper.com/design/how-i-slay-the-spire-i-s-devs-use-data-to-balance-their-roguelike-deck-builder)
- [Loop Hero Postmortem - Gamedeveloper](https://www.gamedeveloper.com/design/postmortem-loop-hero)
- [Loop Hero Game Design Breakdown - Medium](https://medium.com/@sacitsivri/game-design-breakdown-loop-hero-4a86d55142b8)
- [Building Perfect Vertical Slice - GDC 2025](https://schedule.gdconf.com/session/building-the-perfect-vertical-slice-essential-strategies-for-developers/907576)
- [Why Your Indie Game Needs a Vertical Slice - Indie Bandits](https://indiebandits.com/2023/02/13/why-your-indie-game-needs-a-vertical-slice/)
- [More Satisfying Mining - ResetEra](https://www.resetera.com/threads/more-satisfying-mining-in-games.1128900/)
- [Hytale Mining Rework - Gfinity](https://www.gfinityesports.com/article/hytale-creator-says-mining-isnt-fun-enough-and-notes-thousands-of-feedback-based-changes)
- [Mobile Game Economy - Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/balanced-mobile-game-economy)
- [Motherload - TVTropes](https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/Motherload)
- [Upgrade Games Analysis - NuMuKi](https://www.numuki.com/games/upgrade/)
- [Risk vs Reward Board Games - Brain Games](https://brain-games.com/en-us/blogs/board-game-explorer/risk-vs-reward-balancing-strategies-in-board-games)

## Session 13 Research: Discovery, Automation, and Player Return

> Last updated: 2026-02-01 (Session 13)

### Astroneer Terrain Deformation Design

From [Gamedeveloper](https://www.gamedeveloper.com/design/what-i-astroneer-i-s-devs-learned-while-leaving-early-access):

- "Sculpting the terrain is what people want to do in the game. It's kind of like the output valve."
- The entire game was built around terrain deformation from day one
- "Full ground deformation with your digging tool" creates "simple joy to creating and finding things"
- Can "dig right to the core of each planet" - validates infinite depth appeal
- Uses marching cubes algorithm + chunk-based rebuilding for performance

**GoDig Application**: Our block-based digging is simpler but each dig should still feel impactful. The "making a mark on the world" feeling is key to satisfaction.

### Factory Builder Automation Design (Satisfactory/Factorio)

From [ThinkYGames](https://thinkygames.com/features/a-satisfactory-result-how-factory-builders-use-logic-puzzles-to-revolutionise-the-management-genre/):

- Satisfactory: "glossier, more accessible experience, effectively streamlining many of the ideas Factorio pioneered"
- Infinite resource deposits remove tedious "seek new veins" loop
- "Overseeing a system of interconnected machines is its own type of logic puzzle"
- Player quote: "I don't know where the factory ends and I begin" - deeply immersive

**GoDig v1.1 Application**: Auto-Miner Station should create simple optimization puzzles without over-complicating. Satisfactory succeeded by streamlining - we should do the same.

### Procedural Generation Discovery Principles

From [Slavna Studio](https://www.slavnastudio.com/blog/top-strategies-for-implementing-procedural-generation-in-games/):

- "The key is control: randomness should surprise players, but never betray them. Think of it like jazz."
- Cellular automata mimics natural cave erosion - creates believable chambers
- Wave Function Collapse creates "unpredictable but still cohesive" results
- Hidden corridors offer "alternative routes if discovered"

From [EditorialGE](https://editorialge.com/mind-blowing-procedural-generation-games/):

- Deep Rock Galactic: completely destructible procedural caves are "key feature"
- Spelunky 2: "no two expeditions are identical" - keeps runs fresh
- Terraria: "unique secrets, including hidden chests, underground temples"

**GoDig Application**: Our procedural generation should include discoverable secrets - hidden treasure rooms, rare structure spawns, mini-puzzles. These create stories players tell.

### Discovery as Core Design Element

From [GamersLearn](https://www.gamerslearn.com/design/curiosity-exploration-and-discovery-in-video-games):

- "It's not just exploration that's required, but also the sense of discovery that makes these games magical"
- Discovery = "going out into the game to find things you didn't know were there"
- Games need "narrative or mechanical branching" to create true exploration feel

From [MrMineBlog](https://blog.mrmine.com/free-mining-games-mr-mine-idle-clicker-adventure/):

- "These moments break the routine and add depth to your mining journey"
- "They make the game feel more like an adventure than a numbers game"
- Hidden journals, audio logs, artifacts tell tales of the underground

**GoDig Implementation**: Add discoverable lore elements - old mining journals, strange artifacts, abandoned equipment. These create emotional investment beyond pure progression.

### Mobile Player Re-engagement & Comeback Mechanics

From [GameRefinery](https://www.gamerefinery.com/four-ways-how-mobile-games-re-engage-lapsed-players/):

- 77% of mobile app users churn within first 3 days - re-engagement critical
- "Welcome back" campaigns: 3-7 days for users who haven't played in X days
- "Claim your 1,000 free gems now!" feels like gift, not ad
- Clash Royale's "Season Reset" gives lapsed players fresh start

From [AppSamurai](https://appsamurai.com/blog/retargeting-in-mobile-gaming-how-to-win-back-players-and-boost-ltv-in-2025/):

- Effective rewards: premium currency, gacha tickets, exclusive items
- Timed boosts create urgency without guilt
- Personalized messages: "You were so close to unlocking a new character! Come back and finish"
- ML-driven segmentation: at-risk mid-value, high-value whales, low-value free players

From [Mistplay](https://business.mistplay.com/resources/player-retention):

- Mistplay removed streak pressure from daily rewards - "players were happier"
- **Key insight**: Don't punish absence. Streaks create guilt, not joy.

**GoDig Implementation**: Welcome back rewards should include ladders (core resource), premium ore, and progress reminder. NO daily login streaks.

### 2025 Mobile Retention Benchmarks

From [NudgeNow](https://www.nudgenow.com/blogs/mobile-game-retention-benchmarks-industry):

- Average Day 1 retention: 26%
- Average Day 7 retention: 10%
- Average Day 30 retention: <4%
- Top performers (puzzle/casual): 35%+ Day 1, 12%+ Day 7
- Genshin Impact: 40%+ Day 30 through exploration, events, character upgrades

**GoDig Target**: Aim for casual-tier retention (30%+ D1, 12%+ D7) through satisfying core loop.

## Implementation Priorities Update (Session 13)

### New High-Priority Features Identified

| Feature | Priority | Rationale |
|---------|----------|-----------|
| Discoverable lore (journals) | P2 | Breaks routine, creates adventure feel |
| Hidden treasure rooms | P2 | "Surprise but never betray" discovery |
| Welcome back rewards | P2 | Critical for re-engagement |
| v1.1: Simple automation | P3 | Streamlined like Satisfactory |

### Implementation Specs Created

- `GoDig-implement-discoverable-lore-67646ab4` - Journals, artifacts, equipment
- `GoDig-implement-welcome-back-f99d9b0d` - Return player rewards
- `GoDig-implement-hidden-treasure-9fd6f4c2` - Procedural treasure rooms
- `GoDig-implement-automation-building-496db9d0` - Auto-Miner v1.1

## Sources (Session 13)

- [What Astroneer's Devs Learned - Gamedeveloper](https://www.gamedeveloper.com/design/what-i-astroneer-i-s-devs-learned-while-leaving-early-access)
- [Satisfactory Factory Builders - ThinkYGames](https://thinkygames.com/features/a-satisfactory-result-how-factory-builders-use-logic-puzzles-to-revolutionise-the-management-genre/)
- [Procedural Generation Strategies - Slavna Studio](https://www.slavnastudio.com/blog/top-strategies-for-implementing-procedural-generation-in-games/)
- [Procedural Generation Games - EditorialGE](https://editorialge.com/mind-blowing-procedural-generation-games/)
- [Curiosity and Discovery - GamersLearn](https://www.gamerslearn.com/design/curiosity-exploration-and-discovery-in-video-games)
- [Mr Mine Analysis - MrMineBlog](https://blog.mrmine.com/free-mining-games-mr-mine-idle-clicker-adventure/)
- [Re-engaging Lapsed Players - GameRefinery](https://www.gamerefinery.com/four-ways-how-mobile-games-re-engage-lapsed-players/)
- [Retargeting in Mobile Gaming 2025 - AppSamurai](https://appsamurai.com/blog/retargeting-in-mobile-gaming-how-to-win-back-players-and-boost-ltv-in-2025/)
- [Player Retention Guide - Mistplay](https://business.mistplay.com/resources/player-retention)
- [Mobile Retention Benchmarks - NudgeNow](https://www.nudgenow.com/blogs/mobile-game-retention-benchmarks-industry)

## Session 17 Research: Discovery Design, Layer Identity, and FTUE

> Last updated: 2026-02-01 (Session 17)

### Animal Well: Layered Secrets & Minimalist Discovery

From [NoisyPixel](https://noisypixel.net/animal-well-2024-indie-game-success/) and [ThinkYGames](https://thinkygames.com/features/how-animal-wells-environmental-design-taps-into-our-need-for-puzzle-solving-satisfaction/):

- Solo developer created over 7 years with custom C++ engine - no external libraries
- Inspired by Fez, The Witness, Tunic - games that hide secrets in plain sight
- **Three-layer structure**:
  - Layer 1: Puzzle game for all players (accessible)
  - Layer 2: Hidden discoveries for keen explorers
  - Layer 3: ARG elements requiring 50+ player collaboration
- No cutscenes - "trusts the player to discover the game world firsthand"
- Level design makes "discovery feel like intuitive play even when it's secretly giving you a well-planned tutorial"
- Encrypted assets with puzzle solutions as decryption keys - prevents data mining spoilers
- 650,000 copies sold by August 2024, ranked #2 highest-rated Switch game of 2024

**GoDig Application**: Layer our secrets - basic ore for all, rare finds for explorers, community puzzles for hardcore. Don't explain everything; let players feel smart discovering.

### Rain World: Anti-Agency as Design Philosophy

From [Experienced Machine](https://experiencedmachine.wordpress.com/2019/09/16/rain-world-reaching-enlightenment-through-unfairness-part-ii/):

- "The most anti-videogame idea there is" - player agency is deliberately robbed
- World "exists entirely on its own, completely separate from player's influence and desires"
- Slugcat in "middle of food chain" - avoids combat, emphasizes stealth and flight
- No upgrades, no new weapons, no skill points - "progress is not the goal"
- Creatures "learn to recognize you" - scavengers ally if player provides pearls
- 95% emergent gameplay - "tells players absolutely nothing about mechanics"

**GoDig Contrast**: We EMPOWER through upgrades, but learn from Rain World: make the underground feel alive and independent of the player. Creatures should have their own goals.

### Nine Sols: Combat-Focused Metroidvania Flow State

From [Lords of Gaming](https://lordsofgaming.net/2025/02/nine-sols-review-a-near-masterpiece-metroidvania/):

- Parry system creates "flow state that feels supremely rewarding" once mastered
- Risk/reward: Must "spend" built-up Talisman attacks or waste damage opportunities
- Grappling hook from start enables vertical exploration
- Map design: "Clear and accessible" with collectible tracking per zone
- Called "not only one of the best games of 2024, but one of the best modern 2D games ever made"

**GoDig Application**: Combat-free design needs satisfaction from mining itself. Each pickaxe tier should feel like achieving "parry mastery" - a tangible skill upgrade.

### Dead Cells: Biome Variety & Path Choice

From [DeepNight](https://deepnight.net/tutorial/the-level-design-of-dead-cells-a-hybrid-approach/):

- Each biome has unique identity: Toxic Sewers = careful positioning, Ramparts = vertical combat
- Concept graph approach: Entrance/exit placed first, then special rooms, then connecting tiles
- Self-directed difficulty: "Safe path vs dangerous detours" for better rewards
- **Cursed Biome mechanic**: +10% cursed chest chance, +1 loot level, but harder enemies
- Player always has non-cursed path option - choice, not forced difficulty
- 70+ unique enemies, 20+ biomes, 50+ weapons prevents comfort zone builds

**GoDig Application**: Each layer should have distinct identity. Optional danger zones (collapsed mine, lava pocket) for better rewards. Always give safe path option.

### Drill Core (July 2025): Mining Roguelite Analysis

From [GameLuster](https://gameluster.com/drill-core-review-the-finest-roguelite-mining/):

- Day/night split: Mine resources by day, defend from aliens by night
- Core risk/reward: "Drill down fast or risk another night for more resources"
- Push too far and core explodes, losing workers and loot
- Run length: 30-50 minutes - creates frustration when late run fails
- Criticism: "Lack of deeper complexity causes burnout after few hours"

**GoDig Advantage**: Our 5-minute loops prevent late-run frustration. Variety from depth tiers, not just cosmetics.

### Core Gameplay Loop Best Practices (2025-2026)

From [GameDistribution](https://blog.gamedistribution.com/core-gameplay-loop-design-small-tweaks-big-engagement/):

- "Micro loop must be satisfying or no progression system can save your game"
- Build micro loop first in isolation - "Does movement/input/feedback feel fun with greyboxes?"
- Misaligned loops = why games don't feel "tight" - not art/narrative problem
- Understanding Micro/Macro/Meta loops = "most powerful framework in game design"

**GoDig Validation**: Our micro loop (tap-mine-collect) must feel great BEFORE adding systems.

### Mobile FTUE vs Full Onboarding

From [Mobile Game Doctor](https://mobilegamedoctor.com/2025/05/30/ftue-onboarding-whats-in-a-name/):

- **FTUE** = First 60 seconds + first 15 minutes (kinesthetic learning)
- **Full Onboarding** = First 7 days (introduce longer-term systems)
- "First thing players need is to PLAY! Don't make them click/choose/sign in"
- Epic WOW moment early creates attention hook
- Progressive disclosure: Hide systems not needed for first 15 minutes
- Clash Royale: 5 short tutorials at relevant moments, building on previous

**GoDig Implementation**: FTUE = dig, find ore, return, sell in 60 seconds. Day 2+ = shop details, upgrades, deeper systems.

### Roguelike Mastery Design

From [Grid Sage Games](https://www.gridsagegames.com/blog/2025/08/designing-for-mastery-in-roguelikes-w-roguelike-radio/):

- "We want more!" - skilled players demand harder challenges, extended content
- Extended game: Optional challenges after "normal" completion
- Cogmind has 10 endings with unique preparation/execution requirements
- Every upward connection = permanent decision leaving other possibilities behind

**GoDig v1.1**: Add extended goals - depth records, achievement challenges, rare drop collections.

### Mobile Push Notification Ethics

From [ContextSDK](https://contextsdk.com/blogposts/gaming-push-strategy-overcoming-the-63-5-industry-opt-in-challenge):

- Gaming has lowest opt-in rate: 63.5% (37% rejection rate)
- Best times: 12pm-1pm and 7pm-9pm, but personalization matters
- Personalized notifications improve reaction rates by 400%
- "Sustainable engagement vs Player Burnout" - burnout destroys LTV
- Send same number of notifications as player session frequency

**GoDig v1.1**: Match notification frequency to play frequency. Never spam absent players.

## Implementation Priorities Update (Session 17)

### New Critical Features Identified

| Feature | Priority | Rationale |
|---------|----------|-----------|
| FTUE 60-second hook | P0 | "First thing players need is to PLAY" |
| Distinct layer identity | P1 | Dead Cells proved biome variety critical |
| Layered secret system | P2 | Animal Well's 3-tier discovery model |
| Optional danger zones | P2 | Self-directed difficulty scaling |

### Implementation Specs Created (Session 17)

- `GoDig-implement-ftue-60-94baf4fa` - FTUE: Dig-find-return in 60 seconds
- `GoDig-implement-distinct-layer-a60843e5` - Dead Cells-style layer identities
- `GoDig-implement-layered-secret-8ba7afe0` - Animal Well 3-tier secret system
- `GoDig-implement-optional-danger-cc87675c` - High-risk/high-reward danger zones

## Sources (Session 17)

- [Animal Well Success - NoisyPixel](https://noisypixel.net/animal-well-2024-indie-game-success/)
- [Animal Well Design - ThinkYGames](https://thinkygames.com/features/how-animal-wells-environmental-design-taps-into-our-need-for-puzzle-solving-satisfaction/)
- [Rain World Design - ExperiencedMachine](https://experiencedmachine.wordpress.com/2019/09/16/rain-world-reaching-enlightenment-through-unfairness-part-ii/)
- [Nine Sols Review - Lords of Gaming](https://lordsofgaming.net/2025/02/nine-sols-review-a-near-masterpiece-metroidvania/)
- [Dead Cells Level Design - DeepNight](https://deepnight.net/tutorial/the-level-design-of-dead-cells-a-hybrid-approach/)
- [Drill Core Review - GameLuster](https://gameluster.com/drill-core-review-the-finest-roguelite-mining/)
- [Core Loop Design - GameDistribution](https://blog.gamedistribution.com/core-gameplay-loop-design-small-tweaks-big-engagement/)
- [FTUE vs Onboarding - Mobile Game Doctor](https://mobilegamedoctor.com/2025/05/30/ftue-onboarding-whats-in-a-name/)
- [Roguelike Mastery - Grid Sage Games](https://www.gridsagegames.com/blog/2025/08/designing-for-mastery-in-roguelikes-w-roguelike-radio/)
- [Gaming Push Strategy - ContextSDK](https://contextsdk.com/blogposts/gaming-push-strategy-overcoming-the-63-5-industry-opt-in-challenge)

## Session 18 Research: 5-Minute Loop, Upgrade Psychology, and Juice Calibration

### Mobile Session Length Reality (2025-2026 Data)

From [Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/session-length) and [Quantumrun](https://www.quantumrun.com/consulting/average-gaming-session-length-by-age-group/):

- **Median mobile session**: 5-6 minutes (not 15-30 as developers often assume)
- **Top 25% performers**: 8-9 minutes average session
- **Multiple sessions**: Players average 4-6 sessions daily
- **Median daily playtime**: 22 minutes total across all sessions
- This directly contradicts the "epic 30-minute session" assumption

**GoDig Critical Insight**: Each complete loop (dig-sell-upgrade) MUST fit in 5 minutes. Design for 4-6 daily sessions, not one long session.

### FTUE Best Practices 2025 (Comprehensive)

From [GameAnalytics](https://www.gameanalytics.com/blog/tips-for-a-great-first-time-user-experience-ftue-in-f2p-games/) and [Unity](https://unity.com/how-to/10-first-time-user-experience-tips-games):

- "Just a few minutes — or less — to hook a player"
- **Worst games lose 46% by minute 5**; best lose only 17%
- "Core loop (action + reward + progression) should complete within 3-5 minutes"
- "88% of users return after experiencing a satisfying cycle"
- Progressive disclosure: "Hide systems not needed for first 15 minutes"
- "No ads during FTUE - ads frustrate and distract from onboarding"
- D1 retention improvements: "Improving FTUE can increase D1 retention by up to 50%"

**GoDig Implementation**: FTUE must complete one full loop in under 3 minutes: dig → find ore → return → sell → see upgrade path.

### SteamWorld Dig 2 Perfect Upgrade Pacing

From [Medium/Gandheezy](https://gandheezy.medium.com/steamworld-dig-2-axby-review-695d7db73ed5) and [Metacritic User Reviews](https://www.metacritic.com/game/steamworld-dig-2/user-reviews/):

- "Upgrade system is perfectly balanced so you're never over or under powered"
- Each tool "serves a very specific purpose: to help you keep digging"
- "Reviewers had trouble choosing among available upgrades, because each has noticeable effect"
- Creates "just one more trip" mentality to hit next tier
- Cog system: Collectibles that customize tools with mods - adds player agency
- Key insight: **Upgrade should solve problem player JUST faced, not future problems**

**GoDig Learning**: Each upgrade should directly address a frustration the player just experienced. Track player pain points and surface relevant upgrades.

### Dome Keeper Success Analysis (90% Positive, 17K Reviews)

From [RetroStyleGames](https://retrostylegames.com/blog/why-dome-keeper-so-good/):

- "Simple core loop but very addicting"
- "Music, presentation, and gameplay loop are all 10/10"
- "Feeling of getting back to base with a second to spare" = core satisfaction
- Variety through unlocks: extra domes, game modes, starting modifiers
- Criticism: "Building same things in same order" - need more build variety

**GoDig Advantage**: Our surface expansion (multiple shops) and pickaxe variety should provide more decision variety than Dome Keeper.

### Game Juice Calibration (Over-Juicing Warning)

From [Wayline](https://www.wayline.io/blog/the-perils-of-over-juicing) and [BloodMoon Interactive](https://www.bloodmooninteractive.com/articles/juice.html):

- "When used correctly, screen shake creates engaging game feel; if overused, players feel nauseous"
- "Reserve intense effects for special occasions" - mining is CONSTANT
- **Screen shake**: 0.1-0.3 seconds, randomize direction, ease out smoothly
- **Particles**: "Start basic, layer complexity for important events"
- **Hitstop**: Both attacker and target pause for impact feel
- "Juice can't fix bad design" - core loop must work without any juice first
- Accessibility: "Implement options to customize intensity of visual/audio effects"

**GoDig Implementation**: Subtle feedback for regular mining, reserved juice for ore discovery and upgrades. Always include option to reduce effects.

### Keep Digging (January 2026): New Competitor

From [Steam](https://store.steampowered.com/app/3585800/Keep_Digging/):

- Multiplayer co-op mining game reaching 1,000m depth across 10 layers
- No combat, pure exploration focus - validates our cozy mining approach
- Up to 8 players, cross-progression between solo and multiplayer
- Equipment upgrades to level 20, over 8 upgradeable technologies
- "Hybrid approach - dig vertically until exciting depth, then explore sideways"

**GoDig Competitive Position**: Our ladder-based risk system remains unique differentiator. Keep Digging lacks the tension mechanic that makes GoDig's push-your-luck compelling.

### Addictive Core Loop Anatomy (2025 Consensus)

From [Mr. Mine Blog](https://mrmine.com/blog/what-are-idle-mining-games-and-why-are-they-soaddictive//) and [NotebookCheck](https://www.notebookcheck.net/Fun-grind-and-addictive-progression-these-games-motivate-with-more-than-just-the-endgame.1086973.0.html):

- **Core loop**: dig-collect-upgrade-repeat is inherently compelling
- **Discovery thrill**: "Rare finds aren't just for fun - they help unlock stronger tools"
- **Low time commitment**: Perfect for mobile - "very little required time" yet engaging
- **Constant progress**: "The more you play, the more efficient and powerful you become"
- **Idle element appeal**: Progression even when not actively playing (for hybrid games)

**GoDig Validation**: Our active mining + ladder risk differentiates us from idle games while keeping the core loop addictive.

### Two-Tier Juice System Design

Based on Session 18 research synthesis:

**Tier 1: Subtle Constant Feedback (Mining)**
- Tiny dust particles on block break (2-4 particles)
- Soft "crunch" sound with slight pitch variation
- Micro screen shake (0.5-1 pixel, optional)
- Quick brightness flash on broken block (50ms)

**Tier 2: Reserved Discovery Juice (Ore/Upgrades)**
- Burst of colored particles matching ore type (8-12 particles)
- Distinct "discovery" chime + ore-specific sound
- Medium screen shake (2-3 pixels, 100ms)
- Glow effect radiating from ore
- HUD popup with ore name + value
- Haptic feedback (short burst on mobile)

**Tier 3: Jackpot Moments (Rare/Legendary)**
- Full particle explosion (20+ particles)
- Unique legendary sound effect
- Dramatic screen shake (4-5 pixels, 200ms)
- Screen flash with ore color tint
- Large floating text with celebration words
- Strong haptic feedback
- Brief time slowdown (100ms)

### Implementation Priorities Update (Session 18)

| Feature | Priority | Rationale |
|---------|----------|-----------|
| 5-minute complete loop | P0 | Median session is 5-6 min; loop must fit |
| Upgrade solves frustration | P1 | SteamWorld Dig 2's "noticeable effect" pattern |
| Two-tier juice system | P1 | Prevent fatigue, reserve impact for discoveries |
| Juice accessibility options | P2 | Allow players to customize effect intensity |

### Implementation Specs Created (Session 18)

- `GoDig-implement-5-minute-655909a4` - 5-minute complete loop guarantee
- `GoDig-implement-upgrade-solves-92eac94a` - Upgrade solves recent frustration pattern
- `GoDig-implement-subtle-mining-7540eb96` - Subtle mining vs reserved discovery juice
- `GoDig-implement-game-juice-8a70d20e` - Game juice accessibility options
- `GoDig-research-keep-digging-512417e2` - Keep Digging competitive analysis

## Sources (Session 18)

- [Mobile Session Length - Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/session-length)
- [Gaming Session Length by Age - Quantumrun](https://www.quantumrun.com/consulting/average-gaming-session-length-by-age-group/)
- [FTUE Best Practices - GameAnalytics](https://www.gameanalytics.com/blog/tips-for-a-great-first-time-user-experience-ftue-in-f2p-games/)
- [FTUE Tips - Unity](https://unity.com/how-to/10-first-time-user-experience-tips-games)
- [SteamWorld Dig 2 Review - Gandheezy](https://gandheezy.medium.com/steamworld-dig-2-axby-review-695d7db73ed5)
- [SteamWorld Dig 2 - Metacritic User Reviews](https://www.metacritic.com/game/steamworld-dig-2/user-reviews/)
- [Why Dome Keeper Is Good - RetroStyleGames](https://retrostylegames.com/blog/why-dome-keeper-so-good/)
- [Over-Juicing Warning - Wayline](https://www.wayline.io/blog/the-perils-of-over-juicing)
- [Game Juice Guide - BloodMoon Interactive](https://www.bloodmooninteractive.com/articles/juice.html)
- [Keep Digging - Steam](https://store.steampowered.com/app/3585800/Keep_Digging/)
- [Idle Mining Games Addiction - Mr. Mine Blog](https://mrmine.com/blog/what-are-idle-mining-games-and-why-are-they-soaddictive//)
- [Fun Grind Progression - NotebookCheck](https://www.notebookcheck.net/Fun-grind-and-addictive-progression-these-games-motivate-with-more-than-just-the-endgame.1086973.0.html)

## Session 22: Core Loop Validation & Competitor Updates (2026-02-01)

### Deep Rock Galactic: Rogue Core (Q2 2026 Early Access)

Major new competitor entering the mining roguelite space:
- Players start with ONLY their pickaxe - must scavenge weapons/equipment
- The "Grayout Barrier" disables technology on contact - forces survival gameplay
- Expenite harvesting enables crafting progression within runs
- 1-4 player co-op with meta-progression between runs

**GoDig Competitive Position**: Our mobile-first ladder economy remains unique. DRG:RC is a PC co-op shooter with extraction focus - different target audience but validates the mining roguelite space continues to grow.

### The Over-Juicing Problem

Critical design insight from Wayline and game design research:
- "Exaggerated feedback is harming game design" - when every hit feels like nuclear explosion
- Screen shake creates engaging feel "if used correctly; if overused, players feel nauseous"
- Juice as smokescreen: "If combat lacks strategic depth, designers might just add more screen shake"
- Animation communicates weight better than particle effects
- Dark Souls feels significant through animation, not particles

**GoDig Application**:
- Reserve intense effects for discoveries and upgrades
- Regular mining should have subtle, satisfying feedback only
- Test by playing for 5+ minutes - does feedback feel fatiguing?

### Push-Your-Luck Design Validation

BoardGameGeek and BGDF research confirms our ladder mechanic is well-designed:
- "Push your luck is different than pure luck" - requires meaningful DECISIONS
- Core tension: "decide whether to keep going to gain more... and risk losing it all or stopping"
- Self-balancing mechanics: "fewer players still in = greater potential reward"
- Quacks of Quedlinburg adds mitigation: chip return mechanic reduces bad luck impact

**GoDig Validation**: Our ladder depletion creates superior progressive risk vs sudden bust mechanics. The gradual tension buildup is better than binary "you're dead" moments.

### Dome Keeper Player Feedback Polarization

Analysis of 9,500+ reviews (90% positive) reveals key insights:

**Negative Feedback**:
- "too slow, repetitive, grindy"
- "so much back and forth"
- "tediously inefficient input"

**Positive Feedback**:
- "addicting mix of tower defence and Dig Dug"
- "10/10 gameplay loop"
- "nothing feels better than getting back to base with a second to spare"

**Key Learning**: Players who love it praise the TENSION. Players who hate it cite TEDIUM. The difference is whether return trips feel like achievement or chore.

**GoDig Application**: Our return trip must feel like achievement through:
1. Wall-jump = skill expression
2. Ladder placement = strategic decision
3. Elevator unlock = late-game convenience reward

### SteamWorld Dig Upgrade Pacing (Gold Standard)

Deep dive into why upgrades feel satisfying:
- Core flow: "enter mine -> dig -> uncover ore/gems -> return to surface -> sell -> upgrade tools"
- Each upgrade has noticeable effect creating "just one more trip" mentality
- SteamWorld Dig 2: "impeccably paced, new powers opening up just when comfortable"
- Fastest pickaxe: "immensely satisfying to just blast through the mines at super-sonic speed"

**GoDig Implementation Requirement**: Each pickaxe tier must be dramatically different:
- Not just faster stats
- Different visual appearance
- Different sound effects
- Different particle effects
- Player should know which pickaxe they have by FEEL alone

### Core Loop Greybox Test Requirement

2025-2026 research consensus is clear:
- "If your core loop isn't fun, it doesn't matter how great your narrative or physics interactions are"
- "Without tight and emotionally satisfying gameplay, no amount of progression can sustain engagement"

**GoDig Critical Validation**: We MUST test tap-to-mine with NO systems:
1. Create greybox test level (no textures, no progression)
2. Playtest with 3+ people
3. Ask: "Is breaking a single block satisfying?"
4. If no, fix core feel before adding systems

### Inventory Full as Decision Moment

Research shows inventory limits are design feature, not limitation:
- "Limited inventory forces players to make decisions"
- "Is it worth the risk to grab that rare loot or head back to camp and unload?"
- Resident Evil 4 briefcase: "puzzle-like mechanic rewarding players who maximized space"

**GoDig Application**: When inventory is full, create decision moment:
- Show what ore would be collected
- Options: Drop item / Return to Surface / Keep Mining
- This IS our push-your-luck moment
- Make the decision feel meaningful, not annoying

### Session 22 Implementation Specs

| Spec ID | Feature | Priority |
|---------|---------|----------|
| GoDig-implement-two-tier-614931d2 | Two-tier juice system | P1 |
| GoDig-implement-pickaxe-tier-d9f2b6a2 | Pickaxe tier differentiation | P1 |
| GoDig-implement-full-inventory-cf22e045 | Full inventory decision moment | P1 |
| GoDig-implement-core-loop-bfedf6c9 | Core loop greybox validation | P0 |

## Sources (Session 22)

- [DRG: Rogue Core - Steam](https://store.steampowered.com/app/2605790/Deep_Rock_Galactic_Rogue_Core/)
- [DRG:RC Gameplay Info - Game8](https://game8.co/articles/reviews/deep-rock-galactic-rogue-core-gameplay-and-story-info)
- [Over-Juicing Problem - Wayline](https://www.wayline.io/blog/the-juice-problem-how-exaggerated-feedback-is-harming-game-design)
- [Game Feel Guide - Blood Moon Interactive](https://www.bloodmooninteractive.com/articles/juice.html)
- [Push Your Luck Mechanics - Board Game Design Course](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/)
- [Push Your Luck - BoardGameGeek](https://boardgamegeek.com/boardgamemechanic/2661/push-your-luck)
- [Dome Keeper Reviews - Metacritic](https://www.metacritic.com/game/dome-keeper/user-reviews/)
- [Dome Keeper Steam Reviews](https://steamcommunity.com/app/1637320/reviews/)
- [SteamWorld Dig Review - Play Critically](https://playcritically.com/2021/11/22/steamworld-dig-review/)
- [SteamWorld Dig 2 - Game Informer](https://gameinformer.com/games/steamworld_dig_2/b/switch/archive/2017/09/28/steamworld-dig-2-review.aspx)
- [Core Loop Design - GameAnalytics](https://www.gameanalytics.com/blog/how-to-perfect-your-games-core-loop)
- [Mobile Retention Strategies - Segwise](https://segwise.ai/blog/boost-mobile-game-retention-strategies)
- [Dopamine Loops in Games - JCOMA](https://jcoma.com/index.php/JCM/article/download/352/192)
- [Inventory Systems - Meegle](https://www.meegle.com/en_us/topics/game-design/inventory-systems)
- [Resource Management - Meegle](https://www.meegle.com/en_us/topics/game-design/resource-management)
- [Dig Dig Boom - Steam](https://store.steampowered.com/app/2026040/Dig_Dig_Boom/)
