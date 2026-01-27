# Mobile Touch Controls Research

## Sources
- [Virtual-Joystick-Godot](https://github.com/MarcoFazioRandom/Virtual-Joystick-Godot)
- [Godot Asset Library - Virtual Joystick](https://godotengine.org/asset-library/asset/1787)
- [Godot Touch Screen Joystick Tutorial](https://randommomentania.com/2018/08/godot-touch-screen-joystick-part-1/)
- [Godot Mobile Porting Tutorial](https://ramatak.com/2023/02/24/godot-tutorial-porting-your-games-controls-for-mobile-devices/)

## Control Schemes for Mining Game

### Option A: Virtual Joystick + Buttons (IMPLEMENTED)
```
┌─────────────────────────────────────┐
│                                     │
│              GAME VIEW              │
│                                 INV │
│                                     │
│  ┌───┐                       ┌───┐  │
│  │ ⬤ │ Move                 │JUMP│  │
│  │   │                       └───┘  │
│  └───┘                              │
└─────────────────────────────────────┘
```
**Note:** DIG button was removed as redundant - moving into blocks auto-mines,
and tap-to-dig allows tapping directly on adjacent blocks.

### Option B: Tap-to-Move/Dig
- Tap direction to move
- Tap block to dig
- Swipe up to jump
- Simpler, fewer on-screen elements

### Option C: Hybrid
- Left side: Virtual joystick for movement
- Right side: Tap on blocks to dig them
- Best of both worlds

## Virtual Joystick Implementation

### Recommended Asset
Use MarcoFazioRandom's Virtual Joystick from Asset Library.

### Node Structure (Current Implementation)
```
UI (CanvasLayer)
├── TouchControls (Control)
│   ├── VirtualJoystick (Control) - procedurally drawn
│   └── ActionButtons (Control)
│       ├── InventoryButton (TouchScreenButton)
│       └── JumpButton (TouchScreenButton)
```
**Note:** No DigButton - digging is automatic when moving into blocks,
or via tap-to-dig on adjacent blocks.

### Joystick Modes

**Fixed Mode**
- Joystick stays in fixed position
- Predictable, always visible
- Traditional console feel

**Dynamic Mode**
- Appears where player touches
- More natural for touch
- First touch sets center

**Following Mode**
- Joystick follows finger
- Prevents losing control zone
- Best for continuous input

### Integration Code
```gdscript
# Player.gd
@onready var joystick = $"../UI/VirtualJoystick"

func _physics_process(delta):
    var move_input: Vector2

    # Check for joystick input
    if joystick.is_pressed:
        move_input = joystick.output
    else:
        # Fallback to keyboard
        move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    velocity.x = move_input.x * speed

    # For mining game: up/down on ladder
    if is_climbing:
        velocity.y = move_input.y * climb_speed
```

### Dead Zone & Clamp
```gdscript
# Joystick settings
dead_zone = 0.2      # No output until 20% distance
clamp_zone = 1.0     # Max output at 100% distance
```

## TouchScreenButton for Actions

### Why TouchScreenButton?
- Supports multitouch (regular Button does not)
- Can map to input actions
- Designed for mobile

### Setup
```gdscript
# In Editor:
# - Add TouchScreenButton node
# - Set Texture Normal/Pressed
# - Set Action = "dig" (or "jump", etc.)

# Or via code:
func _on_dig_button_pressed():
    Input.action_press("dig")

func _on_dig_button_released():
    Input.action_release("dig")
```

### Button Layout (Implemented)
```
# For mining game:
# Left side: Movement joystick (procedurally drawn)
# Right side (stacked vertically):
#   - Inventory button (100x64, top)
#   - Jump button (100x100, bottom - wall-jump mechanic)
#
# Digging: Automatic when moving into blocks OR tap adjacent blocks
```

## Tap-to-Interact System

### For Block Selection
```gdscript
# Detect which block player tapped
func _input(event):
    if event is InputEventScreenTouch and event.pressed:
        var tap_pos = event.position
        var world_pos = get_global_mouse_position()
        var tile_pos = tilemap.local_to_map(world_pos)

        if is_adjacent_to_player(tile_pos):
            dig_tile(tile_pos)
```

### Adjacency Check
```gdscript
func is_adjacent_to_player(tile_pos: Vector2i) -> bool:
    var player_tile = tilemap.local_to_map(player.position)
    var distance = (tile_pos - player_tile).abs()
    # Can only dig adjacent tiles
    return distance.x <= 1 and distance.y <= 1
```

## Gesture Support

### Swipe Detection
```gdscript
var swipe_start: Vector2
var swipe_threshold = 50

func _input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            swipe_start = event.position
        else:
            var swipe = event.position - swipe_start
            if swipe.length() > swipe_threshold:
                _handle_swipe(swipe.normalized())

func _handle_swipe(direction: Vector2):
    if direction.y < -0.7:
        jump()  # Swipe up = jump
    elif direction.y > 0.7:
        place_ladder()  # Swipe down = place ladder
```

## UI Considerations

### Screen Regions
```
┌─────────────┬─────────────┐
│   Movement  │   Action    │
│    Zone     │    Zone     │
│             │             │
│  Joystick   │  Tap/Dig    │
│   Input     │   Input     │
└─────────────┴─────────────┘
```

### Visibility Modes
- **Always**: Buttons always visible
- **Touchscreen Only**: Hide on desktop
- **When Touched**: Appear on first touch

### Auto-Detect Platform
```gdscript
func _ready():
    var is_mobile = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")

    if is_mobile:
        show_touch_controls()
    else:
        hide_touch_controls()
```

## Implemented Approach for GoDig

### Primary Controls (Current)
1. **Left Virtual Joystick**: Movement (walk left/right, down to dig)
2. **Auto-Mine**: Moving into blocks automatically mines them
3. **Tap-to-Dig**: Tap directly on adjacent blocks to mine
4. **Jump Button**: Right side, 100x100 (for wall-jump mechanic)
5. **Inventory Button**: Above jump button, 100x64

### Why No Dig Button?
The DIG button was removed because:
- Moving the joystick into a block auto-mines it
- Tap-to-dig allows targeting specific blocks
- Having both made the DIG button redundant
- Simpler UI = better mobile UX

### Context-Sensitive Actions
- Near shop: Show "Enter" button
- On ladder: Joystick controls climb
- Holding ladder item: Show "Place" button

### Accessibility
- Adjustable button size
- Opacity slider for controls
- Option to swap left/right handed

## Questions to Resolve
- [x] Virtual joystick position (fixed vs dynamic?) → Fixed position, left side
- [x] Tap-to-dig or button-to-dig? → Both options available
- [x] Gesture support (swipe to jump?) → v1.0 option, not MVP
- [x] Button size for different screen sizes → Auto-scale based on screen DPI
- [x] Landscape vs portrait orientation → Portrait mode
