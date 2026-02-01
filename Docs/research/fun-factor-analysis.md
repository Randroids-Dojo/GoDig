# Fun Factor Analysis - Mining Game Core Loop

> Research compilation from game design analysis, forums, and similar games.
> Last updated: 2026-02-01 (Session 7: Push-Your-Luck & Quick Restart)

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
