# Tutorial & Onboarding Research

## Sources
- [Mobile Game Onboarding Best Practices](https://www.gamedeveloper.com/design/mobile-onboarding-best-practices)
- [First Time User Experience (FTUE)](https://www.deconstructoroffun.com/blog/ftue-analysis)
- [Progressive Disclosure in Games](https://www.nngroup.com/articles/progressive-disclosure/)

## Core Principles

### 1. Show, Don't Tell
- Avoid walls of text
- Let players learn by doing
- Use visual cues over written instructions
- Context-sensitive hints only

### 2. Progressive Disclosure
- Introduce one mechanic at a time
- Don't overwhelm new players
- Gate complexity behind progress
- Each new thing builds on previous

### 3. Safe Failure Space
- Early game should be forgiving
- No permanent failure states in tutorial
- Let players experiment without punishment
- Reserve challenge for post-tutorial

### 4. Quick to Fun
- First "fun moment" within 30 seconds
- First meaningful choice within 2 minutes
- Tutorial complete within 5 minutes
- Player feels competent before complexity

## Tutorial Sequence

### Phase 1: Movement (0-30 seconds)
**Goal**: Player moves around comfortably

**Implementation**:
```
[Visual: Arrow keys / joystick indicator on screen]
"Move around using the joystick"

[Trigger]: Player moves 10 tiles
[Result]: "Great!" indicator, move to Phase 2
```

**Key Points**:
- Non-blocking prompt
- Auto-dismiss on success
- No text beyond one line

### Phase 2: Digging (30 seconds - 1 minute)
**Goal**: Player understands how to dig

**Setup**: Player starts on surface with obvious dirt below

**Implementation**:
```
[Visual: Pulsing highlight on dirt tiles below player]
[Visual: Dig button/tap indicator]
"Dig down by [action]"

[Trigger]: Player digs 3 blocks
[Result]: First ore discovered (guaranteed copper spawn)
```

**Key Points**:
- Guaranteed reward placement
- Immediate positive feedback
- "You found copper!" popup

### Phase 3: Collection & Inventory (1-2 minutes)
**Goal**: Player understands pickup and inventory

**Implementation**:
```
[Visual: Inventory icon pulses when item picked up]
"Resources go to your inventory"
"Dig more to fill your pockets!"

[Trigger]: Collect 5 items
[Result]: Inventory slot fills up visibly
```

### Phase 4: Returning to Surface (2-3 minutes)
**Goal**: Player learns to navigate back up

**Setup**: Player is ~10 blocks deep

**Implementation**:
```
[Visual: Arrow pointing up toward surface]
"Return to surface to sell your finds"
[Optional hint after 10 seconds]: "Jump and climb walls to get back up"

[Trigger]: Player reaches surface
[Result]: Shop indicator appears
```

**Key Points**:
- Let player figure out wall-jump naturally
- Only give climbing hint if stuck
- Surface has visual beacon

### Phase 5: Selling & Economy (3-4 minutes)
**Goal**: Player completes the core loop

**Implementation**:
```
[Visual: Shop building highlighted]
"Enter the shop to sell resources"

[In shop]:
"Tap resources to sell them"
[Auto-sell first time? Or let player tap?]

[Result]: Coins awarded, satisfying ka-ching!
"You earned 50 coins!"
```

### Phase 6: First Upgrade (4-5 minutes)
**Goal**: Player experiences progression

**Implementation**:
```
[If player has enough coins]:
"Visit the blacksmith to upgrade your pickaxe"

[In blacksmith]:
"Upgrades make mining faster"
[Highlight upgrade button]

[Result]: Upgrade purchased
"Your pickaxe is stronger now!"
```

### Phase 7: Tutorial Complete
```
"You're ready to dig deeper!"
"Find rare gems, build your mining empire!"
[One-time reward: 100 bonus coins]
[Tutorial flag set, never shows again]
```

## Tutorial UI Elements

### Non-Intrusive Prompts
```gdscript
# tutorial_prompt.gd
extends Control

@export var message: String
@export var auto_dismiss_time: float = 5.0
@export var dismiss_on_action: String = ""

func show_prompt(msg: String):
    $Label.text = msg
    $AnimationPlayer.play("fade_in")

    if auto_dismiss_time > 0:
        await get_tree().create_timer(auto_dismiss_time).timeout
        dismiss()

func _input(event):
    if dismiss_on_action and event.is_action_pressed(dismiss_on_action):
        dismiss()
```

### Highlighting System
```gdscript
# highlight_manager.gd
func highlight_node(node: Node2D, color: Color = Color.YELLOW):
    var highlight = HighlightEffect.new()
    highlight.target = node
    highlight.color = color
    add_child(highlight)
    return highlight

func highlight_ui(control: Control):
    var pulse = UIPulseEffect.new()
    control.add_child(pulse)
```

### Progress Indicators
```
Tutorial Progress: [====------] 4/10
Skip Tutorial? [X]
```

## Skip Tutorial Option

### When to Offer
- After Phase 1 (movement)
- Always visible but unobtrusive
- Confirmation dialog: "Are you sure? Tutorial rewards will be skipped"

### Skip Handling
```gdscript
func skip_tutorial():
    GameManager.tutorial_complete = true
    GameManager.save_game()
    # Don't give tutorial rewards
    # But don't penalize either
    emit_signal("tutorial_skipped")
```

## Returning Players

### Smart Detection
```gdscript
func _ready():
    if SaveManager.has_save():
        # Returning player - skip tutorial
        tutorial_enabled = false
    else:
        # New player - run tutorial
        tutorial_enabled = true
```

### Soft Reminders
For returning players after long absence:
```
[Subtle toast notification]
"Welcome back! Need a refresher? [Tap here]"
```

## Context-Sensitive Hints

### Hint Triggers
| Situation | Hint |
|-----------|------|
| Player stuck in hole for 10s | "Try jumping off walls!" |
| Inventory full, still mining | "Return to surface to sell!" |
| Has coins, hasn't upgraded | "Visit the blacksmith!" |
| Deep but no ladder | "Ladders help you climb!" |
| Low health, far from surface | "Find healing items in shops" |

### Hint Implementation
```gdscript
# hint_system.gd
var hint_cooldown: Dictionary = {}
const HINT_COOLDOWN_TIME = 60.0  # Don't spam hints

func maybe_show_hint(hint_id: String, message: String):
    var now = Time.get_ticks_msec() / 1000.0
    if hint_id in hint_cooldown:
        if now - hint_cooldown[hint_id] < HINT_COOLDOWN_TIME:
            return

    hint_cooldown[hint_id] = now
    show_hint(message)

func _on_player_stuck_in_hole(duration: float):
    if duration > 10.0:
        maybe_show_hint("wall_jump", "Jump against walls to climb!")
```

### Disable Hints Option
```
Settings > Gameplay > Show hints: [ON/OFF]
```

## First Session Goals

### Checklist for First 5 Minutes
- [ ] Player has moved
- [ ] Player has dug blocks
- [ ] Player has collected resources
- [ ] Player has returned to surface
- [ ] Player has sold resources
- [ ] Player has made first purchase

### Soft Targets
- First ore: Within 10 seconds of digging
- First gem: Within 3 minutes
- First upgrade: Within 5 minutes
- Reach depth 50m: Within 10 minutes

## Onboarding Analytics

### Track These Events
```gdscript
func track_tutorial_event(event_name: String, data: Dictionary = {}):
    Analytics.log_event("tutorial_" + event_name, data)

# Example events:
track_tutorial_event("started")
track_tutorial_event("phase_complete", {"phase": 1})
track_tutorial_event("hint_shown", {"hint": "wall_jump"})
track_tutorial_event("skipped", {"at_phase": 3})
track_tutorial_event("completed", {"time_seconds": 240})
```

### Analyze Drop-off Points
- Where do players quit during tutorial?
- Which hints are most shown?
- What's the average tutorial completion time?

## Questions to Resolve
- [ ] Mandatory tutorial or always skippable?
- [ ] Text prompts or fully visual?
- [ ] Tutorial rewards (coins, items)?
- [ ] Repeatable tutorial from settings?
- [ ] Hint frequency and intrusiveness?
