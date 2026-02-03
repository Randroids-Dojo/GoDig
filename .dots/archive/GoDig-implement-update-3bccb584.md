---
title: "implement: Update LightingManager to modern signal connect syntax"
status: closed
priority: 3
issue-type: task
created-at: "\"\\\"2026-02-03T06:26:25.687862-06:00\\\"\""
closed-at: "2026-02-03T06:28:11.571269-06:00"
close-reason: Updated LightingManager signal connections to Godot 4 modern syntax
---

## Description
Update signal connections to Godot 4 style.

## Context
Lines 63, 67 use old-style: `GameManager.connect("depth_updated", _on_depth_changed)`
Should be: `GameManager.depth_updated.connect(_on_depth_changed)`

## Changes
- Update signal connections in _ready()
- No functional change, just code style modernization

## Verify
- [ ] Godot --check-only passes
- [ ] Lighting still works (signals still fire)
