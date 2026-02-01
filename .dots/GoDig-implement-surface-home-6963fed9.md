---
title: "implement: Surface 'home base' comfort signals"
status: open
priority: 3
issue-type: task
created-at: "2026-02-01T01:09:24.744484-06:00"
---

Make surface feel like a safe, rewarding home base to contrast with underground tension.

## Research Findings
- 'Home Base Comfort' - surface represents safety
- 'Cycle between danger and comfort' creates satisfying rhythm
- Contrast makes surface feel rewarding after dangerous dive
- Shop interactions should feel positive and welcoming

## Implementation
1. Brighter, warmer color palette on surface vs underground
2. Upbeat background music/ambient on surface
3. 'Welcome back!' toast when returning from deep (50m+)
4. Coin counter animates satisfyingly when selling
5. Shop NPCs have brief positive dialogue

## Files
- scripts/autoload/sound_manager.gd (surface music)
- scripts/ui/floating_text.gd (welcome toast)
- scripts/ui/shop.gd (animated coin counter)
- scenes/surface.tscn (visual warmth)

## Verify
- [ ] Surface feels noticeably different from underground
- [ ] Returning after dive feels rewarding
- [ ] Music/ambient transitions smoothly
- [ ] No jarring contrast (smooth not sudden)
