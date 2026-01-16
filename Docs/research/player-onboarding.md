# Player Onboarding & Tutorial Design

## Onboarding Philosophy

### Principles
1. **Show, don't tell** - Demonstrate through gameplay, not walls of text
2. **Teach through play** - Learn by doing, not reading
3. **One concept at a time** - Don't overwhelm with information
4. **Let players skip** - Veterans should be able to skip tutorials
5. **Make failure safe** - Early mistakes shouldn't be punishing

### Mobile-Specific Considerations
- Players often in distracted environments
- Touch controls need demonstration
- Sessions may be interrupted anytime
- Progress should save constantly

## First-Time User Experience (FTUE)

### Immediate Start
No lengthy intro screens. Get player into gameplay within 30 seconds.

```
App Launch
    ↓
Logo splash (2 sec max)
    ↓
"Tap to Start"
    ↓
Game begins with contextual tutorial
```

### First 60 Seconds

**0-10 seconds**: Player spawns at mine entrance
```
Prompt: "Tap to enter the mine" (arrow pointing down)
```

**10-30 seconds**: First dig
```
Prompt: "Use joystick to move. Tap a block to dig."
[Wait for player to break first block]
Celebration: "Great! You found some dirt."
```

**30-60 seconds**: Collect first resource
```
[Player breaks block containing coal]
Prompt: "You found Coal! Resources are added to your inventory."
[Show inventory icon with +1 animation]
```

### First 5 Minutes

**Learning Movement**
- Natural level design guides player downward
- Soft dirt only (easy to break)
- Can't get stuck in first area

**Learning Collection**
- Multiple easy ores in first 20 blocks
- Inventory fills up (8 slots)
- "Inventory Full! Return to surface to sell."

**Learning Economy**
- Guide player back to surface
- "Enter the General Store to sell resources"
- Walk through sell interface
- "You earned 150 coins!"

**First Upgrade**
- "Visit the Blacksmith to upgrade your pickaxe"
- Show upgrade interface
- "Upgrade complete! Dig faster now."

### Tutorial Gating

#### Soft Gates (Recommended)
- Prompts appear but can be dismissed
- Player can explore freely
- Hints available if stuck

#### Hard Gates (Avoid)
- Forced to complete tutorial steps
- Blocks progression until learned
- Feels restrictive

## Contextual Hints System

### Dynamic Hints
Show hints based on player behavior, not scripted sequence.

```gdscript
# hint_manager.gd
var hints_shown = {}

func check_hints():
    # Show dig hint if player hasn't dug after 10 seconds
    if not hints_shown.get("dig") and player.blocks_broken == 0:
        if player.time_underground > 10.0:
            show_hint("dig", "Tap on a block to dig!")

    # Show return hint if inventory is full
    if not hints_shown.get("return") and inventory.is_full():
        show_hint("return", "Inventory full! Go up to sell.")

    # Show shop hint if near shop and hasn't entered
    if not hints_shown.get("shop") and player.near_shop:
        if not player.has_entered_shop:
            show_hint("shop", "Enter the shop to sell resources!")
```

### Hint Categories

**Movement Hints**
- "Use the joystick to move"
- "Tap a block to dig it"
- "Swipe up to jump" (if using gestures)
- "You can wall-jump off walls!"

**Resource Hints**
- "Gold ores are more valuable!"
- "Different layers have different ores"
- "Gems are rare but worth a lot"

**Progression Hints**
- "Upgrade your pickaxe at the Blacksmith"
- "New depth record!" (when reaching milestones)
- "A new shop has appeared!" (when unlocking)

**Warning Hints**
- "Can't dig up... yet!"
- "Careful! You're getting deep."
- "Inventory almost full!"

## Visual Indicators

### Highlighting
- Pulse glow on interactive elements
- Arrow pointing to next objective
- Particle trail leading to goal

### UI Indicators
```
┌──────────────────────────┐
│ [Joystick] - Move        │
│ [Tap Block] - Dig        │
│ [Jump Button] - Jump     │
└──────────────────────────┘
```

### Control Overlay
First-time: Show semi-transparent control hints on screen
After first session: Remove hints

## Tutorial Progression

### Phase 1: Core Loop (First Session)
- Move
- Dig
- Collect
- Return to surface
- Sell
- Buy upgrade

### Phase 2: Exploration (Second Session)
- Discover new layer
- Find rarer ore
- Unlock new shop

### Phase 3: Mastery (Ongoing)
- Wall-jumping
- Ladder placement
- Tool switching
- Optimal routes

## Skip Tutorial Option

### For Returning Players
```
"Welcome back, miner! Would you like to:"
[Continue from save]
[Start new game (skip tutorial)]
[Start new game (with tutorial)]
```

### For Veterans
- Detect if controls used correctly in first 30 seconds
- If player breaks 5+ blocks without prompt, skip basic tutorial
- Assume competence until proven otherwise

## Tutorial Pacing

### Avoid Information Overload
```
Bad:  "Move with joystick, dig by tapping, collect resources,
      watch your inventory, return to sell, upgrade at blacksmith,
      unlock new shops, dig deeper for better rewards..."

Good: "Tap a block to dig it."
      [Wait for action]
      "Great! Keep digging to find treasures."
```

### Spacing
- One concept per dig session
- Let player practice before introducing next concept
- Maximum 3 hints per minute

## Measuring Tutorial Success

### Metrics to Track
- Time to complete first dig
- Time to complete first sell
- Drop-off points (where do players quit?)
- Hint dismissal rate
- Tutorial skip rate

### Success Indicators
- Player breaks 10+ blocks in first session
- Player completes sell cycle
- Player returns for second session
- Player upgrades tool

### Failure Indicators
- Player quits before first dig
- Player confused at shop
- Multiple hints dismissed without action
- No return after first session

## Handling Confusion

### Stuck Detection
```gdscript
func _process(delta):
    if player.is_underground and not player.moved_recently(30.0):
        # Player hasn't moved in 30 seconds
        offer_help("Need help? Tap here for tips!")
```

### Help Button
- Always accessible in pause menu
- "How to Play" section
- Control reference
- FAQ

### Recovery
- "Stuck? Tap here to return to surface" (emergency escape)
- No penalty for using in tutorial area

## Questions to Resolve
- [ ] Skip tutorial by default for returning players?
- [ ] How many hints before "help" prompt?
- [ ] Tutorial area vs main world?
- [ ] Achievement for completing tutorial?
- [ ] Voice-over or text-only?

## Implementation Checklist

### MVP
1. Basic joystick + tap-to-dig hints
2. Inventory full prompt
3. Shop interaction guide
4. First upgrade prompt
5. Skip option for repeat plays

### v1.0
1. Contextual hint system
2. Stuck detection
3. Tutorial metrics tracking
4. Control reference in pause menu
5. Visual highlighting

### v1.1+
1. Adaptive tutorial (detect skill level)
2. Achievement-gated tips
3. Coach character?
4. Video demonstrations?
