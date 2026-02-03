---
title: "research: Mobile battery optimization strategies for idle games"
status: closed
priority: 2
issue-type: research
created-at: "\"2026-02-02T22:25:29.214540-06:00\""
closed-at: "2026-02-02T22:37:47.275012-06:00"
close-reason: Completed research on mobile battery optimization. Documented frame rate strategies, GPU idle states, offline progress system, and Godot-specific implementation patterns.
---

## Research Question

How can idle/mining games optimize for battery efficiency? What are best practices for background states, GPU usage, and building player trust around battery consumption?

## Key Findings

### 1. Frame Rate is the Biggest Factor

**Core Principle:**
"The simplest and most effective thing for battery optimization is clamping the frame rate"

**Recommendations:**
- 60 FPS for active gameplay (smooth but not excessive)
- 30 FPS for idle states/menus
- Lower still for background/paused states
- "Setting maximum frame rate to 60 fps was enough to have smooth movement and animations while still not turning the phone into a heater"

**Impact:**
- 120 Hz vs 60 Hz: "31-44% more display power"
- "For turn-based, puzzle, or RPG games, locking refresh to 60 Hz saves 29% battery with zero gameplay impact"

### 2. Display is the Biggest Drain

**Display Power Facts:**
- "Display accounts for 48-62% of total power draw during active gaming"
- "More than CPU, GPU, and cellular combined"

**Optimization Levers:**
1. Refresh rate (biggest impact)
2. Brightness (obvious)
3. Color gamut (dark themes help OLED)
4. Pixel emission profile

### 3. GPU Idle States

**Key Insight:**
"The longer your CPU & GPU stay in idle for continuous periods of time, the more you can save in battery"

**VSync Benefits:**
- "VSync is forced on in Mobile"
- "Chips will spend more time in idle state"
- Don't fight it - use it

**Texture Optimization:**
- "Bandwidth is expensive in terms of power consumption"
- "Compressed textures, low bpp formats, and low res textures fit easier in cache"
- "Saves bandwidth and therefore, battery"

### 4. Idle Game Advantages

**Why Idle Games Are Battery-Friendly:**
- "Visual simplicity, real-time animations are more limited"
- "Frame rates are lower"
- "Consume less system resources"
- "Allow gameplay progress with minimal battery impact"

**Offline Progress Design:**
- "Continue to play out in background even when players are offline"
- "Calculate rewards based on most recent production rate"
- Zero battery use when app is closed

### 5. Background and System States

**Android Doze Mode:**
- "Device goes into Doze mode... system attempts to keep system in sleep state"
- "Periodically resume normal operations for brief periods"
- Design around this - don't fight it

**App Standby:**
- "System determines app is idle when user does not touch for certain period"
- "Disables network access and suspends syncs"
- Offline progress calculation handles this gracefully

### 6. Thermal Management

**Thermal Throttling:**
- "Devices forcibly lower CPU/GPU clock speeds to prevent overheating"
- "Causes dramatic performance drops"

**Prevention:**
- "Thermal-aware GPU scaling"
- Don't push maximum performance constantly
- Allow cooling periods

**Measurable Results:**
- "30-55% fewer frame drops"
- "28-42% longer play sessions"
- "2.1x longer battery lifespan"

### 7. Godot-Specific Considerations

**Godot Philosophy:**
- "Designed to prioritize balance and flexibility over raw performance"
- "Default settings are pretty solid, but not always best fit for mobile"
- Must optimize specifically for mobile

**Key Optimizations:**
- Use sprite sheets over procedural animations
- Batch draw calls (combine meshes with same material)
- Minimize texture fetches
- Use compressed textures

## Application to GoDig

### Frame Rate Strategy

| State | Target FPS | Reason |
|-------|------------|--------|
| Active mining | 60 | Smooth responsive digging |
| Surface/shop | 45 | Less action, save power |
| Inventory/menus | 30 | Static content |
| Paused | 15 | Minimal updates |
| Backgrounded | 0 | Calculate offline progress |

### Godot Implementation

```gdscript
# Frame rate management
func _on_state_changed(new_state: GameState) -> void:
    match new_state:
        GameState.MINING:
            Engine.max_fps = 60
        GameState.SURFACE:
            Engine.max_fps = 45
        GameState.MENU:
            Engine.max_fps = 30
        GameState.PAUSED:
            Engine.max_fps = 15

# Background notification handling
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_APPLICATION_PAUSED:
            _save_timestamp_for_offline_progress()
            Engine.max_fps = 0
        NOTIFICATION_APPLICATION_RESUMED:
            _calculate_offline_rewards()
            Engine.max_fps = 60
```

### Offline Progress System

**When App Closes:**
1. Save current timestamp
2. Save production rates (ore/min, coin/min)
3. Save resource quantities

**When App Opens:**
1. Calculate elapsed time
2. Apply production rates to time
3. Cap at reasonable maximum (e.g., 8 hours)
4. Show "Welcome back!" with rewards

**Benefits:**
- Zero battery drain while closed
- Progress feels continuous
- Players trust the app won't drain battery

### GPU Optimization Checklist

**Textures:**
- [x] Use compressed formats (ETC2 for Android, ASTC)
- [x] Use sprite sheets for animations
- [x] Use texture atlases for UI
- [x] Limit texture sizes (256x256 for tiles)

**Draw Calls:**
- [x] Batch similar sprites
- [x] Use MultiMesh for repeated elements
- [x] Minimize material changes
- [x] Use single atlas for common elements

**Rendering:**
- [x] Avoid post-processing effects on mobile
- [x] Limit particle systems
- [x] Use simple shaders
- [x] Avoid real-time shadows

### Display Optimization

**Dark Theme Benefits:**
- OLED screens save power with dark pixels
- Underground theme naturally dark
- Surface can use sunset/night modes
- Settings for brightness preference

**Color Considerations:**
- Dark backgrounds use less power
- Bright UI elements limited to important info
- Glow effects used sparingly

### Battery Settings Option

**Player-Facing Options:**
```
Battery Saver Mode:
  [x] Reduce visual effects
  [x] Limit frame rate to 30
  [x] Disable particle effects
  [x] Use static backgrounds
```

**Why This Builds Trust:**
- Players see we care about battery
- Gives control to player
- Transparent about trade-offs

### Testing and Monitoring

**Tools:**
- GameBench for profiling
- Android Studio profiler
- Xcode Instruments

**Metrics to Track:**
- Average FPS
- Battery drain rate (mA)
- Thermal state
- Session length vs battery %

### Implementation Recommendations

### Phase 1 (v1.0): Essential
- Frame rate capping by state
- Offline progress calculation
- Compressed textures
- Sprite batching

### Phase 2 (v1.1): Enhanced
- Battery saver mode option
- Adaptive quality based on thermal state
- Display optimization for dark underground

### Phase 3 (v1.2+): Advanced
- Per-device optimization profiles
- Predictive thermal management
- Battery usage analytics

## Design Principles

1. **Idle Games Have Advantage** - Lean into low-power design
2. **Frame Rate = Battery** - Lower is better when acceptable
3. **Dark Theme = Power Savings** - Underground theme helps
4. **Offline Progress = Zero Drain** - Calculate, don't simulate
5. **Player Control** - Battery saver option builds trust
6. **Test on Real Devices** - Simulators don't show battery impact

## Sources

- [Battery Optimization Challenges in Mobile Game Development - MyNnovation](https://www.mynnovation.com/2025/12/08/battery-optimization-challenges-in-mobile-game-development/)
- [On Games' Power Consumption and Phones - Yosoygames](https://www.yosoygames.com.ar/wp/2018/06/on-games-power-consumption-and-phones/)
- [Simple Battery-life Optimization for Mobile Games - ModDB](https://www.moddb.com/tutorials/simple-battery-life-and-energy-optimization-for-mobile-games-using-unity)
- [Mastering Godot Mobile Game Performance 2025 - Howik](https://howik.com/godot-mobile-game-performance)
- [Optimizing Android Game Performance - DEV Community](https://dev.to/krishanvijay/optimizing-android-game-performance-memory-gpu-battery-strategies-26pe)
- [Idle Game Background Progress - Godot Forum](https://forum.godotengine.org/t/idle-game-background-progress/105645)
- [Passive Resource Systems in Idle Games - Adrian Crook](https://adriancrook.com/passive-resource-systems-in-idle-games/)

## Status

Research complete. Provides foundation for battery optimization implementation and offline progress system.
