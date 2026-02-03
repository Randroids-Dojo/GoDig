---
title: "implement: SoundManager integration tests"
status: active
priority: 2
issue-type: task
created-at: "\"2026-02-03T08:45:00.059775-06:00\""
---

## Description\nWrite integration tests for SoundManager autoload singleton.\n\n## Tests to Add\n1. SoundManager exists as autoload\n2. Has expected signals (music_changed, sound_played, tension_level_changed)\n3. Has expected methods for playback\n4. Music control methods work\n5. Tension audio system exists and responds\n6. Get/set functions work correctly\n7. Pool size constants are accessible\n\n## Affected Files\n- tests/test_sound.py (new)\n- tests/helpers.py (add SoundManager path)\n\n## Verify\n- [ ] Tests pass locally\n- [ ] SoundManager loads in headless mode
