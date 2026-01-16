# Screen Orientation Decision

## Overview
Should GoDig use portrait or landscape orientation for mobile? This affects UI layout, controls, and overall game feel.

## Option Analysis

### Option A: Portrait Mode

**Layout:**
```
┌─────────────────┐
│   [HUD TOP]     │
├─────────────────┤
│                 │
│                 │
│   GAME VIEW     │
│   (tall view)   │
│                 │
│                 │
├─────────────────┤
│   [CONTROLS]    │
│  [JOY]   [BTN]  │
└─────────────────┘
```

**Pros:**
- Natural phone holding position
- One-handed play possible
- More vertical view (see depth)
- Standard mobile game orientation
- Easy thumb reach for controls
- Good for mining (vertical movement)

**Cons:**
- Less horizontal view (surface buildings)
- Narrower game world visible
- May feel cramped for surface activities

**Games Using This:**
- Most mobile games
- Idle games
- Casual games

### Option B: Landscape Mode

**Layout:**
```
┌─────────────────────────────────────┐
│ [INV]              GAME VIEW  [MENU]│
│                   (wide view)       │
│ [JOY]                         [BTN] │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

**Pros:**
- More horizontal view (surface exploration)
- Feels more "game-like"
- Better for action-heavy games
- More screen real estate

**Cons:**
- Requires two-handed play
- Awkward for quick sessions
- Less vertical view (depth)
- Can't check notifications easily
- Poor for mining (vertical game)

**Games Using This:**
- Action games
- Racing games
- Traditional console ports

### Option C: Support Both (Adaptive)

**Pros:**
- Player choice
- Maximum flexibility
- Appeals to all preferences

**Cons:**
- Double the UI work
- Must balance both layouts
- Testing complexity
- May compromise both experiences

---

## Decision Factors

### Mining Game Nature
- **Primary movement is VERTICAL** (digging down)
- Portrait naturally shows more depth
- Underground exploration benefits from tall view
- Surface is secondary activity

### Mobile Usage Patterns
| Context | Preferred Orientation |
|---------|----------------------|
| Commuting | Portrait (one hand on rail) |
| Couch gaming | Either |
| Waiting in line | Portrait |
| Bathroom break | Portrait |
| Bed/lying down | Portrait |
| Dedicated session | Either |

**Result:** 70%+ mobile usage is portrait

### Control Comfort
- Portrait: Thumbs naturally reach controls at bottom
- Landscape: Harder to reach center of screen
- One-handed play only possible in portrait

### Competitor Analysis
| Game | Orientation | Type |
|------|-------------|------|
| SteamWorld Dig | Landscape | Console port |
| Motherload | Landscape | Desktop game |
| Most mobile miners | Portrait | Mobile-first |
| Mr Mine | Portrait | Idle miner |
| Idle Miner Tycoon | Portrait | Mobile |

---

## Recommendation: **Portrait Mode (Option A)**

### Rationale:

1. **Vertical gameplay matches vertical view**
   - Mining is primarily downward
   - Portrait shows 60% more depth at same zoom

2. **Mobile-first design**
   - One-handed play supported
   - Quick session friendly
   - Natural phone position

3. **Simpler development**
   - Single UI layout
   - Focused design decisions
   - Faster iteration

4. **Audience expectations**
   - Mobile gamers expect portrait for casual games
   - Genre convention for idle/mining games

### Surface Activity Accommodation:
- Horizontal scrolling for surface
- Camera follows building interaction
- Zoom out option when on surface
- Mini-map shows surface overview

---

## Implementation

### Godot Project Settings:
```
Display > Window > Handheld:
  - Orientation = portrait

Display > Window > Size:
  - Width = 720
  - Height = 1280
  - Test Width = 360
  - Test Height = 640

Display > Window > Stretch:
  - Mode = canvas_items
  - Aspect = keep_height
```

### Aspect Ratio Support:
| Device | Ratio | Notes |
|--------|-------|-------|
| iPhone SE | 16:9 | Narrow |
| iPhone 14 | 19.5:9 | Tall |
| Pixel 7 | 20:9 | Very tall |
| iPad | 4:3 | Wide |

### Adaptive UI for Ratios:
```gdscript
func _ready():
    var ratio = get_viewport().size.x / get_viewport().size.y

    if ratio > 0.6:  # Tablet-like
        # Wider layout, smaller controls
        controls.scale = Vector2(0.8, 0.8)
        hud.use_compact_mode()
    else:  # Phone
        # Standard layout
        controls.scale = Vector2(1.0, 1.0)
```

### Safe Areas:
```gdscript
func _ready():
    var safe_area = DisplayServer.get_display_safe_area()
    # Adjust HUD position for notches
    $HUD.position.y = safe_area.position.y
    $Controls.position.y = safe_area.end.y - control_height
```

---

## Layout Design

### Portrait UI Zones:
```
┌─────────────────────┐
│  [💰] [⚒️] [📦] [≡] │ ← Top HUD (coins, tool, inventory, menu)
├─────────────────────┤
│                     │
│                     │
│    GAME WORLD       │ ← Main viewport (majority of screen)
│   (Player + Tiles)  │
│                     │
│                     │
├─────────────────────┤
│  ┌───┐       ┌───┐  │
│  │ ⬤ │       │DIG│  │ ← Controls zone
│  │   │  [🪜] │JMP│  │    (joystick, quick-slot, buttons)
│  └───┘       └───┘  │
└─────────────────────┘
```

### Depth Indicator:
```
Right edge of screen:
│ ▲ Surface
│ │
│ │ Current: 247m
│ │
│ ▼ Depth
```

---

## Questions Resolved
- [x] Portrait or landscape? → **Portrait**
- [x] Support both? → **No** (focus on one)
- [x] Aspect ratio handling? → Adaptive UI with safe areas
- [x] Tablet support? → Scaled down controls, same orientation

---

## Summary

**Decision: Portrait orientation for mobile**

Portrait mode aligns with:
- Vertical nature of mining gameplay
- Mobile usage patterns (one-handed, quick sessions)
- Genre conventions for mobile mining games
- Development efficiency (single UI focus)

Surface horizontal exploration is accommodated through camera movement and optional zoom-out, but the primary experience optimizes for the digging-down core loop.
