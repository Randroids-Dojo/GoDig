---
title: "implement: Instant restart UX after surface return"
status: open
priority: 2
issue-type: task
created-at: "2026-02-01T01:58:36.668268-06:00"
---

## Description
When player returns to surface (via death, forfeit cargo, or normal return), ensure minimal friction before next dive. Research shows instant restart is key to 'one more run' psychology.

## Context
From Session 5 research:
- Roguelikes succeed because "you can near-instantly restart after failure"
- "Menus getting in the way can antagonize an already frustrated player"
- Quick restart contributes to "one more game" mentality
- The moment between runs should be 3-5 seconds maximum

## Current State
After death/forfeit, player respawns at surface. But:
- No visual cue that they're "ready to go again"
- No quick action to dive immediately
- May need to manually walk to mine entrance

## Implementation

### Death/Forfeit Respawn Flow
1. Quick fade to black (0.3s)
2. Respawn at surface spawn point (no loading screen)
3. Brief respawn animation (particles, player appears)
4. Show context-appropriate message:
   - Death: "Respawned. Cargo lost." (0.5s toast)
   - Forfeit: "Escaped! Cargo forfeit." (0.5s toast)
5. If player has 3+ ladders: Show "DIVE AGAIN" prompt
6. Total time from death to moveable: under 2 seconds

### "Ready State" After Any Return
When player is on surface with adequate supplies:
1. Show subtle "Ready to Dive" indicator near mine entrance
2. Mine entrance has gentle pulse/glow effect
3. Walking to entrance auto-starts descent (no extra button)
4. Alternative: Tap mine entrance from anywhere on surface

### Visual Feedback
```
After death:
[Quick black fade] -> [Player appears with dust puff] -> [Toast: "Respawned"]
                                                          |
                                               [1s] "DIVE AGAIN?" prompt

After selling:
[Coin animation] -> [Balance updates] -> "DIVE AGAIN?" button visible
```

### Performance Requirements
- No loading screens between death and respawn
- Chunks should be preloaded around surface
- Respawn position is always valid (surface spawn point)

## Affected Files
- `scripts/player/player.gd` - Death handling, respawn trigger
- `scripts/autoload/game_manager.gd` - Respawn state management
- `scripts/ui/hud.gd` - Dive again prompt, respawn toast
- `scenes/main.tscn` - Mine entrance interaction area

## Related Specs
- `GoDig-add-forfeit-cargo-e9e163d7` - Forfeit mechanic
- `GoDig-implement-quick-dive-0cb05828` - Quick dive after selling
- `GoDig-implement-death-and-fd4aaba6` - Death system

## Verify
- [ ] Death to moveable player: under 2 seconds
- [ ] Forfeit to moveable player: under 2 seconds
- [ ] No loading screen during respawn
- [ ] Toast message visible but non-blocking
- [ ] "Dive Again" prompt appears if 3+ ladders
- [ ] Mine entrance walkable/tappable to start dive
- [ ] Works on web build (no native dependencies)
