# Quality of Life Features Checklist

## Purpose
A comprehensive checklist of QoL features that make the game more enjoyable and reduce friction.

## MVP QoL Features

### Controls & Input
- [x] Virtual joystick with adjustable position
- [x] Tap-to-dig on mobile
- [ ] Auto-dig when holding button
- [ ] Dig direction indicator
- [ ] Input buffering for responsive feel

### Inventory Management
- [ ] Auto-pickup nearby items
- [ ] Stack similar items automatically
- [ ] Quick-sell button (sell all common)
- [ ] Sort inventory button
- [ ] Inventory full warning before it's full

### Navigation & Orientation
- [ ] Depth indicator always visible
- [ ] Direction to surface indicator
- [ ] Mini-map (toggleable)
- [ ] "Return to surface" quick travel (consumable)

### Information Display
- [ ] Ore value on hover/long-press
- [ ] Tool effectiveness on current block
- [ ] Break time indicator
- [ ] Running total of inventory value

## v1.0 QoL Features

### Advanced Controls
- [ ] Swipe gestures for movement
- [ ] Double-tap to jump
- [ ] Control customization menu
- [ ] Sensitivity sliders

### Inventory QoL
- [ ] Auto-sell when entering shop (optional)
- [ ] Favorite items (don't auto-sell)
- [ ] Inventory value preview
- [ ] "Sell all" with confirmation

### Visual Aids
- [ ] Highlight diggable vs undiggable blocks
- [ ] Show ore spawn indicators at depth thresholds
- [ ] Player trail (see where you came from)
- [ ] Block hardness color coding

### Convenience Features
- [ ] Quick restart from main menu
- [ ] Skip animations option
- [ ] Speed up text option
- [ ] Remember last shop tab

## v1.1+ QoL Features

### Automation
- [ ] Auto-climb ladders when near
- [ ] Auto-wall-jump option
- [ ] Idle mining while offline
- [ ] Resource processing queue

### Advanced Navigation
- [ ] Placeable waypoints
- [ ] Teleport to waypoint
- [ ] Path highlighting
- [ ] Saved locations

### Statistics & Tracking
- [ ] Session statistics summary
- [ ] Total play time
- [ ] Resources collected lifetime
- [ ] Depth records

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
