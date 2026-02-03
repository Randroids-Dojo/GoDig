# Battery and Thermal Management for Mobile Game Optimization

## Executive Summary

Mobile game energy efficiency is a critical player experience factor. This research examines platform APIs, frame rate trade-offs, and adaptive quality strategies. The key insight: **proactive thermal management beats reactive throttling**. Games should monitor thermal state and reduce workload before the system forces throttling, maintaining consistent (if reduced) performance rather than dramatic drops.

## Platform APIs

### Apple iOS Game Mode

**Automatic Activation:**
- Turns on automatically when launching games
- Gives highest priority access to CPU/GPU
- Lowers usage for background tasks
- Reduces Bluetooth latency for controllers and AirPods

**Developer Implementation:**
```xml
<!-- Info.plist -->
<key>LSSupportsGameMode</key>
<true/>
```

**iOS 26+ Enhancements:**
- New thermal APIs for proactive throttling detection
- MetalFX for higher fidelity without thermal cost
- Better sustained performance curves

**Apple's Thermal Philosophy:**
> "Apple's thermal design prioritizes sustained performance over peak bursts: the A17 Pro throttles GPU clocks earlier but maintains tighter voltage regulation, yielding flatter FPS curves under load."

### Android Dynamic Performance Framework (ADPF)

**Thermal API (Android 11+):**
```kotlin
// Poll thermal headroom
val thermalManager = getSystemService(ThermalService::class.java)
val headroom = thermalManager.getThermalHeadroom(forecastSeconds)

// headroom < 1.0 = safe
// headroom > 1.0 = risk of throttling
if (headroom > 0.8) {
    reduceGraphicsQuality()
}
```

**Performance Hint API (Android 12+):**
- Tell system about workload requirements
- System optimizes CPU scheduling
- Better sustained performance

**Sustained Performance Mode:**
> "When using sustained mode, the device can, for example, render consistently at 45 FPS for the entire 30 minutes" vs degrading from 60 to 30 over time.

**Real-World Results (Lineage W):**
- FPS standard deviation dropped 25%
- Stable 60 FPS with thermal headroom < 1.0
- Longer play sessions without throttling

### Android 15 Changes

- Default 60Hz refresh for games (power optimization)
- Must explicitly request higher rates via Frame Rate API
- System can override based on battery/thermal state

## Frame Rate vs Battery Trade-offs

### Power Consumption by Frame Rate

| FPS Target | Power Draw | Use Case |
|------------|------------|----------|
| 30 FPS | Baseline (12-18% battery/hr) | Casual, puzzle, story |
| 60 FPS | 1.5-2x baseline | Standard gaming |
| 90 FPS | 2-2.5x baseline | Competitive |
| 120 FPS | 2.5-3x baseline | Twitch shooters |

**Key Finding:**
> "90 FPS burns 40-60% more power than 60 FPS"

### Dynamic Frame Rate Switching

**Implementation:**
```gdscript
func adjust_frame_rate_for_conditions() -> void:
    var thermal_state = get_thermal_state()
    var battery_level = OS.get_power_percent_left()

    if thermal_state > 0.8 or battery_level < 20:
        Engine.max_fps = 30
    elif thermal_state > 0.5 or battery_level < 40:
        Engine.max_fps = 45
    else:
        Engine.max_fps = 60
```

**Player Communication:**
When reducing frame rate, show brief notification:
- "Optimizing for battery life"
- "Cooling down device"

### 2D Games vs 3D Games

For 2D games like GoDig:
- 60 FPS is sufficient for smooth animation
- 30 FPS acceptable during low-action moments (menus, shops)
- No need for 90/120 FPS modes
- Focus on consistent frame pacing over peak FPS

## Thermal Management Strategies

### Proactive vs Reactive

**Reactive (Bad):**
1. Game runs at max settings
2. Device heats up
3. System throttles CPU/GPU
4. FPS drops suddenly (60 → 30)
5. Player notices stuttering

**Proactive (Good):**
1. Game monitors thermal headroom
2. When headroom drops to 80%, reduce workload
3. Maintain smooth 50 FPS
4. Device stays cool
5. Player experiences consistent performance

### Quality Reduction Priority

When reducing workload for thermal reasons:

| Priority | What to Reduce | Player Impact |
|----------|----------------|---------------|
| 1 | Particle effects | Low - decorative |
| 2 | Animation frame rate | Low - subtle |
| 3 | Shadow quality | Medium |
| 4 | Texture resolution | Medium |
| 5 | Frame rate cap | High - noticeable |

**Principle:** Reduce decorative elements before core game visuals.

### Physical Considerations

External factors affecting thermal performance:
- Device cases trap heat
- Warm environments accelerate throttling
- Charging while playing adds heat
- Direct sunlight on device

## Godot 4 Specific Optimizations

### Rendering

**Draw Call Reduction:**
- Batch similar objects together
- Use texture atlases
- Limit unique materials

**Texture Optimization:**
- Use ETC compression for Android
- Generate mipmaps
- Size textures appropriately (don't use 4K for small sprites)

**Shader Efficiency:**
- Avoid complex fragment shaders
- Pre-compute expensive calculations
- Use simpler alternatives when possible

### Battery-Specific Techniques

**Background State:**
```gdscript
func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_PAUSED:
        # Game backgrounded - reduce to minimal
        Engine.max_fps = 10
        set_process(false)
    elif what == NOTIFICATION_APPLICATION_RESUMED:
        # Game foregrounded - restore settings
        Engine.max_fps = 60
        set_process(true)
```

**Idle Detection:**
```gdscript
var idle_time: float = 0.0

func _process(delta: float) -> void:
    if Input.is_anything_pressed():
        idle_time = 0.0
        Engine.max_fps = 60
    else:
        idle_time += delta
        if idle_time > 5.0:
            # Player idle, reduce power
            Engine.max_fps = 30
```

### Culling and LOD

```gdscript
# Use VisibilityNotifier2D for automatic culling
func _on_visibility_notifier_screen_exited() -> void:
    set_process(false)

func _on_visibility_notifier_screen_entered() -> void:
    set_process(true)
```

## Player Settings Design

### Battery/Performance Mode Toggle

**UI Options:**
- **Performance Mode:** Target 60 FPS, higher quality
- **Balanced Mode:** Target 45 FPS, medium quality (default)
- **Battery Saver:** Target 30 FPS, lower quality

**Implementation:**
```gdscript
enum PerformanceMode { PERFORMANCE, BALANCED, BATTERY_SAVER }

func apply_performance_mode(mode: PerformanceMode) -> void:
    match mode:
        PerformanceMode.PERFORMANCE:
            Engine.max_fps = 60
            RenderingServer.viewport_set_msaa_2d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_4X)
            particle_amount_ratio = 1.0

        PerformanceMode.BALANCED:
            Engine.max_fps = 45
            RenderingServer.viewport_set_msaa_2d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_2X)
            particle_amount_ratio = 0.5

        PerformanceMode.BATTERY_SAVER:
            Engine.max_fps = 30
            RenderingServer.viewport_set_msaa_2d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)
            particle_amount_ratio = 0.25
```

### Automatic Mode Switching

Optionally offer "Auto" mode that adjusts based on:
- Battery level (< 20% → battery saver)
- Thermal state (high heat → reduce quality)
- Charging state (plugged in → performance mode)

```gdscript
func auto_adjust_mode() -> void:
    var battery = OS.get_power_percent_left()
    var charging = OS.get_power_state() == OS.POWERSTATE_CHARGING

    if charging:
        apply_performance_mode(PerformanceMode.PERFORMANCE)
    elif battery < 20:
        apply_performance_mode(PerformanceMode.BATTERY_SAVER)
    elif battery < 50:
        apply_performance_mode(PerformanceMode.BALANCED)
    else:
        apply_performance_mode(PerformanceMode.PERFORMANCE)
```

## Profiling and Testing

### Tools

**Godot Built-in:**
- Profiler for CPU/GPU time
- Remote Debugger for on-device testing
- Monitor for real-time stats

**Platform Tools:**
- Xcode Instruments (iOS)
- Android Profiler
- GPU profilers

### Testing Checklist

| Test | Target |
|------|--------|
| 30 min sustained play | No throttling |
| Full battery to 10% | Graceful degradation |
| Charging while playing | No overheating |
| Hot environment (30°C+) | Playable performance |
| Background/foreground cycle | Proper state transitions |

### Battery Consumption Targets

For a 2D mining game like GoDig:

| Condition | Target Battery/Hour |
|-----------|---------------------|
| Active mining | 10-15% |
| Surface/shop | 5-8% |
| Backgrounded | < 1% |
| Idle (5 min) | 3-5% |

## Implementation Recommendations for GoDig

### Phase 1: Foundation

1. **Set reasonable frame cap**
   - 60 FPS max for active gameplay
   - 30 FPS for menus/shops
   - 10 FPS when backgrounded

2. **Reduce background processing**
   - Pause world simulation when backgrounded
   - Stop particle effects
   - Disable off-screen updates

3. **Add performance settings**
   - Simple toggle: Performance / Battery Saver
   - Default to Battery Saver on mobile

### Phase 2: Adaptive Quality

1. **Monitor thermal state**
   - Poll system thermal APIs
   - Reduce quality before throttling

2. **Dynamic particle reduction**
   - Mining particles scale with thermal headroom
   - Celebration effects optional

3. **Idle detection**
   - Reduce FPS when player inactive
   - Resume on input

### Phase 3: Platform Integration

1. **iOS Game Mode**
   - Enable via Info.plist
   - Test on real devices

2. **Android ADPF**
   - Implement thermal monitoring
   - Use Performance Hints API

## Anti-Patterns to Avoid

| Don't | Why |
|-------|-----|
| Always run at max FPS | Drains battery, causes throttling |
| Ignore thermal warnings | Results in sudden FPS drops |
| Process in background | Wastes battery when not visible |
| Complex shaders for 2D | Unnecessary GPU load |
| Skip real device testing | Emulators don't show thermal behavior |

## Sources

- [iOS 26 for Gamers: Apple's New Gaming-Focused Update](https://fryosstudios.com/ios-26-for-gamers-everything-you-need-to-know-about-apples-new-gaming-focused-update-in-2025/)
- [Mobile Gaming Optimization 2025](https://exscape.com/mobile-gaming-optimization-2025-the-complete-performance-guide-for-android-and-ios/)
- [Optimize thermal and CPU performance with ADPF](https://developer.android.com/games/optimize/adpf)
- [Thermal API - Android Developers](https://developer.android.com/games/optimize/adpf/thermal)
- [Lineage W ADPF Case Study](https://developer.android.com/stories/games/lineagew-adpf)
- [Optimize refresh rates - Android Developers](https://developer.android.com/games/optimize/display-refresh-rate-change)
- [Optimize power efficiency - Android Developers](https://developer.android.com/games/optimize/power)
- [Battery Optimization Challenges in Mobile Game Development](https://www.mynnovation.com/2025/12/08/battery-optimization-challenges-in-mobile-game-development/)
- [Enhancing Performance for Mobile Games in Godot](https://www.sharpcoderblog.com/blog/enhancing-performance-for-mobile-games-in-godot)
- [General optimization tips - Godot Documentation](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html)
- [Mastering Godot Mobile Game Performance in 2025](https://howik.com/godot-mobile-game-performance)

## Research Session

- **Date:** 2026-02-02
- **Focus:** Mobile game energy efficiency and thermal management
- **Key Insight:** Proactive thermal management beats reactive throttling - reduce workload before system forces it
