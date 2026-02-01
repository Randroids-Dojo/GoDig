---
title: "implement: Mining sound design system"
status: open
priority: 1
issue-type: task
created-at: "2026-02-01T02:24:16.030441-06:00"
---

## Description
Create distinct, satisfying sounds for mining different block types. Sound is the #1 factor in making mining feel good.

## Context
Research shows Minecraft's sound design is consistently cited as the gold standard for mining satisfaction. Each block type needs unique audio that matches its material properties.

## Affected Files
- `scripts/autoload/sound_manager.gd` - Add mining sound system
- `scripts/player/player.gd` - Trigger sounds on block hits
- `scripts/world/dirt_grid.gd` - Emit block type info when hit
- `assets/audio/` - New sound effect files needed

## Implementation Notes
### Sound Categories
| Block Type | Sound Character | Notes |
|------------|-----------------|-------|
| Dirt/Surface | Soft thud, muffled | Most common, must not annoy |
| Stone | Sharp crack, resonant | Satisfying "chink" |
| Ore (copper/iron) | Metallic ping + crack | Rewarding discovery feel |
| Gems | Chime, sparkle | Exciting, special |
| Hard rock | Deep, heavy impact | Conveys difficulty |

### Technical Requirements
1. Slightly randomize pitch (+-5%) for variety
2. Volume scaled to block hardness
3. Sync precisely with visual hit feedback
4. Layer: hit sound + debris sound

### Collection Sound
When ore enters inventory:
- Short, punchy pickup chime
- Pitch varies slightly per pickup
- Distinct from hit sounds

## Verify
- [ ] Each block type has distinct sound
- [ ] Sounds sync with visual block damage
- [ ] Pitch randomization prevents repetitive feel
- [ ] Pickup sound plays on item collection
- [ ] Sounds are not annoying after 100+ blocks
- [ ] Volume balanced with other game audio
