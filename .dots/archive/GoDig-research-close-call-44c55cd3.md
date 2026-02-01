---
title: "research: Close-call moments - how mining games create near-death excitement"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T02:08:49.135780-06:00\\\"\""
closed-at: "2026-02-01T02:20:05.035731-06:00"
close-reason: Completed research on close-call moments. Documented detection criteria, celebration techniques from Vlambeer GDC talk, and what NOT to do. References existing implementation spec.
---

Research how games create thrilling 'close call' moments where player barely escapes. From research: 'Near-misses may be MORE motivating than winning or losing.' Investigate: What triggers recognition of a close call? How do games celebrate narrow escapes? Document patterns for: low HP escape, last ladder used, just-made-it-back scenarios.

## Research Findings

### Why Close-Calls Are More Powerful Than Wins

From [Psychology of Games](https://www.psychologyofgames.com/2016/09/the-near-miss-effect-and-game-rewards/):
> "A 2009 paper in the journal Neuron showed that near misses activated the same reward systems in the brain as actual gambling wins."

Key insight: The brain interprets "almost" as progress, not failure. Close-calls feel like SKILL demonstrations.

### SteamWorld Dig's Design Sweet Spot

From the archived research:
> "Testers fell down a hole, sweated a bit, then found a clever way of getting back up again, feeling awesome."

This is the ideal player experience:
1. **Danger** - "Oh no, I'm stuck/low on resources"
2. **Problem solving** - "Wait, if I wall-jump here and use my last ladder..."
3. **Escape** - "YES! I made it!"
4. **Pride** - "I'm good at this game"

### Types of Close-Calls to Detect in GoDig

| Scenario | Detection Criteria | Emotional Weight |
|----------|-------------------|------------------|
| **Last ladder escape** | Used final ladder while >20m deep | HIGH |
| **Low HP survival** | Returned with <30% HP | MEDIUM |
| **Full haul** | Returned with inventory 90%+ full | MEDIUM |
| **Depth record** | New personal depth + successful return | HIGH |
| **Close call combo** | Multiple factors combined | VERY HIGH |

### How to Celebrate Close-Calls: The "Juice" Approach

From [Jan Willem Nijman's GDC Talk](https://theengineeringofconsciousexperience.com/jan-willem-nijman-vlambeer-the-art-of-screenshake/):
> "Just fill your game with love and tiny details."

**Celebration Techniques**:
1. **Screen shake** - Brief, satisfying shake on successful escape
2. **Particle burst** - Confetti or sparkle effect
3. **Sound design** - Triumphant sound cue (not annoying)
4. **Text feedback** - "Close call!" or "Clutch escape!"
5. **Slowdown** - Brief 100ms pause to let moment sink in
6. **Camera zoom** - Quick zoom-in on player

### The 1 HP Meme: Why Players LOVE This Feeling

The "survived with 1 HP" meme exists because these moments are memorable. Players:
- Share stories with friends
- Remember the specific run
- Feel personally skilled (not lucky)
- Want to recreate the feeling

**Design Implication**: Don't prevent close-calls - CELEBRATE them!

### Hades' Approach: Make "Failure" Rewarding

From [Gamedeveloper](https://www.gamedeveloper.com/design/how-supergiant-weaves-narrative-rewards-into-i-hades-i-cycle-of-perpetual-death):
> "Take the pain out of dying and having to restart... make sure the moment of death isn't about rage-quitting."

Even when player FAILS (dies), Hades celebrates:
- New dialogue unlocks
- Story progression
- Character relationships deepen
- "I wonder what happens next" feeling

**GoDig Application**:
- Death should reveal something (ore location? layer preview?)
- Close-call that succeeds should feel AMAZING
- Close-call that fails should still feel like "good try"

### Implementation: Close-Call Detection System

**Criteria for triggering celebration**:

```
is_close_call = (
    (ladders_remaining <= 1 AND depth >= 20) OR
    (hp_percent <= 0.30) OR
    (inventory_fill >= 0.90 AND depth >= 30) OR
    (is_new_depth_record AND successful_return)
)

celebration_intensity = count_matching_criteria()
# 1 criteria = "Nice!" (small celebration)
# 2 criteria = "Close call!" (medium)
# 3+ criteria = "INCREDIBLE!" (big celebration)
```

### Visual/Audio Feedback Escalation

| Intensity | Visual | Audio | Text |
|-----------|--------|-------|------|
| Small | Subtle glow | Chime | "Nice work!" |
| Medium | Particle burst | Triumphant chord | "Close call!" |
| Large | Screen shake + particles + brief slowdown | Victory fanfare | "INCREDIBLE ESCAPE!" |

### The "Replay" Moment

Players remember and share close-calls. Consider:
- Stats tracking: "Closest calls: 5"
- Achievement: "Escape with 1 ladder remaining"
- Session summary: "This run: 2 close calls, deepest: 85m"

### What NOT To Do

1. **Don't punish close-calls**: If player escaped, they succeeded
2. **Don't make celebration annoying**: Brief, punchy, not long
3. **Don't block gameplay**: Celebration happens, player keeps control
4. **Don't make it random**: Player should know WHY they got celebration

## Implementation Specs Created

See existing dot: GoDig-implement-close-call-034e09a9

## Sources
- [Psychology of Games - Near Miss Effect](https://www.psychologyofgames.com/2016/09/the-near-miss-effect-and-game-rewards/)
- [Jan Willem Nijman - Art of Screenshake](https://theengineeringofconsciousexperience.com/jan-willem-nijman-vlambeer-the-art-of-screenshake/)
- [Gamedeveloper - Hades Death Design](https://www.gamedeveloper.com/design/how-supergiant-weaves-narrative-rewards-into-i-hades-i-cycle-of-perpetual-death)
- [Medium - Hades Death Analysis](https://joshli1997.medium.com/why-the-roguelike-formula-works-so-well-with-hades-and-why-death-feels-so-fun-52bba1736221)
- [LarkSuite - Clutch Play Definition](https://www.larksuite.com/en_us/topics/gaming-glossary/clutch-play)
