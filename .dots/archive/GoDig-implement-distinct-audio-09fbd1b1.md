---
title: "implement: Distinct audio/visual feel per pickaxe tier"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-02-01T08:31:10.919166-06:00\""
closed-at: "2026-02-02T01:13:58.373179-06:00"
close-reason: Implemented in GoDig-implement-pickaxe-tier - all pickaxes now have distinct sound_pitch, sound_character, particle_color, particle_scale, creates_sparks settings
---

## Description

Each pickaxe tier should have DISTINCT audio/visual feedback, not just faster mining. The upgrade moment is wasted if the player can't FEEL the difference immediately.

## Context (Session 13 Research)

From SteamWorld Dig analysis:
- "When you get that newest upgrade so you can dig through each block with only one hit, it's immensely satisfying"
- Sound design: "tinkling noise becomes clearer with higher tempo with every subsequent hit"
- Criticism: upgrades are "boringly straightforward" (just stat increases)

From power progression psychology research:
- "Each time user achieves something exciting, brain releases dopamine"
- First upgrade must be FELT immediately (40% session length increase when upgrade feels impactful)

## Current State

Check `resources/tools/*.tres` for existing pickaxe definitions.
Check `scripts/player/` for dig feedback implementation.

## Design

### Audio Differentiation (per tier)

| Tier | Tool | Sound Character |
|------|------|-----------------|
| 1 | Rusty Pickaxe | Dull thud, slow rhythm |
| 2 | Copper Pickaxe | Clearer ring, medium rhythm |
| 3 | Iron Pickaxe | Sharp clang, faster rhythm |
| 4 | Steel Pickaxe | Heavy impact, powerful thud |
| 5+ | Premium tiers | Magical/crystalline overlay |

### Visual Differentiation

| Tier | Effect |
|------|--------|
| 1-2 | Basic particle dust |
| 3-4 | More particles, slight screen shake |
| 5+ | Colored particles matching tool material, light flash |

### Implementation

1. Add `dig_sound` and `dig_particles` to ToolData resource:
   ```gdscript
   @export var dig_sound: AudioStream
   @export var dig_particle_color: Color = Color.WHITE
   @export var dig_screen_shake: float = 0.0
   ```

2. In player dig code, reference equipped tool's feedback settings

3. Create distinct audio files (or programmatic pitch/tempo variations)

## Affected Files

- `resources/tools/*.tres` - Add sound/particle references
- `scripts/player/player.gd` - Read tool feedback settings on dig
- `scenes/player/dig_particles.tscn` - Parameterize color
- `assets/audio/` - Add tier-specific dig sounds (or single sound with pitch variation)

## Verify

- [ ] Rusty Pickaxe sounds dull/slow
- [ ] Copper Pickaxe noticeably different (clearer, faster)
- [ ] Iron Pickaxe feels powerful
- [ ] After upgrading, player IMMEDIATELY notices the difference
- [ ] No noticeable audio lag between hit and sound
- [ ] Works on mobile (audio latency acceptable)

## Related Research

Session 13: SteamWorld Dig pickaxe satisfaction analysis
Session 11: Vampire Survivors - minimal input, maximum feedback
