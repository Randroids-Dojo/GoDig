---
title: "implement: Increase game fixture timeout and add retry logic"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-03T08:22:53.219631-06:00\\\"\""
closed-at: "2026-02-03T08:23:32.842550-06:00"
close-reason: Implemented extended timeouts (60-90s) and retry logic (max 2 retries) in both main_menu and game fixtures to handle parallel execution scenarios
---

## Context
Tests using the game fixture are timing out due to parallel execution. The game fixture has a 60s timeout for scene loading but when multiple Godot processes run simultaneously, this isn't enough.

## Root Cause
From research: tests take 1:24:10 total due to 30s timeouts per test. Parallel agent execution causes resource contention.

## Implementation
1. Increase wait_for_node timeout from 30s to 60s in game fixture
2. Increase scene change timeout
3. Add retry logic (max 3 attempts) for scene loading
4. Add connection health check before each test

## Affected Files
- tests/conftest.py

## Verify
- [ ] Tests using game fixture pass more reliably
- [ ] Test execution time remains reasonable
- [ ] Retries are logged for debugging
