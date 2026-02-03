---
title: edit
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"\\\\\\\"\\\\\\\\\\\\\\\"2026-02-03T04:27:28.825260-06:00\\\\\\\\\\\\\\\"\\\\\\\"\\\"\""
closed-at: "2026-02-03T05:00:35.540440-06:00"
close-reason: "Fixed: Added null checks for get_tree() in set_state() and start_game() to handle web build initialization timing"
---

Critical bug: Game not entering PLAYING state on web build.

ROOT CAUSE IDENTIFIED:
- Debug shows: GameManager.state=0 (MENU), is_running=false
- test_level.gd:149 calls GameManager.start_game() in _ready()
- But game never transitions to PLAYING state

This is NOT a mouse_filter issue - the game itself isn't starting!

Investigation:
1. Check if test_level.gd _ready() completes without error
2. Check if something resets state after start_game()
3. Check scene load completion on web
4. Check if any overlay is calling end_game() or set_state(MENU)

Web-specific: The scene may be loading but scripts failing silently.
