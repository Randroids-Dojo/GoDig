# Accessibility Features Research

## Sources
- [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/)
- [Xbox Accessibility Guidelines](https://docs.microsoft.com/en-us/gaming/accessibility/)
- [Mobile Game Accessibility](https://developer.apple.com/accessibility/)

## Why Accessibility Matters

### Player Reach
- 15-20% of players have some form of disability
- Accessible games reach wider audience
- Many accessibility features benefit all players
- Required for some app store features

### Categories of Accessibility
1. **Visual** - Color blindness, low vision
2. **Motor** - Limited mobility, one-handed play
3. **Cognitive** - Reading difficulties, memory
4. **Audio** - Deaf/hard of hearing

## Visual Accessibility

### Colorblind Modes
Affect ~8% of male players, ~0.5% of female players

**Types to Support**
- Deuteranopia (red-green, most common)
- Protanopia (red-green)
- Tritanopia (blue-yellow, rare)

**Implementation**
```gdscript
# colorblind_filter.gd
extends ColorRect

enum ColorblindMode {NONE, DEUTERANOPIA, PROTANOPIA, TRITANOPIA}

var current_mode: ColorblindMode = ColorblindMode.NONE

const SHADERS = {
    ColorblindMode.DEUTERANOPIA: preload("res://shaders/deuteranopia.gdshader"),
    ColorblindMode.PROTANOPIA: preload("res://shaders/protanopia.gdshader"),
    ColorblindMode.TRITANOPIA: preload("res://shaders/tritanopia.gdshader"),
}

func set_mode(mode: ColorblindMode):
    current_mode = mode
    if mode == ColorblindMode.NONE:
        material = null
    else:
        material = ShaderMaterial.new()
        material.shader = SHADERS[mode]
```

**Design Solution: Shape + Color**
Don't rely on color alone:
```
Ore Types:
- Coal: Black + SQUARE shape
- Copper: Orange + CIRCLE shape
- Iron: Gray + TRIANGLE shape
- Gold: Yellow + STAR shape
- Diamond: Blue + DIAMOND shape
```

### High Contrast Mode
```gdscript
# high_contrast.gd
func enable_high_contrast():
    # Increase UI contrast
    $UI.modulate = Color(1.2, 1.2, 1.2, 1.0)
    
    # Add borders to interactive elements
    for button in get_tree().get_nodes_in_group("buttons"):
        button.add_theme_stylebox_override("normal", high_contrast_style)
```

### Text Scaling
```gdscript
# text_settings.gd
var text_scale: float = 1.0  # 0.8 to 1.5

func apply_text_scale():
    var base_size = 16
    var scaled_size = int(base_size * text_scale)
    
    for label in get_tree().get_nodes_in_group("scalable_text"):
        label.add_theme_font_size_override("font_size", scaled_size)
```

**Font Recommendations**
- Sans-serif fonts (easier to read)
- Minimum 16px at default
- High contrast text/background
- Avoid all-caps for body text

### Screen Reader Support
```gdscript
# accessibility_narrator.gd
func announce(text: String, priority: int = 0):
    if OS.has_feature("accessibility"):
        # Platform-specific TTS
        DisplayServer.tts_speak(text, priority)
```

## Motor Accessibility

### One-Handed Play Mode
```
Default Layout:
[Joystick LEFT]    [Buttons RIGHT]

One-Hand Mode (Right):
                   [Joystick]
                   [Jump] [Dig]

One-Hand Mode (Left):
[Joystick]
[Jump] [Dig]
```

### Touch Target Sizes
```gdscript
# Minimum touch target: 44x44 points (Apple guideline)
# Recommended: 48x48 points

const MIN_TOUCH_SIZE = Vector2(48, 48)

func _ready():
    for button in get_tree().get_nodes_in_group("touch_buttons"):
        if button.size < MIN_TOUCH_SIZE:
            button.custom_minimum_size = MIN_TOUCH_SIZE
```

### Auto-Actions
```gdscript
# Reduce required inputs
var auto_collect: bool = true  # Pick up items automatically
var auto_climb: bool = false   # Auto-climb ladders when near
var auto_sell: bool = false    # Sell when inventory full

func _on_item_nearby(item):
    if auto_collect:
        collect_item(item)
```

### Hold vs Tap Options
```gdscript
# Some players can't hold buttons
var dig_mode: String = "hold"  # "hold" or "toggle"

func _process(delta):
    match dig_mode:
        "hold":
            is_digging = Input.is_action_pressed("dig")
        "toggle":
            if Input.is_action_just_pressed("dig"):
                is_digging = !is_digging
```

### Adjustable Timing
```gdscript
# For time-sensitive actions
var reaction_time_multiplier: float = 1.0  # 0.5 to 2.0

func get_adjusted_time(base_time: float) -> float:
    return base_time * reaction_time_multiplier
```

## Cognitive Accessibility

### Clear UI Design
- Consistent button placement
- Clear iconography with labels
- Avoid information overload
- Tutorial can be re-accessed

### Reading Assistance
```gdscript
# Dyslexia-friendly options
var use_dyslexia_font: bool = false
var increase_line_spacing: bool = false
var reduce_text_motion: bool = false

func apply_reading_settings():
    if use_dyslexia_font:
        # OpenDyslexic or similar
        theme.default_font = dyslexia_font
    
    if increase_line_spacing:
        # 1.5x line height
        for label in text_labels:
            label.add_theme_constant_override("line_spacing", 8)
```

### Simplified Mode
```gdscript
# Reduce complexity for cognitive accessibility
var simplified_mode: bool = false

func apply_simplified_mode():
    if simplified_mode:
        # Hide secondary stats
        $UI/DetailedStats.visible = false
        # Larger, clearer buttons
        $UI/Buttons.scale = Vector2(1.2, 1.2)
        # Fewer simultaneous notifications
        max_notifications = 1
```

### Memory Aids
```gdscript
# Help players remember goals
func show_current_objective():
    $ObjectiveReminder.text = "Current Goal: Reach depth 100m"
    $ObjectiveReminder.visible = true

# Persistent hints
var show_control_hints: bool = true
```

## Audio Accessibility

### Visual Sound Indicators
```gdscript
# Show visual cues for important sounds
func play_sound_with_visual(sound: AudioStream, visual_type: String):
    audio_player.play(sound)
    
    if Settings.visual_sound_cues:
        match visual_type:
            "danger":
                flash_screen_border(Color.RED)
            "pickup":
                show_icon_popup("pickup")
            "achievement":
                show_confetti_effect()
```

### Subtitle System
```gdscript
# Subtitles for important audio
func play_with_subtitle(sound: AudioStream, text: String):
    audio_player.play(sound)
    
    if Settings.subtitles_enabled:
        show_subtitle(text)
        await get_tree().create_timer(sound.get_length()).timeout
        hide_subtitle()
```

### Haptic Feedback Alternative
```gdscript
# Replace audio cues with vibration
func notify_player(type: String):
    match type:
        "rare_find":
            if Settings.audio_enabled:
                play_sound("rare_find")
            if Settings.haptics_enabled:
                Input.vibrate_handheld(100)
            if Settings.visual_cues:
                flash_screen(Color.GOLD)
```

## Settings Menu Structure

```
┌─────────────────────────────────────┐
│  ACCESSIBILITY SETTINGS             │
├─────────────────────────────────────┤
│  VISUAL                             │
│  ├─ Colorblind Mode: [Dropdown]     │
│  ├─ High Contrast: [Toggle]         │
│  ├─ Text Size: [Slider 80-150%]     │
│  └─ Screen Flash: [Toggle]          │
│                                     │
│  CONTROLS                           │
│  ├─ One-Hand Mode: [Left/Right/Off] │
│  ├─ Button Size: [Slider]           │
│  ├─ Dig Mode: [Hold/Toggle]         │
│  └─ Auto-Collect: [Toggle]          │
│                                     │
│  AUDIO                              │
│  ├─ Visual Sound Cues: [Toggle]     │
│  ├─ Subtitles: [Toggle]             │
│  └─ Haptic Feedback: [Toggle]       │
│                                     │
│  GAMEPLAY                           │
│  ├─ Simplified UI: [Toggle]         │
│  ├─ Objective Reminder: [Toggle]    │
│  └─ Timing Assist: [Slider]         │
└─────────────────────────────────────┘
```

## Implementation Priority

### MVP (Must Have)
- [ ] Colorblind-safe ore shapes
- [ ] Scalable text
- [ ] One-handed control option
- [ ] Touch target minimum sizes
- [ ] Pause anytime

### v1.0 (Should Have)
- [ ] Full colorblind mode filters
- [ ] High contrast mode
- [ ] Hold/toggle options
- [ ] Visual sound cues
- [ ] Auto-collect option

### v1.1+ (Nice to Have)
- [ ] Screen reader support
- [ ] Dyslexia font option
- [ ] Full subtitle system
- [ ] Custom control remapping
- [ ] Cognitive assist mode

## Testing Checklist

### Before Release
- [ ] Test with colorblind simulator
- [ ] Test with screen reader
- [ ] Test one-handed on device
- [ ] Test with text at max size
- [ ] Verify all info conveyed multiple ways
- [ ] Get feedback from disabled players

## Questions to Resolve
- [ ] Which colorblind modes to prioritize?
- [ ] Custom control remapping at launch?
- [ ] How much to invest in screen reader support?
- [ ] Separate "Easy Mode" or integrated accessibility?
- [ ] Which accessibility features are MVP?
