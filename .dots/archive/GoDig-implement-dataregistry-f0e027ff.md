---
title: "implement: DataRegistry integration tests"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-03T11:16:42.355024-06:00\\\"\""
closed-at: "2026-02-03T11:18:27.998032-06:00"
close-reason: Created test_data_registry.py with 66 comprehensive tests. Version bumped to 0.59.33.
---

Create comprehensive integration tests for DataRegistry autoload covering:
- Singleton existence
- Layer system (get_layer, get_layer_at_depth, layers count)
- Ore system (get_ore, get_ores_at_depth)
- Item system (get_item, get_all_items)
- Tool system (get_tool, get_all_tools)
- Equipment system
- Sidegrade system
- Lore system
- Test helper methods
