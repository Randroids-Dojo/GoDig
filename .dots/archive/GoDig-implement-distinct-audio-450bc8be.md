---
title: "implement: Distinct audio for each ore type"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-02-02T18:33:32.811230-06:00\\\"\""
closed-at: "2026-02-02T22:43:52.571160-06:00"
close-reason: Added discovery_sound, discovery_pitch, discovery_volume exports to OreData. Added play_ore_discovery(ore) to SoundManager. Updated dirt_grid to use ore-specific sounds. Each ore type can now have distinct audio.
---

Based on audio design research (Session 27), each ore type needs a distinct collection sound. 85% of players appreciate audio impact, well-executed audio boosts satisfaction by 70%, and games with effective audio see 20% higher retention. Mining sound must be satisfying with ore-specific sounds for discovery moments.
