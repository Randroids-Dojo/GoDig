---
title: "implement: Add settings popup integration tests"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-03T06:25:02.821421-06:00\\\"\""
closed-at: "2026-02-03T06:25:39.579889-06:00"
close-reason: "Added 9 integration tests for SettingsManager properties: accessibility, control, gameplay, and audio settings"
---

## Description
Add integration tests for the settings popup UI.

## Context
The settings popup is integrated in main_menu.gd and pause_menu.gd but has no test coverage.
Tests should verify:
1. Settings popup node paths exist when opened
2. All UI controls map to correct settings
3. Changing settings updates SettingsManager

## Tests to Add
1. Settings button exists in main menu
2. Settings popup can be opened (verify SettingsManager is accessible)
3. All setting categories have headers (Accessibility, Controls, Gameplay, Audio)
4. Core settings are present (haptics, peaceful mode, volume sliders)

## Affected Files
- tests/test_main_menu.py (add settings tests)
- tests/helpers.py (add settings popup paths if needed)

## Verify
- [ ] Tests are collected by pytest
- [ ] Tests pass when settings popup not visible (just verify settings manager exists)
