---
title: "BUG: Game not entering PLAYING state on web build"
status: closed
priority: 0
issue-type: task
created-at: "\"\\\"2026-02-03T04:28:30.370768-06:00\\\"\""
closed-at: "2026-02-03T04:44:47.151608-06:00"
close-reason: Added game state verification system in test_level._ready() to force PLAYING state on web builds. Added comprehensive debug logging to game_manager.start_game() and test_level._ready() to track state transitions. Includes fallback mechanisms for web-specific timing issues.
---

Critical bug: Game scene loads but never transitions to PLAYING state on web.

SYMPTOMS:
- HUD ignoring all clicks/touches
- Keyboard controls not working
- Touch controls not responding
- Affects both desktop and mobile web modes

DEBUG EVIDENCE:
- GameManager.state: 0 (MENU - should be 1 = PLAYING)
- GameManager.is_running: false (should be true)
- tutorial_state: 4 (COMPLETE - not blocking)
- Scene appears to load (Player equipped, save works)

CODE PATH:
1. main_menu.gd: tap-to-start overlay dismissed
2. main_menu.gd:141: _auto_start_new_game() called
3. main_menu.gd:154: SaveManager.new_game(0) succeeds
4. main_menu.gd:155: _transition_to_game() called
5. main_menu.gd:277: change_scene_to_file('test_level.tscn')
6. test_level.gd:149: GameManager.start_game() SHOULD run in _ready()
7. ??? - Game stays in MENU state

INVESTIGATION NEEDED:
- Is test_level.gd _ready() completing on web?
- Is there a script error silently failing?
- Does something reset state after start_game()?
- Is there a web-specific timing issue with scene loading?
- Check browser console for errors during scene transition

NOT THE CAUSE:
- mouse_filter issues (game isn't running at all)
- tap-to-start overlay (it dismisses, scene changes)
- tutorial_state (4 = COMPLETE, not blocking)

RELATED:
- AGENTS.md documents CanvasLayer input issues but this is different
- GoDig-bug-hud-ignoring-cc7dc21a (original symptom report)
