# Fun Factor Analysis - Mining Game Core Loop

> Research compilation from game design analysis, forums, and similar games.
> Last updated: 2026-02-01 (Session 3: Return Trip Tension & Sell Satisfaction)

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
