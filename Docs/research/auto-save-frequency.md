# Auto-Save Frequency and Player Perception Research

## Overview

This research investigates optimal auto-save frequency for mobile games, examining when players notice/appreciate saves, performance impacts, and best practices for save indicators.

## Key Findings

### Industry Benchmarks

| Game | Auto-Save Frequency | Notes |
|------|---------------------|-------|
| Minecraft | Every 2 seconds (micro), 45 seconds (full) | Most changes backed up nearly instantly |
| Minecraft Servers | Every 5 minutes (6000 ticks) | Server-wide comprehensive saves |
| Mobile Games (typical) | 30-60 seconds | Balance of safety and performance |
| Roguelites (Hades) | Room completion | Event-based, not time-based |

### Player Perception Insights

**Positive Perception:**
- "Without auto-save, it is annoying to have to save after every mission, or come back to the game and realize you must replay 2 hours of progress because you forgot to save"
- Players expect their progress to be safe without manual intervention
- Auto-save that "just works" goes unnoticed (ideal state)

**Negative Perception:**
- Some players experience lag during auto-save process
- Performance issues lead players to decrease frequency (5 min -> 20 min)
- Uncertainty about whether progress is saved creates anxiety

### Critical Insight: Perception of Time Loss

**Call of Duty: Modern Warfare II Approach:**
Shows "amount of time the player will lose" in pause menu with checkpoint timestamp. This gives players enough information to decide whether they can quit safely.

## Hybrid Approach: Time + Events

### Recommended Save Triggers for GoDig

**Immediate Saves (Critical Events):**
| Event | Reason |
|-------|--------|
| App backgrounded/paused | Mobile reality - users switch apps constantly |
| Returning to surface | Natural session boundary, safe point |
| Purchase/sell at shop | Economic transactions must persist |
| Ore collected (rare+) | High-value discoveries shouldn't be lost |
| Achievement unlocked | Progress milestones are important |
| Depth milestone reached | Record-breaking should persist |
| Tool/gear upgrade | Significant progression step |

**Periodic Saves (Background):**
| Interval | Scope | Notes |
|----------|-------|-------|
| Every 30 seconds | Delta only | Only save changed data since last save |
| Every 60 seconds | Full state | Complete world state snapshot |
| On idle (5+ seconds no input) | Full state | Player is likely AFK/thinking |

### Why 30 Seconds (Not the Originally Specified 30 Seconds)

The implementation task (GoDig-implement-auto-save-12772c71) specifies "every 30 seconds." This is actually reasonable because:

1. **Mobile Context**: Players get interrupted frequently (calls, notifications, switching apps)
2. **Session Length**: GoDig targets 5-15 minute sessions - losing even 30 seconds of mining progress is noticeable
3. **Delta Saves**: Only saving changes since last save is very fast
4. **Mining Feedback**: Players want their ore discoveries saved immediately after the celebration

**Recommendation: Keep 30-second interval for time-based saves, but prioritize event-based saves.**

## Save Indicator Design

### What Players Need to Know

1. **"I'm saving"** - Brief activity indicator during save
2. **"You're safe"** - Confirmation that progress is protected
3. **"Last saved X ago"** - In pause menu for transparency

### UI Patterns

**During Active Gameplay:**
```
Minimal: Small icon in corner (spinning gear/disk icon)
Duration: 0.3-0.5 seconds
Position: Top-right corner, unobtrusive
```

**In Pause Menu:**
```
"Progress saved"
"Last checkpoint: 12 seconds ago"
```

**After Important Events:**
```
Brief "Saved" toast that fades after 1-2 seconds
Optional: Combine with event celebration (ore found + saved)
```

### Design Guidelines

From UX research:
- "Automatic saving of progress should be indicated by either 'Saving...' (with spinner) or 'Saved' (with timestamp)"
- "Indicating the current status reassures the users that their progress won't be lost"
- "Even when a system has already performed autosave, giving feedback when users manually save is beneficial"

## Performance Considerations

### Minimize Save Impact

1. **Delta Compression**: Only save changed chunks/data
2. **Async Saves**: Don't block the main thread
3. **Batch Writes**: Collect changes, write once per interval
4. **Skip Redundant Saves**: If nothing changed, don't write

### Mobile Battery Impact

Frequent disk writes consume battery. Mitigate by:
- Using in-memory caching between saves
- Batching writes to reduce I/O operations
- Avoiding save operations when battery is critically low (optional)

## Cloud vs. Local Saves

### Local (MVP Focus)

For MVP, focus on local saves:
- Faster, more reliable
- No network dependency
- Works offline

### Cloud (Future Consideration)

From Google Play Games Services documentation:
- "Always load the latest data from the service when your application starts up or resumes"
- "Save data to the service with reasonable frequency"
- "Conflicts occur when an instance cannot reach the cloud while syncing"

**Recommendation for v1.1+:**
- Implement cloud backup as supplement to local saves
- Sync to cloud on major milestones (surface return, shop exit)
- Never rely solely on cloud - maintain local copy

## Roguelite-Specific Considerations

### Hades Model (Room Completion Saves)

Hades saves:
- After clearing each room
- When returning to home base
- Allows "save and quit" between rooms

For GoDig:
- Each "surface return" is analogous to a room clear
- Depth milestones are natural save points
- "Mining run" is our equivalent of a "run"

### Death/Respawn Handling

If GoDig has death mechanics:
- Save immediately on death
- Save respawn state at surface
- Never lose ore collected before death (it should auto-deposit or be saved)

## Implementation Checklist

### MVP (v1.0)
- [x] Auto-save every 30-60 seconds
- [x] Save on app background/pause
- [x] Save on surface return
- [x] Save on shop transactions
- [x] Simple save indicator (icon + brief text)
- [x] "Last saved" timestamp in pause menu

### v1.1+
- [ ] Cloud save integration
- [ ] Multiple save slots
- [ ] Save file migration system
- [ ] Explicit "save slot" UI
- [ ] Cross-device sync

## Summary: GoDig Auto-Save Strategy

### Core Principles

1. **Never lose ore**: Ore discoveries are the core reward; losing them breaks trust
2. **Transparent but unobtrusive**: Players should know they're safe without being interrupted
3. **Event-driven first**: Save on meaningful events, time-based as backup
4. **Mobile-aware**: Assume app will be interrupted at any moment

### Recommended Configuration

```gdscript
# Save intervals
const AUTO_SAVE_INTERVAL := 30.0  # Seconds between time-based saves
const IDLE_SAVE_DELAY := 5.0      # Seconds of no input before save

# Event triggers (immediate save)
# - App backgrounded
# - Surface reached
# - Shop transaction
# - Rare ore collected (uncommon+)
# - Achievement unlocked
# - New depth record

# Save indicator
# - Small icon in top-right during save
# - "Saved" text fades after 1 second
# - Pause menu shows "Last saved: X ago"
```

### Final Verdict

The 30-second auto-save interval specified in the implementation task is appropriate for GoDig. Combined with event-based saves for critical moments, this provides robust progress protection without noticeable performance impact.

## Sources

- [Google Play Games Saved Games](https://developers.google.com/games/services/common/concepts/savedgames)
- [Unity Forum: When to Save on Mobile](https://forum.unity.com/threads/when-to-save-game-on-mobile-and-what-events-to-use.1221564/)
- [The UX of Saving & Quitting in Videogames](https://rystorm.com/blog/save-game-ux)
- [UI Patterns: Autosave](https://ui-patterns.com/patterns/autosave)
- [Hades Wiki: Saving your Progress](https://hades.fandom.com/wiki/Saving_your_Progress)
- [Gamasutra: Saving the Day - Save Systems in Games](https://www.gamedeveloper.com/design/saving-the-day-save-systems-in-games)
- [TV Tropes: Auto-Save](https://tvtropes.org/pmwiki/pmwiki.php/Main/Autosave)
