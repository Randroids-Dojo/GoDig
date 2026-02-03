# Mobile Haptic Design: Deep Dive

## Overview

This document provides comprehensive guidance on haptic feedback implementation for GoDig, focusing on when vibration enhances gameplay versus when it becomes annoying, with detailed platform-specific considerations and accessibility requirements.

## Sources

- [Apple Core Haptics Documentation](https://developer.apple.com/documentation/corehaptics/)
- [Apple Human Interface Guidelines: Playing Haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
- [Android Haptics Design Principles](https://developer.android.com/develop/ui/views/haptics/haptics-principles)
- [WWDC 2021: Practice Audio Haptic Design](https://developer.apple.com/videos/play/wwdc2021/10278/)
- [WWDC 2019: Designing Audio-Haptic Experiences](https://developer.apple.com/videos/play/wwdc2019/810/)
- [2025 Guide to Haptics - Saropa](https://saropa-contacts.medium.com/2025-guide-to-haptics-enhancing-mobile-ux-with-tactile-feedback-676dd5937774)
- [Mobile Gaming UX Haptic Feedback - Interhaptics](https://interhaptics.medium.com/mobile-gaming-ux-how-haptic-feedback-can-change-the-game-3ef689f889bc)
- [Older Adults Haptic Preferences Study - JMIR](https://games.jmir.org/2025/1/e73135)
- [W3C Haptics Accessibility Workshop](https://www.w3.org/2023/07/breakout_haptics_TPAC/haptics.pdf)
- [Enhancing UI/UX Accessibility with Haptic Feedback - Algoworks](https://www.algoworks.com/blog/haptic-feedback-in-ui-ux-design/)

## Apple's Three Guiding Principles

Apple's Core Haptics team defines three core principles that should guide all haptic design:

### 1. Causality
For feedback to be useful, it must be obvious what caused it. The player should never wonder "why did my phone vibrate?" In mining games, this means:
- Vibrate when the block breaks, not during the swing
- Vibrate on ore discovery, not on every scan tick
- Vibrate on achievement unlock, not on progress increment

### 2. Harmony
"Our senses work best when they are coherent, consistent, and working together." Haptics should match visual and audio cues:
- Small ore = light tap, soft sound, small particle effect
- Large ore = heavy thump, deep sound, large particle burst
- Rare discovery = distinctive pattern that matches the visual celebration

### 3. Utility
"Don't add feedback just because you can." Haptics should provide clear value:
- Confirm actions the player needs confirmation for
- Signal important events that might be missed visually
- Create memorable moments worth celebrating
- DO NOT decorate every interaction with unnecessary buzz

## When Haptics Enhance vs Annoy

### Enhancement Zone (Add Haptics)

| Scenario | Why It Works | Recommended Pattern |
|----------|--------------|---------------------|
| **Rare ore discovery** | High emotional value, deserves celebration | Rich sequence, 0.7-0.9 intensity |
| **Achievement unlock** | Milestone moment, reinforces accomplishment | Success pattern, 0.6 intensity |
| **Block break completion** | Confirms action, satisfying impact | Light transient, 0.2-0.3 intensity |
| **Danger warning** | Urgent attention needed | Distinct warning pattern, 0.5 intensity |
| **Tool upgrade** | Significant investment, deserves feedback | Medium transient, 0.5 intensity |
| **Sell transaction** | Confirms financial action completed | Soft success, 0.4 intensity |

### Annoyance Zone (Avoid Haptics)

| Scenario | Why It Fails | Alternative |
|----------|--------------|-------------|
| **Every mining hit** | Too frequent (2-3 per second), numbing | Only on break completion |
| **Every footstep** | Constant background noise, distracting | No haptic feedback |
| **Every coin pickup** | Rapid collection creates buzz storm | Visual/audio only |
| **Scrolling UI** | Standard system behavior, unnecessary | Use system defaults |
| **Background notifications** | Player isn't actively engaged | Silent or visual only |
| **Menu navigation** | Low stakes, wastes haptic "budget" | Optional system click |

### Gray Zone (Context-Dependent)

| Scenario | When to Include | When to Skip |
|----------|-----------------|--------------|
| **Item pickup** | Single valuable item | Bulk collection |
| **Ladder placement** | First few placements | Rapid ladder spam |
| **Depth milestones** | Major milestones (100m, 500m) | Every 10m |
| **Damage taken** | First hit or critical | Continuous damage |

## Player Preference Research

### Key Findings from Studies

**Older Adults Study (2025, n=250)**
- 63.2% preferred "slight" haptic feedback
- Strong preference for customizable intensity
- Unanimous appreciation for ability to disable
- Takeaway: Default to lighter feedback, allow adjustment

**Mobile Gaming UX Research**
- Players report "haptic fatigue" after 10+ minutes of continuous feedback
- Peak satisfaction at 3-7 haptic events per minute during active play
- Discovery/reward haptics rated most valuable
- Combat feedback rated second
- UI haptics rated lowest value

**Cross-Platform Study**
- iOS users expect higher quality haptics (Taptic Engine standard)
- Android users more tolerant of simple vibration patterns
- All users value ability to disable
- 18% of surveyed gamers play with haptics disabled

## Frequency Guidelines

### Maximum Haptic Rates

| Context | Max Events/Second | Max Events/Minute |
|---------|-------------------|-------------------|
| **Combat/Action** | 2 | 30 |
| **Exploration** | 1 | 10 |
| **Menu/UI** | 0.5 | 5 |
| **Idle/Background** | 0 | 0 |

### Minimum Spacing Between Events

| Priority Level | Minimum Gap |
|----------------|-------------|
| **Critical** (achievement, rare ore) | 100ms |
| **Important** (block break, sell) | 200ms |
| **Minor** (UI feedback) | 300ms |

### Event Priority System

When multiple haptic-worthy events occur simultaneously, use priority queuing:

```
Priority 1 (Highest): Achievement/Milestone
Priority 2: Rare ore discovery
Priority 3: Common ore discovery
Priority 4: Block break
Priority 5: UI actions
Priority 6 (Lowest): Ambient events (skip these)
```

Higher priority events cancel lower priority queued events.

## iOS Taptic Engine Deep Dive

### Hardware Capabilities

The Taptic Engine (iPhone 8+) provides:
- **Frequency range**: 80-230 Hz
- **Transient events**: Single-cycle momentary feedback (10-50ms)
- **Continuous events**: Sustained texture feedback (avoid for mining)
- **Intensity control**: 0.0 to 1.0 scale
- **Sharpness control**: 0.0 (soft/dull) to 1.0 (crisp/defined)

### Core Haptics Event Types

**Transient Events (Recommended for GoDig)**
```
Event Type: HapticTransient
Use For: Mining hits, discoveries, confirmations
Parameters: Intensity (0-1), Sharpness (0-1)
Duration: Automatic (single cycle)
```

**Continuous Events (Use Sparingly)**
```
Event Type: HapticContinuous
Use For: Danger warning sustained buzz
Parameters: Intensity, Sharpness, Duration
Warning: Can feel "buzzy" if misused
```

### Recommended Patterns for GoDig

**Ore Discovery Pattern (by rarity):**
```swift
// Common: Single soft tap
[HapticTransient(intensity: 0.3, sharpness: 0.5)]

// Uncommon: Medium tap
[HapticTransient(intensity: 0.5, sharpness: 0.6)]

// Rare: Double tap
[HapticTransient(intensity: 0.6, sharpness: 0.7),
 delay(100ms),
 HapticTransient(intensity: 0.5, sharpness: 0.7)]

// Epic: Triple ascending
[HapticTransient(intensity: 0.5, sharpness: 0.7),
 delay(80ms),
 HapticTransient(intensity: 0.6, sharpness: 0.8),
 delay(80ms),
 HapticTransient(intensity: 0.7, sharpness: 0.9)]

// Legendary: Signature pattern
[HapticTransient(intensity: 0.7, sharpness: 0.9),
 delay(100ms),
 HapticTransient(intensity: 0.5, sharpness: 0.7),
 delay(150ms),
 HapticTransient(intensity: 0.9, sharpness: 1.0)]
```

### Audio-Haptic Synchronization

Apple recommends pairing haptics with synchronized audio:
- Haptic and audio should trigger within 10ms of each other
- Audio attack should match haptic onset
- Creates "multimodal" feedback that feels more real
- Core Haptics supports AHAP (Apple Haptic Audio Pattern) files

## Android Considerations

### Device Fragmentation Challenge

Unlike iOS, Android haptic capabilities vary dramatically:
- **Flagship phones**: LRA actuators with HD haptics
- **Mid-range**: Basic ERM motors with limited patterns
- **Budget devices**: On/off vibration only

### Recommended API Approach

```java
// Use HapticFeedbackConstants for cross-device consistency
view.performHapticFeedback(HapticFeedbackConstants.CONFIRM)

// Use VibrationEffect for custom patterns (API 26+)
// But test extensively on multiple devices
VibrationEffect.createOneShot(10, 128) // duration, amplitude

// Avoid deprecated vibrate() calls
// (Still works but may feel inconsistent)
```

### Graceful Degradation Strategy

| Device Class | Haptic Approach |
|--------------|-----------------|
| **HD Haptics** | Full custom patterns |
| **Basic LRA** | Simplified patterns (fewer events) |
| **ERM Only** | Binary on/off, minimal use |
| **No Vibration** | Disable haptics entirely |

### Detection Pattern

```gdscript
# Check for vibration support
if OS.has_feature("mobile"):
    var vibrator_available = Input.vibrate_handheld(-1) # Test vibrate
    if vibrator_available:
        # Enable haptic features
        haptics_enabled = true
```

## Accessibility Design

### Who Benefits from Haptics

| User Group | Benefit | Design Consideration |
|------------|---------|---------------------|
| **Visual impairments** | Primary feedback channel | Ensure distinct patterns |
| **Hearing impairments** | Alternative to audio cues | Pair critical audio with haptics |
| **Motor impairments** | Confirms action success | Predictable, consistent feedback |
| **Cognitive differences** | Reduces ambiguity | Clear, simple patterns |

### Who May Be Harmed

| User Group | Risk | Mitigation |
|------------|------|------------|
| **Sensory processing disorders** | Overwhelming stimulation | Easy disable, intensity slider |
| **Touch sensitivity** | Physical discomfort | Low-intensity defaults |
| **PTSD (some cases)** | Startling vibrations | No sudden intense haptics |
| **Vestibular disorders** | Potential dizziness trigger | User control essential |

### Required Accessibility Settings

**Must Have:**
```
Settings > Accessibility > Haptics
├── Haptic Feedback: [On / Off]
├── Intensity: [Slider 0-100%]
└── Advanced
    ├── Discovery Haptics: [On / Off]
    ├── Achievement Haptics: [On / Off]
    └── UI Haptics: [On / Off]
```

**Should Have:**
- Respect system-wide accessibility settings
- Remember preferences across sessions
- Apply changes immediately (no restart required)

### WCAG Considerations

While WCAG doesn't directly address haptics, core principles apply:
- **Perceivable**: Haptics supplement, don't replace, visual/audio
- **Operable**: No action should require haptic perception
- **Understandable**: Consistent patterns users can learn
- **Robust**: Works across devices, graceful degradation

## Battery Impact Analysis

### Research Summary

Studies by Immersion Corp. found minimal battery impact from haptics:
- Even aggressive usage: only 0.95-4.11% of device battery
- Racing game with continuous engine haptics: 1-2% additional drain
- Audio playback actually consumes more power than haptics

### Best Practices for Power

1. **Prefer transient over continuous**: Single taps use less power
2. **No background haptics**: Only trigger during active gameplay
3. **Consider device state**: Reduce haptics at low battery (optional)
4. **Batch similar events**: Don't queue redundant haptics

### When Battery Matters

For a mining game with 15-30 minute sessions:
- Expected haptic battery impact: <1% per session
- User-perceived impact: Negligible
- Recommendation: Don't sacrifice UX for battery concerns

## Implementation Architecture

### Centralized Haptic Service

```gdscript
# haptic_manager.gd (Autoload)
extends Node

enum HapticType { LIGHT, MEDIUM, HEAVY, SUCCESS, WARNING }
enum HapticPriority { LOW = 1, MEDIUM = 2, HIGH = 3, CRITICAL = 4 }

var _enabled: bool = true
var _intensity: float = 1.0
var _last_haptic_time: int = 0
const MIN_HAPTIC_INTERVAL_MS = 100

signal haptic_triggered(type: HapticType)

func trigger(type: HapticType, priority: HapticPriority = HapticPriority.MEDIUM) -> void:
    if not _enabled:
        return
    if not _can_trigger(priority):
        return

    _execute_haptic(type)
    _last_haptic_time = Time.get_ticks_msec()
    haptic_triggered.emit(type)

func _can_trigger(priority: HapticPriority) -> bool:
    var elapsed = Time.get_ticks_msec() - _last_haptic_time
    var min_interval = MIN_HAPTIC_INTERVAL_MS / priority
    return elapsed >= min_interval

func _execute_haptic(type: HapticType) -> void:
    if not OS.has_feature("mobile"):
        return

    var duration_ms: int
    match type:
        HapticType.LIGHT: duration_ms = 10
        HapticType.MEDIUM: duration_ms = 20
        HapticType.HEAVY: duration_ms = 40
        HapticType.SUCCESS: duration_ms = 15
        HapticType.WARNING: duration_ms = 50

    duration_ms = int(duration_ms * _intensity)
    Input.vibrate_handheld(duration_ms)
```

### Event Integration Points

```gdscript
# In ore discovery handler
func _on_ore_discovered(ore: OreData) -> void:
    var haptic_type = _get_haptic_for_rarity(ore.rarity)
    HapticManager.trigger(haptic_type, HapticPriority.HIGH)

# In block break handler
func _on_block_broken() -> void:
    HapticManager.trigger(HapticType.LIGHT, HapticPriority.LOW)

# In achievement handler
func _on_achievement_unlocked(achievement: Achievement) -> void:
    HapticManager.trigger(HapticType.SUCCESS, HapticPriority.CRITICAL)
```

## Testing Protocol

### Device Matrix

| Platform | Device | Haptic Quality | Test Priority |
|----------|--------|----------------|---------------|
| iOS | iPhone 15 Pro | HD Taptic | High |
| iOS | iPhone SE | Basic Taptic | Medium |
| Android | Pixel 8 | HD Haptics | High |
| Android | Samsung A54 | Good Haptics | Medium |
| Android | Budget (<$200) | Basic | Low |

### Test Checklist

- [ ] All haptic events trigger on iOS
- [ ] All haptic events trigger on Android (flagship)
- [ ] Haptic patterns are distinct and recognizable
- [ ] Intensity slider affects all haptic events
- [ ] Disable toggle stops all haptics
- [ ] Category toggles work independently
- [ ] No haptics during pause/background
- [ ] No haptic spam during rapid mining
- [ ] Battery usage acceptable in 30-min session
- [ ] Settings persist across app restarts
- [ ] Haptics sync with audio (within 10ms)

### User Feedback Collection

After playtesting, gather:
1. "Did you notice the vibration?" (awareness)
2. "Was it too much, too little, or about right?" (intensity)
3. "Did any vibrations annoy you?" (problem areas)
4. "Did any feel satisfying?" (success areas)
5. "Would you keep haptics on or turn them off?" (overall)

## GoDig Implementation Roadmap

### Phase 1: MVP (No Haptics)
Focus on core gameplay. Haptics can be added without architectural changes.

### Phase 2: v1.0 (Basic Haptics)
- Ore discovery haptics (rarity-tiered)
- Achievement haptics
- Global enable/disable
- Intensity slider
- Settings persistence

### Phase 3: v1.1 (Enhanced Haptics)
- Audio-haptic synchronization
- Per-category toggles
- Custom patterns per ore type
- Danger warning haptics
- iOS Core Haptics integration (if using native plugin)

### Phase 4: v1.2+ (Advanced Haptics)
- AHAP file support for iOS
- Android HD Haptics API for flagships
- Haptic language for player communication
- A/B testing optimal patterns

## Summary

### Golden Rules for GoDig Haptics

1. **Celebrate discoveries, not every action** - Reserve haptics for emotional peaks
2. **Match the moment** - Intensity should reflect significance
3. **Respect player choice** - Always allow disable, always remember preference
4. **Test on real devices** - Simulators lie about haptic feel
5. **Less is more** - When in doubt, skip the haptic
6. **Be consistent** - Same action = same haptic, every time
7. **Sync with audio** - Multimodal feedback feels more real

### Quick Reference Card

| Event | Haptic? | Intensity | Priority |
|-------|---------|-----------|----------|
| Mining hit | No | - | - |
| Block break | Yes | Light | Low |
| Ore discovery (common) | Yes | Light | Medium |
| Ore discovery (rare+) | Yes | Medium-Heavy | High |
| Achievement | Yes | Medium | Critical |
| Danger warning | Yes | Medium | High |
| Upgrade purchase | Yes | Medium | Medium |
| Sell complete | Optional | Light | Low |
| UI tap | System default | - | - |
| Menu navigation | No | - | - |
