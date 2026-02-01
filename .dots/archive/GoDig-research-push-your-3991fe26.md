---
title: "research: Push-your-luck threshold tuning - when should players feel pressure to return"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T02:08:55.667117-06:00\\\"\""
closed-at: "2026-02-01T02:17:43.932103-06:00"
close-reason: "Completed comprehensive research on push-your-luck thresholds. Created 3 implementation specs: inventory tension visuals, depth-aware ladder warning, subtle tension audio."
---

Research the optimal tension curve for mining games. Key questions from board game design: 'If what you have to lose is greater than what you have to gain, it might be a good time to stop.' Document: At what inventory fill % should pressure begin? How does depth factor in? What verbal/visual cues communicate 'you should consider returning'? Reference: Zombie Dice 3-strikes, Quacks of Quedlinburg white chips, Incan Gold card counting.

## Research Findings

### The Core Formula: Risk vs Reward Equilibrium

From [Board Game Design Course](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/):
> "If what you have to lose is greater than what you have to gain, it might be a good time to stop."

This is the golden rule. The moment a player's carried value exceeds what they might find ahead, tension peaks.

### When Pressure Should Begin: The 50-60% Threshold

Based on analysis of successful push-your-luck games:

| Inventory Fill | Tension Level | Player Psychology |
|----------------|--------------|-------------------|
| 0-30% | None | "I just started, plenty of room" |
| 30-50% | Awareness | "Making good progress" |
| **50-60%** | **Pressure begins** | "Do I have enough to make it worthwhile?" |
| 60-75% | Active tension | "Should I start heading back?" |
| 75-90% | High tension | "One more ore and I turn around" |
| 90-100% | Crisis mode | "Must get back NOW" |

**Key Insight**: Pressure should START at 50-60%, not at near-full. This gives players a "tension runway" where the pressure builds.

### Dome Keeper's Carrying Capacity Model

From [Josh Anthony's Design Dive](https://joshanthony.info/2023/05/24/design-dive-dome-keeper/):
- Materials slow movement when carrying capacity is high
- This creates **natural pressure escalation** - heavier = slower = more danger
- "Come back too early, and you've wasted precious time... come back too late, and you're going to take some hits"

**GoDig Application**: Consider subtle speed penalty when inventory >75% full? Or just visual/audio cues.

### The Depth Factor

Depth creates **compounding risk**:

1. **Distance penalty**: Deeper = longer return trip = more ladders needed
2. **Sunken cost fallacy**: "I came all this way, might as well fill up"
3. **Discovery temptation**: Rarer ores at depth = harder to walk away

**Recommended Depth Thresholds for GoDig**:
| Depth | Warning Type | Message |
|-------|-------------|---------|
| 25m+ with <3 ladders | Yellow | "Getting deep. Check your ladders." |
| 50m+ with <5 ladders | Orange | "Long way back. Consider returning." |
| 100m+ with <10 ladders | Red | "Very deep! Make sure you can get home." |

### Visual/Audio Cues That Work

From [Retromine](https://puzzle-game.io/game/retromine):
- Countdown warnings before collapse
- Visual instability (screen shake, particles)
- Audio tension builds (heartbeat, rumbling)

**Recommended Cues for GoDig**:

1. **Inventory Visual**: HUD bar changes color at thresholds
   - Green (0-50%)
   - Yellow (50-75%)
   - Orange (75-90%)
   - Red (90-100%)

2. **Ladder Warning System**:
   - Subtle pulse on ladder count when entering "risky" depth
   - More urgent pulse when critically low vs depth

3. **Depth Indicator Enhancement**:
   - Show depth in different colors based on risk
   - Display "estimated ladders needed" when deep

4. **Audio Cues**:
   - Subtle heartbeat when >75% inventory AND >50m deep
   - Warning chime when ladder count drops below "safe" threshold for depth

### Near-Miss Psychology

From [Psychology of Games](https://www.psychologyofgames.com/2016/09/the-near-miss-effect-and-game-rewards/):
> "Near misses may be MORE motivating than winning or losing"

The brain treats "almost made it" as progress, not failure. This is why:
- Returning with 1 ladder left feels AMAZING
- Almost dying but escaping creates memorable stories
- "I almost got stuck but clever wall-jumps saved me"

**Design Implication**: Don't just avoid frustration - engineer near-misses! The tension curve should OFTEN bring players close to the edge.

### Incan Gold's "Second Hazard" Model

In Incan Gold, players track which hazard cards have appeared. A second identical hazard = wipe.

This creates:
- **Countable risk**: Players can calculate odds
- **Shared tension**: Everyone watching the same cards
- **Gut-check moments**: "Do I feel lucky?"

**GoDig Adaptation**: Ladders serve as "countable" resource. But unlike cards, players control ladder use. The tension is in planning, not luck.

### The "Sunk Cost" Sweet Spot

Players feel strongest pull to continue when:
- They've invested significant time (15+ minutes)
- They're close to a valuable find
- They've already placed several ladders

**Counter-Design**: Make return trips feel valuable:
- Celebrate successful returns
- Show "total haul" value prominently
- Tease next upgrade progress

### Recommended Pressure Points for GoDig

Based on all research:

**Primary Triggers** (should activate warnings):
1. **Inventory 60%+ AND depth 30m+**: Start subtle tension cues
2. **Inventory 80%+ at any depth**: Active "consider returning" state
3. **Ladders < depth/10**: Warning about risky ladder count
4. **Last ladder placed**: Celebratory/tense "committed" notification

**Visual Escalation**:
- 60% inventory: Backpack icon pulses once
- 75% inventory: Bar turns yellow, single audio cue
- 90% inventory: Bar turns orange, inventory "strains" visually
- Full inventory: Red bar, "FULL" text appears

**Depth-Based Overlay**:
- Show faint "return distance" indicator when >50m deep
- Increase intensity as depth increases
- Never block gameplay, just ambient awareness

## Implementation Specs Created

Based on this research, the following implementation dots should be created:

### 1. implement: Inventory tension visual system
Graduated visual feedback as inventory fills (color changes, pulses, strain effects)

### 2. implement: Depth-aware ladder warning
Calculate safe ladder count based on current depth, warn when below threshold

### 3. implement: Return distance indicator
Subtle HUD element showing estimated effort to return when deep

### 4. implement: Tension audio layer
Ambient audio that shifts based on combined risk factors (depth + inventory + ladders)

## Sources
- [Board Game Design Course - Push Your Luck](https://boardgamedesigncourse.com/game-mechanics-sometimes-you-want-to-push-your-luck/)
- [Josh Anthony - Dome Keeper Design Dive](https://joshanthony.info/2023/05/24/design-dive-dome-keeper/)
- [Psychology of Games - Near Miss Effect](https://www.psychologyofgames.com/2016/09/the-near-miss-effect-and-game-rewards/)
- [BoardGameGeek - Incan Gold](https://boardgamegeek.com/boardgame/15512/diamant)
- [Gamedeveloper - SteamWorld Dig Deep Dive](https://www.gamedeveloper.com/design/game-design-deep-dive-the-digging-mechanic-in-i-steamworld-dig-i-)
- [Retromine - Push Your Luck Mining](https://puzzle-game.io/game/retromine)
