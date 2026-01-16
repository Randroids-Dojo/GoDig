# Social Features Research

## Sources
- [Social Features in Mobile Games](https://www.gamedeveloper.com/business/social-features-in-mobile-games)
- [Asynchronous Multiplayer Design](https://gameanalytics.com/blog/async-multiplayer/)
- [Leaderboards Best Practices](https://developer.apple.com/game-center/)

## Philosophy

### Single-Player First
GoDig is fundamentally a single-player experience. Social features should:
- **Enhance**, not require social interaction
- Be **optional** - full game without them
- Add **friendly competition**, not toxic rivalry
- Avoid **pay-to-win** leaderboard domination

### Priority: Low for MVP
Social features are nice-to-have for v1.1+, not core gameplay.

## Social Feature Options

### 1. Leaderboards

**Categories**
| Leaderboard | Metric | Reset |
|-------------|--------|-------|
| Deepest Dive | Max depth (m) | Never |
| Speed Runner | Time to 500m | Weekly |
| Richest Miner | Total coins earned | Never |
| Collector | Unique items found | Never |
| Prestige Master | Prestige count | Never |

**Implementation**
```gdscript
# leaderboard_manager.gd
func submit_score(board: String, score: int):
    if not social_enabled:
        return
    
    # Platform-specific (Game Center, Google Play Games)
    match OS.get_name():
        "iOS":
            GameCenter.submit_score(board, score)
        "Android":
            PlayGames.submit_score(board, score)
        "Web":
            # Custom backend or skip
            pass
```

**Privacy Options**
```
Leaderboard Privacy:
○ Public (show username)
○ Anonymous (show as "Miner #12345")
○ Friends Only
○ Disabled (don't submit)
```

### 2. Friend Leaderboards

**Concept**: Compete only against friends

**Benefits**:
- More meaningful competition
- Less intimidating than global
- Encourages friend invites

**Implementation**:
- Requires account system
- Platform friends (Game Center/Play Games)
- Or custom friend codes

### 3. Achievements / Trophies

**Platform Integration**
- iOS: Game Center Achievements
- Android: Google Play Games Achievements
- Web: Custom or skip

**Achievement Design**
Already covered in end-game-goals.md

### 4. World Seed Sharing

**Concept**: Share interesting world seeds

**Implementation**
```gdscript
func get_shareable_seed() -> String:
    return "GODIG-" + str(world_seed).sha256_text().substr(0, 8)

func share_seed():
    var seed_code = get_shareable_seed()
    var text = "Try my GoDig world: %s" % seed_code
    OS.shell_open("https://twitter.com/intent/tweet?text=" + text.uri_encode())
```

**Use Cases**:
- "This seed has diamonds at 100m!"
- "Great cave layout in this one"
- Content creator seeds

### 5. Screenshot/GIF Sharing

**Concept**: Share discoveries and achievements

**Implementation**
```gdscript
func capture_and_share():
    var image = get_viewport().get_texture().get_image()
    var path = OS.get_user_data_dir() + "/screenshot.png"
    image.save_png(path)
    
    # Platform share sheet
    if OS.has_feature("mobile"):
        NativeShare.share_image(path, "Check out my GoDig discovery!")
```

### 6. Asynchronous Challenges (v1.2+)

**Concept**: Challenge friends to beat your record

**Flow**:
1. Player A sets challenge: "Beat my 500m in 10 mins"
2. Challenge sent to Friend B
3. Friend B attempts challenge
4. Results compared

**No Real-Time Required**

### 7. Ghost Runs (Advanced)

**Concept**: Race against friend's recorded run

**Implementation**:
- Record player movement/actions
- Replay as "ghost" in friend's game
- Compare times

**Complexity**: High, defer to v2.0+

## Implementation Priority

### Not in MVP
Social features add complexity without core value.

### v1.0 (Optional)
- [x] Platform achievements (Game Center/Play Games)
- [x] Basic leaderboards (depth, coins)
- [x] World seed sharing

### v1.1+
- [x] Friend leaderboards
- [x] Screenshot sharing
- [x] Async challenges

### v2.0+ (Maybe)
- [x] Ghost runs
- [x] Guilds/clans
- [x] Cooperative features

## Technical Considerations

### Account System
Options:
1. **Platform only**: Game Center / Play Games
   - Pros: No backend needed
   - Cons: No cross-platform

2. **Custom accounts**: Email/password
   - Pros: Cross-platform, control
   - Cons: Need backend, GDPR, security

3. **Anonymous + optional link**: 
   - Pros: Frictionless start
   - Cons: Can't recover if lost

**Recommendation**: Platform accounts for MVP social, custom later if needed.

### Backend Requirements (If Custom)
- User accounts
- Score storage
- Friend relationships
- Data privacy (GDPR/CCPA)
- Moderation (usernames)

**Alternative**: Firebase, PlayFab, or similar BaaS

### Cheating Prevention
```gdscript
# Basic validation
func validate_score(depth: int, time: float) -> bool:
    # Impossible values
    if depth > 100000:  # Way too deep
        return false
    if time < 60 and depth > 1000:  # Too fast
        return false
    return true
```

For serious anti-cheat, need server-side validation.

## Social UX

### Opt-In Design
```
┌─────────────────────────────────────┐
│  SOCIAL FEATURES                    │
├─────────────────────────────────────┤
│  Connect to see how you rank!       │
│                                     │
│  [Connect Game Center]              │
│  [Maybe Later]                      │
│                                     │
│  You can play without connecting.   │
└─────────────────────────────────────┘
```

### Leaderboard Display
```
┌─────────────────────────────────────┐
│  DEEPEST DIVE - GLOBAL              │
├─────────────────────────────────────┤
│  1. DeepMiner99      5,234m         │
│  2. GemHunter        4,891m         │
│  3. DiggingPro       4,567m         │
│  ...                                │
│  127. You            1,234m         │
├─────────────────────────────────────┤
│  [Global] [Friends] [Weekly]        │
└─────────────────────────────────────┘
```

## Questions to Resolve
- [x] Social features at v1.0 or later? → Optional at v1.0, expanded v1.1+
- [x] Platform accounts or custom? → Platform only (Game Center/Play Games)
- [x] Leaderboard categories to include? → Depth, total coins, prestige count
- [x] Moderation for usernames needed? → Use platform usernames, no custom names
- [x] Cross-platform leaderboards? → No, keep platform-specific for simplicity
