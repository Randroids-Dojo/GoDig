---
title: "implement: Add peaceful mode toggle to settings popup"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-03T05:37:56.888609-06:00\\\"\""
closed-at: "2026-02-03T05:38:42.685773-06:00"
close-reason: Added peaceful mode toggle to settings popup under new Gameplay section
---

## Description
The SettingsManager has a peaceful_mode setting that disables enemy encounters, but there's no UI for users to toggle it. This is an important accessibility option that should be exposed.

## Implementation
- Add a checkbox to the settings popup under the Controls section
- Connect to SettingsManager.peaceful_mode
- Load/save the setting properly

## Affected Files
- scripts/ui/settings_popup.gd

## Verify
- [ ] Peaceful mode checkbox appears in settings
- [ ] Toggle persists after closing/reopening settings
- [ ] When enabled, no enemies spawn (tested at depth 100+)
