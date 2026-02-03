---
title: "research: Ongoing competitive analysis - mining/digging games"
status: pending
priority: 2
issue-type: research
created-at: "2026-02-01T07:56:09.847420-06:00"
---

## Purpose

Continuous monitoring of mining game releases, player feedback, and game design discussions to keep GoDig's design evolving and competitive.

## Research Areas

### Games to Monitor
- **Active Mining**: SteamWorld Dig series, Super Motherload, Terraria
- **Idle Mining**: Mr. Mine, Idle Miner Tycoon, Idle Mining Empire
- **Roguelite Mining**: Dome Keeper, Spelunky 2
- **New Releases**: itch.io indie mining games, Steam new releases

### Discussion Forums
- Reddit: r/gamedesign, r/indiegaming, r/roguelikes
- Steam discussions for competitor games
- BoardGameGeek for push-your-luck mechanics

### Design Principles to Track
- Core loop satisfaction
- Push-your-luck mechanics
- Mobile-specific UX patterns
- Monetization that doesn't frustrate

## Research Log

### Session 8 (2026-02-01)
**Mr. Mine Analysis**:
- Depth-based surprises key to engagement
- Fast satisfaction curve (minutes, not hours)
- Hybrid active/passive appeals to multiple playstyles
- Milestones tied to content unlocks, not just numbers

**Dome Keeper 2024-2025**:
- Hit 1M players - validates mining + defense loop
- Complaints: "too slow, repetitive, grindy"
- Mitigation: Quick-buy, elevator, procedural variety

### Session 9 (2026-02-01)
**Spelunky Risk Design Analysis**:
- Core insight: "game of information and decision-making, not execution"
- Every micro-decision has risk/reward calculation
- Risk management separates great games from good games
- Our ladder system creates similar meaningful decisions

**Push-Your-Luck Board Game Mechanics**:
- Self-balancing: deeper = better rewards but higher risk
- Gradual tension buildup (like Deep Sea Adventure) beats sudden bust
- Mathematical balance: ~80% success per moment for 50% overall bust
- Our gradual ladder depletion creates superior tension curve

**Mobile Onboarding 2025 Best Practices**:
- Progressive onboarding: one mechanic at a time
- "One-minute rule": win player's heart in first 60 seconds
- Tutorial levels should BE fun gameplay (Candy Crush)
- Never monetize before first upgrade

**"One More Run" Psychology**:
- Defeat + determination = addictive loop
- Every run teaches something new
- Meta-progression critical (Rogue Legacy pattern)
- Quick restart is essential

**Dome Keeper 2025-2026 Updates**:
- Multiplayer mode in development
- Artillery and Tesla domes add strategic variety
- Community feedback: gadget randomness being addressed
- Lesson: plan for post-launch economy tuning

**itch.io Mining Game Landscape**:
- Terminal Descent: idle mining robots - validates core loop
- Astropop: asteroid mining roguelike - space setting
- Veinrider: incremental journey into depths
- Competition growing but few do mobile well

### Session 10 (2026-02-01)

**Balatro Variable Reward System (GDCA 2025 Game of the Year)**:
- Exponential growth via multipliers creates "making numbers go up" satisfaction
- Variable ratio reinforcement: uncertainty keeps players engaged
- Randomness + player agency: "You cannot pay to win here. You have to learn how to use the chaos."
- Meta-progression: even failures yield permanent rewards
- **GoDig Application**: Each block mined is a micro-uncertainty moment. Ore discovery parallels card draw excitement.

**Terraria Biome Discovery Lessons**:
- 64M+ copies sold - biome priority system creates exploration tension
- Evil biomes (Corruption/Crimson) spread and infect - creates dynamic world
- Board game adaptation uses tile-based world generation for replayability
- **GoDig Application**: Our 7 layers serve as "biomes" - each should have distinct visual/mechanical identity

**Cozy Mining Games & Casual Market (2025)**:
- Casual games: $24.2B in 2025, 31% of global downloads
- 45+ demographic fastest growing, drawn to cozy simulations
- 70% likelihood upcoming mining games will blend with management elements
- Forager: "fast-paced loop makes mining feel satisfying"
- **GoDig Application**: Our active mining is differentiated from idle games - but we can learn from cozy pacing

**Haptic Feedback Best Practices (iOS/Android)**:
- iOS significantly outperforms Android for haptic quality/control
- Marvel Snap example: "feel the weight of each move" creates memorable interactions
- Haptics must sync precisely with visuals - even small delays feel unnatural
- Reserve custom haptic patterns for high-value scenarios (ore discovery, upgrades)
- **GoDig Implementation**: Add haptic feedback for ore discovery (short burst), upgrade celebration (longer rumble), ladder placement (subtle tap)

**One-Hand Mobile Controls Research**:
- 49-75% of smartphone users operate one-handed
- "Subway Thumb" is most casual grip - game must support this
- 59% of users disengage if controls are physically uncomfortable
- Green zone (easy reach) vs yellow (manageable) vs red (hard) - design for thumb arc
- **GoDig Application**: Dig controls are already tap-based. HUD elements must be in thumb-reachable zones.

**Hades 2 Progression Pacing (Metacritic 94/100)**:
- Early Access used to tune balance based on player feedback
- Boons rebalanced: "Rare and Epic feel even more special now"
- New foes spawn in completed areas to maintain challenge
- Ending reworked based on player feedback post-launch
- **GoDig Lesson**: Plan for post-launch economy tuning. Start with generous progression, tighten later.

**Idle Game Monetization 2025**:
- Rewarded videos = 60-70% of idle game revenue
- Best practice: don't front-load monetization - wait until Day 3
- "Ads that bail players out, not slow them down" = 42% engagement (vs 25-30% average)
- Hybrid models work: ads + IAPs + battle passes
- **GoDig Application**: First upgrade free, monetization gates only after player is invested

**Dome Keeper 2025 Community Feedback**:
- Assessor character complaints: "too much downtime waiting"
- Players want rhythm variation: "If pressure is always max, it's just exhausting"
- Developer response: community feedback integral to development success
- Versus mode in development: competing teams on shared mine
- **GoDig Learning**: Vary tension rhythm - surface visits should provide genuine relief

**itch.io Mining Games 2025**:
- Terminal Descent: "Mine, drill, blast to deepest depths" - validates incremental core loop
- Space Miner: asteroid mining clicker - casual/strategy hybrid
- PlanetCore: drill + survive + upgrade missions
- Mine is Life: 2025 game jam entry - fresh competition emerging
- **Competitive Position**: GoDig's ladder-based risk system is unique differentiator

### Session 11 (2026-02-01)

**Vampire Survivors - Gambling Psychology Applied Successfully**:
- Creator Luca Galante applied gambling industry experience to game design
- Result: "distils the essence of compelling, just-one-more-go game design"
- PENS Model: Games fulfill competence (power/mastery) and autonomy (freedom)
- Minimal input (directional only) but maximum feedback (constant visual rewards)
- **GoDig Application**: Our tap-to-dig is simple; feedback (particles, sounds, toasts) must be rich

**Mining Game Grindiness - The Player Feedback Spectrum**:
- Keep on Mining (2025): "dopamine-inducing early, repetitive mid-game" - pacing issue
- Deep Rock Galactic Survivor: "best loop mechanically" but exponential scaling ruins late game
- Super Mining Mechs: "If digging isn't satisfying by itself, the game isn't for you"
- Hytale: Developer publicly stated mining "isn't fun enough" - they're fixing it
- Key insight: Mining must be inherently satisfying BEFORE any systems/upgrades

**What Makes Mining Satisfying (Forum Consensus)**:
- Deep Rock Galactic: "digging away and finding caverns etc is so much fun"
- Stardew Valley: time limits + enemies + shortcuts + bombs = variety
- SteamWorld Dig 2: "frequently mentioned as standout" for upgrade feel
- **Common thread**: Discovery and exploration, not just extraction

**Cult of the Lamb - Two-Loop Retention**:
- Dungeon crawling feeds base building, base building motivates dungeons
- Forgiving death: lose "a little bit of progress" not everything
- "Brilliant entry point to roguelites" - accessibility praised
- **GoDig Application**: Our surface/underground loops feed each other similarly

**Push-Your-Luck: Deep Sea Adventure Model**:
- Players share single oxygen supply - greed affects everyone
- Taking treasure = slowing return + draining shared resource
- "Incredible moment of anticipation" when decisions revealed
- **GoDig Application**: Our ladder depletion is gradual like oxygen - BETTER than sudden bust

**Mobile Session Reality (2025 Data)**:
- Median session: 4-6 minutes (not 15-30 as often assumed)
- Players average 4-6 sessions daily, 3-5 min each
- 80% of players churn by Day 1 - retention is critical
- First session 10-20 minutes is vital for F2P success
- **GoDig Application**: Design for 5-minute complete loops, hook within 2 minutes

**SteamWorld Dig 2 Addiction Analysis**:
- "Gameplay loop of dungeon crawler - little progress each outing, always gathering rewards"
- "Price/benefits of items well-tuned" - creates "just a few more coins" feeling
- "Impeccably paced - new powers when comfortable" - timing matters
- Upgrade impact: "Tier 1 vs Tier 3 should feel like night and day"

**Motherload Tedium Problem**:
- "Repetition of going up and down gets increasingly tedious"
- "Best part is upgrading, everything in between is grind"
- Mitigation: underground stations charge more but save time
- **GoDig Application**: Need late-game infrastructure (elevator) to prevent tedium

### Session 12 (2026-02-01)

**Slay the Spire Metrics-Driven Design (GDC Vault)**:
- Sold 1M+ copies first year, 3M+ on Steam with 97% positive rating
- "Metrics-driven design and balance" - heavy data usage throughout Early Access
- Community feedback integral to balance while maintaining game feel
- Key insight: "Allowing for combos and strong synergies is a hallmark of their design"
- Weekly updates during 14-month Early Access - iteration matters

**Loop Hero Idle/Active Hybrid Design**:
- "Brilliant combination of idle design with persistence and run focus of roguelite"
- "Commit or retreat" method creates meaningful decisions
- Resource retention varies by exit: die=30%, early retreat=60%, camp=100%
- Won Best Foreign Mobile Game at 2025 Pegases Awards
- Criticism: "On the hard side due to RNG and grinding required"

**Vertical Slice Best Practices (GDC 2025)**:
- "Becoming more important than ever" for publisher attention (Playstack - publishers of Balatro)
- "Make First 10 Seconds Count" - bold visual, sound tone, player control quickly
- Player validation data critical: "30-40% completed feedback surveys"
- "Core mechanic produces repeatable fun across multiple playtests"

**Mining Game "Feel" 2025 Consensus**:
- Hytale dev: "Mining isn't fun enough" - reworking audiovisual feel
- Deep Rock Galactic: "digging away and finding caverns is so much fun"
- SteamWorld Dig: "best platforming mechanics not made by Nintendo"
- Stardew Valley: time limits + enemies + shortcuts + bombs = variety
- Key: Discovery and exploration, not just extraction

**Mobile Game Economy First 5 Minutes**:
- 62% of players abandon due to lack of currency/resources (GameAnalytics)
- Dual currency (soft/hard) in 78% of successful titles
- "Layered approach perfect for mobile" - 5 min bus ride or 1 hour session
- Warning: "Too generous = blast through content, too stingy = frustrated quit"
- 30% increase in engagement from steady reward tapering

**Motherload Underground Stations**:
- "Stations at various levels underground so don't have to go all the way back up"
- They charge more (justified as transport cost)
- First "screw this game" moment: tedium of return trip
- Solution appears as REWARD: "underground outpost appears as a reward"
- **GoDig Application**: Elevator unlock should feel like achievement, not purchase

**Risk vs Reward Psychology**:
- Board games teach: "thrill of enormous success + devastation of losing all"
- Push-your-luck is DISTINCT from pure luck - requires meaningful CHOICES
- Incan Gold: self-balancing (fewer players = greater reward)
- "Good tension: I wish I could do both but must choose"
- "Bad frustration: I can't do anything meaningful"

**First Upgrade Hook Psychology**:
- "First few rounds feel tedious as characters move slowly"
- "Players who prove patience won't go unrewarded"
- "Satisfaction of seeing hero improve keeps players glued"
- Mobile: 40% session length increase when controls mastered in 5 min
- Critical: First upgrade must be FELT immediately

### Session 13 (2026-02-01)

**Deep Sea Adventure: The Gold Standard for Shared Resource Tension**:
- Core mechanic: All players share a single oxygen supply (starts at 25)
- Taking treasure = oxygen drains faster + movement slows (double punishment for greed)
- "If one dives too deep, other divers' lives will be on the line"
- Social tension: "convincing people not to take treasure if you're too far from submarine"
- Chain reaction: "if one person picks up then everyone else almost always follows"
- **GoDig Application**: Our ladder depletion creates similar gradual tension, but SOLO (no social blame). This is BETTER for mobile - player only blames themselves.

**The Return Journey Problem (Dome Keeper / Motherload)**:
- Dome Keeper: "Mining underground is strangely peaceful... but tension always hangs in background"
- Motherload: "Repetition of going up and down gets increasingly tedious"
- Solution: Gadgets that make return easier (Lift, Teleporter) unlock as REWARDS
- Dome Keeper Lift: "cut down time to go from mines to dome exponentially"
- **GoDig Critical Insight**: The return trip is where FUN can die. Must balance:
  1. Early game: Wall-jump + ladders = skill expression, feels clever
  2. Mid-game: Elevator unlock = reward for investment
  3. Late-game: Teleport scroll = emergency bailout (premium feel)

**Push-Your-Luck Board Game Design (BoardGameGeek Analysis)**:
- Core tension: "stop or keep going - get too greedy, end up with nothing"
- Self-balancing: "fewer players still in = greater their potential reward"
- Best games: Quacks of Quedlinburg (bag-building + push), Flip 7 (Spiel des Jahres 2025 nominee)
- Deep Sea Adventure: 2015 Game Market Prize winner - validates shared tension model
- **GoDig Unique Angle**: Solo ladder economy = all tension, no social blame

**SteamWorld Dig Pickaxe Satisfaction Analysis**:
- "When you get that newest upgrade so you can dig through each block with only one hit, it's immensely satisfying"
- Sound design critical: "tinkling noise becomes clearer with higher tempo with every subsequent hit"
- Progression criticism: upgrades are "boringly straightforward" (just stat increases)
- **GoDig Improvement**: Each tier should have VISUAL/AUDIO differences, not just faster

**Power Progression Psychology**:
- "Understanding the psychology behind power progression helps create experiences that resonate"
- Balance intrinsic (mastery) vs extrinsic (rewards) motivation
- Dopamine: "each time user achieves something exciting, brain releases dopamine"
- Power creep danger: "new content must be challenging, but makes older content boring"
- **GoDig Solution**: Horizontal progression later (cosmetics, automation) not just vertical

**Just One More Run Psychology (2025 Analysis)**:
- "Endless loop of defeat and determination has made roguelikes one of the most addictive genres"
- Quick runs matter: "games where runs are pretty quick help because you can go from doing great to dead fast"
- Nuclear Throne: "great because it's quick - you can get to the Throne in less than ten minutes"
- Risk of Rain 2: "item drops turn into stacking frenzy of busted combinations"
- **GoDig Target**: 5-minute complete loop (dig -> sell -> upgrade) enables "one more run"

**Idle Miner Tycoon Economy Design**:
- "Upgrades feel rewarding... love how fast the progression feels without forcing you to spend money"
- Core satisfaction: "return-from-idle" animation showing idle cash earned
- Prestige system: "resets progress but gives permanent multiplier"
- "Satisfying loop where small actions support big goals"
- **GoDig Inspiration**: Surface visits = our "return from idle" moment (even though active)

**Sell Animation Psychology**:
- "Accumulated coin piles accompanied by sparkling sounds evoke feelings of achievement"
- "Vivid visuals—shining coins, flashing lights—amplify perceived reward"
- Short-term rewards: "immediate feedback, coin or sound effect after completing task"
- "Ideally awards should be made immediately... player quickly confirms competence"
- **GoDig Implementation**: Selling ore needs SATISFYING coin cascade animation + sound

**Roguelite Time Pressure Design**:
- "Time-based clock prods player along, imposes cost on spending too long"
- "Leaving good players without time pressure invites optimal tedium"
- 20-30 minute ideal run length for roguelites, but mobile is different
- "Every roguelite has a period during a run where it starts feeling like a chore"
- **GoDig Solution**: Natural stopping points (surface return) prevent chore feeling

### Session 14 (2026-02-01)

**Deep Rock Galactic Extraction Phase Design**:
- Extraction creates "satisfying tension" - players must backtrack to escape pod once objective is complete
- Community debates: time limit (30 seconds) feels punishing when pod spawns far away
- Deep Rock Galactic Survivor: Phase 5 extraction timer criticized as redundant after boss kill
- Season 6 (Q1 2026) introduces "Heavy Extraction" mission type with booster rockets
- Lift gadget "exponentially cuts return time" - critical for late-game usability
- 90% positive (17,000+ reviews) validates mine-defend-extract core loop
- **GoDig Application**: Our surface return isn't timed, but ladder depletion creates similar pressure. Elevator unlock should mirror DRG's Lift satisfaction.

**Cozy Game Design: Safe Zone Principles (Gamasutra)**:
- Coziness = safety + abundance + softness (lower stress, needs met, gentle stimuli)
- Distinct thresholds between dangerous/safe spaces heighten relief (snowstorm → cabin)
- Protection signals: sleeping pets, relaxed guardians, warm tones, enclosed spaces
- Mundanity matters: familiar settings (tea rooms, pantries) cozier than exotic ones
- Focus through elimination: no interruptions, intimate framing, knowable space
- Undertale cited: warm tones + relaxed guardian + focused interior = safe haven
- **GoDig Application**: Surface should have warm colors, enclosed shop interiors, no threats visible. Underground should feel increasingly unfamiliar.

**Noita Physics-Based Destruction**:
- "Every pixel is physically simulated" - 95% positive rating (45,499 reviews)
- Environmental destructibility is "key to appeal and greatest asset"
- Liquids pour/fill realistically - creates emergent problem-solving
- Chain reactions: burn wood → collapses → releases toxic sludge → erodes enemies
- Players describe "amazed by pretty pixels and physics" as initial hook
- "You can destroy the whole world if you wish" - player agency maximized
- **GoDig Application**: Our block destruction should feel impactful. Particle effects, debris falling, dust clouds. Each dig should feel like "making a mark on the world."

**Mobile Session End Celebrations (2025 Best Practices)**:
- Session-end rewards create "positive experience" - players feel appreciated
- Level completion events provide immediate rewards/recognition
- "Little 'you did it!' moments" via badges, trophies, animations boost retention
- Satisfying animations encourage return visits
- Game UI Database: over 1,300 games with 55,000 UI screenshots for reference
- Responsive animation feedback makes sequences "satisfying" and "organic"
- **GoDig Application**: After selling ore, need celebratory moment. After safe return from deep dive, need "you made it!" relief celebration.

**Mr. Mine - Idle Mining Progression (88% positive, 6,857 reviews)**:
- "Adventure and discovery" emphasized over pure incremental progress
- Each new depth introduces "rarer minerals, hidden structures, surprises"
- 100+ drill upgrades create constant progression milestones
- Progression unlocks: battles, reactors, caves, new worlds - content gates, not just numbers
- "Keeps players hooked through constant sense of discovery"
- **GoDig Lesson**: Depth should unlock NEW THINGS, not just harder blocks. Caves, treasures, secrets.

**Core Keeper Mining Progression (2025)**:
- Biome-based ore progression: Copper → Tin → Iron → Scarlet → Octarine → Galaxite
- "Each mining skill level increases mining damage by 1" - granular progression
- Automation via drills unlocks mid-game - first step into passive income
- Ore Boulders as "plentiful source" once drills available - reward for investment
- Crafting station prerequisites create natural gates: Tin Workbench → Iron Workbench
- "Points invested into perk trees may be refunded" - encourages experimentation
- **GoDig Application**: Our pickaxe tiers should have similar "can I mine this?" gating by depth.

**Roguelike Design Principles (2025 Synthesis)**:
- "Player themselves getting better" is the core hook - skill accumulates across runs
- Expert players have "higher-than-average chance at winning" despite same odds
- Near-instant restart after failure prevents antagonizing frustrated players
- "One more game" mentality = strong addiction factor
- "Satisfying and short gameplay loop" critical for repeated play (Hades cited)
- Permadeath adds "strong sense of consequences" - every action matters
- **GoDig Application**: Death should be quick + restart immediate. Our "emergency rescue" should feel like a consequence but not punishment.

**Dome Keeper 2025 Deep Dive**:
- Central tension: "do you risk delving deeper, or return to prepare for attack?"
- Lift gadget: "important boost late-game" for return trip efficiency
- Three resources (iron, water, cobalt) create "efficiency puzzle"
- 90% positive with 17,000+ reviews validates the mine-defend loop
- Multiplayer announced for 2026 - validates cooperative mining interest
- Xbox Game Pass December 2025 - broad audience appeal proven
- **GoDig Distinction**: No defense mechanic means pure push-your-luck on ladder economy

**Incremental Game Psychology: "Number Go Up"**:
- Core hook: "you click the cookie, you have a cookie, enough cookies net automatic gains"
- Shortcut to positive feedback loop - minimal friction to reward
- Genre exploding: "new games developed almost daily"
- Itch.io game tagline captures it: "Drop balls. Make money. Number go up. Happy."
- **GoDig Application**: Our ore count, coin count, depth record - all "numbers going up". Make each visible and satisfying.

### Session 15 (2026-02-01)

**Astroneer Terrain Deformation Design**:
- "Decided to make the hardest possible game on all dimensions" - picked challenging technical approach
- Core philosophy: "terrain deformation from day one... the entire game was built around that idea"
- "Sculpting the terrain is what people want to do in the game. It's kind of like the output valve."
- "Full ground deformation with your digging tool" creates "simple joy to creating and finding things"
- Dig Tool offers excavate, raise, flatten modes - versatile terrain manipulation
- Can "dig right to the core of each planet" - validates infinite depth appeal
- Marching cubes algorithm + chunk-based rebuilding for performance
- **GoDig Application**: Our block-based digging is simpler but each dig should still feel impactful. The "making a mark on the world" feeling is key.

**Factory Builder Automation Design (Satisfactory/Factorio)**:
- Satisfactory: "glossier, more accessible experience, effectively streamlining many of the ideas Factorio pioneered"
- Infinite resource deposits in Satisfactory remove tedious "seek new veins" loop
- Conveyor belts are "own type of logic puzzle" - players optimize and iterate
- "Overseeing a system of interconnected machines" creates satisfying complexity
- Player quote: "I don't know where the factory ends and I begin" - deeply immersive
- Factorio includes tower defense element (pollution attracts enemies) - defense + mining
- **GoDig v1.1 Application**: Automation buildings (Auto-Miner Station) should create simple optimization puzzles. Don't over-complicate - Satisfactory succeeded by streamlining.

**Procedural Generation Discovery Principles**:
- "The key is control: randomness should surprise players, but never betray them. Think of it like jazz."
- Cellular automata mimics natural cave erosion - creates believable chambers
- Wave Function Collapse creates "unpredictable but still cohesive" results
- Hidden corridors connect rooms, offering "alternative routes if discovered"
- Deep Rock Galactic: completely destructible procedural caves are "key feature"
- Spelunky 2: "no two expeditions are identical" - keeps runs fresh
- Terraria: "unique secrets, including hidden chests, underground temples, and mysterious NPC encounters"
- **GoDig Application**: Our procedural generation should include discoverable secrets - hidden treasure rooms, rare structure spawns, mini-puzzles.

**Discovery as Core Design Element**:
- "It's not just exploration that's required, but also the sense of discovery that makes these games magical"
- Discovery = "going out into the game to find things you didn't know were there"
- Games need "narrative or mechanical branching" to create true exploration feel
- Mr Mine: "These moments break the routine and add depth to your mining journey. They also make the game feel more like an adventure than a numbers game."
- Keep on Mining: "Hidden journals, audio logs, and artifacts tell tales of the underground"
- Colossal Cave Adventure: original cave exploration + treasure hunt (milestone-based points)
- **GoDig Implementation**: Add discoverable lore elements - old mining journals, strange artifacts, abandoned equipment. These create stories players tell.

**Mobile Player Re-engagement & Comeback Mechanics**:
- 77% of mobile app users churn within first three days - re-engagement critical
- "Welcome back" campaigns: 3-7 days for users who haven't played in X days
- Effective value exchange: "Claim your 1,000 free gems now!" feels like gift, not ad
- Clash Royale: "Season Reset" gives lapsed players fresh start - genius retention
- Returning player rewards: premium currency, gacha tickets, exclusive items
- Timed boosts create urgency: "The better the boost, the greater the incentive not to let it go to waste!"
- Message framing: "You were so close to unlocking a new character! Come back and finish what you started"
- **GoDig Implementation**: Welcome back rewards should include ladders (core resource), premium ore, and progress reminder. Don't punish absence.

**Lapsed Player Segmentation Strategy**:
- ML-driven prediction of who will lapse and who responds to re-engagement
- Segments: at-risk mid-value (moderate rewards), high-value whales (VIP treatment), low-value free (ad-based incentives)
- Mistplay: removed streak pressure from daily rewards - "players were happier without having the pressure"
- **GoDig Learning**: Don't punish missed days. Streak bonuses create guilt, not joy.

**2025 Mobile Retention Benchmarks**:
- Average Day 1 retention: 26%
- Average Day 7 retention: 10%
- Average Day 30 retention: <4%
- Top performers (puzzle/casual): 35%+ Day 1, 12%+ Day 7
- Genshin Impact: 40%+ Day 30 through exploration, events, character upgrades
- **GoDig Target**: Aim for casual-tier retention (30%+ D1, 12%+ D7) through satisfying core loop

### Session 16 (2026-02-01)

**Eureka Moments in Puzzle Games (The Witness Analysis)**:
- The Witness "breaks traditional rules of puzzle design" yet produces "Aha! moments" when players figure things out
- Key insight: "Make the puzzle solution a reward for completing a puzzle that does follow rules"
- Bonfire Peaks DLC cited for "great eureka moments" - short snappy puzzles with discoverable mechanics
- Öoo: "Simple core mechanic — placing and exploding bombs — then mines so much puzzling gold out of it"
- Blue Prince: "Love letter to puzzle-solving with many great moments where the game expands in mind-expanding ways"
- **GoDig Application**: Each new depth layer should introduce a subtle twist that creates "aha" moments - new block types, mechanics, surprises

**Subnautica Depth-Based Progression Model**:
- Core loop: "find resources/blueprints → craft tools/vehicles → discover new areas → find more powerful tools"
- Depth tiers create natural gates: 500m default → 900m (Ruby upgrade) → 1300m (Nickel) → 1700m (Kyanite)
- "Player cannot descend without another technology" - technology unlocks enable physical access
- PDA messages arrive at specific depths/locations creating "natural breadcrumb trail that feels organic"
- "Depth as both literal and metaphorical storytelling device" - deeper = more significant revelations
- "Unlocks narrative progression not through levels but by evaluating player's physical and emotional readiness"
- Open-ended pacing: "You simply can't do things out of order, because there is no real order"
- **GoDig Critical Insight**: Our depth progression should mirror Subnautica's model - pickaxe tiers unlock deeper access, but player chooses when to venture

**Hollow Knight Exploration Reward Structure**:
- Core philosophy: "A lot of these decisions... all built around this sense of discovery"
- Discovery "doesn't just mean finding 500 flags" - it means "unique sights, unique characters, unique systems"
- Map system creates dual reward: players earn complete maps through exploration + incomplete maps create "tense yet exhilarating" moments
- "Collectibles and abilities well placed in far corners of map" - almost every mastered ability rewarded
- "Impressive amount of secrets, hidden areas and optional content" - replayability through discovery
- Criticism: "Relatively limited number of main upgrades" can make progression feel sparse
- Set new metroidvania standard - even Silksong "has to reckon with" Hollow Knight's influence
- **GoDig Application**: Hidden areas should reward skill mastery. Incomplete map knowledge creates tension that complements ladder economy.

**Procedural + Handcrafted Hybrid Design (2025 Best Practices)**:
- Spelunky: "Assembles pre-designed rooms according to strict rules ensuring playability"
- "Each level segment has defined entry and exit points, guaranteeing levels are always completable"
- "Constraints and careful rule design produce better results than pure randomness"
- The Binding of Isaac: "Room pool contains thousands of handcrafted designs" with procedural arrangement
- 2025 trend: "Combining handcrafted areas with procedurally generated ones - best of both worlds"
- "True challenge is controlling randomness so player feels levels are handcrafted each time"
- Gen AI 2025: "Levels that adapt, evolve, and never feel the same twice"
- **GoDig Application**: Use Spelunky-style chunks - handcraft interesting cave formations, special encounters, then procedurally arrange them. Guarantee fun.

**SteamWorld Dig Upgrade Satisfaction Deep Dive**:
- Core flow: "Enter mine → dig → uncover ore/gems → return to town → sell → upgrade tools"
- "Better pickaxe digs faster through harder soil" - direct power-to-progress relationship
- "At the end of each cave, you receive an upgrade... gives very rewarding sense of progression"
- "How perfectly everything 'clicks' - upgrades introduced at just the right time"
- Movement satisfaction: "wall-jump, running, run-jump, high-jump, double-jump make moving around very satisfying"
- SteamWorld Dig 2: "Impeccably paced, new powers opening up just when comfortable with current loadout"
- "Difference in capabilities between start and end is monumental" - dramatic power curve
- Criticism: "Game ends right when starting to feel at peak of power" - pacing issue
- **GoDig Learning**: Time upgrade unlocks to when player has mastered previous tier. The moment of "wait, I can do THAT now?" is pure satisfaction.

**Risk vs Reward Tension Design (2025)**:
- "Risk = potential for negative outcomes (losing currency, health, progress). Reward = benefits motivating those risks"
- "Creates compelling tension: players weigh possibility of loss against allure of significant gains"
- Risk/Reward "naturally creates Tension as players may fail to gain Rewards they want"
- Mobile 2025: "More strategic than previous years. Biggest titles reward long-term planning, careful timing"
- "Excessively risky scenarios may discourage casual players, while overly safe experiences lack excitement"
- Variable payout: "Safer, smaller rewards in early levels → more volatile, lucrative opportunities as players progress"
- **GoDig Application**: Early depths should be low-risk with reliable rewards. Deeper = higher variance but better expected value. Let player CHOOSE risk level.

**Psychology of Grinding & Satisfaction**:
- Self-Determination Theory (SDT): "Drives intrinsic motivation — doing something for the pure joy of it"
- Three needs: autonomy (freedom), competence (mastery), relatedness (connection)
- Grinding "extends far beyond mechanical progression" - shaped by "operant conditioning, variable reward anticipation"
- "Immediate feedback for player actions enhances user experience" - visual/audio cues critical
- Dopamine release: "Each time user achieves something exciting, brain releases dopamine"
- Hedonic engagement: "Active involvement and immersion into activity intended for pure enjoyment"
- Liberation: "Feeling of release, freeing individual from everyday restrictions"
- **GoDig Application**: Mining itself must be the fun, not just the rewards. Each dig needs satisfying feedback. Upgrades amplify already-fun activity.

**"One More Run" Psychology (Rogue Legacy Model)**:
- "Run length, moveset, and outside progression must blend carefully to create can't-put-down game"
- Rogue Legacy: First to establish "winning formula for macro progression outside individual runs"
- Loss aversion: "Couldn't keep all gold before next run, forcing hard choices on what to spend"
- "Players improve over time, eventually reaching point of exploring with dangerous levels of confidence"
- Quick runs critical: "Games where runs are pretty quick help because you can go from doing great to dead fast"
- Some roguelikes integrate narrative into loop (Returnal cited for smart delivery)
- **GoDig Application**: Our emergency rescue = "death" but keeps some progress. Player learns, improves, digs deeper next run. 5-minute loops enable "one more."

**Mobile Battle Pass Ethical Implementation (2025)**:
- Standard structure: Free track + Premium track, Tiers unlocked with XP/missions, 30-60 day reset
- 2025 evolution: "AI-personalized missions, dynamic reward tracks, tiered passes for different spending levels"
- Modern trend: "Resource-rich incentives over decorations" - materials, gacha tickets, direct progression help
- Ethical concerns: "Time-limited rewards create FOMO, compelling excessive time or money investment"
- Younger players "especially vulnerable" to psychological pressure
- Call of Duty Mobile: "Community widely regards its battle pass as best deal in game" - F2P friendly model
- Best practice: "Challenges should be achievable by merely playing the game for a while"
- Regulatory landscape: FTC settlement with Epic Games for "dark patterns" - transparency requirements increasing
- **GoDig v1.1**: If implementing battle pass, make free track genuinely valuable. Premium = cosmetics + convenience, not power.

### Session 17 (2026-02-01)

**Animal Well: Layered Secrets & Minimalist Discovery (2024 GotY Contender)**:
- Solo developer Billy Basso created over 7 years with custom C++ engine, no external libraries
- Inspired by Fez, The Witness, Tunic, and Super Mario Bros. 2's "aggressively nonsensical" secrets
- Three-layer structure: Layer 1 (puzzle game for all), Layer 2 (discovery for keen players), Layer 3 (ARG requiring 50+ players to collaborate)
- No cutscenes - "trusts the player to discover the game world firsthand"
- Level design makes "discovery feel like intuitive play even when it's secretly giving you a well-planned tutorial"
- Encrypted assets with puzzle solutions as decryption keys - prevents data mining
- 650,000 copies sold by August 2024, ranked #2 highest-rated Switch game of 2024
- **GoDig Application**: Layer our secrets - basic ore for all, rare finds for explorers, community puzzles for hardcore players

**Rain World: Anti-Agency as Design Philosophy**:
- "The most anti-videogame idea there is" - player agency is deliberately robbed
- World "exists entirely on its own, completely separate from player's influence and desires"
- Slugcat is "in the middle of the food chain" - avoids combat, emphasizes stealth and flight
- No upgrades, no new weapons, no skill points - "progress is not the goal"
- Creatures "learn to recognize you" - scavengers ally if player provides pearls
- PC Gamer: cumbersome controls "thematically appropriate" for disempowerment
- 95% emergent gameplay - "tells players absolutely nothing about mechanics"
- **GoDig Contrast**: Our game EMPOWERS through upgrades. But learning Rain World's ecosystem lesson: make the underground feel alive and independent of the player.

**Nine Sols: Combat-Focused Metroidvania (2024 Standout)**:
- "Execution nothing short of astonishing" - Metroidvania + Sekiro parry combat in 2D
- Parry system: Perfect parry = satisfying clang + negates damage + grants Qi charge
- Risk/reward: Must "spend" built-up Talisman attacks or waste damage opportunities
- "Flow state" achieved when countering/parrying becomes natural
- Grappling hook from start enables vertical exploration (like our wall-jump)
- Map design: "Clear and accessible" with collectible tracking per zone
- Criticism: "Metroidvania-lite" - rarely need to return to previous areas
- Combat and progression praised as "best parts" that overcome map design weaknesses
- **GoDig Application**: Our combat-free design needs the satisfaction to come from mining itself. Each tier of pickaxe should feel like a "parry mastery" moment.

**Dead Cells: Biome Variety & Path Choice Design**:
- Biomes have unique identities: Toxic Sewers require careful positioning, Ramparts emphasize vertical combat
- Concept graph approach: Entrance/exit placed first, then special rooms, then connecting tiles
- Self-directed difficulty: "Safe path vs dangerous detours" for better rewards
- Cursed Biome mechanic: +10% cursed chest chance, +1 loot level, but harder enemies
- Player always has non-cursed path option - choice, not forced difficulty
- 70+ unique enemies, 20+ biomes, 50+ weapons - prevents "comfort zone" builds
- Procedural generation "altered feeling of combat" - emphasizes instincts over rote learning
- **GoDig Application**: Each layer should have distinct identity. Optional danger zones (collapsed mine, lava pocket) for better rewards.

**Drill Core (July 2025): Mining Roguelite Analysis**:
- Day/night split: Mine resources by day, defend from aliens by night
- Core risk/reward: "Drill down as fast as possible or risk another night for more resources"
- Push too far and core explodes, losing workers and loot
- Roguelite progression: Materials from contracts fund permanent upgrades
- Run length: 30-50 minutes - creates frustration when poor choice kills late run
- Criticism: Variations "don't change gameplay enough" - dwarves on ice still feels same
- Lesson: "Core loop engaging but lack of deeper complexity causes burnout after a few hours"
- **GoDig Advantage**: Our 5-minute loops prevent late-run frustration. Variety comes from depth tiers, not just cosmetic changes.

**Core Gameplay Loop Design Best Practices (2025-2026)**:
- "Micro loop must be satisfying or no progression system can save your game"
- Build micro loop first in isolation - "Does movement/input/feedback feel fun with greyboxes?"
- Misaligned loops = why games don't feel "tight" - not art or narrative problem
- Understanding Micro/Macro/Meta loops = "most powerful framework in game design"
- Core Keeper: "Digging through walls, setting up base, mastering skills is rewarding"
- Progressive upgrades essential: upgrade tools to dig deeper to seek better resources
- Deep exploration hook: "Thrill comes from seeing what lies just one layer further down"
- **GoDig Validation**: Our micro loop (tap-mine-collect) must feel great BEFORE systems

**Mobile Onboarding: FTUE vs Full Onboarding (2025)**:
- FTUE = first 60 seconds + first 15 minutes (kinesthetic learning - learn by doing)
- Full Onboarding = first 7 days (introduce longer-term systems and goals)
- "First thing players need is to PLAY! Don't make them click/choose/sign in"
- Epic WOW moment early creates attention hook
- Progressive disclosure: Hide systems not needed for first 15 minutes
- Clash Royale model: 5 short tutorials at relevant moments, each building on previous
- First win + reason to return tomorrow = retention foundation
- **GoDig Implementation**: FTUE = dig, find ore, return. Day 2+ = shop, upgrades, deeper dives.

**Roguelike Mastery Design (Grid Sage Games/Cogmind 2025)**:
- "We want more!" - skilled players demand harder challenges, extended content
- Extended game concept: Optional challenges after "normal" completion (Brogue lumenstones, DCSS runes)
- Cogmind has 10 endings with unique preparation/execution requirements
- Every upward connection = permanent decision leaving other possibilities behind
- Community engagement via Discord where developer helps players and discusses design
- **GoDig v1.1 Application**: Add extended goals for mastery players - depth records, achievement challenges, rare drop collections

**Mobile Push Notification Ethical Design (2025)**:
- Gaming has lowest opt-in rate: 63.5% (37% rejection rate)
- Best times: 12pm-1pm and 7pm-9pm on average, but personalization matters
- Personalized notifications improve reaction rates by up to 400%
- Optimal timing based on user activity improves reaction rates by 40%
- Ethical guideline: "Sustainable engagement (Flow) vs Player Burnout (Dissociation)"
- Player burnout = "Short-term revenue spikes, but trust erosion inevitable"
- Best practice: Send same number of daily notifications as player session frequency
- One push per week = 10% disable notifications, 6% uninstall
- **GoDig v1.1**: Match notification frequency to play frequency. Never notify absent players aggressively.

### Topics for Future Research
- [x] Analyze Spelunky 2's "secrets and lessons" retention (Session 9)
- [x] Study Terraria's biome discovery system (Session 10)
- [x] Review idle game monetization patterns (Session 10)
- [x] Research haptic feedback patterns on iOS/Android (Session 10)
- [x] Study one-hand mobile controls in similar games (Session 10)
- [x] Analyze Hades 2 early access feedback on progression pacing (Session 10)
- [x] Study Balatro's variable reward system (Session 10)
- [x] Research "cozy mining" games for casual appeal patterns (Session 10)
- [x] Analyze Cult of the Lamb retention mechanics (Session 11)
- [x] Study Vampire Survivors for minimalist "just one more" design (Session 11)
- [x] Analyze Slay the Spire metrics-driven design (Session 12)
- [x] Study Loop Hero for passive progression ideas (Session 12)
- [x] Research vertical slice playtesting methodologies (Session 12)
- [x] Analyze Deep Sea Adventure shared resource tension model (Session 13)
- [x] Study push-your-luck board game mechanics (Session 13)
- [x] Research SteamWorld Dig pickaxe satisfaction design (Session 13)
- [x] Analyze "just one more run" psychology (Session 13)
- [x] Study Idle Miner Tycoon economy design (Session 13)
- [x] Analyze Deep Rock Galactic extraction phase design in detail (Session 14)
- [x] Research "cozy comfort" signals in home base areas (Session 14)
- [x] Study Noita physics-based destruction feel (Session 14)
- [x] Research mobile game "session end" celebrations (Session 14)
- [x] Study Satisfactory/Factorio automation for v1.1 features (Session 15)
- [x] Analyze Astroneer mining and terrain deformation satisfaction (Session 15)
- [x] Research "hidden depths" discovery moments in mining games (Session 15)
- [x] Study mobile game "comeback" mechanics after player absence (Session 15)
- [x] Research "eureka moments" in puzzle/exploration games (Session 16)
- [x] Study Subnautica's biome progression and discovery pacing (Session 16)
- [x] Analyze Hollow Knight's exploration reward structure (Session 16)
- [x] Research procedural "set pieces" that feel handcrafted (Session 16)
- [x] Study mobile battle pass design for ethical implementation (Session 16)
- [x] Analyze Animal Well's minimalist discovery design (Session 17)
- [x] Study Rain World's emergent ecosystem and player agency (Session 17)
- [x] Research Nine Sols combat and exploration balance (Session 17)
- [x] Analyze Dead Cells' biome variety and path choice system (Session 17)
- [x] Study mobile game notification timing for ethical engagement (Session 17)
### Session 18 (2026-02-01)

**Keep Digging (January 2026): New Competitor Analysis**:
- Multiplayer co-op mining game reaching 1,000m depth across 10 layers
- No combat, pure exploration focus - validates our cozy mining approach
- Up to 8 players, cross-progression between solo and multiplayer
- Equipment upgrades to level 20, over 8 upgradeable technologies
- "Hybrid approach - dig vertically until exciting depth, then explore sideways"
- Steam release by Wild Dog (Tokyo-based studio)
- **GoDig Competitive Position**: Our ladder-based risk system is still unique; their depth (1000m) matches our mid-game. We differentiate on the tension/risk mechanics.

**Push-Your-Luck Game Design (BoardGameGeek/Incan Gold)**:
- Self-balancing mechanic: "fewer players still in = greater potential reward"
- Double hazard card = bust mechanic creates anticipation
- Deck manipulation (removing hazard after bust) creates hope for next round
- **GoDig Application**: Our ladders naturally create self-balancing - the deeper you go with fewer ladders, the more committed you are to the rewards.

**The Forge (Roblox): Luck-Based Mining Analysis**:
- Luck stat as percentage modifier for rare ore encounters
- When mining a rock, base item pool determined first, then luck modifies probabilities
- Creates "lucky streak" feeling when rare ores appear
- **GoDig Consideration**: Could add "lucky pickaxe" modifier or depth-based luck bonuses for variety.

**What Makes Mining Games Addictive (2025 Consensus)**:
- **Core loop**: dig-collect-upgrade-repeat is inherently compelling
- **Discovery thrill**: "Rare finds aren't just for fun - they help unlock stronger tools"
- **Low time commitment**: Perfect for mobile - "very little required time" yet engaging
- **Constant progress**: "The more you play, the more efficient and powerful you become"
- **Idle element appeal**: Progression even when not actively playing (for hybrid games)
- **GoDig Validation**: Our active mining + ladder risk differentiates us from idle games while keeping the core loop addictive.

**Idle Miner Tycoon Economy Lessons**:
- Three-tier bottleneck system: miners → elevator → transporter
- "Balancing these three ensures steady growth. Over-invest in one = bottleneck"
- New player trap: "dump coins into miners, leaving elevators overwhelmed"
- Prestige timing: "Early = prioritize upgrades. Mid = prestige more. Late = prestige is primary engine"
- **GoDig Application**: Our single-resource (coins) approach is simpler, but we could add subtle bottlenecks (inventory space, pickaxe durability) for interesting decisions.

**Mobile Game Session Length Reality (2025-2026 Data)**:
- **Median mobile session**: 5-6 minutes (not 15-30 as developers often assume)
- **Top 25% performers**: 8-9 minutes average
- **Multiple sessions**: Players average 4-6 sessions daily
- **Median daily playtime**: 22 minutes total across all sessions
- **GoDig Target**: Each complete loop (dig-sell-upgrade) should fit in 5 minutes. Design for 4-6 daily sessions.

**FTUE Best Practices 2025 (GameAnalytics/Unity/Udonis)**:
- "Just a few minutes — or less — to hook a player"
- Worst games lose 46% by minute 5; best lose only 17%
- "Core loop (action + reward + progression) should complete within 3-5 minutes"
- "88% of users return after experiencing a satisfying cycle"
- Progressive disclosure: "Hide systems not needed for first 15 minutes"
- **First session 10-20 minutes is vital** for F2P retention
- "No ads during FTUE - ads frustrate and distract from onboarding"
- D1 retention improvements: "Improving FTUE can increase D1 retention by up to 50%"
- **GoDig Implementation**: FTUE must complete one full loop in under 3 minutes: dig → find ore → return → sell → see upgrade path.

**SteamWorld Dig 2: Perfect Upgrade Pacing Analysis**:
- "Upgrade system is perfectly balanced so you're never over or under powered"
- Each tool "serves a very specific purpose: to help you keep digging"
- "Reviewers had trouble choosing among available upgrades, because each has noticeable effect"
- Creates "just one more trip" mentality to hit next tier
- Cog system: Collectibles that customize tools with mods - adds player agency
- **GoDig Learning**: Each upgrade should solve a specific frustration the player just experienced. Pickaxe too slow? Here's faster one. Inventory too small? Here's expansion.

**Dome Keeper: Why It Works (90% Positive, 17K Reviews)**:
- "Simple core loop but very addicting"
- "Music, presentation, and gameplay loop are all 10/10"
- "Feeling of getting back to base with a second to spare" = core satisfaction
- Variety through unlocks: extra domes, game modes, starting modifiers
- Criticism: "Building same things in same order" - need more build variety
- **GoDig Advantage**: Our surface expansion (multiple shops) and pickaxe variety should provide more decision variety than Dome Keeper.

**Game Juice Best Practices 2025 (Over-Juicing Warning)**:
- "When used correctly, screen shake creates engaging game feel; if overused, players feel nauseous"
- "Reserve intense effects for special occasions" - mining is CONSTANT
- **Screen shake**: 0.1-0.3 seconds, randomize direction, ease out smoothly
- **Particles**: "Start basic, layer complexity for important events"
- **Hitstop**: Both attacker and target pause for impact feel
- "Juice can't fix bad design" - core loop must work without any juice first
- Accessibility: "Implement options to customize intensity of visual/audio effects"
- **GoDig Implementation**: Subtle feedback for regular mining, reserved juice for ore discovery and upgrades. Always include option to reduce effects.

**New Indie Mining Games 2025-2026**:
- **Mashina** (July 2025): Stop-motion visual style, mining robot, upgrade equipment
- **ITER** (2025): Mining roguelite with 2D-3D dimension shifting
- **Hold the Mine** (Gamescom 2025): Roguelike wave-based mining + base-building + card-battler
- **Keep Digging** (Jan 2026): Co-op exploration to 1000m depth
- **Kin and Quarry** (Jan 2026): Mining focus, recent release
- **GoDig Competitive Landscape**: Competition growing but mobile-focused ladder-risk games remain rare.

### Session 19 (2026-02-01)

**Core Loop Fundamentals (2025-2026 Consensus)**:
- "A well-crafted core gameplay loop sits at the center of every great game, driving both player retention and monetization"
- "If your core loop isn't fun, it doesn't matter how great your narrative or physics interactions are"
- Players must have fun "minute to minute" or they will drop off
- Keep on Mining: praised for "smooth and satisfying core gameplay loop of mining and upgrading"
- Criticism: "gameplay tends to become repetitive and grind-heavy midway through"
- **GoDig Critical Insight**: Our core loop must pass the "greybox test" - is tap-to-mine fun with NO systems?

**Chipmatic (2025): Cozy Mining Automation**:
- "Mining incremental inspired by Motherload, Dome Keeper and Super Mining Mechs with added automation"
- Player controls Chip, a robot digging to Earth's core
- Demo received 500+ playtest requests - validates interest in cozy mining
- Features: coal/solar power, ore smelting, production chain automation
- "Go underground for coal, iron, and other useful minerals. Refill fuel manually or automate energy"
- **GoDig v1.1 Learning**: Automation should unlock mid-game as reward, not starting mechanic

**Push-Your-Luck Design Deep Dive**:
- "Push your luck is different than pure luck" - requires meaningful DECISIONS
- Core tension: "decide whether to keep going to gain more... and risk losing it all or stopping"
- Board game balance: ~50% chance per step means 25% chance of two successful steps
- "Players consider 25% total chance to be very low" - design for gradual pressure buildup
- Self-balancing: "fewer players still in = greater potential reward"
- **GoDig Application**: Our ladder mechanic is superior to sudden bust - gradual depletion creates sustained tension

**What Makes Mining Satisfying (Forum/Review Synthesis)**:
- Sound design critical: "In Minecraft, the satisfaction comes mostly because of the sounds"
- VR insight: "See texture becoming more cracked... until they shatter and release precious ore"
- Stardew Valley success: "time limit + enemies + shortcuts + bombs = variety"
- SteamWorld Dig 2: "Every improvement feels impactful. Pacing is tight - never stuck waiting."
- Discovery + automation: "The promise of finding something new keeps you hooked"
- **GoDig Implementation**: Each pickaxe tier should have unique crack patterns, sounds, particle effects

**Currency Animation Psychology (Game Economist Consulting)**:
- "Currency animations may play hundreds of thousands of times during player lifecycle"
- "Animations stitch action into experience - draw cause-effect loop between action and reward"
- Beatstar: "coins flip and spin, reflecting light when they enter balance"
- "Classically conditioned injection of dopamine" similar to Pavlov's bell
- **GoDig Priority**: Sell animation needs satisfying coin cascade + sound. This is played repeatedly - must be polished.

**Mobile Game Retention Psychology (2025 Data)**:
- Hook Model: Trigger → Action → Variable Reward → Investment → Loop
- Loss aversion leveraged heavily: "players feel stopping would result in missed benefits"
- Sunk cost fallacy: "continue investing to avoid feeling previous efforts were wasted"
- Day 1 retention average: 26%, Day 7: 10%, Day 30: <4%
- Top performers (puzzle/casual): 35%+ D1, 12%+ D7
- **GoDig Target**: Design for casual-tier retention through satisfying core loop, not manipulation

**Return Journey Problem (Motherload/SteamWorld Analysis)**:
- "Repetition of going up and down gets increasingly tedious"
- SteamWorld Dig solution: "generous with shortcuts... warp points and droppable teleporters"
- Super Motherload: "subterranean bases with all amenities... cutting out long treks"
- Critical quote: "depths between outposts get longer, until by the end you're spending many minutes just to reach site"
- **GoDig Implementation Priority**:
  1. Early game: Wall-jump mastery makes return feel skillful
  2. Mid-game: Elevator unlock as REWARD for reaching certain depth
  3. Late-game: Teleport scroll for emergency bailout (premium feel)

**ITER (2025): Mining Roguelite Competitor**:
- 2D to 3D dimension shifting for puzzles and exploration
- Mine resources → enhance capabilities → build base defenses
- "Death is one of the potential career paths... but you're totally replaceable!"
- Roguelite meta-progression: replacement operative picks up where you left
- **GoDig Differentiation**: We're mobile-first with ladder economy. ITER is PC roguelite with defense.

**Idle Miner Tycoon Economy Design Lessons**:
- Three-tier bottleneck: miners → elevator → transporter
- "Balancing these three ensures steady growth. Over-invest in one = bottleneck"
- New player trap: "dump coins into miners, leaving elevators overwhelmed"
- Economy health: "money constantly moving through it" - give Super Cash free to encourage spending
- Return-from-idle animation creates anticipation and satisfaction
- **GoDig Simplification**: Single resource (coins) is correct for MVP. Avoid premature complexity.

**Procedural Discovery Design (2025 Synthesis)**:
- "One of the most important elements: fostering belief that there is something exciting around the corner"
- Minecraft: "simple elements can come together in vast cave systems hidden underground"
- No Man's Sky: "never-ending journey of discovery... sense of wonder and curiosity"
- Key insight: "engaging gameplay loops distract player from seeing underlying predictability"
- Player feedback reveals unexpected interactions - plan for iteration
- **GoDig Application**: Our caves need handcrafted "set pieces" mixed with procedural generation. Guarantee interesting finds, not just random blocks.

**Mobile First Upgrade Psychology (2025 Data)**:
- "First 60 seconds determine whether users will come back"
- Candy Crush: "immediate rewards like free boosters or easy matches early on boost confidence"
- Royal Match: "minimize initial friction by skipping logins... every tap leads to meaningful action"
- Retention increase: "up to 50% with effective onboarding"
- Old reward model (one-time) has "nearly zero retention value" - must be spaced and dynamic
- Gamification (streaks, badges) can increase D30 retention by 15-30%
- **GoDig Critical**: First upgrade must happen within 5 minutes. Frame it as achievement, not purchase.

**Permadeath and Fair Punishment Design (Roguelike Best Practices)**:
- "Permadeath places heavy burden on designers to ensure every element is balanced"
- Key insight: "permadeath works when there are NOT sudden-death situations"
- Softer implementations: "retain money or items while introducing repercussions for failure"
- Non-death failures create challenge without frustration: "losing valuable item, getting levels drained"
- Hades "God Mode": damage resistance increases with each death - accessibility without removing consequence
- Creative death: "death woven into story provides in-universe explanation for coming back"
- Customization via death: "take two acquired buffs to next run - death becomes opportunity"
- **GoDig Emergency Rescue Design**:
  1. NOT a sudden-death - player sees ladder count depleting, makes choices
  2. Rescue costs SOME cargo, not ALL - learn from failure without starting over
  3. Frame as "emergency rescue service fee" not punishment
  4. Deeper = higher rescue cost = natural risk scaling
  5. Consider: rare drop (emergency flare) reduces rescue cost when used

**Game Feel / Juice Deep Dive (2025 Research)**:
- "Juice doesn't change rules of game, but changes how it feels... turns inputs into interactions"
- "Better to juice moment-to-moment events" rather than one-time occurrences
- Research finding: "outcome binding ('my action caused this effect') is precondition of competence"
- Curiosity is "strongest enjoyment and only playtime predictor"
- Warning: "amplification unexpectedly reduced motives, possibly impeding sense of agency"
- Hitstop: "Brief slow-motion can turn ordinary moment into memorable one... 0.2 seconds after critical hit"
- Sound design: "Crisp satisfying sounds for actions like jumping, landing... reinforces effort of perfect jump"
- **GoDig Implementation Priority**:
  1. Each dig hit: small particle burst, crisp sound
  2. Block break: larger particle explosion, screen shake (subtle), satisfying crack
  3. Ore discovery: 0.1s hitstop, glow effect, distinct celebratory sound
  4. Upgrade purchase: big celebration (reserved juice)
  5. Avoid over-juicing regular mining - reserve impact for discoveries

**Topics for Future Research**
- [x] Analyze Keep Digging (Jan 2026) for depth/layer design (Session 18)
- [x] Study push-your-luck board game balance mechanics (Session 18)
- [x] Research mobile session length reality vs assumptions (Session 18)
- [x] Analyze FTUE best practices 2025 (Session 18)
- [x] Study SteamWorld Dig 2 upgrade pacing in detail (Session 18)
- [x] Research game juice over-juicing warnings (Session 18)
- [x] Research core loop fundamentals 2025-2026 (Session 19)
- [x] Analyze Chipmatic automation design (Session 19)
- [x] Study currency animation psychology (Session 19)
- [x] Research return journey solutions (Motherload/SteamWorld) (Session 19)
- [x] Analyze ITER roguelite design (Session 19)
- [x] Study Idle Miner Tycoon economy balance (Session 19)
- [x] Research procedural discovery design principles (Session 19)
- [x] Study mobile first upgrade psychology (Session 19)
- [x] Analyze permadeath and fair punishment design (Session 19)
- [x] Research game feel / juice best practices 2025 (Session 19)
- [x] Analyze Windblown (Dead Cells devs new roguelike) for co-op design (Session 20)
- [x] Study mobile game "offline progress reveal" animation patterns (Session 20)
- [x] Research Cogmind's extended game challenges for v1.1 mastery content (Session 20)
- [ ] Analyze Cryptical Path's "build the dungeon" mechanic for player agency
- [x] Study Core Keeper's mining skill progression system (Session 20)
- [ ] Research Retromine's card-based mining progression system
- [ ] Study UnderMine's action-adventure roguelike mining blend
- [ ] Analyze SpaceRat Miner for fast-paced mobile mining roguelite patterns

### Session 20 (2026-02-01)

**Windblown (Dead Cells Devs) - Co-op Roguelite Design**:
- Motion Twin's new 3-player co-op roguelite launched Early Access October 2024, full 1.0 planned 2026
- Core design goal: "Match intensity of Devil May Cry/Bayonetta but with friends"
- Progression philosophy: "Flow in and out of multiplayer" with drop-in/drop-out + scaling difficulty
- Meta-progression: Memories of fallen players absorbed for build-defining powers
- Endless Mode planned: continue after final boss with current build, stacks infinitely
- "Plan was to make a bigger game than Dead Cells" + "easier to come into" for non-roguelite players
- Hub called "the Ark" - cozy home base for permanent upgrades between runs
- **GoDig Learning**: Our surface is our "Ark" - make it feel like home base with permanent progression visible

**Core Keeper Mining Skill System Analysis**:
- Mining damage increases by +1 per level (up to +100 at level 100)
- Talent points every 5 levels - meaningful skill tree choices
- Key talents: Efficient Excavation (+10% damage), Meticulous Miner (+20% extra ore), Night Vision (+10 tile visibility)
- Movement boost after mining creates satisfying flow
- "Bags & Blasts" update (March 2025) added Explosives Skill Tree - new way to play
- XP based on "swings to break" not blocks - using efficient tools slows XP gain (interesting tradeoff)
- Ore Boulders require Drills - automated mining as mid-game unlock
- **GoDig Application**: Consider mining skill progression for v1.1 - each level gives small damage boost, talents unlock special abilities

**Roguelite Mastery Design (Cogmind/Grid Sage Games)**:
- "Extended game" concept: optional challenges after normal completion (Brogue lumenstones, DCSS runes)
- "Metaprogression of the mind" - players grow in understanding, not just stats
- Mastery Challenges (Idle Champions): Enable optional restrictions for bonus rewards
- Prestige cosmetics as mastery rewards - Card Sleeves example
- **GoDig v1.1 Application**: Add optional depth challenges - "reach 500m with only 3 ladders" for cosmetic rewards

**Idle Game Offline Progress Patterns**:
- Idle Slayer: Minions accumulate resources automatically, upgrades boost offline efficiency
- Clicker Heroes: Heroes defeat monsters while logged off, big pile of gold waiting on return
- Core pattern: "Return-from-idle" moment is key satisfaction point
- Coin Idle: 3-hour timer creates anticipation for collection
- UI clarity matters: "shows gold income, hero upgrades, DPS, stage progress"
- **GoDig Learning**: Even active games benefit from "welcome back" moments - show depth record, coins earned last session, progress toward next upgrade

**"One More Run" Psychology Deep Dive**:
- Core hook: "endless loop of defeat and determination"
- "Feeds into same part of brain that likes gambling - never know if THIS run is the one"
- Learning through failure: "Every run teaches something new - enemy patterns, loot strategies"
- Dead Cells carry-forward upgrades: "doesn't carry same sting" when reset, makes new run tempting
- Hades narrative progression: "Even when you fail, you're rewarded with narrative progression"
- **GoDig Critical Insight**: Our emergency rescue should feel like a "lesson learned" not punishment. Show what was lost + what was gained (knowledge).

**Power Fantasy & Upgrade Satisfaction (2025 Research)**:
- Definition: "virtual context where person can do something they wouldn't in real life"
- Screen shake, sound effects make combat "feel weighty and powerful"
- Progression must feel EARNED: "each victory feels earned and meaningful"
- Hades foundation: "responsive controls make combat satisfying BEFORE upgrades"
- Mobile loops: "enter short challenge, make choices, earn resources, upgrade, repeat"
- "Moment-to-moment must be juicy - crisp timings, responsive effects"
- **GoDig Priority**: Core tap-to-mine must feel satisfying with NO upgrades. Then each upgrade amplifies already-fun activity.

**FTUE and Core Loop Retention (2025-2026 Data)**:
- FTUE = first 60 seconds + first 15 minutes (kinesthetic learning)
- Worst games lose 46% by minute 5; best lose only 17%
- "Core loop should complete within 3-5 minutes"
- "88% of users return after experiencing satisfying cycle"
- Free to play: "midterm motivation loop must be established within 5-7 minutes"
- D1-D3 drop = FTUE problem; D7 cliff = core loop lacks depth; D30 slide = missing late-game content
- Target retention: D1 26% average, D7 10%, D30 <4%; Top performers: D1 35%+, D7 12%+
- **GoDig Target**: Complete dig-find-sell-upgrade cycle in under 3 minutes. First upgrade within 5 minutes.

**New Indie Mining Games 2025-2026 Update**:
- **ITER** (2025): Mining roguelite tower defense, 2D-3D dimension shifting, Warsaw 2-person studio
- **UnderMine**: Action-adventure roguelike with mining, "Mine gold, die, upgrade, try again"
- **SpaceRat Miner** (Playdate): Fast-paced roguelite mining - collect gems, dodge rocks, beat bosses
- **Retromine**: Card-based mining with 50+ resource/tool/action cards - novel approach
- **Hollow Mine**: Action roguelite combining mining, crafting, 2D top-down combat
- **GoDig Competitive Position**: Still unique with ladder-based push-your-luck on mobile

**Push-Your-Luck Design Validation**:
- "Push-your-luck is DIFFERENT from pure luck - requires meaningful CHOICES"
- Progressive risk: "longer engaged in risky behavior = higher stakes"
- Banking mechanic: "accumulated points temporarily reside in BANK - uncashed, vulnerable"
- Balance principle: "At beginning, risk low but so are rewards - most keep going"
- Middle area: "moderate risk, greater reward - should be rewarded for stopping"
- Tension is key: "If no chance of failure, no tension. If success impossible, players avoid risk."
- **GoDig Validation**: Our ladder depletion creates perfect progressive risk curve

### Session 21 (2026-02-01)

**UnderMine: Action-Adventure Roguelike Mining Analysis**:
- Blend of combat and dungeon crawling with RPG progression - "mine gold, die, upgrade, try again"
- Core loop praised as "addictive" - "even through routine failure players couldn't stop thinking about next deep dive"
- Progression system provides safety net: "spend gold to improve and set up your next character"
- Hundreds of items including relics, potions, blessings, and curses that combo and stack
- Post-game Othermine: true roguelike mode without base game progression - extended content for mastery players
- Criticism: struggles to differentiate from peers; RNG can throw frustrating combinations
- **GoDig Differentiation**: Our ladder economy creates unique risk tension UnderMine lacks

**SpaceRat Miner (Playdate): Fast-Paced Mobile Mining**:
- Core loop: dig deep, collect gems, dodge falling rocks, run from lava, beat bosses
- Procedurally generated map each run ensures variety
- Equipment progression: improve gear to go further each run
- Controls: A button to mine, D-Pad to move, crank for drill recharge
- Platform constraint (Playdate) forced streamlined mobile-friendly design
- **GoDig Validation**: Simple controls (tap to mine) with depth-based progression works for mobile

**Cryptical Path: Rogue-Builder Mechanic (January 2025 Release)**:
- "World's first action roguelite builder" - players place rooms to build their own dungeon path
- Core innovation: purchase rooms with currency earned from combat, place them adjacent to current position
- Strategic dynamism: "not at mercy of game as your own thriftiness"
- Push-your-luck integration: "decide whether worth building across to another outcrop for possible rewards, or heading straight to boss"
- Developer quote: "empowering players to combine tactical planning with unpredictable nature of roguelites"
- Fully optimized for Steam Deck - validates handheld/mobile potential
- **GoDig Learning**: Player agency over path creates investment. Our surface building system could offer similar player-directed progression.

**Retromine: Card-Based Mining Progression**:
- Deckbuilding roguelike where cards enable digging, movement, and resource gathering
- Dig with cards, manage deck order, survive cave collapses
- Dual resource tension: scorium (survival) vs ore (upgrades) - must balance both
- Shop between runs: buy new cards AND remove basic cards to streamline deck
- Card types: Resource Cards, Tool Cards, Action Cards, Utility Cards (game-changing)
- Synergy discovery is core satisfaction - combining walkie-talkie + minecart for movement multiplier
- Discard pile mechanics prevent infinite loops while enabling combo play
- **GoDig Inspiration**: Card/item synergies create discovery moments. Our pickaxe + inventory upgrades could create similar combo satisfaction.

**Hollow Mine: Mining + Crafting + Combat Integration**:
- Fully destructible environments - dig tunnels, set traps, flank enemies
- 120 items, 9 unlockable character classes with unique abilities
- Five unique biomes with procedurally generated rooms
- 40-minute+ run length with fast-paced action
- Resources enable crafting weapons, spells, and potions
- Mining wagons, bombs, and biome-specific traps as strategic tools
- **GoDig Contrast**: We're combat-free, which is simpler but requires mining itself to carry all satisfaction. Their destructible environments validate our block-breaking visual polish priority.

**Push-Your-Luck Mathematical Balance**:
- Formula: (points if correct × success probability) - (points lost × failure probability) = expected value
- If expected value > 0, mathematically continue; if < 0, bank
- Key insight: 50% success per step = 25% chance of two successful steps. Players perceive 25% as "very low"
- Balance rule: Risk and reward must BOTH increase during turn duration
- Beginning: low risk, low reward - most continue
- Middle: moderate risk, greater reward - should be rewarded for stopping here
- End: high risk, highest reward - only for committed players
- Self-balancing mechanisms: simultaneous turns, reduced hazards after hits, increasing rewards for persistence
- **GoDig Application**: Our ladder depletion creates gradual risk increase. Consider adding depth-based ore value multipliers for reward scaling.

**FTUE First 60 Seconds Hook (2025 Best Practices)**:
- FTUE = first 60 seconds + first 15 minutes (kinesthetic learning)
- "First 60 seconds determine whether users will come back"
- Worst games lose 46% by minute 5; best lose only 17%
- Key principle: "first thing players need is to PLAY! Don't make them click/choose/sign in"
- Start with hand-crafted level introducing only core concepts
- Common mistake: explaining full value up front overwhelms new players
- Weave narrative lens early so players view gameplay through story context
- D1 weak = onboarding problem; D1 solid but D7 tanks = early content lacks depth
- **GoDig FTUE Target**: First tap breaks first block within 5 seconds. First ore within 30 seconds. First sell within 60 seconds.

**Tension and Relief Design Patterns**:
- Tension creates physical effects: increased heart rate, adrenaline, fight-or-flight response
- Overcoming tension creates strong dopamine release - reinforces engagement
- "Safe zones" allow player to return to point where designers can ramp them up smoothly
- Blue signals safety, green promotes relaxation - ideal for recovery zones
- Tension-relief cycles: alternate between challenging and relaxing sections
- Pacing control creates rhythm and flow
- Player agency: allow players to manage their own tension and relief
- **GoDig Surface Design**: Surface must be CLEARLY safe (warm colors, enclosed shop interiors, no threats visible). Underground = increasing unfamiliarity and tension.

**Resource Scarcity Economy Design**:
- Economy should alternate between abundance and scarcity
- Abundance periods reward players; scarcity prompts planning or purchases
- Too many resources = lose value; too scarce = stuck or forced to spend money
- Dual-tier currency standard: soft currency (earned easily) + hard currency (usually paid)
- Connect reward value to ease of completion + scarcity + synergies
- "Sinks" (upkeep, degradation) balance "faucets" (rewards, drops)
- Avoid grinding burnout: player shouldn't face extreme scarcity of needed resources
- **GoDig Economy**: Ladders are our scarcity lever. Must be available enough to feel achievable but scarce enough to create tension.

**Vertical vs Horizontal Progression**:
- Vertical = SCALE (bigger numbers, more powerful stats)
- Horizontal = OPTIONS (more tools, abilities, playstyles)
- Vertical strength: clear picture of getting stronger
- Vertical weakness: treadmill feeling - power matched by difficulty, nothing changes
- Horizontal strength: promotes strategic thinking and player expression
- Horizontal weakness: useless or overwhelming options harm experience
- Best approach: combine both - horizontal options with vertical improvements
- Auto-balance systems: scale player back in lower zones to prevent power creep
- **GoDig Progression Mix**: Pickaxe tiers (vertical), inventory upgrades (vertical), new item types (horizontal), automation unlocks (horizontal v1.1)

**Inventory Management as Tension Design**:
- Limits create meaningful choices: what to keep, what to drop?
- "Is it worth the risk to grab that rare loot or head back to camp and unload?"
- Resident Evil briefcase: inventory as logic puzzle - efficient packing
- Inventory adds strategy and depth - makes you think, plan, organize
- **GoDig Full Inventory Mechanic**: When inventory full, player faces decision: keep digging (can't collect) or return with current haul. Natural push-your-luck tension.

**Death Penalty Design in Roguelikes**:
- Permadeath places "heavy burden on designers to ensure every element is balanced"
- Key insight: permadeath works when there are NOT sudden-death situations
- Softer implementations: retain money/items with repercussions for failure
- Rogue Legacy inheritance: death is necessity for progress, not punishment
- Blazblue Entropy Effect: take two buffs to next run - death becomes opportunity
- Co-op revival: dead players become ghosts with limited gameplay; revive via chests or bosses
- **GoDig Emergency Rescue Refinement**: Frame rescue as "lesson learned" opportunity. Show what was lost + what was gained (map knowledge, ore locations remembered).

**Dome Keeper Multiplayer Update (2025-2026)**:
- Multiplayer most requested feature since day 1
- Developer warning: adding multiplayer to singleplayer game is "unreasonable amount of work"
- Expected release: early 2026 after December 2025 playtest
- Competitive Versus Mode planned: two teams sharing single big mine
- No public lobbies - join codes + Steam friends only to avoid cheaters
- Before multiplayer: focused on replayability content ("A Keeper's Duty" update)
- **GoDig Learning**: Focus on single-player core loop perfection first. Multiplayer is v2+ feature if ever.

**Currency/Sell Animation Psychology**:
- "Currency animations stitch action into experience - draw cause-effect loop between action and reward"
- Beatstar: coins flip and spin, reflecting light when entering balance
- "Classically conditioned injection of dopamine" - similar to Pavlov's bell
- Currency animations play hundreds of thousands of times during player lifecycle - polish is critical
- Sound + visual sync essential: music feels "like reverberating from subwoofer"
- **GoDig Sell Animation Priority**: This is one of most-repeated moments. Needs satisfying coin cascade + sound + brief celebration. Each sale should feel rewarding.

### Session 22 (2026-02-01)

**Deep Rock Galactic: Rogue Core (Q2 2026) - Major Competitor Analysis**:
- Roguelite spinoff where players start with ONLY their pickaxe - must scavenge weapons/equipment
- The "Grayout Barrier" disables technology on contact - forces scavenging gameplay
- Crafting via Expenite harvesting creates progression within runs
- 1-4 player co-op with roguelite meta-progression: unlock new weapons, suits, mods between runs
- The Reclaimers team must restore lost dig sites and uncover "The Greyout" mystery
- **GoDig Distinction**: Our game is mobile-first with ladder economy. DRG:RC is PC co-op shooter with extraction focus.

**The Over-Juicing Problem (Wayline/Game Design Research)**:
- "Exaggerated feedback is harming game design" - when every hit feels like nuclear explosion
- Screen shake "creates engaging game feel if used correctly; if overused, players feel nauseous"
- Juice as smokescreen: "If combat lacks strategic depth, designers might just add more screen shake"
- Animation communicates weight better than particle effects - Dark Souls feels significant through animation, not particles
- **GoDig Application**: Reserve intense effects for discoveries and upgrades. Regular mining should have subtle, satisfying feedback only.

**Push-Your-Luck Design Principles (BoardGameGeek/BGDF)**:
- "Push your luck is different than pure luck" - requires meaningful DECISIONS
- Core tension: "decide whether to keep going to gain more... and risk losing it all or stopping"
- Self-balancing mechanics: "fewer players still in = greater potential reward"
- Classic examples: Can't Stop (dice), Zombie Dice (3 strikes), Incan Gold (hazard cards)
- Quacks of Quedlinburg adds mitigation: chip return mechanic reduces bad luck impact
- **GoDig Validation**: Our ladder depletion creates superior progressive risk vs sudden bust mechanics.

**Dome Keeper Player Feedback Polarization**:
- Negative: "too slow, repetitive, grindy" + "so much back and forth" + "tediously inefficient input"
- Positive: "addicting mix of tower defence and Dig Dug" + "10/10 gameplay loop" + "nothing feels better than getting back to base with a second to spare"
- Critical: Pacing matters - players who love it praise the tension, players who hate it cite tedium
- 90% positive with 9,500+ reviews despite mixed individual experiences
- **GoDig Learning**: Our return trip must feel like achievement. Wall-jump + ladders = skill expression. Elevator = late-game convenience.

**SteamWorld Dig Series - Upgrade Pacing Gold Standard**:
- Core flow: "enter mine → dig → uncover ore/gems → return to surface → sell → upgrade tools"
- Each upgrade has noticeable effect: "just one more trip to hit next tier" mentality
- SteamWorld Dig 2 praised as "impeccably paced, new powers opening up just when comfortable"
- Fastest pickaxe creates "immensely satisfying" feeling of "blasting through mines at super-sonic speed"
- Cog system adds customization layer beyond straight stat upgrades
- **GoDig Implementation**: Each pickaxe tier must feel dramatically different. Not just faster - DIFFERENT (visual, audio, particle effects).

**Dopamine and Mobile Retention Psychology (2025-2026 Research)**:
- Dopamine released during ANTICIPATION, not just receipt - uncertainty creates engagement
- Variable ratio reinforcement: unpredictable rewards are more engaging than fixed schedules
- Progression "taps into brain's dopamine system" - every small reward reinforces positive experience
- First few minutes determine retention: "easy victory early activates sense of accomplishment"
- Warning: 93% of free mobile games popular with children contain "potentially manipulative" design elements
- **GoDig Ethical Approach**: Satisfy through genuine game feel, not psychological exploitation. First upgrade = real achievement, not manipulation.

**Core Loop Fundamentals (2025-2026 Consensus)**:
- "If your core loop isn't fun, it doesn't matter how great your narrative or physics interactions are"
- Core loop = "set of actions player takes to get rewards that can be reinvested"
- Four pillars: Satisfaction, Viscerality, Strategy, Fantasy
- D1-D3 drop = FTUE problem; D7 cliff = core loop lacks depth; D30 slide = missing late-game content
- **GoDig Critical Test**: Does tap-to-mine feel fun with NO systems? If not, no amount of progression can save it.

**Dig Dig Boom - Turn-Based Mining Puzzle (Godot Engine)**:
- "Time only moves when you do" - blend of real-time and turn-based
- Combines grid-based puzzle, turn-based strategy, and dungeon crawler elements
- Both handcrafted puzzles AND procedurally generated caves
- Handcrafted = introduction to techniques, procedural = application
- Made with Godot Engine (same as GoDig)
- **GoDig Insight**: Handcrafted "tutorial chunks" mixed with procedural generation is validated approach.

**Inventory as Decision-Making Mechanic**:
- "Limited inventory forces players to make decisions" - this is feature, not limitation
- Creates prioritization: "carry large item to merchant, discard other loot"
- Resident Evil 4 briefcase: "puzzle-like mechanic rewarding players who maximized space"
- Limits add creative constraint: "if they have small inventory, they'll start getting creative"
- Real-time inventory tension: "managing items while remaining vulnerable"
- **GoDig Full Inventory Design**: When inventory is full, player faces decision: keep digging (can't collect) or return. This IS the push-your-luck moment.

**Mobile Session Length Reality (Reinforced)**:
- Average session: 5-6 minutes median
- Players average 4-6 sessions daily, 3-5 min each
- First session 10-20 minutes is vital for F2P retention
- "Core loop should complete within 3-5 minutes"
- "88% of users return after experiencing satisfying cycle"
- **GoDig Target**: Complete dig-find-sell-upgrade cycle in under 3 minutes for first run.

**Ladder/Rope Mechanics in Mining Games**:
- Minecraft rope ladder proposal: "click on existing piece to extend it downwards" (like scaffolding)
- Stonehearth: auto-unrolling rope ladder when terrain is dug up next to it
- TerraFirmaCraft: anchor section + extension mechanic
- Hytale: rope for high places, ladders when rope can't reach ceiling
- **GoDig Differentiation**: Our ladders are consumable resources creating push-your-luck tension. This is unique.

### Session 23 (2026-02-01)

**Mining Core Loop - The Fun Debate (GameDev.net Consensus)**:
- Divergent view: "Digging is not the fun part of these games, it's merely the means to get resources to craft cool things"
- Counter view: "Something satisfying about digging, discovery, and using those discoveries to enable more digging"
- SteamWorld Dig specifically called out: "it's quite satisfying just to dig dig dig, without any further concerns"
- Motherload appeal: "surviving in dangerous environment while accumulating wealth, constantly making decisions about risks vs rewards"
- Classic tension: "My air tank is just about gone, I need to return to surface, but there's two diamond ores right there"
- **GoDig Critical Insight**: The FUN comes from the DECISION moment, not the digging itself. Ladder scarcity creates those decisions.

**Failure Design: Incremental vs Instant Loss**:
- "Instant death won't be fun" - players need warning and agency
- Better: "incremental losses that players can choose to quit from"
- Players should "see their losses increase step by step, not in huge jumps"
- "Implicit choice of returning to base and cutting losses or pressing onward"
- **GoDig Application**: Low ladder warning should appear BEFORE crisis. Player chooses to return or push luck. Emergency rescue = fail state, not instant loss.

**Loop Hero Retreat System - Gold Standard**:
- Three outcomes: Die (lose 70%), Early retreat (lose 40%), Camp return (keep 100%)
- Creates meaningful decision: "cut your losses" is genuine strategic choice
- "Breaks down the structure of a roguelike into a series of small loops"
- Accessibility praised: "wonderfully approachable" for roguelike newcomers
- Resources fuel meta-progression - every run adds permanent value
- **GoDig Application**: Model our surface return as "camp" (keep all), emergency rescue as "retreat" (lose %), death as worst outcome.

**Push-Your-Luck Mechanics (BoardGameGeek Deep Dive)**:
- Definition: "Decide whether to stop or keep going... get too greedy, end up with nothing"
- Critical: Push-your-luck is DISTINCT from pure luck - requires meaningful CHOICES
- Self-balancing: "Fewer players still in = greater potential reward"
- Best examples 2025: Quacks of Quedlinburg (bag-building + push), Flip 7 (Spiel des Jahres nominee)
- Deep Sea Adventure: shared oxygen creates social tension - our solo version avoids blame
- **GoDig Advantage**: Our ladder economy creates push-your-luck with SOLO responsibility. Player only blames themselves.

**First Upgrade Psychological Hook (F2P Design)**:
- "High conversion item" = the virtual item most likely to incentivize first engagement
- Example: "Double Coin" boost - single $2 purchase, permanent effect, massive perceived value
- "After player drops first dollar, they are more likely to stick around"
- Builder unlocks in base builders: "effectively doubling progression speed"
- Key: First upgrade must have MASSIVE perceived value, even if small actual cost
- **GoDig Application**: First pickaxe upgrade should feel transformative. Not 10% better - 50%+ noticeable improvement.

**Upgrade Instant Feel - Why It Matters**:
- Dark Souls: "immensely satisfying to return to areas that kicked your ass once levelled up"
- "You really feel the journey from fragile weakling to god slayer"
- Upgrades must be FELT, not just seen in stats
- Visual changes matter: "Bioshock guns start average, end up sci-fi looking"
- One hit vs multiple hits creates "night and day" feel difference
- **GoDig Priority**: When player buys Copper Pickaxe, first dig should feel DRAMATICALLY different.

**Mobile Retention Benchmarks 2025**:
- Day 1 retention: ~18-20% median (80% churn!)
- Day 7 retention: ~10%
- Day 30 retention: <4%
- Top performers: 35%+ D1, 12%+ D7
- Critical: First session determines retention fate
- **GoDig Target**: Beat casual benchmark (30%+ D1) through satisfying core loop.

**Dopamine and Anticipation (Core Loop Science)**:
- Dopamine created during ANTICIPATION, released upon reward
- Three-part cycle: anticipation → activity → reward
- "The excitement before the reward that gets us hooked"
- Unpredictable rewards fuel endless engagement cycle
- Casual games: small reward every 30-90 seconds, major accomplishment every 10-15 minutes
- **GoDig Timing**: Ore discovery = small dopamine hit (30-90 sec cadence). Surface sell = major hit (3-5 min cadence).

**Currency Animation Excellence**:
- "Currency flows from claim button to wallet's UI location"
- Beatstar example: "coins flip and spin, reflecting light when entering balance"
- Each currency type should have unique sound profile
- Brawl Stars: "currency pauses mid-animation, ensuring players admire it"
- Hundreds of thousands of plays during player lifecycle - benefits compound
- **GoDig Sell Animation**: When selling ore, coins should flow visibly to wallet. Sound should be satisfying. Pause for player to "admire" earnings.

**Tension UI Indicators (Mobile Best Practices)**:
- Progress bars create urgency and excitement
- Red = danger/urgency, Green = positive/safe
- Low health indicators: "flashing red around peripheries" or character visual changes
- Timers add urgency without punishing casual play
- Haptic feedback "vastly under-utilized" on mobile
- **GoDig Ladder Warning**: Implement visual urgency indicator when ladders low + depth high. Red pulsing border, or ladder icon flashing.

**Depth Progression Models (Terraria/Starbound/Under A Rock)**:
- Terraria: "Spelunking is key to gameplay... many great weapons and item drops littered below surface"
- Starbound layer system: Subsurface → Shallow Underground → Mid Underground → Deep Underground → Core
- Each layer has unique monsters, blocks, microdungeons, plants
- Under A Rock 2026: "Resources can now be harvested underground, giving caves value beyond exploration"
- **GoDig Layer Design**: Our 7 layers should each have distinct visual identity, unique ore types, and layer-specific surprises.

**Climbing/Ladder Satisfaction (2025 Analysis)**:
- "Climbing isn't just a mechanic anymore - it's evolving into a genre"
- "There's something truly satisfying about climbing to survive, explore or relax"
- Death Stranding: ladders are physics objects, can be deployed horizontally or as ramps
- Jusant: individual hand control, stamina system, physics-based movement
- Half-Life Alyx: realistic manual ladder climbing in VR
- **GoDig Ladder Feel**: Ladder placement should feel significant. Brief animation, satisfying sound, visible progress indicator.

### Topics for Future Research
- [x] Analyze Cryptical Path's "build the dungeon" mechanic for player agency (Session 21)
- [x] Research Retromine's card-based mining progression system (Session 21)
- [x] Study UnderMine's action-adventure roguelike mining blend (Session 21)
- [x] Analyze SpaceRat Miner for fast-paced mobile mining roguelite patterns (Session 21)
- [x] Study Hollow Mine's mining + crafting + combat integration (Session 21)
- [x] Research idle game "return animation" patterns for surface arrival (Session 22 partial)
- [x] Analyze Dome Keeper player feedback polarization (Session 22)
- [x] Study SteamWorld Dig upgrade pacing (Session 22)
- [x] Research Deep Rock Galactic Rogue Core for 2026 (Session 22)
- [ ] Analyze Windblown's "Endless Mode" for post-game content ideas
- [ ] Study how Core Keeper balances XP gain vs efficient tools
- [ ] Research "inventory Tetris" satisfaction patterns (Resident Evil, Diablo)
- [ ] Study mobile game "abundance/scarcity" cycle timing
- [ ] Analyze vertical/horizontal progression balance in successful mobile games
- [ ] Research Dome Keeper multiplayer design when released (Q1 2026)
- [ ] Study Cryptical Path player reviews for "rogue-builder" reception
- [ ] Analyze Dig Dig Boom full release reception when available
- [ ] Research DRG: Rogue Core player feedback when Early Access launches Q2 2026
- [x] Study Jusant's climbing stamina system for ladder/traversal inspiration (Session 24)
- [ ] Research Cairn's climbing feedback when full release available (2026)
- [x] Analyze Starbound's underground layer variety system in depth (Session 24)
- [ ] Study Under A Rock's cave resource harvesting design when released
- [x] Analyze Windblown's Endless Mode for post-game content ideas (Session 24)
- [x] Study Core Keeper XP vs efficient tools balance (Session 24)
- [x] Research inventory tetris satisfaction patterns (Session 24)
- [x] Study mobile game abundance/scarcity cycle timing (Session 24)
- [ ] Analyze Cryptical Path player reviews for "rogue-builder" reception when more reviews available
- [ ] Study DRG: Rogue Core player feedback when Early Access launches Q2 2026

### Session 24 (2026-02-01)

**Windblown Endless Mode Design (Motion Twin - Dead Cells Devs)**:
- Endless Mode launched March 4th, 2025 - allows continuing after beating final boss
- Key feature: players keep weapons, power-ups, and stat boosts from completed run
- "Stack infinitely" design for bragging rights and build optimization
- Gear reforging added: change/upgrade trinkets and weapons between loops
- Codex tracks meta-stats: enemies killed, runs played - creates collection motivation
- 2026 roadmap includes New Game Plus, new boss, improved mid/late game meta systems
- The Ark (hub) serves as cozy home base for permanent progression
- **GoDig v1.1 Application**: Consider "Endless Dig" mode after main progression - keep upgrades, deeper layers unlock

**Core Keeper Mining XP vs Efficient Tools Paradox**:
- XP awarded per HIT, not per block destroyed - critical balancing insight
- Using efficient pickaxes actually SLOWS XP gain (fewer hits per block)
- Testing showed: Ancient Pickaxe (one-hit kills) = half level per 20 blocks; no pickaxe (6 hits each) = 2.5 levels
- Creates interesting tradeoff: speed vs skill progression
- Level 89 with half to 90 = actual midpoint of level 100 (exponential curve)
- Best mining gear: Cosmos Armor (+274 block damage) vs Miner's Set (+40% and +120 flat)
- **GoDig Design Decision**: If we add mining skill, efficient pickaxes should NOT slow XP. Our game values player time over artificial grind.

**Inventory Tetris Satisfaction (Resident Evil / Diablo Analysis)**:
- Core appeal: "bizarre satisfaction to Feng shui'ing your attache case"
- "Just lining up items or making things look pretty is more satisfying than entire video games"
- 3D grid naturally limits items while communicating item scale (sword > dagger)
- Save Room (indie game) turned inventory Tetris into core mechanic - validates standalone appeal
- Criticism: difficult to find items, requires periodic shuffling, can feel tedious
- **GoDig Application**: Our slot-based inventory is simpler than Tetris - CORRECT for mobile. But consider "full inventory" as decision moment, not frustration.

**Mobile Economy Abundance/Scarcity Cycles (2025 Best Practices)**:
- Core strategy: alternate between resource abundance (rewarding) and scarcity (planning/purchasing)
- Genshin Impact model: event rewards create abundance, then scarcity encourages farming/purchasing
- 40% higher engagement with limited-time offers (scarcity + urgency)
- Circular economy: earn → spend → need more → earn (Clash of Clans raid loop)
- 78% of successful titles use dual currency (soft earned, hard premium)
- 62% abandon due to currency/resource shortage - scarcity must not feel unfair
- Critical balance: too generous = blast through content, too stingy = frustrated quit
- **GoDig Ladder Economy**: Ladders are our scarcity lever. Early game = abundance (5 starting), mid-game = tension (must buy wisely), late-game = elevator unlocks abundance again.

**Jusant Climbing Stamina System Deep Dive**:
- Left/right triggers control left/right hands - "perfect control over character with bit of pressure"
- Stamina depletes on grab (tiny) and jump (large) - creates moment-to-moment decisions
- Small portion regenerates mid-climb if player rests - safety net without removing consequence
- Developer iterated through: independent arm stamina, chunk system, rope-only regen - none worked
- Playtesters rejected punitive versions - "disrupted climbing flow"
- Environmental variety: sun biome drains stamina faster, vegetation creates alternate handholds
- Accessibility: No Stamina mode, Simplified Climbing (stick only), Jump Assistance
- **GoDig Application**: Our wall-jump doesn't need stamina (too punitive for mobile). But ladder placement creates similar "when to commit" decisions.

**Starbound Underground Layer Variety System**:
- Three underground layer types: Shallow (Tarpit, Mushrooms), Mid (Luminous, Bone, Ice Caves), Deep (Cell, Flesh, Slime Caves)
- Each layer has primary biome + optional secondary biomes + possible sub-biomes
- Underground type is INDEPENDENT of surface biome - creates discovery surprise
- Underground caves can spawn "in place of" generic layer - special rare zones
- Unique characteristics: plants, monsters, blocks distinct per biome
- Modding system: region types describe terrain, liquid, ore generators
- **GoDig Layer Design Validation**: Our 7 layers should have distinct visual identities AND surprise cave biomes that override normal generation.

**Push-Your-Luck Tension Mechanics (Board Game Wisdom)**:
- Core insight: push-your-luck is DIFFERENT from pure luck - requires meaningful CHOICES
- Banking mechanic creates strategic depth: accumulated points are "vulnerable" until cashed
- Self-balancing: fewer players remaining = greater potential reward (Incan Gold)
- Quacks of Quedlinburg: chip return mechanic mitigates bad luck - cost to refresh
- Zombie Dice "3 strikes" rule: incremental failure, not sudden bust
- RPG implementation (PbtA games): "potential of enormous success or terrible disaster"
- **GoDig Validation**: Our ladder depletion is GRADUAL tension (superior to sudden bust). Player sees warnings, makes informed choices.

**Subnautica Depth-Fear Design Principles**:
- Four fear metrics: brightness, depth, hostility, visibility - all worsen as player descends
- Key quote: "Every aspect intentionally designed to make players feel they do not belong"
- 3D space means "dangers come from any direction, including behind, above and below"
- Creature design: color, behaviour, size create terror without breaking immersion
- Sound design creates dread BEFORE visual contact (Reaper Leviathan roar)
- Fear diminishes with mastery: known quantity becomes "respected but not feared"
- Developer intent: preserve "shiver of the unknown" - never feel truly complete
- **GoDig Tension Model**: Our depth layers should increase unfamiliarity. Surface = safe/known, deep = uncertain/hostile. Mastery (upgrades) reduces fear.

**Numbers Go Up Psychology (Idle Game Retention)**:
- Core insight: "seeing numbers go up creates very positive feedback loop of micro-dopamine hits"
- Retention power is "unmistakable" - keeps players coming back
- Works even when player isn't actively engaged (idle accumulation)
- **GoDig Implementation**: Depth counter, coin total, ore count, upgrade progress - all should be visible and satisfying. Each increment = tiny reward.

**Vertical Slice Playtesting (GDC 2025 / SLICE Conference)**:
- GDC 2025 session: vertical slices "more important than ever" for publisher attention
- SLICE Expo 2025: one-day B2B conference for indie/AA developers (August 27, Seattle)
- Speakers include Eric Barone (Stardew Valley), Kim Swift (Portal)
- Key insight: "First impressions decide whether players lean in or tune out"
- Best practices: bold visual first, set tone with sound, give players control quickly
- Pitfalls: scope creep, placeholders, failing to polish - "cut scope, not quality"
- 30-40% of playtesters complete feedback surveys - validation data critical
- **GoDig Priority**: Before any polish, validate core mining feel with greybox playtest.

**Roguelite Death Penalty Design (2025 Consensus)**:
- Roguelites retain "spirit of format but allow players to retain SOME progress"
- Hades innovation: death advances narrative - "dying was no longer failure"
- Resources that don't reset fund permanent upgrades (meta-progression)
- Key insight: "knowledge carries forward" - learning from failure is the loop
- Death creates resilience: "constantly encouraged to push through setbacks"
- **GoDig Emergency Rescue Refinement**: Frame as learning moment. Show depth reached, ores collected, map revealed. "You learned something valuable."

### Topics for Future Research
- [ ] Research Cairn's climbing feedback when full release available (2026)
- [ ] Study Under A Rock's cave resource harvesting design when released
- [ ] Analyze Cryptical Path player reviews for "rogue-builder" reception
- [ ] Study DRG: Rogue Core player feedback when Early Access launches Q2 2026
- [ ] Research SLICE Expo 2025 talks when recordings available
- [ ] Analyze Windblown 1.0 launch reception (2026)
- [ ] Study mobile game "prestige" system timing and player satisfaction

### Implementation Specs Created from Research
- `GoDig-implement-progressive-tutorial-3a7f7301` - One mechanic at a time
- `GoDig-implement-guaranteed-first-99e15302` - First ore within 30 seconds
- `GoDig-implement-ladder-placement-2b7d760f` - Decision feedback
- `GoDig-implement-haptic-feedback-2abf435a` - Mobile haptics for ore/upgrades (Session 10)
- `GoDig-implement-one-hand-5bfe1242` - One-hand friendly HUD layout (Session 10)
- `GoDig-implement-surface-home-81016105` - Surface cozy signals (Session 10)
- `GoDig-implement-monetization-gate-43da3d31` - Day 3 monetization gate (Session 10)
- `GoDig-implement-post-launch-37e1e607` - Remote economy tuning framework (Session 10)
- `GoDig-implement-ore-discovery-5f8102ab` - Balatro-style ore micro-celebrations (Session 10)
- `GoDig-implement-block-adjacent-ef98f7e1` - Near-miss ore shimmer hints (Session 10)
- `GoDig-implement-core-mining-debb2ca2` - Core mining feel validation test (Session 11)
- `GoDig-implement-anti-grind-ea5b1d1e` - Anti-grind economy balance pass (Session 11)
- `GoDig-implement-underground-rest-bf86dfe8` - Underground rest stations v1.1 (Session 11)
- `GoDig-implement-first-5-0e449846` - First 5 minute economy tuning (Session 12 validation)
- `GoDig-implement-distinct-audio-09fbd1b1` - Distinct audio/visual per pickaxe tier (Session 13)
- `GoDig-implement-satisfying-sell-150bde42` - Satisfying sell animation with coin cascade (Session 13)
- `GoDig-implement-return-route-86fe3653` - Visual hint for efficient return routes (Session 13)
- `GoDig-implement-safe-return-6aad4c11` - Safe return celebration when reaching surface (Session 14)
- `GoDig-implement-block-destruction-9de5b1c4` - Block destruction particle effects (Session 14)
- `GoDig-implement-surface-cozy-e7e78188` - Surface cozy zone visual distinction (Session 14)
- `GoDig-implement-depth-unlocks-9826143d` - Depth unlocks new discoveries (Session 14)
- `GoDig-implement-instant-restart-35c6a217` - Instant restart after emergency rescue (Session 14)
- `GoDig-implement-numbers-go-5805c161` - Numbers go up visibility and satisfaction (Session 14)
- `GoDig-implement-discoverable-lore-67646ab4` - Journals, artifacts, abandoned equipment (Session 15)
- `GoDig-implement-welcome-back-f99d9b0d` - Welcome back rewards for returning players (Session 15)
- `GoDig-implement-hidden-treasure-9fd6f4c2` - Hidden treasure rooms in procedural caves (Session 15)
- `GoDig-implement-automation-building-496db9d0` - Auto-Miner Station v1.1 feature (Session 15)
- `GoDig-implement-depth-specific-9e7ded37` - Depth-specific eureka mechanics (Session 16)
- `GoDig-implement-risk-gradient-62fd403a` - Risk gradient scaling by depth (Session 16)
- `GoDig-implement-handcrafted-cave-812a8dfa` - Spelunky-style pre-designed cave chunks (Session 16)
- `GoDig-implement-exploration-fog-ba6cb120` - Exploration fog with map reveal (Session 16)
- `GoDig-implement-layered-secret-8ba7afe0` - Animal Well-style 3-tier secret system (Session 17)
- `GoDig-implement-distinct-layer-a60843e5` - Dead Cells-style distinct layer identities (Session 17)
- `GoDig-implement-optional-danger-cc87675c` - Optional high-risk high-reward danger zones (Session 17)
- `GoDig-implement-ftue-60-94baf4fa` - FTUE: Dig-find-return in first 60 seconds (Session 17)
- `GoDig-implement-upgrade-solves-92eac94a` - Each upgrade solves specific recent frustration (Session 18)
- `GoDig-implement-game-juice-8a70d20e` - Accessibility options for visual/audio intensity (Session 18)
- `GoDig-implement-5-minute-655909a4` - Ensure complete loop fits in 5 minutes (Session 18)
- `GoDig-implement-subtle-mining-7540eb96` - Two-tier juice system (subtle mining vs discovery) (Session 18)
- `GoDig-research-keep-digging-512417e2` - Keep Digging competitive differentiation (Session 18)
- `GoDig-implement-elevator-unlock-a0099585` - Elevator unlock celebration/discovery framing (Session 19)
- `GoDig-implement-block-crack-c5b298f2` - Block crack progression visual feedback (Session 19)
- `GoDig-implement-wall-jump-ec117d74` - Wall-jump mastery celebration feedback (Session 19)
- `GoDig-implement-emergency-rescue-c0e6b975` - Emergency rescue fee proportional to depth (Session 19)
- `GoDig-implement-mining-combo-5de8f33a` - Mining combo/streak feedback (Session 20)
- `GoDig-implement-surface-home-6963fed9` - Surface home base comfort signals (Session 20)
- `GoDig-implement-risk-indicator-b563b726` - Risk indicator for deep dives (Session 20)
- `GoDig-implement-mining-streak-1de66c2b` - Mining streak/combo subtle feedback (Session 20)
- `GoDig-implement-subtle-tension-0b659daa` - Subtle tension audio layer (Session 20)
- `GoDig-implement-depth-based-1cb81c32` - Depth-based ore value multiplier for risk/reward scaling (Session 21)
- `GoDig-implement-full-inventory-8ac866d7` - Full inventory decision moment design (Session 21)
- `GoDig-implement-emergency-rescue-aa6fc471` - Emergency rescue "lesson learned" framing (Session 21)
- `GoDig-implement-surface-warm-3b40fce7` - Surface warm colors and cozy visual distinction (Session 21)
- `GoDig-implement-juice-tiered-system` - Two-tier juice: subtle mining vs discovery celebration (Session 22)
- `GoDig-implement-pickaxe-feel-distinct` - Each pickaxe tier visually/aurally distinct (Session 22)
- `GoDig-implement-scavenged-equipment` - Rare equipment finds underground (inspired by DRG:RC) (Session 22)
- `GoDig-implement-retreat-vs-2b7f49b2` - Loop Hero-style retreat preserves more resources than death (Session 23)
- `GoDig-implement-visual-ladder-3119af69` - Visual urgency indicator for low ladder count (Session 23)
- `GoDig-implement-upgrade-instant-a98283f7` - Upgrades must be FELT immediately after purchase (Session 23)
- `GoDig-implement-coin-flow-4c1b405e` - Coin flow sell animation with satisfying sound cascade (Session 23)
- `GoDig-implement-endless-dig-mode` - v1.1 Endless mode after main progression (Session 24)
- `GoDig-implement-layer-cave-biomes` - Surprise cave biomes that override normal generation (Session 24)
- `GoDig-implement-greybox-playtest` - Core mining feel validation before polish (Session 24)
- `GoDig-implement-depth-unfamiliarity` - Increasing visual unfamiliarity with depth (Session 24)

### Session 25 (2026-02-01)

**Mining Game Fun Factor - The Decision Moment Theory**:
- Forum consensus: "Digging is not the fun part... it's merely the means to get resources"
- Counter: "Something satisfying about digging, discovery, and using those discoveries to enable more digging"
- SteamWorld Dig cited: "quite satisfying just to dig dig dig, without any further concerns"
- Motherload appeal: "surviving in dangerous environment while accumulating wealth, constantly making decisions about risks vs rewards"
- Classic tension quote: "My air tank is just about gone, I need to return to surface, but there's two diamond ores right there"
- **GoDig Critical Insight**: The FUN comes from the DECISION MOMENT, not the digging itself. Ladder scarcity creates decision moments.

**Deep Sea Adventure - Gold Standard for Shared Tension**:
- Shared oxygen is "probably the smartest part of this game"
- Players calculate: grab treasure close for quick return, or risk diving deep?
- Each treasure reduces air by 1 per turn for that player - greed affects everyone
- Movement reduced by 1 per treasure held - the greedier you are, the harder the ascent
- Creates "ever-growing sense of tension" as players push luck
- Social dynamic: "trying to tell people not to take treasure" sparks laughter
- Dead simple to learn, "absolute blast to play" - few games "capture the fun, tension, and greed"
- **GoDig Application**: Our solo ladder economy removes social blame. Player only blames themselves = cleaner mobile experience.

**"One More Run" Addiction Loop (2025-2026 Analysis)**:
- Core quote: "This endless loop of defeat and determination has made roguelikes one of the most addictive genres"
- "The thrill isn't just about survival—it's about growth"
- "Every run teaches you something new, whether it's enemy patterns, loot strategies, or the best time to risk everything"
- Gambling parallel: "feeds into that same part of our brain that likes gambling; you never know if that run will be the one"
- Quick runs matter: "runs are pretty quick which helps too because you can go from doing great to dead pretty fast"
- Against the Storm quote: "Game is like heroin... 'Finished another settlement, I might play something else now... But maybe one more.'"
- **GoDig Application**: Our 5-minute loops enable "one more run" psychology. Emergency rescue should teach, not punish.

**Push-Your-Luck Game Design Principles (Board Game Deep Dive)**:
- Definition: "Decide whether to stop or keep going... get too greedy, end up with nothing"
- Critical distinction: "Push your luck is DIFFERENT from pure luck - requires meaningful CHOICES"
- Probability math: 50% success per step = only 25% chance of two successful steps - players perceive 25% as "very low"
- Self-balancing mechanic: "fewer players still in = greater potential reward" (Incan Gold)
- Banking mechanic: "accumulated points temporarily reside in BANK - uncashed, vulnerable"
- Best games add mitigation: Quacks of Quedlinburg chip return reduces bad luck impact
- **GoDig Validation**: Our ladder economy creates superior progressive risk vs sudden bust mechanics.

**Mobile Game Economy - First Upgrade Psychology**:
- Currency systems should be introduced early with dual-tier: soft currency (earned) + hard currency (paid)
- Early onboarding should be "designer controlled" - player investment is small, require minimal effort
- Monopoly Go! example: "offers generous dice rolls early on... allows them to get hooked on the loop without friction"
- Common mistake: "over-rewarding early progression" or failing to consider motivation
- Balance is tricky: "too generous = blast through content and get bored; too stingy = frustrated and quit"
- Rewards must scale with effort - tough levels should reward more than simple tasks
- Include "sinks" (item upgrades, unlocks) to prevent inflation and hoarding
- **GoDig Application**: First pickaxe upgrade should be achievable quickly but FEEL transformative. Not 10% better - dramatically different.

**Why Mining Games Are Addictive (2025 Consensus)**:
- Progress loop: "Each layer you uncover feels like a small win"
- Core cycle: "dig, collect, upgrade, repeat" - found in idle mining AND clicker games
- Satisfaction feedback: combination of clicking for resources, passive generation, and production boosts
- Discovery and exploration: "There's just something satisfying about digging, discovery, and using those discoveries to enable more digging"
- Power progression: "progressively increasing power" as tools unlock faster mining and deeper exploration
- Depth as narrative: "digging isn't just a number that goes up, it's a journey downward. The deeper you go, the more the game opens up."
- **GoDig Validation**: Our depth = narrative approach is validated. Each layer should feel like entering new territory.

**New Mining Roguelikes 2025-2026 Landscape**:
- **Kin and Quarry** (January 2026): New mining indie, validates ongoing interest
- **Dig Dig Boom**: "Time only moves when you do" - roguelike mining puzzle (Godot engine)
- **ITER**: Mining roguelite with 2D-3D dimension shifting, announced for 2025
- itch.io growing: asteroid mining roguelikes, ant mining roguelikes, Blast Mining Co. (steampunk)
- 2026 trend: "long-term content updates, season-style progression, deeper simulation systems"
- Co-op mining keeping momentum with "season drops and new biomes/events"
- **GoDig Competitive Position**: Mobile-first ladder-based push-your-luck remains unique differentiator.

**Core Loop Design Fundamentals (2025-2026)**:
- Three elements: Challenge (obstacle), Action (player response), Reward (feedback)
- "This triad creates a feedback loop that motivates the player to keep playing"
- Core loop is "engagement engine which, when properly built, is the driving force behind revenue and long-term retention"
- FTUE critical: "first few minutes often determine whether a player will continue or uninstall"
- Get players into game quickly: "if first few minutes are not interesting... vast majority drop out"
- Poor onboarding = major cause of low D1 retention: players feel lost, don't see fun fast enough
- D1 drop = fix FTUE/tutorial; D7 cliff = core loop lacks depth; D30 slide = missing late-game content
- **GoDig Implementation**: First block breaks within 5 seconds. First ore within 30 seconds. First sell within 60 seconds. First upgrade within 5 minutes.

**SteamWorld Dig Upgrade Satisfaction Analysis**:
- Positive: "good deal of satisfaction from collecting every bit of ore" - upgrades keep things fresh
- Pacing praised: just when pickaxe fails against bedrock, drill enables continued descent
- Loop satisfaction: "wallet empty, return to mine, new upgrades let me travel deeper. This satisfying loop continues."
- Sequel (SteamWorld Dig 2) improvements: "difference in capabilities between start and end is monumental"
- Upgrade choice: "trouble choosing among available upgrades, because each has noticeable effect"
- **Criticism**: special orbs "too rare at beginning, too common at end" - pacing issue
- **Criticism**: progression walls require either story caves or grinding runs for upgrades
- **GoDig Learning**: Each upgrade should solve specific frustration player just experienced. Pacing must be consistent.

**Dome Keeper Player Feedback Polarization**:
- Negative: "too slow, repetitive, grindy" + "so much back and forth" + "tediously inefficient input"
- Positive: "addicting mix of tower defence and Dig Dug" + "10/10 gameplay loop" + "nothing feels better than getting back to base with a second to spare"
- Critical insight: Pacing matters - lovers praise tension, haters cite tedium
- Despite polarization: 92% positive recent reviews (9,700+ total)
- **GoDig Learning**: Return trip must feel like ACHIEVEMENT. Wall-jump + ladders = skill expression. Elevator = late convenience.

### Session 26 (2026-02-02)

**Mr. Mine Depth-Surprise System Analysis**:
- Core philosophy: "Adventure and discovery" emphasized over pure incremental progress
- Each new depth introduces "rarer minerals, hidden structures, surprises" - breaks monotony
- 100+ drill upgrades create constant progression milestones
- Random events like "finding a mysterious cave" mix up routine gameplay
- Unlocking secrets (new areas, special upgrades) adds excitement most idle games skip
- Light narrative woven in: "hints of a bigger purpose" as you dig deeper
- Spans 3 distinct worlds (Earth, Moon, Titan) - major content gates prevent burnout
- Secret achievements system adds meta-goal layer for completionists
- **GoDig Application**: Each depth layer should introduce discoverable surprises - caves, abandoned equipment, rare ore veins. Not just harder blocks.

**Keep Digging (September 2025) Player Reception Analysis**:
- Released September 11, 2025 at $5 price point - validates low barrier entry
- Current reviews: 81% positive (recent), 80% overall (2,350+ reviews) - solid reception
- Core loop praised: "relaxing satisfaction of digging, discovery, and upgrading"
- Up to 8 players co-op, 10 layers to 1,000m depth
- **No combat, no stealth** - validates cozy mining approach
- Cross-progression between solo and multiplayer praised highly
- Player quote: "pure exploration focus" works for casual audience
- Criticism: "performance hiccups in co-op at deeper layers" + lobby matching issues
- **GoDig Competitive Position**: Our ladder-based risk system remains unique; Keep Digging has no tension mechanic. We differentiate on push-your-luck, they differentiate on multiplayer.

**Mobile Game Lapsed Player Re-engagement (2025-2026 Best Practices)**:
- Key driver 2026: "re-engaging known user via retargeting significantly cheaper than acquiring new one"
- Login calendars especially popular in Japan - acknowledge returning players warmly
- State of Survival's "Survivor Recall" event includes its own Battle Pass for lapsed players
- Pokémon GO "comeback events" reward returning players with bonus XP and rare items
- ML-driven prediction separates: at-risk mid-value (moderate rewards), high-value whales (VIP treatment), low-value free (ad-based incentives)
- Mistplay learning: "players were happier without having the pressure" of streak systems - remove guilt
- Playable ads remind lapsed players of core gameplay loop without app friction
- **GoDig Application**: Welcome-back rewards should feel like gift, not guilt. Show depth record + progress reminder + free ladders.

**Dome Keeper Multiplayer Update (Early 2026)**:
- Multiplayer was most requested feature since day 1
- December 2025 playtest completed, early 2026 release expected
- Modes: Cooperative (up to 8 players online) + Competitive Versus (two teams, one shared mine)
- Developer quote: "Adding multiplayer to singleplayer game is unreasonable amount of work"
- Game hit 1M players milestone, 12,000+ reviews at Very Positive rating
- **GoDig Learning**: Focus on single-player core loop perfection. Multiplayer is v2+ feature if ever.

**Deep Rock Galactic: Rogue Core (Q3 2025 Early Access)**:
- Roguelite spinoff - start each mission with ONLY pickaxe, scavenge weapons/equipment
- "The Greyout Barrier" disables technology on contact - forces scavenging gameplay
- Expenite mineral powers temporary upgrades within runs
- Meta-progression: unlock Reclaimer Weapons, Phase Suits, Suit Mods between runs
- 1-4 player co-op, made by Ghost Ship Games in Unreal Engine 4
- Difficulty increases drastically as you progress (vs consistent difficulty in original DRG)
- **GoDig Distinction**: Our game is mobile-first with ladder economy. DRG:RC is PC co-op shooter.

**Push-Your-Luck Mechanics Deep Dive (Board Game Design)**:
- Core definition: "Decide whether to settle for existing gains or risk them all for further rewards"
- Key distinction: Push-your-luck is DIFFERENT from pure luck - requires meaningful CHOICES
- Psychology: "The thrill of potentially enormous success, and the devastation of losing it all"
- Balance formula: Risk AND reward must both increase during turn duration
- Beginning: low risk, low reward - most players keep going
- Middle: moderate risk, greater reward - should be rewarded for stopping here
- End: high risk, highest reward - only for committed players
- Can't Stop (Sid Sackson): 44 years of success proves the mechanic's timeless appeal
- Zombie Dice: "3 strikes and you're out" rule creates gradual tension
- Quacks of Quedlinburg: bag-building + push-your-luck with mitigation mechanics
- **GoDig Validation**: Our ladder depletion creates superior progressive risk vs sudden bust.

**Mobile Game First Upgrade Psychology (2025)**:
- D1 retention is where "most of the retention is made"
- Only 2-5% of players ever spend money in F2P games
- Games like Head Ball 2 don't show IAPs to new users at all initially
- Daily rewards establish habit loop - "people hate breaking streaks"
- If D1 is weak, onboarding is the issue; if D1 solid but D7 tanks, early content lacks depth
- UA costs have skyrocketed due to privacy changes - retention > acquisition in 2025
- Mobile gaming generated $92B in 2024, 98% from F2P
- **GoDig Critical**: First upgrade must be achievable quickly AND feel transformative. No IAPs shown until player has experienced full loop.

**Multi-Layer Progression Design (2025 Best Practices)**:
- Single 'progression system' not enough - need short, medium, and long-term goals
- Hybrid progression combines XP-based, item-based, skill-based, narrative layers
- Meta layer "must feed core game, and core game must feed meta layer"
- "Tower of Wants" philosophy: players must always anticipate something new
- Hybrid casual games (hyper-casual + deeper mechanics) showing higher LTV
- AI enabling adaptive, personalized progression structures
- **GoDig Implementation**: Short-term (ore discovery), medium-term (pickaxe upgrade), long-term (layer unlock, shop expansion).

**New Mining Roguelikes 2025-2026 Landscape Update**:
- **Slay the Spire II** expected March 2026 - major roguelite event
- **Tears of Metal** Scottish Musou roguelike - slipped from 2025 to early 2026
- **Returnal 2** slated for 2026 - validates roguelite + narrative structure
- itch.io growing: Terra Pit, Illumine, BORE BLASTERS, Blast Mining Co. (steampunk)
- 2026 trend: season-style progression, deeper simulation systems, long-term content updates
- **GoDig Competitive Position**: Mobile-first ladder-based push-your-luck still unique.

**Balatro Development Update (LocalThunk)**:
- 1.1 update pushed back to 2026 - "done when it's done"
- Creator cites burnout after 1.0 launch + mobile port work
- Will include new Jokers + Matador overhaul + blue stake difficulty changes
- 5M+ copies sold as of January 2025
- Vampire Survivors crossover: 4 Balatro characters added (Jimbo, Canio, Chicot, Perkeo)
- **GoDig Learning**: Solo dev burnout is real. Plan for sustainable development pace.

### Session 27 (2026-02-02)

**Prestige System Timing (Mobile/Idle Game Best Practices)**:
- Key question: When is the optimal time to reset for maximum efficiency?
- Signs it's time to prestige: upgrade costs grow faster than gains, multiplier growth flattens, progress stalls
- Time efficiency: "better to prestige when you have good relic gain per minute rather than pushing extremely high stages slowly"
- Common mistakes: prestiging too early (missing bigger rewards), waiting too long (wasting time on low-value upgrades)
- Pre-prestige strategy: upgrade heavily before resetting, save multipliers for end of run
- Advanced timing: Early = every 2-4 hours active play; Late = every 30-60 minutes as scaling improves
- Result: "Each prestige run should take less time but yield exponentially higher gains"
- **GoDig v1.1 Application**: If prestige system added, signal when player "should" prestige (progress stalled indicator), make it feel like strategic choice not punishment.

**Roguelike Difficulty Curve Balance (2025 Consensus)**:
- Perfectly balanced difficulty: "turns every setback into a learning opportunity"
- Balance comes from "clever enemy design, well-paced unlocks, or adaptive difficulty curves"
- Hades example: God Mode "gradually increases damage reduction with each death" - customizable challenge
- Dead Cells example: "Boss Cell system lets you customize your challenge level as skills improve"
- Into the Breach example: "mistakes are punishing, but solutions are always within reach"
- Meta-progression debate: some prefer pure skill (Spelunky), others like permanent unlocks (Hades)
- RNG fairness: Three layers - Fixed (skill baseline), Semi-Random (strategy playground), Pure RNG (memorable moments)
- Quote: "I died because I deserved it — that's exactly why I have to go again"
- **GoDig Application**: Emergency rescue should feel fair - player saw warnings, made choices. Not sudden-death RNG.

**Mobile Game Audio Design (2025 Research)**:
- 85% of players appreciate audio impact on gaming experience
- Well-executed audio can boost player satisfaction by 70%
- 88% of players consider audio as important as visuals
- Audio signals enhance awareness of interactive elements (resource collection, character actions)
- Games with effective audio integration see 20% increase in player retention
- FMOD/Wwise middleware enables dynamic audio that responds to player actions
- AI/ML expected to automate sound design and create adaptive audio environments
- **GoDig Priority**: Mining sound must be satisfying. Each ore type needs distinct collection sound. Upgrade sounds need celebration feel.

**Touch Controls Best Practices (Mobile Design)**:
- "Subway Thumb" control: same hand holds device and controls game action
- Touch controls "will make or break your game on a mobile device"
- Best mobile games "accepted that touchscreens aren't the same as gamepads"
- Tap-and-drag most common for one-handed play
- Pointer system: most frameworks support 2 simultaneous touches minimum
- Gesture controls (swipe, tap, hold) can replace virtual buttons for cleaner UI
- **GoDig Validation**: Our tap-to-mine design is mobile-native. HUD elements must stay in thumb-reachable zones.

**Spelunky 2 Procedural Generation Secrets**:
- Two-layer system: front layer (entrance/exit) + back layer (doors/tunnels to secret areas)
- Back layer contains treasure rooms, hidden passages, special places
- Secret areas require items from previous zones (Eye of Udjat, Hedjet, Scepter, etc.)
- Multi-step secrets: Black Market → Temple → City of Gold → Cosmic Ocean
- "No two expeditions are identical" yet all paths are fair and completable
- Community maintained 5+ years of engagement via layered secrets discovery
- March 2025: PS5 upgrade with 120 FPS - continued platform investment
- **GoDig Application**: Consider two-layer caves - visible front + hidden back areas accessible with special items.

**Terraria Underground Layer Design**:
- Five distinct layers: Space → Surface → Underground → Cavern → Underworld
- Each layer has proportional depth regardless of world size
- Underground begins at 0ft depth, contains early game ores (T1, T2)
- Cavern layer: T3 and T4 ores, true underground biome versions (Ice, Jungle, Desert)
- Biomes span multiple layers but have distinct underground variants
- Numeric threshold system: ~1,500 blocks within 84-tile radius triggers biome effects
- "Spelunking is key to gameplay... many great weapons and item drops littered below surface"
- **GoDig Layer System**: Model after Terraria's clear depth progression. Each layer introduces new ore tier + visual identity.

**Pixel Art Mining Games (2025 Landscape)**:
- PixelVerse Explorer: randomly generated maps, new biomes, hidden caves, dangerous dungeons
- Core Keeper: "Terraria meets Stardew Valley" - lighting and shadows create tension + wonder
- CraftPix mining assets available for rapid prototyping
- itch.io growing ecosystem: Aground, UNEARTHED, Arcane Earth, Kin and Quarry
- Common praise: "retro-inspired pixel graphics with modern smooth animations"
- **GoDig Art Direction**: Pixel art validated for mining games. Lighting/shadows critical for depth atmosphere.

### Topics for Future Research
- [ ] Research Cairn's climbing feedback when full release available (2026)
- [ ] Study Under A Rock's cave resource harvesting design when released
- [ ] Analyze Cryptical Path player reviews for "rogue-builder" reception
- [ ] Study DRG: Rogue Core player feedback when Early Access launches
- [ ] Analyze Slay the Spire II for roguelite innovation (March 2026)
- [ ] Research Dome Keeper multiplayer reception after Q1 2026 launch
- [x] Study mobile game "prestige" system timing and player satisfaction (Session 27)
- [x] Analyze Keep Digging player reception (Session 26)
- [x] Study mobile game "comeback" mechanics (Session 26)
- [x] Analyze Mr. Mine depth-surprise system (Session 26)
- [x] Research roguelike difficulty balance (Session 27)
- [x] Study mobile game audio satisfaction (Session 27)
- [x] Research Spelunky 2 procedural secrets (Session 27)
- [x] Study Terraria underground layers (Session 27)

### Session 28 (2026-02-02)

**Mobile Haptic Feedback Best Practices (iOS/Android 2025)**:
- iOS Taptic Engine offers more nuanced control than Android
- Android: prioritize HapticFeedbackConstants, avoid legacy vibrate() calls
- Two haptic types: Clear (crisp button presses) vs Rich (expressive, wider frequency)
- "Given choice of buzzy haptics or no haptics for touch feedback, choose no haptics"
- Haptics must match visual/audio feedback for cohesive experience
- Vibration reserved for events requiring immediate attention
- Unity: Nice Vibrations plugin offers cross-platform HD haptic control
- Accessibility: always allow users to disable; some users find vibrations overwhelming
- Performance: avoid excessive triggering, ensure async calls don't block UI
- **GoDig Implementation**: Subtle haptic on ore discovery, stronger on upgrade purchase. Disable option required.

**Roguelite Meta Progression Balance (2025 Debate)**:
- Two types: Stat upgrades (power increases) vs Sidegrades (more options/unlocks)
- Common complaint: "game balanced expecting 500 runs for 500 1% upgrades before you can win"
- Evergreen concern: "permanent upgrades eventually reach ceiling where you can easily finish"
- Best practice: "unlock alternate equipment/starting loadouts rather than pure stat increases"
- Hades solution: Heat system optionally increases difficulty to counterbalance power
- Quote: "Roguelites with heavy meta-progression prioritize something other than mastery"
- Sidegrade examples: Binding of Isaac, Enter the Gungeon - expand item pool, not stats
- **GoDig Application**: Consider sidegrades (new item types, inventory layouts) over pure stat increases for late-game.

**Casual Mobile Session Length (2025 Data)**:
- Average mobile session: 5-8 minutes, median 5-6 minutes
- Top 25% games: 8-9 minute average sessions
- First session design: aim for 10-20 minutes to "have any chance of F2P success"
- Players average 4-6 sessions daily - snackable gaming behavior
- Session restriction methods: Energy systems, Lives systems
- Rule of thumb: 10-minute session possible without spending money
- Hyper-casual: "tap-reward-repeat" loop, short sessions, clean visuals
- Hybrid-casual: easy entry + meta layers (progression, cosmetics) for better LTV
- Interruption handling: player must be able to exit anytime and return to exact state
- **GoDig Target**: Complete dig-sell-upgrade loop in 5 minutes. Support instant exit/resume.

**Idle Game Offline Progress Calculation**:
- Core principle: "Players rewarded for coming back, never punished for taking a break"
- Time caps standard: typically 24 hours to 4 days maximum offline progress
- Simplified calculations: complex mechanics approximated rather than fully simulated
- Averaging approach: base calculations on recent performance before going offline
- Mr Mine: miners keep working offline; early investment in drill power pays off
- Melvor Idle: full simulation approach - determines skill trained, simulates progression up to 24 hours
- Some features (auto-upgrades) often disabled during offline periods
- **GoDig v1.1 Consideration**: If passive income added, cap offline progress and use simplified calculation.

**Block Break Animation & Particle Effects (Mining Games)**:
- Minecraft Physics Mod: realistic particles that move/fall after block break, move away when player walks through
- Fancy Block Particles: converts 2D particles to 3D animated particles (763K+ downloads)
- Particle Interactions: unique particles for placing, breaking, sprinting on blocks
- Loading bar animation: visual progression gauge makes break times easier to gauge
- Immersive Mining (Vintage Story): frame-synchronized effects, shake effect, custom animations/sounds
- Multi-stage crack patterns: gradual web of cracks until block shatters - "more immersive and satisfying"
- **GoDig Priority**: Progressive crack pattern on blocks, satisfying particle burst on break, subtle screen shake on hard blocks.

### Topics for Future Research
- [ ] Research Cairn's climbing feedback when full release available (2026)
- [ ] Study Under A Rock's cave resource harvesting design when released
- [ ] Analyze Cryptical Path player reviews for "rogue-builder" reception
- [ ] Study DRG: Rogue Core player feedback when Early Access launches
- [ ] Analyze Slay the Spire II for roguelite innovation (March 2026)
- [ ] Research Dome Keeper multiplayer reception after Q1 2026 launch
- [x] Study mobile game "prestige" system timing and player satisfaction (Session 27)
- [x] Analyze Keep Digging player reception (Session 26)
- [x] Study mobile game "comeback" mechanics (Session 26)
- [x] Analyze Mr. Mine depth-surprise system (Session 26)
- [x] Research roguelike difficulty balance (Session 27)
- [x] Study mobile game audio satisfaction (Session 27)
- [x] Research Spelunky 2 procedural secrets (Session 27)
- [x] Study Terraria underground layers (Session 27)
- [x] Research mobile haptic feedback best practices (Session 28)
- [x] Study roguelite meta progression balance (Session 28)
- [x] Analyze casual mobile session length (Session 28)
- [x] Research idle game offline progress calculation (Session 28)
- [x] Study block break animation patterns (Session 28)

### Session 29 (2026-02-02)

**Dome Keeper Multiplayer Update Status (2026)**:
- Multiplayer announced August 2025, expected release "early 2026" (estimated March 2026)
- Two-person team making multiplayer despite advice not to: "unreasonable amount of work"
- Multiple modes planned: cooperative (finding relic together) + competitive (two teams, shared mine)
- Community excitement overwhelming: "BEST UPDATE EVER!!!"
- Game at 93% positive (9,766 reviews), 1M+ players at 2-year anniversary
- **GoDig Lesson**: Multiplayer post-launch is extremely costly. Design for single-player first; MP as bonus.

**Deep Rock Galactic: Rogue Core Development (2026)**:
- Q2 2026 Early Access launch (delayed from late 2025)
- 18-24 month Early Access planned for community feedback integration
- Dev quote: "Early Access lets us collect feedback when it's easier to incorporate changes"
- Team found their footing: "things finally clicked into place" after feeling "lost in the woods"
- Community concern: "Roguelike balance can make or break the fun"
- **GoDig Lesson**: Plan for extensive balance iteration. Roguelike economies need tuning post-launch.

**Slay the Spire 2 Innovation (March 2026)**:
- Moving from Unity to Godot engine (validates GoDig's engine choice)
- Early Access approach: "work along with fans to finalize the game"
- New features: alternate acts unlocked via progression - adds variety to roguelite runs
- Characters: Returning (Ironclad, Silent) + New (Necrobinder, Regent)
- Design philosophy: "Deeper systems for returning players, more welcoming on-ramp for newcomers"
- **GoDig Application**: Alternate starting conditions / run modifiers can extend replay value significantly.

**Mobile Retention Benchmarks (2025-2026 Data)**:
- Target benchmarks: D1: 45%+, D7: 20%+, D30: 10%+
- Average benchmark: D1: 30%, D7: 13%, D30: 5%
- iOS vs Android: iOS has 35.7% D1 (vs 27.5% Android), 5% D30 (vs 2.6%)
- Match-3 highest retention (32.6% D1, 7.1% D30), Strategy lowest D1 (25.3%)
- D1 key insight: "If monetization is too aggressive, you'll notice low retention from beginning"
- Best practice: "Fewer ads in beginning, increase once players are hooked"
- **GoDig Target**: Aim for 35%+ D1 retention. No ads/monetization in first 3 runs.

**Thumb Zone Ergonomics (2025)**:
- 80%+ of smartphone users operate with one hand
- Phones now exceed 6.5 inches - old UX patterns don't work
- Three zones: Easy (bottom/center), Stretch (sides), Hard (top corners)
- Bottom navigation, floating action buttons, slide-up drawers are standard
- Left-handed vs right-handed users have different thumb zones
- Swipe gestures can replace virtual buttons for cleaner UI
- **GoDig Validation**: Tap-to-mine is thumb-native. HUD must stay in bottom/center zones.

**Roguelite Progression Philosophy Debate**:
- Two camps: Permanent unlocks (Hades) vs Pure skill (Spelunky)
- Progression criticism: "Lazy design - shifts balancing from designer to player"
- Inverse difficulty curve problem: "Game is hardest at beginning, keeps getting easier"
- Spelunky argument: "I have everything needed from run 1, just need knowledge and skills"
- Hybrid solution: Unlocks expand OPTIONS (sidegrades) not raw POWER (stat increases)
- Ascension/Heat systems: Reward mastery with MORE challenge, not less
- Quote: "Roguelites with progression 'end' by nature; skill-based games last forever"
- **GoDig Application**: Consider sidegrades (new items, abilities) over stat boosts for late-game.

**Procedural Cave Generation Algorithms**:
- Cellular Automata: Initialize 40% filled, smooth via neighbor counting, iterate
- Random Walk: Simple path creation, mark as you go
- Perlin/Simplex noise: Natural-looking terrain gradients
- Connection strategy: Minimum Spanning Tree (Prim's/Kruskal's) ensures all rooms reachable
- Problem with pure MST: Too linear, no cycles - add extra edges for variety
- Flood fill: Identify unique rooms, random-walk corridors to connect them
- Seeds: Ensure reproducibility for testing while appearing random
- **GoDig Implementation**: Cellular automata for caves, MST+extras for connectivity.

**Mobile Game Save State Best Practices**:
- Always load latest data on app start/resume, save frequently
- Offline-first: Core gameplay works without internet, sync when connection resumes
- JSON preferred (58% of devs) for readability; binary for performance-critical saves
- Don't store large data in instance state - use IDs to reconstruct
- Tiered saving: Player progress continuous, secondary elements less frequent
- 70% of players prefer resuming from last action without downtime
- 54% prefer manual save control alongside auto-save
- **GoDig Implementation**: Auto-save every 30 seconds + on key events. Resume to exact state.

**Game Feel "Juice" in Mining Games**:
- Juice = immediate visual/audio feedback to player actions
- Key elements: Screen shake, particle explosions, size bouncing, sound effects, trails
- Minecraft example: Block particles cause stuttering with many breaks - optimize!
- Research (N=3018): Medium and High juice best; None and Extreme both decrease play time
- Balance is key: Too much juice is as bad as none
- Visual effects must: fit tone, match action, happen instantly, add "magic"
- **GoDig Priority**: Medium-level juice. Progressive cracks + particle burst + subtle shake.

**F2P Economy Balancing (2025)**:
- 78% of successful titles use multiple currencies
- Dual currency systems increase engagement by 30%
- Currency too hard to earn = grind feels offputting, players leave
- Currency too easy = rewards feel worthless, god-mode boredom
- Currency sinks prevent inflation - multi-tier crafting effective
- Time as anchor value: Easiest to track, players understand pace
- Early game (D1-7): Generous soft currency, sparse hard currency
- Mid game (W2-8): Resource management complexity increases
- Late game (M3+): Premium currency importance increases
- **GoDig Economy**: Single currency (coins) for MVP. Generous early, tighter mid-game.

### Topics for Future Research
- [ ] Research Cairn's climbing feedback when full release available (2026)
- [ ] Study Under A Rock's cave resource harvesting design when released
- [ ] Analyze Cryptical Path player reviews for "rogue-builder" reception
- [x] Study DRG: Rogue Core early access feedback (Session 29 - pre-release info only)
- [x] Analyze Slay the Spire II for roguelite innovation (Session 29)
- [ ] Research Dome Keeper multiplayer reception after Q1 2026 launch
- [ ] Study mobile game "juice" calibration - optimal particle density
- [ ] Research procedural generation seeds and reproducibility patterns
- [ ] Analyze successful roguelite sidegrade systems (Isaac, Gungeon)
- [x] Study mobile game "prestige" system timing and player satisfaction (Session 27)
- [x] Analyze Keep Digging player reception (Session 26)
- [x] Study mobile game "comeback" mechanics (Session 26)
- [x] Analyze Mr. Mine depth-surprise system (Session 26)
- [x] Research roguelike difficulty balance (Session 27)
- [x] Study mobile game audio satisfaction (Session 27)
- [x] Research Spelunky 2 procedural secrets (Session 27)
- [x] Study Terraria underground layers (Session 27)
- [x] Research mobile haptic feedback best practices (Session 28)
- [x] Study roguelite meta progression balance (Session 28)
- [x] Analyze casual mobile session length (Session 28)
- [x] Research idle game offline progress calculation (Session 28)
- [x] Study block break animation patterns (Session 28)
- [x] Study mobile game retention benchmarks (Session 29)
- [x] Research thumb zone ergonomics (Session 29)
- [x] Analyze roguelite progression philosophy (Session 29)
- [x] Study procedural cave generation algorithms (Session 29)
- [x] Research mobile save state persistence (Session 29)
- [x] Study game feel "juice" optimization (Session 29)
- [x] Research F2P economy balancing (Session 29)

### Session 30 (2026-02-02)

**Mobile Game Onboarding Best Practices (2025-2026)**:
- FTUE (First Time User Experience): First 60 seconds + first 15 minutes
- Onboarding: First 7 days of gameplay, forming longer-term goals
- Key insight: "Teach by doing, not telling" - learning through gameplay, not isolated screens
- Progressive disclosure: Hide systems not needed for first 15 minutes
- Start onboarding immediately at launch - avoid splash screens and menus
- Gamify tutorials: mini-goals, progress tracking, instant rewards
- Social features early increase retention significantly
- Micro-interactions (sparkles, dings, character nods) make onboarding delightful
- Personalization: Not all users need same guidance level
- Warning: Heavy/long tutorials harm the game - can be "boring, frustrating, and unclear"
- 25% of users abandon after one session; good onboarding can increase retention by 50%
- Tap targets: minimum 44x44 pixels with padding
- **GoDig Application**: First ore in 30 seconds, first sell in 60 seconds, first upgrade in 3 minutes.

**Roguelike Resource Scarcity and Tension Design**:
- "Reducing grind rule": Spending time depletes finite resources (historically: food timers)
- Rich Carlson called this a "clock" - imposes deadline limiting exploration
- Permadeath creates stakes: "Every decision given critical meaning"
- Balance: "Too much predictability kills tension. Too much randomness makes choices meaningless."
- Pre-action vs post-action luck: Pre-action (see item, decide if worth spending key) preserves agency
- Early game: Time constraints incentivize optimizing rather than "sluggishly playing through"
- Consumables: "Dying with inventory full of great potions" trope - teach players to USE items
- **GoDig Application**: Ladder depletion is our "clock." Each ladder used is a decision with consequence.

**Pixel Art Underground Atmosphere Design**:
- Animal Well: 7 years solo development, reduced color palette emphasizes depth and eerie vibe
- Inmost: Desaturated blues/grays, darkness + light/shadow play creates recognizable atmosphere
- Early LucasArts: Masterful dithering creates depth/shading with tiny palettes
- Sierra adventure games: Clever shading makes limited colors feel 3D
- Design principle: "Choose palette to complement emotional tone and setting"
- Every pixel should serve a purpose - balance detail and simplicity
- **GoDig Application**: Use desaturated colors deeper underground. Contrast with warm surface tones.

**Godot Mobile Performance Optimization (2025)**:
- Draw calls: Keep low, use batching (CanvasItem/MeshInstance grouping)
- MultiMeshInstance: Instance repeated objects (trees, ores) in single draw call
- Texture atlases: Combine textures to reduce draw calls
- Collision detection: Use appropriate algorithm complexity for game needs
- Profiling: Use Godot built-in tools + Arm Streamline for mobile
- Specialization constants: Useful but can cause load time issues if overused
- Godot 4.4: Improved culling system, enhanced MultiMeshInstance3D
- Memory baseline: 120-160 MB for medium-complexity scene (efficient)
- Common pitfalls: Over-optimization, under-optimization, ignoring mobile constraints
- **GoDig Implementation**: Profile regularly, batch ore sprites, optimize collision shapes.

**Terraria Biome Visual Identity System**:
- Hallow: Pastel colors, cyan grass, multicolored trees, rainbow background - "fairytale graphics"
- Underground Hallow: Purple background + blue/pink crystals = distinct visual signature
- Corruption: Dark purple wasteland, death/decay theme, thorny bushes
- Underground Corruption: Green-ish colors, different soundtrack, unique enemies
- Background system: Each biome randomly assigned background from set, changeable via World Globe
- Biome conflict: Corruption/Crimson cannot overlap Hallow (gameplay mechanic)
- Detection: Numeric threshold (blocks within radius) triggers biome effects
- **GoDig Layer Design**: Each layer needs: distinct color palette, unique background, specific ore types.

**Subnautica Depth Zone Visual Storytelling**:
- Biomes contribute to atmosphere AND storytelling, enhancing immersion
- Progression: Kelp Forest (safe beginning) → Grassy Plateaus → Jellyshroom Caves (purple glow)
- Deep zones: Lost River + Lava Zones = "alien, biomechanical, hostile territories"
- Design evolution: Each depth tier more uncomfortable - less oxygen, less visibility, more danger
- Mushroom Forest described as "hauntingly beautiful" at night with glowing flora + jellyray "ghosts"
- Environmental storytelling: Architecture + artifacts reveal history, not direct exposition
- Development process: Keywords/references → concept art riffs → expanded visuals
- **GoDig Application**: Use visual discomfort progression. Surface = warm/safe, Deep = cold/alien.

### Session 31 (2026-02-02)

**Cairn Launch Success Analysis (January 2026)**:
- Released January 29, 2026 after delay from November 2025
- 200,000+ copies sold in first 4 days - "first success story of 2026"
- Very Positive on Steam with 800+ user reviews at launch
- Core mechanic: Manually position each of Aava's limbs as she climbs, manage stamina and posture
- Piton placement creates checkpoints, preventing full progress reset on fall
- Described as "survival climber" - manages stamina, posture, and risk without excessive punishment
- The Game Bakers called it conclusion of "trilogy on freedom" (after Furi, Haven)
- 25-person team, 4+ years development - validates indie climbing game viability
- **GoDig Takeaway**: Checkpointing mechanics reduce frustration. Our ladder placement serves similar function - creates player-defined safety points.

**Cryptical Path: Rogue-Builder Reception Analysis (January 2025)**:
- Released January 29, 2025 - "world's first action roguelite builder"
- Steam reviews: 86% positive (122 reviews) - Very Positive rating
- Core innovation: Build dungeon rooms to create your own path to boss
- Player quote: "Not at mercy of game as your own thriftiness" - player agency over route
- Positive: "Movement feels great, combat feels great, map building feels great"
- Positive: "Offers something new and refreshing... building own path brings breath of fresh air"
- Criticism: "Tuning/balancing of hero/items/enemies is godawful" + "strong unfinished vibe"
- Criticism: "No sense of progress after 2h mark, just getting punished"
- Fully optimized for Steam Deck - validates handheld/mobile potential
- **GoDig Application**: Player-directed path creation increases agency and investment. Our surface building system could offer similar "build your strategy" feel.

**Drill Core: Mining Roguelite Competitor Analysis (July 2025)**:
- Full release July 17, 2025 after September 2024 Early Access
- Output Lag scored 8/10: "masterfully blends mining management with tower defense"
- Core praise: "Meticulously polished, developer truly listened to feedback"
- Day/night cycle creates tension: "balancing 'I need more iron' vs 'my miners got crushed'"
- Criticism: Three separate meta-progression systems competing for attention - viewed as padding
- Criticism: Unit AI "maddeningly obtuse" - workers avoid valuable resources
- Criticism: Runs last longer than other roguelikes - pacing issues
- Criticism: "Gameplay gets repetitive quickly" despite new variations
- **GoDig Advantage**: Our 5-minute loops prevent pacing issues. Single progression system (coin economy) avoids competing systems confusion.

**Loop Hero Retreat Mechanic Deep Dive**:
- Three-tier resource retention: Camp (100%), Retreat (60%), Death (30%)
- "Risk/reward dilemma that's fun to engage with on each dive"
- Design insight: "Players blame game less if they lose after not taking retreat option"
- "Supplies" perk: Auto-deposit 50% of materials each loop - changes strategic calculus
- Valid strategy: "Go on resource runs, cash out, not focus on killing boss"
- Retreat creates management layer: weigh accumulated danger vs possible rewards
- No permanent death = roguelite, but resource retention creates meaningful progression
- **GoDig Application**: Model emergency rescue after Loop Hero - surface return = 100%, rescue = 60%, death/failure = 30%. Frame rescue as valid strategy, not punishment.

**Roguelike Difficulty Balance Principles (2025 Consensus)**:
- Quote: "Challenge without fairness is frustration, fairness without challenge is boredom"
- Dead Cells model: Early biomes allow experimentation, later areas increase complexity
- Hades model: Generous early resources, heat system ramps up with proficiency
- "Positive randomness" principle: RNG should provide varying good outcomes, not punishing bad ones
- "No beheading rule": Random elements should never instantly end run without warning/counterplay
- Progressive difficulty via "ascension mode" (Slay the Spire coined) - difficulty modifiers unlock on win
- Roguelites (meta-progression) are more accessible than roguelikes (pure permadeath)
- **GoDig Application**: Our ladder warnings provide counterplay. Never sudden-death from RNG. Progressive depth difficulty with player agency over risk.

**Player Agency and Meaningful Choice Design (2025)**:
- Key elements: Foreseeability, Ability, Desirability, Connection to outcome
- Simpler model: Choice (options), Control, Influence (decisions change world)
- Limiting choice can increase engagement - "thoughtful focus on impactful decisions"
- Disco Elysium example: Each choice reveals personality with rippling consequences
- Sid Meier quote: Decisions should "let players express personality or gaming style"
- Avoid "false choices": No information to decide, options seem equal, all lead to same outcome
- **GoDig Application**: Ladder placement = meaningful choice (where to commit safety). Inventory management = meaningful choice (what to keep). Depth decisions = meaningful choice (risk vs reward).

**Death Penalty Design Across Games**:
- EVE Online model: "Loss of resources, preservation of capabilities" keeps game tense
- Design principle: "Take something that can't be replaced by repeating steps" - otherwise just taking time
- Risk of losing inventory "not inherently poor design" - creates risk measure
- Modern trend: Configurable death penalties in server settings (Palworld, Hytale examples)
- Durability loss as middle ground: consequences without full item removal
- Key insight: "Players unwilling to accept large penalties need accessibility options"
- **GoDig Application**: Our emergency rescue takes cargo percentage, not capabilities (pickaxe tier). Player can recover through repetition but feels the loss. Accessible, not punishing.

**Mobile Mining Passive Income Trends (2025-2026)**:
- Idle Miner Tycoon: Automation unlocks, collect idle cash even offline
- Deep Town: Assign bots to increase motivation, mine resources while offline
- Play-to-earn trend: Blockchain integration for real-world value
- Core pattern: Start manual → unlock automation → offline progress based on production rate
- Mr. Mine Idle: Mining + exploration themes, underground areas to progress
- **GoDig v1.1 Consideration**: If adding passive income, cap offline progress (24h standard) and use simplified calculation. Passive should feel like bonus, not replacement for active play.

**Visual Depth Progression Design Principles**:
- Color theory: "Warm and cool zones create contrast, depth, storytelling nuance"
- Caves of Qud: Fixed 18-color palette with primary/detail/background per tile - consistency matters
- Elden Ring: Modular terrain with consistent palette, light/color shifts match narrative beats
- Returnal: Procedural tiles with consistent palette curation maintain visual identity
- Under A Rock: New cave modules, creatures, underwater visuals for depth variety
- Principle: "Style guide with color palette, line style, level of detail" ensures consistency
- **GoDig Implementation**: Define fixed palette per layer. Warm surface → desaturated deep. Consistent within layer, distinct between layers.

### Session 32 (2026-02-02)

**Drill Core Pacing Deep Dive**:
- Runs last 30-50 minutes - "a poor choice can bite you after half an hour, frustrating"
- Triple-layered progression feels like "unnecessary busywork"
- "Unlocking meaningful improvements requires significant time and effort, bordering on tedious"
- Late-game sessions "blur together" despite variations
- Comparison: BORE BLASTERS proves 5-15 minute runs work for mining roguelites
- Consensus: 20-30 minutes ideal before "repetition feeling sets in"
- **GoDig Recommendation**: 5-10 minute loops. Allow player choice over session length (quick dig vs deep dive).

**Multiple Progression Systems - When They Fail**:
- Drill Core's three systems = cognitive overload, "competing for attention"
- Players don't understand priorities → feels like padding
- Slay the Spire model (best): No power via meta-progression, just unlocks for variety
- Quote: "Games that make you play with no arms/legs until you grind" = bad design
- Quote: "Power boosting means game is penalized without it"
- **GoDig Validation**: Single currency (coins) is correct. Simpler mental model, no decision paralysis.

**Cairn Piton System - Player-Defined Checkpoints**:
- Three placement states: Perfect (reclaimed), Twisted (returns as scrap), Failed (destroyed)
- Skill-based mini-game: timing slider determines outcome quality
- Resource recovery: Climbot makes 1 piton from 2 scraps - never truly out
- Environmental cues: Gray rock = can place, glossy brown = can't place
- Audio feedback: Aava's breathing indicates trouble before UI shows it
- Fall resets to last piton, NOT start - proportional progress loss
- **GoDig Application**: Consider ladder checkpoint system - rescue returns to highest placed ladder, not surface.

**Cairn Stamina Management Lessons**:
- Audio cues "way more immediate than UI element"
- "If you hear her breathing getting fast and panicked, she is in trouble"
- Flat footing = stable, everything else drains stamina
- Accessibility: Options to make stamina management easier
- Player frustration: Lack of explicit meters feels directionless for some
- **GoDig Application**: Audio/visual cues for ladder depletion should be unmistakable. Consider heartbeat audio at low ladders.

**Mining Roguelite Run Length Comparison**:

| Game | Run Length | Notes |
|------|------------|-------|
| Drill Core | 30-50 min | Too long, frustrating when late-run mistakes happen |
| BORE BLASTERS | 5-15 min | Ideal for battery-powered/mobile devices |
| Wall World | ~20 min | Gets longer with meta upgrades |
| Dome Keeper | Variable | Player chooses via map size |
| General consensus | 20-30 min | "Before repetition feeling sets in" |

### Topics for Future Research
- [x] Research Cairn's climbing feedback when full release available (Session 31, 32)
- [ ] Study Under A Rock's cave resource harvesting design when released
- [x] Analyze Cryptical Path player reviews for "rogue-builder" reception (Session 31)
- [ ] Research Dome Keeper multiplayer reception after Q1 2026 launch
- [ ] Study mobile game "juice" calibration - optimal particle density
- [ ] Research procedural generation seeds and reproducibility patterns
- [ ] Analyze successful roguelite sidegrade systems (Isaac, Gungeon)
- [ ] Study biome transition zones in metroidvanias (Hollow Knight, Ori)
- [ ] Research mobile game daily reward systems without guilt/FOMO
- [x] Drill Core pacing analysis - run length and progression systems (Session 32)
- [x] Cairn piton checkpoint system deep dive (Session 32)
- [ ] Analyze tutorial skip options and their impact on retention
- [x] Study DRG: Rogue Core early access feedback (Session 29 - pre-release info only)
- [x] Analyze Slay the Spire II for roguelite innovation (Session 29)
- [x] Study mobile game "prestige" system timing and player satisfaction (Session 27)
- [x] Analyze Keep Digging player reception (Session 26)
- [x] Study mobile game "comeback" mechanics (Session 26)
- [x] Analyze Mr. Mine depth-surprise system (Session 26)
- [x] Research roguelike difficulty balance (Session 27)
- [x] Study mobile game audio satisfaction (Session 27)
- [x] Research Spelunky 2 procedural secrets (Session 27)
- [x] Study Terraria underground layers (Session 27)
- [x] Research mobile haptic feedback best practices (Session 28)
- [x] Study roguelite meta progression balance (Session 28)
- [x] Analyze casual mobile session length (Session 28)
- [x] Research idle game offline progress calculation (Session 28)
- [x] Study block break animation patterns (Session 28)
- [x] Study mobile game retention benchmarks (Session 29)
- [x] Research thumb zone ergonomics (Session 29)
- [x] Analyze roguelite progression philosophy (Session 29)
- [x] Study procedural cave generation algorithms (Session 29)
- [x] Research mobile save state persistence (Session 29)
- [x] Study game feel "juice" optimization (Session 29)
- [x] Research F2P economy balancing (Session 29)
- [x] Study mobile onboarding best practices (Session 30)
- [x] Research roguelike resource scarcity tension (Session 30)
- [x] Analyze pixel art underground atmosphere (Session 30)
- [x] Study Godot mobile performance optimization (Session 30)
- [x] Research Terraria biome visual identity (Session 30)
- [x] Analyze Subnautica depth zone storytelling (Session 30)

### Implementation Dots Created from Session 31
- `GoDig-implement-retreat-percentage` - Emergency rescue keeps 60% cargo (Loop Hero model)
- `GoDig-implement-player-agency-decisions` - Ladder placement, inventory, depth as meaningful choices
- `GoDig-implement-no-sudden-death` - Never instant-death from RNG, always provide warning/counterplay
- `GoDig-implement-depth-palette-system` - Fixed palette per layer, warm→desaturated progression
- `GoDig-implement-rescue-as-strategy` - Frame emergency rescue as valid strategy, not punishment

### Implementation Dots Created from Session 30
- `GoDig-implement-ftue-timing` - First ore 30s, first sell 60s, first upgrade 3min
- `GoDig-implement-progressive-disclosure` - Hide advanced systems until first 15min complete
- `GoDig-implement-depth-color-gradient` - Desaturated colors deeper, warm tones surface
- `GoDig-implement-layer-visual-identity` - Each layer: distinct palette, background, ore types
- `GoDig-implement-ore-batching` - Use MultiMesh for repeated ore sprites

### Implementation Dots Created from Session 29
- `GoDig-implement-thumb-zone-hud` - Ensure all HUD elements are in bottom/center thumb zone
- `GoDig-implement-sidegrade-upgrades` - Design late-game upgrades as sidegrades (options) not stat boosts
- `GoDig-implement-juice-calibration` - Medium juice level: progressive cracks, particles, subtle shake
- `GoDig-implement-auto-save-30s` - Auto-save every 30 seconds and on key events
- `GoDig-implement-d1-retention-focus` - No monetization in first 3 runs, generous early rewards

### Implementation Dots Created from Session 28
- `GoDig-implement-haptic-ore-discovery` - Subtle haptic on ore discovery, stronger on upgrade, with disable option
- `GoDig-implement-sidegrade-unlocks` - Consider sidegrades over pure stat increases for late-game variety
- `GoDig-implement-instant-resume` - Support instant exit and resume to exact game state
- `GoDig-implement-progressive-crack` - Progressive crack pattern on blocks before break

### Implementation Dots Created from Session 27
- `GoDig-implement-prestige-indicator` - v1.1 visual indicator when progress stalls suggesting prestige
- `GoDig-implement-fair-death` - Emergency rescue should feel fair with visible warnings
- `GoDig-implement-audio-satisfaction` - Each ore type needs distinct collection sound
- `GoDig-implement-two-layer-caves` - Hidden back areas accessible with special items

### Implementation Dots Created from Session 26
- `GoDig-implement-depth-surprise-caves` - Add discoverable cave surprises at random depths
- `GoDig-implement-welcome-gift` - Welcome-back rewards without guilt/streak pressure
- `GoDig-implement-layer-identity` - Each layer should have unique visual/mechanical identity
- `GoDig-implement-no-iap-ftue` - Hide monetization until player completes first full loop

### Implementation Dots Created from Session 25
- `GoDig-implement-decision-moment-design` - Design for decision moments, not just digging satisfaction
- `GoDig-implement-first-60-seconds` - First block breaks in 5 seconds, first ore in 30 seconds, first sell in 60 seconds
- `GoDig-implement-first-upgrade-dramatic` - First upgrade (Copper Pickaxe) must feel dramatically different, not incremental

## How to Use This Task

This is a **standing research task** - never closes. Each research session should:
1. Check for new games/updates in the space
2. Read recent player feedback on competitors
3. Search game design forums for relevant discussions
4. Document findings in `Docs/research/fun-factor-analysis.md`
5. Create `implement:` dots for actionable improvements

## Note

This research task supports the user directive to "research similar games and online forums around game design endlessly to keep making our design better and better."
