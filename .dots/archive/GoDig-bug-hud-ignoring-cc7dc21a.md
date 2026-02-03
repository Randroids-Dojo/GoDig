---
title: "BUG: HUD ignoring clicks/touches on web build"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-02-03T04:24:16.859794-06:00\\\"\""
closed-at: "2026-02-03T04:32:04.750656-06:00"
close-reason: "Fixed: GameManager.start_game() now calls set_state(PLAYING). Added mouse_filter handling to death_screen.gd for web builds."
---

Critical bug: Touch controls and clicks not working on web build even when mobile mode is enabled.

Debug report shows:
- PlatformDetector.is_mobile: true
- PlatformDetector.touch_controls: true
- GameManager.state: 0
- GameManager.is_running: false
- tutorial_state: 4

Symptoms:
- HUD buttons not responding to clicks
- Touch controls not responding
- Affects both desktop and mobile web modes

Likely causes:
1. Tap-to-start overlay not dismissing properly or blocking input after dismiss
2. CanvasLayer input handling issue (AGENTS.md mentions this for web)
3. Mouse filter set to IGNORE on parent containers
4. Game state preventing input processing (is_running: false)
5. tutorial_state: 4 might be blocking normal input

Check:
- TapToStartOverlay visibility and mouse_filter after tap
- TouchControls and HUD mouse_filter settings
- Whether game properly transitions to running state
- Input event propagation in browser console
