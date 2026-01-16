# Quality of Life Features Checklist

## Purpose
A comprehensive checklist of QoL features that make the game more enjoyable and reduce friction.

## MVP QoL Features

### Controls & Input
- [x] Virtual joystick with adjustable position
- [x] Tap-to-dig on mobile
- [x] MVP: Auto-dig when holding button
- [x] MVP: Dig direction indicator
- [x] MVP: Input buffering for responsive feel

### Inventory Management
- [x] MVP: Auto-pickup nearby items
- [x] MVP: Stack similar items automatically
- [x] MVP: Quick-sell button (sell all common)
- [x] v1.0: Sort inventory button
- [x] MVP: Inventory full warning before it's full

### Navigation & Orientation
- [x] MVP: Depth indicator always visible
- [x] v1.0: Direction to surface indicator
- [x] v1.0: Mini-map (toggleable)
- [x] v1.0: "Return to surface" quick travel (consumable)

### Information Display
- [x] v1.0: Ore value on hover/long-press
- [x] v1.0: Tool effectiveness on current block
- [x] v1.0: Break time indicator
- [x] v1.0: Running total of inventory value

## v1.0 QoL Features

### Advanced Controls
- [x] v1.0: Swipe gestures for movement
- [x] v1.0: Double-tap to jump
- [x] v1.0: Control customization menu
- [x] v1.0: Sensitivity sliders

### Inventory QoL
- [x] v1.0: Auto-sell when entering shop (optional)
- [x] v1.0: Favorite items (don't auto-sell)
- [x] v1.0: Inventory value preview
- [x] v1.0: "Sell all" with confirmation

### Visual Aids
- [x] MVP: Highlight diggable vs undiggable blocks
- [x] v1.0: Show ore spawn indicators at depth thresholds
- [x] v1.0: Player trail (see where you came from)
- [x] v1.0: Block hardness color coding

### Convenience Features
- [x] v1.0: Quick restart from main menu
- [x] v1.0: Skip animations option
- [x] v1.0: Speed up text option
- [x] v1.0: Remember last shop tab

## v1.1+ QoL Features

### Automation
- [x] v1.1+: Auto-climb ladders when near
- [x] v1.1+: Auto-wall-jump option
- [x] v1.1+: Idle mining while offline
- [x] v1.1+: Resource processing queue

### Advanced Navigation
- [x] v1.1+: Placeable waypoints
- [x] v1.1+: Teleport to waypoint
- [x] v1.1+: Path highlighting
- [x] v1.1+: Saved locations

### Statistics & Tracking
- [x] v1.0: Session statistics summary
- [x] v1.0: Total play time
- [x] v1.0: Resources collected lifetime
- [x] MVP: Depth records

## Implementation Priority

### Must Have (Annoying Without)
1. Auto-pickup
2. Depth indicator
3. Inventory full warning
4. Quick-sell button

### Should Have (Nice Touch)
1. Sort inventory
2. Direction indicator
3. Break time display
4. Stack automatically

### Nice to Have (Polish)
1. Mini-map
2. Player trail
3. Swipe gestures
4. Auto-sell option

## Mobile-Specific QoL

### Touch Optimization
- Large touch targets (44px+)
- No accidental taps (edge padding)
- Confirm dialogs for destructive actions
- Shake to undo (optional)

### Battery Considerations
- Low power mode (reduce effects)
- Background pause
- Quick suspend/resume

### Screen Size Adaptation
- UI scales with screen
- Portrait and landscape support
- Safe area handling (notch, etc.)

## Settings That Improve QoL

```
GAMEPLAY
├─ Auto-pickup items: [ON/OFF]
├─ Auto-sell commons: [ON/OFF]
├─ Show break time: [ON/OFF]
└─ Confirm before sell: [ON/OFF]

CONTROLS
├─ Joystick position: [Left/Right]
├─ Joystick size: [Small/Medium/Large]
├─ Tap sensitivity: [Slider]
└─ Hold to dig: [ON/OFF]

DISPLAY
├─ Show mini-map: [ON/OFF]
├─ Show player trail: [ON/OFF]
├─ Depth indicator: [Always/Mining/Off]
└─ UI scale: [Slider 80-120%]

PERFORMANCE
├─ Reduce particles: [ON/OFF]
├─ Disable screen shake: [ON/OFF]
└─ Battery saver mode: [ON/OFF]
```

## Questions Resolved
- [x] Auto-pickup at MVP? → Yes, essential QoL
- [x] Mini-map at MVP? → No, v1.0 feature
- [x] Swipe controls at MVP? → No, v1.0 feature
