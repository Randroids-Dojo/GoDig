# Analytics & Metrics Research

## Sources
- [Mobile Game Analytics Guide](https://gameanalytics.com/blog/mobile-game-analytics-guide/)
- [Key Mobile Game KPIs](https://www.adjust.com/glossary/mobile-game-kpis/)
- [Firebase for Games](https://firebase.google.com/docs/games)

## Why Analytics?

### Goals
1. **Understand players**: What do they enjoy/struggle with?
2. **Find problems**: Where do players quit?
3. **Improve retention**: What keeps players coming back?
4. **Balance economy**: Are prices right?
5. **Measure success**: Are we growing?

### Privacy-First Approach
- Anonymous by default
- No PII collected
- Clear opt-out option
- GDPR/CCPA compliant

## Key Metrics

### Acquisition Metrics
| Metric | Description | Target |
|--------|-------------|--------|
| Downloads | Total installs | Growth |
| DAU | Daily Active Users | Stability |
| MAU | Monthly Active Users | Growth |
| New Users | First-time players/day | Growth |

### Engagement Metrics
| Metric | Description | Target |
|--------|-------------|--------|
| Session Length | Avg play time | 10-15 min |
| Sessions/Day | How often they play | 2-3x |
| DAU/MAU | Stickiness ratio | >20% |
| D1/D7/D30 Retention | Return rate | 40%/20%/10% |

### Progression Metrics
| Metric | Description | Target |
|--------|-------------|--------|
| Max Depth Reached | How deep players go | Distribution |
| Tutorial Completion | Finish onboarding | >80% |
| First Purchase Time | Time to first upgrade | <10 min |
| Prestige Count | Long-term engagement | Distribution |

### Economy Metrics
| Metric | Description | Target |
|--------|-------------|--------|
| Coins Earned/Session | Income rate | Balanced |
| Coins Spent/Session | Spending rate | <Earned |
| Upgrade Distribution | Popular upgrades | Even spread |
| IAP Conversion | Buyers vs players | 2-5% |

## Event Tracking

### Core Events
```gdscript
# analytics_manager.gd
extends Node

func track_event(event_name: String, params: Dictionary = {}):
    if not analytics_enabled:
        return
    
    # Add common params
    params["user_id"] = get_anonymous_id()
    params["session_id"] = current_session_id
    params["timestamp"] = Time.get_unix_time_from_system()
    
    # Send to analytics service
    _send_event(event_name, params)
```

### Essential Events to Track

**Session Events:**
```gdscript
# Session start
track_event("session_start", {
    "platform": OS.get_name(),
    "version": ProjectSettings.get_setting("application/config/version"),
    "is_first_session": is_first_play
})

# Session end
track_event("session_end", {
    "duration_seconds": session_duration,
    "max_depth_reached": max_depth_this_session,
    "coins_earned": coins_earned_this_session
})
```

**Progression Events:**
```gdscript
# Tutorial progress
track_event("tutorial_step", {"step": step_number})
track_event("tutorial_complete", {"skip": was_skipped})

# Depth milestones
track_event("depth_milestone", {
    "depth": milestone_depth,
    "time_to_reach": time_seconds
})

# Prestige
track_event("prestige", {
    "prestige_number": count,
    "max_depth_before": max_depth,
    "total_playtime": total_seconds
})
```

**Economy Events:**
```gdscript
# Purchase
track_event("purchase", {
    "item_type": "tool",
    "item_id": "iron_pickaxe",
    "cost": 2000,
    "currency": "coins"
})

# Sell
track_event("sell", {
    "item_id": "coal",
    "quantity": 10,
    "value": 50
})

# IAP (if any)
track_event("iap_purchase", {
    "product_id": "remove_ads",
    "price_usd": 2.99,
    "success": true
})
```

**Engagement Events:**
```gdscript
# Feature usage
track_event("feature_used", {
    "feature": "quick_sell",
    "context": "shop"
})

# UI interaction
track_event("ui_tap", {
    "element": "upgrade_button",
    "screen": "blacksmith"
})
```

## Analytics Tools

### Option A: Firebase Analytics (Recommended)
**Pros:**
- Free tier generous
- Real-time dashboard
- Integrates with other Firebase services
- Cross-platform

**Cons:**
- Google dependency
- Learning curve

**Godot Integration:**
```gdscript
# Use Godot Firebase plugin
# https://github.com/GodotNuts/GodotFirebase

func _ready():
    Firebase.Analytics.log_event("game_start")
```

### Option B: GameAnalytics
**Pros:**
- Game-specific features
- Good free tier
- Heatmaps

**Cons:**
- Less flexible than Firebase

### Option C: Custom Backend
**Pros:**
- Full control
- No third-party dependency

**Cons:**
- Development time
- Hosting costs
- Security responsibility

### Recommendation
Start with **Firebase Analytics** - free, powerful, game-friendly.

## Dashboard Metrics

### Daily Dashboard
```
┌─────────────────────────────────────┐
│  GODIG ANALYTICS - TODAY            │
├─────────────────────────────────────┤
│  DAU: 1,234 (+5%)                   │
│  New Users: 156                     │
│  Avg Session: 12.3 min              │
│  Revenue: $45.67                    │
├─────────────────────────────────────┤
│  TOP EVENTS                         │
│  1. session_start: 2,456            │
│  2. dig_block: 89,234               │
│  3. purchase: 3,456                 │
│  4. depth_milestone: 234            │
└─────────────────────────────────────┘
```

### Funnel Analysis
```
Tutorial Funnel:
Start Tutorial:     100% (1000)
Move Character:     95%  (950)
First Dig:          90%  (900)
First Sell:         75%  (750)
First Upgrade:      60%  (600)
Complete Tutorial:  50%  (500)
```

### Retention Cohorts
```
         D1    D7    D30
Week 1   42%   18%   8%
Week 2   45%   20%   10%
Week 3   44%   22%   -
Week 4   48%   -     -
```

## Privacy Implementation

### Opt-In/Out
```gdscript
# settings_manager.gd
var analytics_enabled: bool = true  # Default on, but...

func show_analytics_consent():
    # Show on first launch
    var dialog = ConfirmationDialog.new()
    dialog.dialog_text = "Help improve GoDig by sharing anonymous play data?"
    dialog.connect("confirmed", _on_analytics_accepted)
    dialog.connect("cancelled", _on_analytics_declined)

func _on_analytics_declined():
    analytics_enabled = false
    AnalyticsManager.disable()
```

### What NOT to Collect
- Names, emails, phone numbers
- Precise location
- Device identifiers (use anonymous ID)
- Payment details (handled by platform)

## A/B Testing

### Use Cases
- Tutorial flow variations
- UI layout options
- Economy balance testing
- Notification timing

### Implementation
```gdscript
# ab_test_manager.gd
func get_variant(test_name: String) -> String:
    var user_hash = get_anonymous_id().hash()
    var variants = AB_TESTS[test_name]
    var index = user_hash % variants.size()
    return variants[index]

# Usage
var tutorial_variant = ABTestManager.get_variant("tutorial_style")
# Returns "short" or "detailed"
```

## Questions to Resolve
- [ ] Firebase or GameAnalytics?
- [ ] Analytics opt-in or opt-out default?
- [ ] How much event data to collect?
- [ ] Custom dashboard or use provider's?
- [ ] A/B testing at launch or later?
