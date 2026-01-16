# Notification & Engagement Hooks Research

## Sources
- [Mobile Game Retention Strategies](https://blog.appsflyer.com/mobile-game-retention/)
- [Ethical Push Notification Design](https://www.nngroup.com/articles/push-notification/)
- [Player Engagement Without Dark Patterns](https://www.gamedeveloper.com/design/ethical-game-design)

## Philosophy: Respect Player Time

### Goals
1. **Bring players back** without manipulation
2. **Add value** with each notification
3. **Respect preferences** - easy opt-out
4. **No dark patterns** - no guilt, no FOMO pressure

### Anti-Patterns to Avoid
- "Your miners miss you!"
- "Energy is full, wasting!"
- Countdown timers creating urgency
- Notification spam
- Guilt-tripping language

## Notification Types

### 1. Daily Reward Reminder
**Purpose**: Remind of unclaimed daily reward

**Timing**: Once per day, at player's usual play time

**Message Examples**:
- "Daily reward ready! Claim your bonus."
- "Your daily gift is waiting."

**Rules**:
- Only send if reward actually available
- Max 1 per day
- Stop after 3 days of no opens

### 2. Progress Milestone
**Purpose**: Celebrate achievements, encourage return

**Timing**: When player reaches milestone while away

**Message Examples**:
- "Achievement unlocked: Deep Diver!"
- "New depth record: 500m!"

**Rules**:
- Only for significant milestones
- Max 1 per week
- Include actual achievement

### 3. New Content Alert
**Purpose**: Inform of updates, new features

**Timing**: After app update

**Message Examples**:
- "New update: Cave biomes added!"
- "New shop unlocked on surface"

**Rules**:
- Only for meaningful content
- One notification per update
- Link to changelog

### 4. Offline Progress (If Implemented)
**Purpose**: Show idle gains accumulated

**Timing**: After X hours of offline time

**Message Examples**:
- "Your miners collected 1,234 coins"
- "Resources ready to collect"

**Rules**:
- Only if offline system exists
- Shows actual value earned
- No "wasting" language

## Implementation

### Godot Mobile Notifications
```gdscript
# notification_manager.gd
extends Node

var notifications_enabled: bool = true

func schedule_daily_reward(reward_time: int):
    if not notifications_enabled:
        return
    
    if OS.has_feature("mobile"):
        # Use platform-specific plugin
        var notification = {
            "title": "GoDig",
            "message": "Daily reward ready!",
            "delay_sec": reward_time,
            "channel": "daily_rewards"
        }
        # Platform plugin call here
```

### Permission Request
```gdscript
func request_notification_permission():
    # Ask politely, explain value
    var dialog = AcceptDialog.new()
    dialog.dialog_text = "Get notified about daily rewards and achievements?"
    dialog.add_button("Not Now", true, "decline")
    dialog.add_button("Yes, Notify Me", false, "accept")
    
    dialog.confirmed.connect(_on_notifications_accepted)
    dialog.custom_action.connect(_on_notifications_declined)
```

### Notification Settings
```
┌─────────────────────────────────────┐
│  NOTIFICATION SETTINGS              │
├─────────────────────────────────────┤
│  Push Notifications: [ON/OFF]       │
│                                     │
│  Notify me about:                   │
│  ├─ Daily Rewards: [✓]              │
│  ├─ Achievements: [✓]               │
│  ├─ New Content: [✓]                │
│  └─ Offline Progress: [✓]           │
│                                     │
│  Quiet Hours: 10pm - 8am [✓]        │
└─────────────────────────────────────┘
```

## In-Game Engagement Hooks

### Session Start Hooks
```gdscript
func _on_session_start():
    # Check what's new since last session
    check_daily_reward()
    check_new_achievements()
    show_welcome_back_summary()
```

### Welcome Back Summary
```
┌─────────────────────────────────────┐
│  WELCOME BACK!                      │
├─────────────────────────────────────┤
│  Time away: 8 hours                 │
│                                     │
│  ★ Daily reward ready!              │
│  ★ New depth record yesterday       │
│                                     │
│  [CONTINUE MINING]                  │
└─────────────────────────────────────┘
```

### Daily Login Reward
**Structure**: 7-day cycle with escalating value

| Day | Reward |
|-----|--------|
| 1 | 100 coins |
| 2 | 200 coins |
| 3 | 500 coins |
| 4 | Random gem |
| 5 | 1,000 coins |
| 6 | Rare item |
| 7 | 5,000 coins + bonus |

**Rules**:
- Streak resets after 48 hours (forgiving)
- No "you lost your streak!" messaging
- Just show current day

### Comeback Bonus
If player returns after 3+ days:
```
"Welcome back! Here's a comeback bonus: 500 coins"
```

No guilt, just reward.

## Retention Mechanics

### Short-Term (Daily)
- Daily reward
- Daily challenge (optional)
- "Quick dig" 5-minute session mode

### Medium-Term (Weekly)
- Weekly challenge with good reward
- Progress summary
- New content hints

### Long-Term (Monthly)
- Season pass / battle pass (if added)
- Major milestones
- Collection progress

## Analytics to Track

### Healthy Metrics
```gdscript
func track_engagement():
    Analytics.log_event("session_start", {
        "days_since_last": days_away,
        "notification_opened": from_notification,
        "daily_streak": current_streak
    })
```

### Key Questions
- Do notifications increase returns?
- What's optimal notification frequency?
- Which notification types get opens?
- Are players annoyed? (settings changes)

## Ethical Guidelines

### Do
- Provide genuine value
- Respect player's time choices
- Make opt-out easy and permanent
- Send at appropriate times
- Celebrate achievements

### Don't
- Create artificial urgency
- Guilt trip for not playing
- Send when nothing valuable
- Ignore quiet hours
- Make disabling difficult

## Implementation Priority

### MVP
- [ ] Basic daily reward (no notifications)
- [ ] Session welcome summary

### v1.0
- [ ] Push notification system
- [ ] Daily reward notifications
- [ ] Achievement notifications
- [ ] Notification settings

### v1.1+
- [ ] Weekly challenges
- [ ] Offline progress notifications
- [ ] Smart timing (learn player schedule)

## Questions to Resolve
- [ ] Daily rewards at MVP or v1.0?
- [ ] Offline progress system needed?
- [ ] How many notifications per week max?
- [ ] Battle pass / season system?
- [ ] A/B test notification copy?
