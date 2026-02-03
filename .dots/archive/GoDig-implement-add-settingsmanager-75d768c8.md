---
title: "implement: Add SettingsManager signal connection tests"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-03T06:36:47.759503-06:00\\\"\""
closed-at: "2026-02-03T06:38:05.864668-06:00"
close-reason: Added comprehensive SettingsManager integration tests covering all settings properties, default values, and signal existence
---

Add integration tests for SettingsManager signal emissions when settings change. Should verify that changing each setting type (text_size, colorblind_mode, haptics, audio volumes, etc.) emits the appropriate signal. Tests will help catch any regressions in the settings system.

## Implementation
1. Add test_settings_text_size_signal - verify text_size_changed emits
2. Add test_settings_haptics_signal - verify haptics_changed emits  
3. Add test_settings_audio_signals - verify audio_changed emits for volume changes
4. Add test_settings_juice_level_signal - verify juice_level_changed emits
5. Add test_settings_peaceful_mode_signal - verify peaceful_mode_changed emits

## Affected Files
- tests/test_settings.py (new file)
- tests/helpers.py (add settings_manager path)

## Verify
- [ ] All new tests pass
- [ ] Settings signals emit correctly when values change
