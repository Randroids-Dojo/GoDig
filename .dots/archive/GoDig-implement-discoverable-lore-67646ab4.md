---
title: "implement: Discoverable lore elements (journals, artifacts)"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-01T08:45:43.950669-06:00\\\"\""
closed-at: "2026-02-03T03:28:17.266629-06:00"
close-reason: Implemented discoverable lore system with 10 journal entries, LoreData resource class, JournalManager autoload, LorePickup world interaction, JournalScreen UI, DataRegistry and SaveManager integration, and lore achievements
---

## Description

Add discoverable lore elements throughout the underground that create emergent storytelling and break routine gameplay.

## Context

From Session 15 research:
- Mr Mine: 'These moments break the routine and add depth to your mining journey'
- Keep on Mining: 'Hidden journals, audio logs, and artifacts tell tales of the underground'
- Discovery = 'going out into the game to find things you didn't know were there'

Players remember and share discovery moments. Lore creates emotional investment beyond progression.

## Implementation

### Discoverable Items
1. **Old Mining Journals** - Text snippets about previous miners
   - Spawn rarely in stone/deep layers
   - 10-15 unique entries describing underground lore
   - Each journal entry is numbered ('Journal Entry #7')
   - Collected journals viewable in Museum

2. **Strange Artifacts** - Mysterious objects with unknown purpose
   - Very rare spawns in crystal/magma layers
   - 5-6 unique artifacts
   - Some have gameplay effects (reveal nearby ore, luck bonus)
   - Museum displays unlocked artifacts

3. **Abandoned Equipment** - Signs of previous miners
   - Old pickaxes, broken lanterns, empty crates
   - Visual-only, creates atmosphere
   - Spawn near cave entrances

### Technical Implementation
- Add LoreData resource type with text, rarity, depth_range
- DataRegistry.get_random_lore(depth) returns weighted selection
- Spawn during chunk generation (0.1% chance per chunk in valid depth)
- LorePickup scene similar to OrePickup
- JournalScreen UI to read collected entries

## Affected Files
- resources/lore/journal_*.tres (new - lore entries)
- scripts/resources/lore_data.gd (new)
- scripts/autoload/data_registry.gd (add lore registry)
- scripts/world/chunk.gd (spawn lore items)
- scripts/ui/journal_screen.gd (new)
- scenes/ui/journal_screen.tscn (new)

## Verify
- [ ] Journals spawn rarely in appropriate depth ranges
- [ ] Collected journals persist in save
- [ ] Journal screen displays collected entries
- [ ] Finding journal triggers celebration feedback
- [ ] Museum shows journal collection progress
