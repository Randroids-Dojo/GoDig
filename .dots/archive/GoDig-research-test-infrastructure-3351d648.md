---
title: "research: Test infrastructure reliability - investigate parallel test execution and ERROR state"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-03T08:21:11.745730-06:00\\\"\""
closed-at: "2026-02-03T08:21:45.549592-06:00"
close-reason: "Found root cause: tests using game fixture timeout due to parallel execution overload. Tests take 1:24:10 due to 30s timeouts per test. Need to increase timeouts or reduce parallel execution. main_menu fixture tests pass but game fixture tests fail during scene change."
---

## Context\nMany integration tests are showing ERROR status (not FAILED). Tests using the `main_menu` fixture pass, but tests using the `game` fixture fail.\n\n## Hypotheses\n1. Parallel agent execution may be causing port conflicts\n2. Scene change in game fixture may be timing out\n3. Resource contention when multiple Godot instances run\n\n## Questions\n- How can we make tests more reliable in parallel execution?\n- Should we increase timeouts or add retry logic?\n- Are there race conditions in scene loading?
