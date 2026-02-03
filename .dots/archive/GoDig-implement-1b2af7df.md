---
title: "implement: HandcraftedCaveManager integration tests"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-03T08:56:29.804429-06:00\\\"\""
closed-at: "2026-02-03T08:57:47.417444-06:00"
close-reason: Implemented comprehensive HandcraftedCaveManager integration tests (50+ tests)
---

## Description\nWrite integration tests for HandcraftedCaveManager autoload singleton.\n\n## Tests to Add\n1. HandcraftedCaveManager exists as autoload\n2. Has expected signals (handcrafted_cave_placed, treasure_room_placed, special_tile_generated)\n3. Has expected methods\n4. Constants are defined correctly\n5. Check/query methods work\n6. Reset functionality works\n7. get_stats returns expected data\n\n## Affected Files\n- tests/test_handcrafted_cave.py (new)\n- tests/helpers.py (add path if needed)\n\n## Verify\n- [ ] Tests pass locally\n- [ ] HandcraftedCaveManager loads in headless mode
