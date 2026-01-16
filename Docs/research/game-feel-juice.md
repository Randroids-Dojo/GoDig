# Game Feel & Juice Research

## Sources
- [Game Feel: The Secret Ingredient (GDC)](https://www.youtube.com/watch?v=216_5nu4aVQ)
- [The Art of Screen Shake (Vlambeer)](https://www.youtube.com/watch?v=AJdEqssNZ-U)
- [Juice It or Lose It (GDC Talk)](https://www.youtube.com/watch?v=Fy0aCDmgnxg)

## What is "Juice"?

"Juice" is the collection of small visual, audio, and haptic feedback elements that make a game feel satisfying. A juicy game feels responsive, impactful, and alive.

**Key Principle**: Every action should have a reaction. Players should feel the weight and consequence of their inputs.

## Core Juice Elements for GoDig

### 1. Screen Shake

**When to Shake**
| Event | Shake Intensity | Duration |
|-------|-----------------|----------|
| Block break (soft) | 1-2px | 0.05s |
| Block break (hard) | 3-5px | 0.1s |
| Ore discovered | 2-3px | 0.1s |
| Rare gem found | 4-6px | 0.15s |
| Fall damage | 5-10px | 0.2s |
| Explosion | 8-15px | 0.3s |

**Implementation**
```gdscript
# camera_effects.gd
extends Camera2D

var shake_intensity: float = 0
var shake_decay: float = 5.0

func shake(intensity: float, duration: float = 0.1):
    shake_intensity = intensity
    # Reset after duration
    await get_tree().create_timer(duration).timeout
    shake_intensity = 0

func _process(delta):
    if shake_intensity > 0:
        offset = Vector2(
            randf_range(-shake_intensity, shake_intensity),
            randf_range(-shake_intensity, shake_intensity)
        )
        shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
    else:
        offset = Vector2.ZERO
```

### 2. Particle Effects

**Block Break Particles**
```gdscript
# block_break_particles.gd
extends GPUParticles2D

@export var block_color: Color = Color.BROWN

func burst(pos: Vector2, color: Color):
    position = pos
    process_material.color = color
    emitting = true
```

**Particle Configurations**
| Effect | Particle Count | Lifetime | Spread |
|--------|----------------|----------|--------|
| Dirt break | 8-12 | 0.3s | 45deg |
| Stone break | 6-10 | 0.4s | 60deg |
| Ore pickup | 5-8 | 0.5s | 360deg |
| Gem pickup | 10-15 | 0.8s | 360deg |
| Footstep dust | 3-5 | 0.2s | 30deg |
| Landing dust | 8-12 | 0.3s | 180deg |

### 3. Hit Pause / Freeze Frame

**The "Hitstop" Effect**
Brief pause on impact makes hits feel powerful.

```gdscript
# game_manager.gd
func hit_pause(duration: float = 0.03):
    # Freeze the game briefly
    get_tree().paused = true
    await get_tree().create_timer(duration).timeout
    get_tree().paused = false
```

**When to Use Hit Pause**
- Breaking hard blocks: 0.02s
- Mining ore: 0.03s
- Finding rare gem: 0.05s
- Taking damage: 0.05s

### 4. Squash and Stretch

**Player Animation Principles**
```gdscript
# player_visuals.gd

func on_jump():
    # Squash before jump
    tween_scale(Vector2(1.2, 0.8), 0.05)
    # Stretch during rise
    await get_tree().create_timer(0.05).timeout
    tween_scale(Vector2(0.8, 1.2), 0.1)

func on_land():
    # Squash on landing
    tween_scale(Vector2(1.3, 0.7), 0.05)
    # Return to normal
    await get_tree().create_timer(0.05).timeout
    tween_scale(Vector2(1.0, 1.0), 0.1)

func tween_scale(target: Vector2, duration: float):
    var tween = create_tween()
    tween.tween_property($Sprite, "scale", target, duration)
```

### 5. Pickup Feedback

**Floating Numbers**
```gdscript
# floating_text.gd
extends Node2D

func show_value(value: String, color: Color = Color.WHITE):
    var label = Label.new()
    label.text = value
    label.add_theme_color_override("font_color", color)
    add_child(label)

    # Float up and fade
    var tween = create_tween()
    tween.parallel().tween_property(label, "position:y", -50, 0.8)
    tween.parallel().tween_property(label, "modulate:a", 0, 0.8)
    tween.tween_callback(label.queue_free)
```

**Pickup Trail**
Resources fly toward inventory icon:
```gdscript
func pickup_item(item_pos: Vector2, inventory_icon: Control):
    var sprite = create_flying_icon(item_pos)

    var target = inventory_icon.global_position
    var tween = create_tween()
    tween.tween_property(sprite, "global_position", target, 0.3)\
         .set_trans(Tween.TRANS_QUAD)\
         .set_ease(Tween.EASE_IN)
    tween.tween_callback(func():
        inventory_icon_bounce()
        sprite.queue_free()
    )
```

### 6. UI Bounce and Pop

**Button Press Feedback**
```gdscript
# ui_effects.gd
func button_bounce(button: Control):
    var tween = create_tween()
    tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.05)
    tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.05)
    tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.05)
```

**Number Counter Animation**
```gdscript
func animate_coin_counter(from: int, to: int, duration: float = 0.5):
    var tween = create_tween()
    tween.tween_method(
        func(val): coin_label.text = str(int(val)),
        from, to, duration
    )
```

### 7. Visual Feedback Flash

**Damage Flash**
```gdscript
# player.gd
func take_damage(amount: int):
    health -= amount

    # Flash red
    $Sprite.modulate = Color.RED
    await get_tree().create_timer(0.1).timeout
    $Sprite.modulate = Color.WHITE

    # Optional: brief invincibility frames
    start_invincibility(1.0)
```

**Pickup Flash**
```gdscript
func on_item_pickup():
    # Brief white flash overlay
    $FlashOverlay.modulate = Color.WHITE
    $FlashOverlay.visible = true
    await get_tree().create_timer(0.05).timeout
    $FlashOverlay.visible = false
```

### 8. Haptic Feedback (Mobile)

**Vibration Patterns**
```gdscript
# haptics.gd
func light_tap():
    if OS.has_feature("mobile"):
        Input.vibrate_handheld(10)  # 10ms

func medium_tap():
    if OS.has_feature("mobile"):
        Input.vibrate_handheld(25)

func heavy_impact():
    if OS.has_feature("mobile"):
        Input.vibrate_handheld(50)
```

**When to Vibrate**
| Event | Vibration |
|-------|-----------|
| Block break | Light (10ms) |
| Ore found | Medium (25ms) |
| Rare gem | Heavy (50ms) |
| Button press | Light (10ms) |
| Damage taken | Heavy pattern |

### 9. Sound Pitch Variation

**Prevent Repetitive Audio**
```gdscript
func play_dig_sound():
    var sfx = preload("res://assets/audio/dig.wav")
    var player = $AudioStreamPlayer

    # Randomize pitch slightly
    player.pitch_scale = randf_range(0.9, 1.1)

    # Randomize volume slightly
    player.volume_db = randf_range(-2, 0)

    player.stream = sfx
    player.play()
```

### 10. Environmental Motion

**Background Parallax**
```gdscript
# parallax_layer.gd
func _process(delta):
    # Slight drift/movement in background
    offset.x = sin(Time.get_ticks_msec() / 1000.0) * 5
```

**Ambient Particles**
- Floating dust motes
- Dripping water droplets
- Gem sparkles
- Torch ember particles

## Juice Budget for Mobile

### Performance Considerations
- Limit simultaneous particles (max 50)
- Pool particle systems, don't create new
- Disable shake on low-end devices
- Haptics optional (battery drain)

### Quality Settings
```gdscript
enum JuiceLevel {
    LOW,    # Minimal effects
    MEDIUM, # Some particles, no shake
    HIGH    # Full juice
}

var juice_level: JuiceLevel = JuiceLevel.HIGH

func shake(intensity: float):
    if juice_level >= JuiceLevel.HIGH:
        camera.shake(intensity)

func spawn_particles(pos: Vector2, count: int):
    if juice_level >= JuiceLevel.MEDIUM:
        particles.emit(pos, count)
```

## Checklist: Is Your Game Juicy?

### Every Action Has Feedback
- [ ] Digging has particles
- [ ] Pickups have visual + audio
- [ ] Jumps have squash/stretch
- [ ] Landings have dust
- [ ] UI buttons have bounce
- [ ] Numbers animate, don't snap

### Environmental Life
- [ ] Background has subtle motion
- [ ] Ambient particles exist
- [ ] Lights flicker naturally
- [ ] Water drips/flows

### Impact Feels Impactful
- [ ] Hard blocks shake more
- [ ] Rare finds feel special
- [ ] Damage is visceral
- [ ] Upgrades feel powerful

### Audio is Alive
- [ ] Pitch varies
- [ ] Volume varies
- [ ] Combo sounds chain
- [ ] Silence is intentional

## Questions to Resolve
- [ ] Screen shake intensity preference?
- [ ] Haptic feedback on/off default?
- [ ] Particle quality settings needed?
- [ ] Animation frame budget per entity?
- [ ] How "over the top" should juice be?
