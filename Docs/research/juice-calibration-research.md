# Game Feel Juice Calibration: Quantitative Research

> Research on optimal juice levels, the N=3018 study, and guidelines for mining game feedback design.
> Last updated: 2026-02-02 (Session 33)

## Executive Summary

A landmark study (N=3018) found that **both None and Extreme juice decrease play time** - Medium and High juice levels are optimal. For a mining game like GoDig, this means: constant mining feedback should be subtle, while discovery moments deserve strong celebration. Reserve impactful effects for special occasions.

---

## 1. The Kao Study: Juiciness in an Action RPG

### Study Overview

**Title**: "The Effects of Juiciness in an Action RPG"
**Author**: Dominic Kao
**Published**: Entertainment Computing, 2020
**Sample Size**: N = 3,018 (largest juiciness study to date)

### Methodology

Four identical versions of an action RPG were tested:
1. **None**: No juice effects
2. **Medium**: Moderate effects
3. **High**: Strong effects
4. **Extreme**: Maximum effects

### Key Findings

| Condition | Play Time | Player Experience | Intrinsic Motivation | Performance |
|-----------|-----------|-------------------|---------------------|-------------|
| **None** | Decreased | Decreased | Decreased | Decreased |
| **Medium** | Optimal | Optimal | Optimal | Optimal |
| **High** | Optimal | Optimal | Optimal | Optimal |
| **Extreme** | Decreased | Decreased | Decreased | Decreased |

> "Both lowest and highest juiciness levels lead to decreased play time and performance."

### Interpretation

- **No Juice**: Game felt "dry and less engaging"
- **Extreme Juice**: Players were "irritated by excessive graphics/sound effects"
- **Medium/High**: Goldilocks zone - satisfying without overwhelming

### Implication for GoDig

Mining is a **constant action**. If every block break has maximum juice, players will experience the "Extreme" condition over time. Reserve strong effects for discoveries.

**Sources**: [ScienceDirect - The Effects of Juiciness](https://www.sciencedirect.com/science/article/pii/S1875952118300879), [ResearchGate - Effects of Juiciness](https://www.researchgate.net/publication/339467686_The_Effects_of_Juiciness_in_an_Action_RPG)

---

## 2. What Is "Juice"?

### Definition

Juice is the abundant positive feedback (visual and audio) that makes games feel polished and satisfying. It includes:

- Particles on impact
- Screen shake
- Sound effects
- Animation squash/stretch
- Color flashes
- Number popups

### The Three Domains of Game Feel

Academic research identifies three domains:

| Domain | Description | Polish Type |
|--------|-------------|-------------|
| **Physicality** | How objects respond to input | Tuning |
| **Amplification** | How feedback emphasizes actions | Juicing |
| **Support** | How the game aids the player | Streamlining |

Juicing specifically addresses **amplification** - making actions feel impactful.

### Juice Element Prevalence

A study of interactive visualizations found:

| Element | Occurrence Rate |
|---------|-----------------|
| Animation | 73.85% |
| Particles | 20.51% |
| Audio feedback | 5.64% |
| Persistence | 4.10% |
| Screen shake | 1.03% |

**Note**: Screen shake is used sparingly even in juicy games.

**Sources**: [GameAnalytics - Squeezing More Juice](https://www.gameanalytics.com/blog/squeezing-more-juice-out-of-your-game-design), [Game Design Skills - Game Feel Guide](https://gamedesignskills.com/game-design/game-feel/)

---

## 3. Screen Shake Guidelines

### When to Use Screen Shake

> "Map the intensity of shakes on a scale, where events of great significance will have stronger intensity."

**Appropriate uses**:
- Player taking significant damage
- Large explosions
- Boss attacks
- Rare ore discovery

**Inappropriate uses**:
- Every block break
- Routine actions
- Background events

### Screen Shake Dangers

> "If used incorrectly can make players feel nauseous. Worse yet it can be perceived as annoying and turn off players entirely, so is best used sparingly."

**Risks**:
- Motion sickness
- Visual information obscured
- Fatigue over time
- Player annoyance

### Best Practices

1. **Diminishing strength**: Start strong, fade quickly
2. **Customization**: Allow players to disable
3. **Establish language**: Same shake type = same event type
4. **Reserve for impact**: Use for significant moments only

### Mobile-Specific Notes

> "Zooming screen shake is likely more common in mobile games and abstract games."

Mobile considerations:
- Smaller screens = shake more noticeable
- Touch controls = harder to aim during shake
- Battery impact from constant screen updates

**Sources**: [Feel Documentation - Screen Shakes](https://feel-docs.moremountains.com/screen-shakes.html), [DaveTech - Analysis of Screenshake Types](http://www.davetech.co.uk/gamedevscreenshake)

---

## 4. Particle Effects Optimization

### Mobile Constraints

> "Large particle effects with high density can cause overdraw that negatively impacts performance."

**Target limits for mobile**:
- 200-500 total active particles maximum
- Fewer particles per effect = less GPU strain
- Pooling particles = less memory allocation

### Performance vs Visual Quality

| Strategy | Effect |
|----------|--------|
| Reduce particle count | Direct performance gain |
| Simplify shaders | Less GPU computation |
| Texture compression | Smaller memory footprint |
| Particle pooling | Reduced garbage collection |
| Batched rendering | Fewer draw calls |

### Quality Guidelines

> "50 well-designed game particle effects often look better than 200 poorly designed ones."

Focus on:
- Intentional particle trajectories
- Meaningful color choices
- Appropriate lifetime
- Clear silhouettes

### Battery Considerations

> "Intensive rendering can lead to increased power consumption and heat generation."

Mining games involve constant particle emission. Strategies:
- Limit particles per block break
- Use simple alpha-fade instead of physics
- Pool and reuse particle systems
- Reduce emission rate on repeated actions

**Sources**: [Unity Learn - Optimizing Particle Effects](https://learn.unity.com/tutorial/optimizing-particle-effects-for-mobile-applications), [Wayline - Particle Effect Apocalypse](https://www.wayline.io/blog/particle-effect-apocalypse-avoiding-visual-excess)

---

## 5. Mining Game Specific Guidelines

### The Mining Feedback Problem

Mining involves constant, repetitive block breaking. This creates a unique challenge:
- Too much juice = fatigue and irritation
- Too little juice = boring and unsatisfying

### Minecraft's Lesson

Even in Minecraft, some players create mods to **remove** block break particles:

> "The 'No Block Break Particles' resource pack aims to reduce visual overstimulation when mining blocks."

> "When breaking large amounts of blocks with haste tools, players can experience significant stuttering and frame drops."

This shows that even beloved games can have too much juice for certain activities.

### Two-Tier Feedback System

**Tier 1: Routine Mining (Subtle)**
- Minimal particles (3-5 per block)
- No screen shake
- Soft audio
- Quick fade

**Tier 2: Discovery Moments (Strong)**
- Burst of particles (15-25)
- Brief screen shake
- Impactful audio
- Lingering glow

### Action-Specific Recommendations

| Action | Particle Count | Screen Shake | Audio | Duration |
|--------|----------------|--------------|-------|----------|
| Dirt break | 3-5 | None | Soft | 0.1s |
| Stone break | 5-8 | None | Medium | 0.15s |
| Hard block break | 8-12 | Micro | Strong | 0.2s |
| Ore discovery | 15-25 | Brief | Impactful | 0.5s |
| Rare ore discovery | 25-40 | Medium | Celebration | 1.0s |
| Jackpot (gems) | 40-60 | Strong | Fanfare | 2.0s |

**Sources**: [BraveZebra - Visual Feedback in Game Design](https://www.bravezebra.com/blog/visual-feedback-game-design/)

---

## 6. The Goldilocks Principle

### Research Support

The Kao study confirms what designers call the "Goldilocks Effect":

| Too Little | Just Right | Too Much |
|------------|------------|----------|
| Dry, boring | Satisfying, engaging | Irritating, overwhelming |
| Players lose interest | Players feel empowered | Players become fatigued |
| Game feels cheap | Game feels polished | Game feels chaotic |

### Finding the Balance

> "Feedback was appreciated not just when 'juicy' but also when calmer or reduced. The key is coherence within the game."

**Questions to ask**:
1. Is this action routine or special?
2. How often will players see this effect?
3. Does the effect communicate meaningful information?
4. Could this become annoying after 100 repetitions?

### The Mining Test

For GoDig, apply this test:
- Play for 5 minutes of continuous mining
- If effects feel overwhelming → reduce routine juice
- If effects feel boring → increase discovery juice
- If can't distinguish discoveries → reduce routine, increase discovery

---

## 7. GoDig Implementation Recommendations

### Juice Tiers

**Tier 0: Ambient (Background)**
- Dust particles in air
- Subtle lighting changes
- Minimal audio hum

**Tier 1: Routine (Low Juice)**
- Standard block breaking
- Walking/climbing
- Menu interactions

**Tier 2: Progress (Medium Juice)**
- Ore collection
- Depth milestones
- Inventory changes

**Tier 3: Discovery (High Juice)**
- Rare ore discovery
- Achievement unlock
- First upgrade purchase

**Tier 4: Celebration (Maximum Juice)**
- Jackpot gem find
- Depth record broken
- Safe surface return with full inventory

### Specific Effect Guidelines

**Block Break (Dirt)**
```
Particles: 3-5 small brown specs
Direction: Random within 45° cone upward
Lifetime: 0.1-0.2 seconds
Audio: Soft "thud"
Screen shake: None
```

**Block Break (Stone)**
```
Particles: 5-8 gray chips
Direction: Random within 60° cone upward
Lifetime: 0.15-0.25 seconds
Audio: Medium "crack"
Screen shake: None
```

**Ore Discovery**
```
Particles: 15-25 colored sparkles
Direction: Radial burst from ore position
Lifetime: 0.3-0.5 seconds
Audio: Satisfying "ching" + ore-specific tone
Screen shake: 2-3 pixel displacement, 0.1s
```

**Rare Ore Discovery**
```
Particles: 25-40 bright sparkles + glow ring
Direction: Radial burst + upward drift
Lifetime: 0.5-1.0 seconds
Audio: Celebration fanfare + unique ore tone
Screen shake: 4-5 pixel displacement, 0.15s
Haptic: Strong pulse (if enabled)
```

### Settings Menu

Always provide:
- [ ] Screen shake toggle (on/off)
- [ ] Screen shake intensity slider
- [ ] Particle density option (Low/Medium/High)
- [ ] Haptic feedback toggle

---

## 8. Implementation Checklist

### Before Launch

- [ ] All routine actions have subtle feedback
- [ ] All discoveries have distinct feedback
- [ ] Screen shake is reserved for significant moments
- [ ] Particle counts optimized for mobile
- [ ] Settings allow disabling effects
- [ ] 5-minute mining session doesn't cause fatigue

### Testing Protocol

1. **Routine test**: Mine 100 dirt blocks - should not feel overwhelming
2. **Discovery test**: Find 5 ores - each should feel rewarding
3. **Contrast test**: Discovery should feel 3-5x more impactful than routine
4. **Fatigue test**: Play for 15 minutes - effects should not annoy
5. **Performance test**: Heavy mining should maintain 60fps on target devices

### Red Flags

- Players complain about effects
- Players disable all effects
- Players can't distinguish routine from discovery
- Performance drops during heavy mining
- Effects trigger motion sickness

---

## Sources

### Academic Research
- [ScienceDirect - The Effects of Juiciness in an Action RPG (Kao, 2020)](https://www.sciencedirect.com/science/article/pii/S1875952118300879)
- [ResearchGate - Understanding the Effects of Gamification and Juiciness](https://www.researchgate.net/publication/336100291_Understanding_the_Effects_of_Gamification_and_Juiciness_on_Players)
- [ACM - How does Juicy Game Feedback Motivate?](https://dl.acm.org/doi/10.1145/3613904.3642656)
- [ACM - Juicy Game Design](https://dl.acm.org/doi/10.1145/3311350.3347171)

### Game Design
- [GameAnalytics - Squeezing More Juice](https://www.gameanalytics.com/blog/squeezing-more-juice-out-of-your-game-design)
- [Blood Moon Interactive - Juice in Game Design](https://www.bloodmooninteractive.com/articles/juice.html)
- [Game Design Skills - Game Feel: A Beginner's Guide](https://gamedesignskills.com/game-design/game-feel/)
- [BraveZebra - Visual Feedback in Game Design](https://www.bravezebra.com/blog/visual-feedback-game-design/)

### Technical Implementation
- [Feel Documentation - Screen Shakes](https://feel-docs.moremountains.com/screen-shakes.html)
- [DaveTech - Analysis of Screenshake Types](http://www.davetech.co.uk/gamedevscreenshake)
- [Unity Learn - Optimizing Particle Effects for Mobile](https://learn.unity.com/tutorial/optimizing-particle-effects-for-mobile-applications)
- [Wayline - The Particle Effect Apocalypse](https://www.wayline.io/blog/particle-effect-apocalypse-avoiding-visual-excess)
- [GameDeveloper - Simple High-Performance Particles for Mobile](https://www.gamedeveloper.com/production/tutorial-simple-high-performance-particles-for-mobile)

---

## Key Takeaways for GoDig

1. **N=3018 study proves**: Medium/High juice optimal, None and Extreme both harm engagement
2. **Mining is constant**: Reserve impactful effects for discoveries, not routine
3. **Screen shake sparingly**: Only for significant moments, always allow disabling
4. **200-500 particles max**: Mobile performance constraint
5. **Two-tier system**: Subtle routine, strong discovery
6. **Test for fatigue**: 15 minutes of mining shouldn't annoy
7. **Provide options**: Let players customize effect intensity
8. **Battery matters**: Intense effects drain mobile batteries
9. **Establish language**: Consistent feedback patterns aid player learning
10. **50 > 200**: Fewer, well-designed particles beat many sloppy ones
