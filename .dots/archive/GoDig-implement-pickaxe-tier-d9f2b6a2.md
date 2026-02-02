---
title: "implement: Pickaxe tier feel differentiation"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-01T09:36:44.123374-06:00\\\"\""
closed-at: "2026-02-02T01:13:50.257245-06:00"
close-reason: "Implemented pickaxe tier differentiation: sound_pitch, sound_character, particle_color, particle_scale, creates_sparks, glow_intensity for all 9 pickaxes"
---

## Description

Each pickaxe tier should be dramatically different in look, sound, and feel - not just faster stats.

## Context

SteamWorld Dig research: 'When you get that newest upgrade so you can dig through each block with only one hit, it's immensely satisfying to just blast through the mines at seemingly super-sonic speed.' The upgrade should create a 'night and day' difference.

## Implementation

### Wooden Pickaxe (Starter)
- Brown/wood visual
- Dull 'thunk' sound
- 3-4 hits per block
- Small dust particles

### Copper Pickaxe (Tier 2)
- Orange/copper metallic gleam
- Sharper 'tink' sound
- 2-3 hits per block
- Metallic spark particles

### Iron Pickaxe (Tier 3)
- Gray/silver with shine
- Crisp 'clang' sound
- 2 hits per block
- Brighter spark particles

### Gold Pickaxe (Tier 4)
- Golden glow effect
- Rich 'ring' sound (almost musical)
- 1-2 hits per block
- Golden particle trails

### Diamond Pickaxe (Tier 5)
- Blue crystalline shimmer
- Crystal 'chime' sound
- 1 hit per block for most
- Prismatic light effects

## Affected Files
- scripts/player/player.gd - Pickaxe tier handling
- resources/items/pickaxes/*.tres - Pickaxe data with sound/particle refs
- scenes/effects/pickaxe_effects.tscn - Tier-specific effects
- resources/audio/sfx/pickaxe/ - Tier-specific sounds

## Verify
- [ ] Each tier is immediately recognizable by sound alone
- [ ] Each tier has distinct visual feedback
- [ ] Upgrade from Tier N to N+1 creates 'wow' moment
- [ ] Player can tell which pickaxe they have without looking at HUD
