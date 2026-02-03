# Save Trust Patterns: Player Perception and Confidence in Auto-Save Systems

## Overview

This research documents player psychology around save systems, focusing on how to build trust in auto-save, communicate save status effectively, prevent save corruption fears, and enable confident instant-resume experiences in GoDig.

## Sources

- [Saving the Day: Save Systems in Games - Gamasutra](https://www.gamedeveloper.com/design/saving-the-day-save-systems-in-games)
- [The UX of Saving & Quitting in Videogames](https://rystorm.com/blog/save-game-ux)
- [Autosave Design Pattern - UI Patterns](https://ui-patterns.com/patterns/autosave)
- [Auto-Save - TV Tropes](https://tvtropes.org/pmwiki/pmwiki.php/Main/Autosave)
- [How Auto Save Features Enhance User Experience](https://adanakilitparke.com/blog/how-automatic-save-features-enhance-user-experience-in-digital-gaming/)
- [Saving and Feedback - GitLab Pajamas](https://design.gitlab.com/usability/saving-and-feedback)
- [5 UX Best Practices for Status Indicators](https://www.koruux.com/blog/ux-best-practices-designing-status-indicators/)
- [Indicators, Validations, and Notifications - NN/g](https://www.nngroup.com/articles/indicators-validations-notifications/)
- [UX: How to Design a Better Save Function](https://medium.com/design-bootcamp/ux-design-save-function-5f00c1ecde7b)
- [Cloud Save - Android Developers](https://developer.android.com/games/pgs/savedgames)

## The Psychology of Save Trust

### Why Trust Matters

When players trust that their progress is secure:
- They engage more deeply for longer periods
- They experiment with riskier gameplay strategies
- They experience less anxiety during play
- They develop positive feelings toward the developer

When players don't trust the save system:
- They play conservatively, avoiding experimentation
- They manually save obsessively (if allowed)
- They feel anxious and distracted during play
- They blame the developer when progress is lost

### Core Insight: "Psychological Safety Net"

Auto-save serves as a safeguard that alleviates player anxiety, especially during high-stakes moments. This psychological safety allows players to focus on enjoyment and mastery rather than worry about losing progress.

### Trust Building Requires

1. **Transparency**: Players know when saves happen
2. **Reliability**: Saves always work, never corrupt
3. **Consistency**: Same behavior every time
4. **Recovery**: Clear path when things go wrong

## When Players Trust vs Want Manual Control

### Players Trust Auto-Save When:

| Scenario | Why Trust Works |
|----------|-----------------|
| Quick sessions (<15 min) | Low stakes if something goes wrong |
| Progress is always protected | Never experienced data loss |
| Clear save indicators | They can see it working |
| Mobile gaming context | Expectation of "just works" |
| Low-consequence games | Failure isn't punishing |

### Players Want Manual Control When:

| Scenario | Why Control Matters |
|----------|---------------------|
| Long sessions (1+ hours) | More progress at risk |
| Past save corruption trauma | "Burnt once, shy forever" |
| Experimentation/testing | Want to revert decisions |
| Multiple playthroughs | Save scumming preference |
| High-stakes choices | Permanent consequences |

### GoDig Assessment

GoDig is well-suited for auto-save trust because:
- Sessions are 5-15 minutes (low stakes per session)
- No permanent, irreversible choices (ore can be re-mined)
- Mobile-first audience expects seamless saves
- Roguelite framing sets "loss is part of the game" expectation

## Save Indicator Design

### The Visibility Principle

"Visibility of system status is the very first heuristic among Jakob's ten heuristics for interface design." Players need to know:
1. A save is happening right now
2. The save completed successfully
3. When the last save occurred

### Indicator States

**State 1: Saving in Progress**
```
Visual: Small spinner icon (e.g., rotating gear) in corner
Position: Top-right, unobtrusive
Duration: 0.3-0.5 seconds (or actual save time)
Purpose: Prevent interruption, show activity
```

**State 2: Save Complete**
```
Visual: Checkmark that fades, or "Saved" text
Position: Same location as saving indicator
Duration: 1-2 seconds before fade
Purpose: Confirm success, build trust
```

**State 3: Last Saved (Pause Menu)**
```
Visual: "Last saved: 12 seconds ago" or timestamp
Position: In pause/settings menu
Purpose: Transparency, decision support for quitting
```

### Common Patterns in Games

| Game | Indicator Style |
|------|-----------------|
| Spark the Battle Dog | Floppy disk icon appears in corner |
| Afterimage | Triangular emblem in bottom-right |
| Dark Souls | "Saving..." text briefly appears |
| Minecraft | World saving in progress (settings) |
| Hades | No explicit indicator (room transitions) |

### Indicator Anti-Patterns

| Mistake | Risk |
|---------|------|
| Too subtle indicator | Players don't notice, quit during save |
| No indicator at all | Players don't trust auto-save |
| Intrusive/blocking indicator | Breaks flow, annoying |
| Indicator stays too long | Feels like something is wrong |
| Different indicators for same action | Confusing, inconsistent |

### GoDig Recommended Design

**During Gameplay:**
```
┌─────────────────────────────────────┐
│ [Depth: 127m]          [💾 Saving...] │  <- Small icon + text, fades
│                                     │
│                                     │
│          (gameplay area)            │
│                                     │
└─────────────────────────────────────┘
```

**In Pause Menu:**
```
┌─────────────────────────────────────┐
│           PAUSED                    │
│                                     │
│      [Resume]                       │
│      [Settings]                     │
│      [Quit to Surface]              │
│                                     │
│  ✓ Progress saved (5 sec ago)       │  <- Always visible
└─────────────────────────────────────┘
```

## Recovery from Interrupted Sessions

### The Mobile Reality

Mobile players get interrupted constantly:
- Phone calls
- Notifications
- App switching
- Battery death
- Network loss

**Key Insight**: "Users switch apps constantly. Auto-save on app backgrounded is essential."

### Instant Resume Requirements

1. **State Preservation**: Exact position, camera, inventory, progress
2. **Quick Load**: <2 seconds from launch to gameplay
3. **Clear Context**: "Welcome back! You're at 127m depth"
4. **No Re-tutorial**: Respect previous learning

### Resume UX Flow

**Returning Player Flow:**
```
App Launch
    ↓
Splash Screen (0.5s)
    ↓
[Check for saved game]
    ↓
[If saved game exists]
    ↓
"Continue" button prominently displayed
    ↓
Tap "Continue"
    ↓
Load saved state
    ↓
Brief "Welcome back" with context
    ↓
Gameplay resumes exactly where left off
```

**Welcome Back Message Options:**

| Context | Message |
|---------|---------|
| Underground | "You're at 127m depth with 8 ores. Keep digging!" |
| Surface | "Welcome back! Ready for another run?" |
| Near shop | "Your inventory is nearly full. Visit the shop?" |
| New depth record | "You reached 250m last time. Can you go deeper?" |

### Handling Save During Interruption

```gdscript
# Save triggers for mobile
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_APPLICATION_PAUSED:
            save_game_immediately()
        NOTIFICATION_APPLICATION_FOCUS_OUT:
            save_game_immediately()
        NOTIFICATION_WM_GO_BACK_REQUEST:
            save_game_immediately()
        NOTIFICATION_CRASH:
            save_game_immediately()  # Best effort
```

## Cloud Save Reliability Perceptions

### Player Concerns About Cloud Saves

From community discussions, players fear:
1. **Sync failures**: "Cloud sync corrupted my local save"
2. **Version conflicts**: "It overwrote my new progress with old data"
3. **Network dependency**: "Can't play offline"
4. **Developer control**: "What if the service shuts down?"

### Cloud Save Horror Stories

Common complaints:
- "30 hours of playtime down the drain"
- "My power went out mid-save, questline completely restarted"
- "The cloud will want to revert your new save file with the corrupted one"

### Building Cloud Trust

**Do:**
- Local save is always primary, cloud is backup
- Clearly show sync status
- Allow manual cloud save trigger
- Version saves, keep history
- Sync on safe moments (surface, shop exit)

**Don't:**
- Make cloud the only save location
- Sync during active gameplay
- Auto-resolve conflicts without user input
- Delete local saves after cloud sync

### Conflict Resolution UX

When cloud and local saves differ:
```
┌─────────────────────────────────────┐
│     Save Conflict Detected          │
│                                     │
│  Local: 127m depth, 50,000 coins    │
│         Last played 2 hours ago     │
│                                     │
│  Cloud: 89m depth, 42,000 coins     │
│         Last synced 3 hours ago     │
│                                     │
│  [Keep Local]     [Keep Cloud]      │
│                                     │
│  (Both saves are backed up)         │
└─────────────────────────────────────┘
```

## Save Corruption Fear and Mitigation

### Why Players Fear Corruption

Past trauma drives fear:
- Lost significant progress before
- Heard horror stories from others
- Experienced other software data loss
- Distrust of technology in general

### Technical Causes of Corruption

| Cause | Mitigation |
|-------|------------|
| Power loss during write | Atomic writes, write to temp then rename |
| App crash during save | Write complete file before any deletion |
| Incomplete cloud sync | Never delete local until cloud confirmed |
| Disk full | Check space before write, graceful fail |
| Version mismatch | Save format versioning, migration |

### Atomic Save Pattern

```gdscript
func save_game(data: Dictionary) -> bool:
    var temp_path = save_path + ".tmp"
    var backup_path = save_path + ".bak"

    # Step 1: Write to temp file
    var file = FileAccess.open(temp_path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(data))
    file.close()

    # Step 2: Verify temp file is valid
    if not verify_save_file(temp_path):
        DirAccess.remove_absolute(temp_path)
        return false

    # Step 3: Backup current save
    if FileAccess.file_exists(save_path):
        if FileAccess.file_exists(backup_path):
            DirAccess.remove_absolute(backup_path)
        DirAccess.rename_absolute(save_path, backup_path)

    # Step 4: Rename temp to actual save
    DirAccess.rename_absolute(temp_path, save_path)
    return true
```

### Corruption Recovery UX

If corruption is detected:
```
┌─────────────────────────────────────┐
│     Save File Issue Detected        │
│                                     │
│  We found a problem with your save. │
│  Don't worry - we have backups!     │
│                                     │
│  [Restore from backup]              │
│    (2 hours ago, 89m depth)         │
│                                     │
│  [Start fresh]                      │
│    (Begin new adventure)            │
│                                     │
│  [Contact support]                  │
│    (We can help recover your data)  │
└─────────────────────────────────────┘
```

### Multiple Save Slots vs Single Auto-Save

**Single Auto-Save (GoDig approach):**
- Simpler for casual players
- No save management complexity
- Works well for roguelites
- Trust built through reliability

**Multiple Slots (future consideration):**
- Appeals to core gamers
- Allows experimentation
- Provides player-controlled backup
- Consider for v1.1+

## Implementation Recommendations

### Phase 1: MVP Save System

**Requirements:**
- Auto-save every 30 seconds
- Event-triggered saves (surface, shop, rare ore)
- Immediate save on app background
- Visible save indicator
- "Last saved" in pause menu

**Trust Features:**
- Clear "Saved" confirmation
- Never interrupt player for save
- Fast, unnoticeable save operations

### Phase 2: v1.0 Enhanced

**Requirements:**
- Backup save file (one previous version)
- Corruption detection and recovery
- Save verification after write
- "Continue" prominent on launch

**Trust Features:**
- Instant resume exactly where left off
- Welcome back context message
- Backup restore option

### Phase 3: v1.1 Cloud Integration

**Requirements:**
- Local-first with cloud backup
- Manual cloud save trigger
- Conflict resolution UI
- Offline mode support

**Trust Features:**
- Clear sync status indicator
- Version history (last 3-5 saves)
- "Never delete without asking"

## Trust Communication Checklist

Before launch, verify:

- [ ] Save indicator visible during save
- [ ] "Saved" confirmation shown after save
- [ ] Pause menu shows last save time
- [ ] App background triggers immediate save
- [ ] Resume loads exact state
- [ ] Welcome back message provides context
- [ ] Backup system exists and works
- [ ] Corruption is detected before load
- [ ] Recovery path exists for all error cases
- [ ] Settings persist across sessions

## Summary: Building Save Trust in GoDig

### Core Principles

1. **Save often, show it working**: Visible indicators build trust
2. **Local first, cloud backup**: Never depend solely on network
3. **Never lose ore**: Mining rewards are sacred, protect them
4. **Instant resume**: Respect player time, no friction
5. **Graceful recovery**: When things go wrong, have a path forward

### Key Metrics to Track

| Metric | Target | Indicates |
|--------|--------|-----------|
| Save failures | <0.1% | Technical reliability |
| Corruption incidents | 0 | File integrity |
| Resume rate | >80% | Players trust to return |
| Support tickets (save issues) | <1% of players | User-perceived reliability |

### Final Verdict

For GoDig's mobile roguelite design:
- **Auto-save is essential** (mobile interruptions)
- **30-second interval is appropriate** (quick sessions)
- **Event saves add reliability** (key moments protected)
- **Visible indicators build trust** (players see it working)
- **Instant resume respects time** (welcome back flow)

The goal: Players should never think about saving. They play, they quit, they come back, everything is exactly as they left it. That's trust.
