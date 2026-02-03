# Cloud Save and Cross-Platform Progression UX Patterns

## Executive Summary

Cloud saves are expected by modern players but fraught with UX pitfalls. This research examines player expectations, pain points, and best practices. The key insight: **players need trust in their saves above all else**. This requires transparent conflict resolution UI, offline-first design, and clear communication about what's being synced.

## Case Studies

### Apple Arcade / iCloud - Seamless When It Works

**How It Works:**
- iCloud and Game Center keep progress, high scores, and saves up-to-date across devices
- Requires same Apple Account on all devices
- Game Center handles profiles, syncing, and multiplayer "in the background"
- Players "rarely need to manage anything manually"

**Requirements for Developers:**
- Enable iCloud Drive for the specific game
- Use GameKit for saving game data to player's iCloud account
- Support Apple Games app integration for unified experience

**Pain Points:**
- Users report data not transferring despite same Apple ID
- Deleting game may lose local saves if iCloud sync didn't complete
- iCloud Drive storage limits can block syncing
- Some games don't implement sync even when available on Apple Arcade

**Key Insight:** Apple's system works well when developers implement it fully, but inconsistent implementation creates player confusion about which games sync and which don't.

### Genshin Impact - Account Linking Friction Case Study

**Major Pain Points:**

1. **One-Time Linking Pop-Up:**
   > "The critical linking pop-up only appears during your first game launch on PlayStation. Skip it, and you're permanently stuck with a new account tied to that PSN ID. No do-overs."

2. **No Account Merging:**
   - Cannot merge two accounts with existing progress
   - Players with progress on both PSN and PC/Mobile can't combine them
   - Must choose which account to abandon

3. **Platform-Specific Currency:**
   - Genesis Crystals purchased on PlayStation stayed platform-exclusive (until Update 5.8)
   - Creates confusion about where premium currency lives

4. **Permanent Decisions:**
   > "Once you've linked your PSN and miHoYo accounts, there's no going back."

5. **Server Region Locks:**
   - Cannot transfer between America, Europe, Asia servers
   - Cross-save only works within same server region

**Key Insight:** Genshin demonstrates how irreversible decisions and lack of merge options create permanent player frustration. The cost of "getting it wrong" is too high.

### Among Us - Minimal Progression, Minimal Issues

**Approach:**
- Cross-platform play works across all platforms (PS, Xbox, PC, Switch, iOS, Android)
- Account linking at accounts.innersloth.com
- Cosmetics link but purchases are platform-specific

**Limitations:**
- No progression to sync (by design)
- Ad-free purchases don't transfer between store ecosystems
- Nintendo Switch linking still in development
- PlayStation cannot link accounts at all

**Key Insight:** Among Us sidesteps most cloud save issues by minimizing what needs syncing. For games with progression, this isn't an option, but it shows the value of keeping save data simple.

### Minecraft - Realms vs Local Saves

**Realms (Cloud) Approach:**
- Private, cloud-hosted servers
- Always online, friends can play anytime
- Cross-device play synced via Microsoft account
- Cross-platform within same edition (Java with Java, Bedrock with Bedrock)

**Local Save Problems:**
- Java Edition has no native cloud syncing
- World saves "trapped" on original device (especially Switch)
- 150+ hour worlds can't be moved without manual export
- Lost saves reported with no recovery option

**Player Frustrations:**
> "It's such a pain having to move worlds around through realms just to download and play on a different device."

**Key Insight:** Minecraft shows the gap between "cross-play" (playing together) and "cross-save" (progress everywhere). Players expect both but often only get one.

## Conflict Resolution Best Practices

### Prevention First

| Strategy | Implementation |
|----------|----------------|
| Frequent uploads | Save to cloud on every significant action |
| Small save files | Break save into components, not one blob |
| Atomic units | Group related data so partial syncs don't corrupt |
| Server timestamps | Use server time, not device time for conflict detection |

### UI Design for Conflicts

When conflicts occur, players need:

1. **Clear explanation of what differs**
   - Timestamps for each version
   - Device/platform that created each version
   - Summary of key differences (depth reached, gold collected)

2. **Actionable options**
   - Keep local (with clear description of what's lost)
   - Keep cloud (with clear description of what's lost)
   - Merge (when possible, with preview)

3. **Trust-building information**
   - "Last synced: 2 hours ago from iPhone"
   - "Local changes since then: 3 runs completed"

### Resolution Strategies by Data Type

| Data Type | Strategy | Example |
|-----------|----------|---------|
| High scores | Keep maximum | Best depth record |
| Currency | Keep maximum | Gold collected |
| Achievements | Union merge | All unlocked achievements |
| Settings | Newest wins | Control preferences |
| Progress | Context-dependent | Current upgrade levels |

### Three-Way Merge Pattern

For complex conflicts, compare:
1. Local save (current device)
2. Cloud save (server)
3. Last known synchronized state

This reveals which side made changes and enables intelligent merging.

## Offline-First Architecture

### Core Principles

> "In 2025, offline-first isn't a premium feature for niche use cases. It's becoming the baseline expectation."

**Local Database as Source of Truth:**
- All reads come from local database
- Network requests update local database
- UI always reflects local state
- Sync happens in background

**Sync Engine Components:**
```
Player Action
    ↓
Local Database (immediate write)
    ↓
Sync Queue (pending operations)
    ↓
Network Available?
    ├── Yes → Send to server → Mark synced
    └── No → Wait for connectivity
```

### Implementation for GoDig

**Save Data Structure:**
```gdscript
class_name SaveData extends Resource

# Core progression (merge by keeping max)
@export var max_depth_reached: int = 0
@export var total_gold_earned: int = 0
@export var current_gold: int = 0

# Upgrades (merge by keeping higher values)
@export var pickaxe_level: int = 1
@export var health_level: int = 1
@export var inventory_level: int = 1

# Achievements (union merge)
@export var achievements: Dictionary = {}

# Sync metadata
@export var last_sync_timestamp: int = 0
@export var sync_status: String = "synced"  # synced, pending, conflicted
@export var device_id: String = ""
```

**Conflict Resolution UI:**
```gdscript
func show_conflict_dialog(local: SaveData, cloud: SaveData) -> void:
    var dialog = conflict_dialog.instantiate()

    dialog.set_local_info(
        "This device",
        local.last_sync_timestamp,
        "Depth: %dm, Gold: %d" % [local.max_depth_reached, local.current_gold]
    )

    dialog.set_cloud_info(
        cloud.device_id,
        cloud.last_sync_timestamp,
        "Depth: %dm, Gold: %d" % [cloud.max_depth_reached, cloud.current_gold]
    )

    # Offer intelligent merge when possible
    if can_merge_safely(local, cloud):
        dialog.show_merge_option(preview_merge(local, cloud))

    dialog.connect("choice_made", _on_conflict_resolved)
    add_child(dialog)
```

## Player Trust Patterns

### Building Trust

| Pattern | Implementation |
|---------|----------------|
| Visible sync indicator | Show last sync time in settings |
| Manual sync button | Let anxious players force sync |
| Sync success feedback | Brief toast on successful sync |
| Offline warning | Clear indicator when not synced |

### Destroying Trust (Avoid These)

| Anti-Pattern | Player Reaction |
|--------------|-----------------|
| Silent sync failures | "Where did my progress go?" |
| Overwriting without warning | "The game deleted my save!" |
| Unclear conflict dialogs | "I don't know what I'm choosing" |
| No recovery options | "All my work is lost forever" |

### Recovery Options

Always provide escape hatches:
- Backup saves before major operations
- Allow exporting save data locally
- Maintain save history (last 5 syncs)
- Manual restore from backup

## Platform-Specific Considerations

### Apple (iOS/macOS)

**Pros:**
- iCloud integration well-documented
- Game Center handles profile sync
- Players expect seamless experience

**Cons:**
- Players may not understand iCloud storage limits
- Game must explicitly opt into sync
- Different implementations across games confuses players

### Android (Google Play)

**Pros:**
- Play Games saved games API
- Well-documented conflict resolution

**Cons:**
- Players may not be signed into Play Games
- Some devices don't have Play Services
- Need fallback for non-Play Store distribution

### Cross-Platform (iOS + Android)

**Considerations:**
- Need custom backend or third-party service
- Account linking required (friction point)
- Currency purchases must be platform-specific (App Store rules)

## Implementation Recommendations for GoDig

### Phase 1: Local-First Foundation

1. **Structured save data** with sync metadata
2. **Automatic local saves** on significant events
3. **Export/import** functionality for manual backup
4. **Visible "last saved" indicator** in pause menu

### Phase 2: Platform-Native Sync

1. **iCloud/Game Center** integration for Apple platforms
2. **Google Play Games** saved games for Android
3. **Conflict resolution UI** with clear choices
4. **Merge strategy** for non-conflicting data

### Phase 3: Cross-Platform (If Needed)

1. **Custom account system** or third-party auth
2. **Backend server** for cross-platform saves
3. **Account linking flow** with clear expectations
4. **Currency separation** by platform (App Store rules)

### Anti-Patterns to Avoid

| Never Do | Why |
|----------|-----|
| Silent overwrites | Destroys trust, may lose progress |
| One-time linking decisions | Genshin showed how punishing this is |
| Complex account requirements | Friction causes abandonment |
| No offline support | Players expect to play anywhere |
| Unclear sync status | Anxiety about save state |

## Technical Architecture Notes

### Sync Queue Pattern

```gdscript
# Queue changes for later sync
var sync_queue: Array[Dictionary] = []

func queue_sync(action: String, data: Dictionary) -> void:
    sync_queue.append({
        "action": action,
        "data": data,
        "timestamp": Time.get_unix_time_from_system(),
        "device_id": OS.get_unique_id()
    })

    # Try to sync immediately if online
    if is_online:
        process_sync_queue()

func process_sync_queue() -> void:
    while sync_queue.size() > 0:
        var item = sync_queue[0]
        var result = await send_to_server(item)

        if result.success:
            sync_queue.pop_front()
        elif result.conflict:
            show_conflict_dialog(result.local, result.cloud)
            break
        else:
            # Network error, try again later
            break
```

### Merge Logic Example

```gdscript
func merge_saves(local: SaveData, cloud: SaveData) -> SaveData:
    var merged = SaveData.new()

    # Keep maximum values for progression
    merged.max_depth_reached = maxi(local.max_depth_reached, cloud.max_depth_reached)
    merged.total_gold_earned = maxi(local.total_gold_earned, cloud.total_gold_earned)

    # Currency is tricky - keep higher but warn if significant difference
    merged.current_gold = maxi(local.current_gold, cloud.current_gold)

    # Union merge achievements
    merged.achievements = local.achievements.duplicate()
    for key in cloud.achievements:
        if not merged.achievements.has(key):
            merged.achievements[key] = cloud.achievements[key]

    # Keep highest upgrade levels
    merged.pickaxe_level = maxi(local.pickaxe_level, cloud.pickaxe_level)
    merged.health_level = maxi(local.health_level, cloud.health_level)

    return merged
```

## Sources

- [Access your gameplay progress on all of your Apple devices](https://support.apple.com/en-us/101643)
- [How to use Apple Games & Game Center for cross-device play](https://appleinsider.com/inside/apple-arcade/tips/how-to-use-apple-games-game-center-for-cross-device-play-cloud-saves)
- [Genshin Impact Cross-Save Guide](https://www.thegamer.com/genshin-impact-cross-save-guide/)
- [Account Linking on Among Us](https://www.innersloth.com/account-linking-on-among-us/)
- [Minecraft Realms](https://www.minecraft.net/en-us/realms)
- [Resolving Cloud Save Conflicts - Android Developers](https://minimum-viable-product.github.io/marshmallow-docs/training/cloudsave/conflict-res.html)
- [Cloud Save Systems Implementation Guide](https://practicalmedia.io/article/cloud-save-systems-implementation-guide)
- [The Complete Guide to Offline-First Architecture in Android](https://www.droidcon.com/2025/12/16/the-complete-guide-to-offline-first-architecture-in-android/)
- [Building Cross-Platform Cloud Saves for Godot Games](https://dashboard.godotbaas.com/blog/godot-cloud-saves-guide)

## Research Session

- **Date:** 2026-02-02
- **Focus:** Player expectations and pain points with cloud saves and cross-platform progression
- **Key Insight:** Trust is paramount - players need clear conflict resolution UI, offline-first design, and transparent sync status
