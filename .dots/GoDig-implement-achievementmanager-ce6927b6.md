---
title: "implement: AchievementManager integration tests"
status: active
priority: 2
issue-type: task
created-at: "\"2026-02-03T08:54:32.245594-06:00\""
---

## Description\nWrite integration tests for AchievementManager autoload singleton.\n\n## Tests to Add\n1. AchievementManager exists as autoload\n2. Has expected signals (achievement_unlocked)\n3. Has expected methods (unlock, is_unlocked, get_all_achievements, etc.)\n4. Achievement constants are defined\n5. State tracking methods work\n6. Reset functionality works\n7. Save/load data works\n\n## Affected Files\n- tests/test_achievement.py (new)\n- tests/helpers.py (add AchievementManager path if needed)\n\n## Verify\n- [ ] Tests pass locally\n- [ ] AchievementManager loads in headless mode
