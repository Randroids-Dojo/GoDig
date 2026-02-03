# Mobile Performance Profiling Techniques and Benchmarks for Godot 4.6

> Research on mobile performance optimization techniques for Godot 4.6. Covers profiling tools, target frame rates, memory budgets, common bottlenecks in 2D games, battery drain reduction, particle optimization, and chunk loading strategies.
> Last updated: 2026-02-02 (Session 26)

## Executive Summary

Mobile performance optimization is critical for player retention - 72% of players uninstall after just two performance-related crashes, and 60% drop apps below 30 FPS. For Godot 4.6 2D games on mobile, key targets are: 60 FPS for 75% of sessions, <500MB peak memory in lobby, <975MB during gameplay, and cold start under 1.8 seconds. This research covers profiling tools, optimization techniques, and chunk loading strategies for GoDig.

---

## 1. Performance Targets and Benchmarks (2025)

### Frame Rate Targets

| Device Tier | Target FPS | Notes |
|-------------|------------|-------|
| **Budget Android** (Android 5.1-9) | 30 FPS minimum | Older devices, limited GPU |
| **Mid-range Android** (Android 10+) | 60 FPS | Target for 75% of sessions |
| **High-end Android** (Pixel, Samsung flagship) | 60 FPS | 95% of sessions |
| **iPhone 8 and earlier** | 30 FPS minimum | iOS before 15 |
| **iPhone 8+ and newer** | 60 FPS | Target for all sessions |
| **Competitive games** | 60 FPS | Non-negotiable |
| **Casual games** | 30 FPS | Acceptable minimum |

**Critical stat**: 60% of users drop apps that consistently run below 30 FPS.

**Sources**: [Medium - Essential Performance Metrics](https://foxsterdev.medium.com/level-up-your-game-essential-performance-metrics-for-top-tier-mobile-development-634deac4d1ee)

### Memory Budgets

| Context | Target | Maximum |
|---------|--------|---------|
| **Lobby/Menu** | <500 MB | 600 MB |
| **Gameplay** | <800 MB | 975 MB |
| **Budget devices (3GB RAM)** | <1.8 GB total | 60% of available |
| **Peak usage** | Avoid spikes | Causes OOM crashes |

**Godot 4 baseline**: 120-160 MB (efficient compared to Unity URP at 180-220 MB).

### Startup Performance

| Metric | Target | Warning |
|--------|--------|---------|
| Cold start | <1.8 seconds | >3 seconds |
| Initial download size | <300 MB | >500 MB |
| Total with data/cache | <1 GB | 9% of Android devices have <2GB free |

**Sources**: [Medium - Mobile Game Performance Testing 2025](https://medium.com/@anuradhapal818/the-ultimate-guide-to-mobile-game-performance-testing-in-2025-metrics-tools-and-future-trends-01d16aa06229)

---

## 2. Godot 4.6 Profiling Tools

### Built-in Tools

**Debugger > Profiler**:
- CPU time per function
- Physics time breakdown
- Script processing time
- Identifies hot paths

**Debugger > Monitors**:
- FPS counter
- Memory usage
- Draw calls
- Object count

**Debugger > Video RAM**:
- Texture memory usage
- Render target sizes
- GPU memory allocation

### External Tools

**Arm Performance Studio** (for Android):
- Arm Streamline: CPU/GPU timeline
- Arm Performance Advisor: Automated recommendations
- Mali Offline Compiler: Shader optimization

**Xcode Instruments** (for iOS):
- Time Profiler: CPU hotspots
- Allocations: Memory tracking
- Metal System Trace: GPU analysis
- Energy Log: Battery impact

**Android Studio Profiler**:
- CPU Profiler
- Memory Profiler
- Network Profiler
- Energy Profiler

**Sources**: [Godot Documentation - Performance](https://docs.godotengine.org/en/stable/tutorials/performance/index.html), [GDC 2025 - Profiling Godot with Arm Performance Studio](https://schedule.gdconf.com/session/arm-developer-summit-profiling-and-optimizing-godot-engine-for-mobile-with-arm-performance-studio-presented-by-arm/911375)

---

## 3. Godot 4.6 Mobile Optimization Techniques

### Renderer Selection

| Renderer | Use Case | Performance |
|----------|----------|-------------|
| **Compatibility** | Older hardware, web | Best for broad support |
| **Mobile** | iOS/Android target | Good balance |
| **Forward+** | High-end devices only | Desktop-focused |

**Recommendation for GoDig**: Use **Mobile** renderer for balance, with fallback to **Compatibility** for low-end devices.

### Viewport and Scaling

> "Viewport scaling takes less GPU resources and energy than canvas_items, making a significant difference on mobile devices."

**Settings**:
- Use stretch mode: `viewport`
- Set window/size to target resolution
- Let Godot handle scaling

### Process Function Optimization

> "Use `_process` for CPU-oriented calculations and `_physics_process` only when interacting with the PhysicsServer. This makes a big difference for FPS, showing 3-5x decrease in physics time in the profiler."

**Guidelines**:
- Move non-physics logic to `_process()`
- Use timers instead of per-frame checks
- Batch calculations across multiple frames

### GDScript Optimization

| Technique | Benefit |
|-----------|---------|
| **Static typing** | Faster execution |
| **Preload nodes/scripts** | Avoid runtime lookups |
| **Direct method calls** | Faster than signals |
| **Avoid `get_node()` in loops** | Cache references |

```gdscript
# BAD - lookups every frame
func _process(_delta):
    $Player.position += velocity

# GOOD - cached reference
@onready var _player: Node2D = $Player
func _process(_delta):
    _player.position += velocity
```

### UI Optimization

> "Avoid PanelContainer, Panel, and TextureRect UI elements due to a known issue, as avoiding these can result in massive energy savings."

**Alternatives**:
- Use ColorRect instead of Panel
- Use Sprite2D instead of TextureRect for game elements
- Minimize nested containers

**Sources**: [Norman's Oven - Godot 4 2D Mobile Optimization](https://www.normansoven.com/post/godot-4-2d-mobile-optimization), [Howik - Mastering Godot Mobile Game Performance 2025](https://howik.com/godot-mobile-game-performance)

---

## 4. 2D Rendering Optimization

### Batching

As of Godot 4.4+, batching is available in all renderers:
> "Now 2D performance is comparable between all backends."

**What batching does**:
- Combines similar draw calls
- Reduces GPU state changes
- Automatically groups sprites with same texture

**Best practices**:
- Use texture atlases
- Group sprites with same material
- Avoid per-sprite shaders when possible

### Draw Call Reduction

| Technique | Impact |
|-----------|--------|
| **Texture atlases** | Major reduction |
| **Sprite batching** | Automatic in Godot 4.4+ |
| **Avoid transparency sorting** | Reduces overdraw |
| **Use TileMap for static geometry** | Single draw call |
| **Implement culling** | Don't draw off-screen |

### Shader Optimization

> "When targeting mobile devices, consider using the simplest possible shaders you can reasonably afford to use."

**Guidelines**:
- Avoid complex math in fragment shaders
- Use vertex shaders where possible
- Minimize texture reads per fragment
- Avoid trilinear filtering when linear works

**Sources**: [Godot Documentation - GPU Optimization](https://trinovantes.github.io/godot-docs/tutorials/performance/gpu_optimization.html)

---

## 5. Particle System Optimization

### GPUParticles vs CPUParticles

| Type | Pro | Con | Use When |
|------|-----|-----|----------|
| **GPUParticles** | Fast rendering | Expensive initialization | Large effect counts |
| **CPUParticles** | Predictable cost | Slower with many particles | Small effects, mobile |

### Optimization Guidelines

> "GPUParticles are expensive. Limit particle effects and keep particle fixed FPS to 30, as higher values will significantly impact performance."

**Recommendations**:
1. Cap particle FPS at 30
2. Limit total active particle systems to 5-10
3. Pool particle effects (don't instantiate/free)
4. Use simpler particle materials
5. Reduce particle count per effect (50 well-designed > 200 sloppy)

### Mobile Particle Budgets

| Effect Type | Particle Count | Systems Active |
|-------------|----------------|----------------|
| Block break (dirt) | 3-5 | Many allowed |
| Block break (stone) | 5-8 | Many allowed |
| Ore discovery | 15-25 | 1-2 at a time |
| Rare discovery | 25-40 | 1 at a time |
| Jackpot | 40-60 | 1 at a time, rare |
| **Total on screen** | <200-500 | Limit concurrency |

### Object Pooling

> "Object pooling is important on mobile devices. Pool physics bodies like enemies, GPUParticle effects, projectiles, and anything you can reuse and recycle."

```gdscript
# Particle pool example
var _particle_pool: Array[GPUParticles2D] = []

func get_particle_effect() -> GPUParticles2D:
    if _particle_pool.is_empty():
        return _create_new_particle()
    return _particle_pool.pop_back()

func return_particle_effect(particles: GPUParticles2D) -> void:
    particles.emitting = false
    _particle_pool.append(particles)
```

---

## 6. Battery and Thermal Optimization

### Understanding Thermal Throttling

> "If a device gets too hot, it downclocks the speed of the CPU and GPU to reduce power consumption. This behavior, referred to as thermal throttling, affects the performance of your game."

**The problem**: Games run perfectly for 20 minutes, then become unplayable.

### Causes of Battery Drain

1. **High CPU/GPU usage** - Primary culprit
2. **Display refresh rate** - Higher = more power
3. **Network activity** - Background syncs
4. **Excessive particles** - GPU overdraw
5. **Complex shaders** - Fragment shader cost

### Optimization Strategies

**Dynamic Quality Adjustment**:
> "Allow the game to adjust graphics quality dynamically based on battery level or thermal status."

**Android APIs**:
- **Thermal API**: Monitor device temperature
- **Game Mode API**: Prioritize performance or battery
- **ADPF**: Android Dynamic Performance Framework

**iOS**:
- Use `ProcessInfo.thermalState`
- Respond to thermal notifications

### Practical Tips

| Optimization | Impact |
|--------------|--------|
| Cap FPS at 30 | Huge thermal reduction |
| Reduce particle effects | Less GPU load |
| Disable shadows | Significant savings |
| Lower texture resolution | Memory + GPU savings |
| Match display refresh to target FPS | Eliminate wasted frames |

**Important**: Higher refresh rates above game FPS = wasted power
> "If the display refresh rate is higher than the target frame rate of the game, there is no benefit from the higher refresh rate, only increased power consumption."

**Sources**: [Android Developers - Optimize Power](https://developer.android.com/games/optimize/power), [DEV Community - Optimizing Android Game Performance](https://dev.to/krishanvijay/optimizing-android-game-performance-memory-gpu-battery-strategies-26pe)

---

## 7. Chunk Loading Strategies

### Core Concepts

> "Chunks are essentially small segments of the game world. The primary purpose of chunk loading is to manage the game's memory and performance efficiently by only processing the parts of the world that are immediately relevant to the player."

### Loading Strategies

| Strategy | Description | Best For |
|----------|-------------|----------|
| **Streaming** | Load on-demand as player approaches | Memory-constrained |
| **Pre-loading** | Load before player reaches | Fast-moving games |
| **Proximity-based** | Load within radius of player | Most common |

### Chunk Manager Architecture

Maintain multiple chunk lists for different states:

```
ChunkLoadList     - Chunks queued for loading
ChunkSetupList    - Chunks being initialized
ChunkRenderList   - Chunks ready to render
ChunkVisibilityList - Potentially visible chunks
ChunkUnloadList   - Chunks queued for unloading
```

### Performance Techniques

**Asynchronous Loading**:
> "Loading chunks asynchronously and only loading a certain number per frame increases framerate during load."

**Visibility vs Render Separation**:
> "Update the visibility list when the camera moves across a chunk boundary, not every frame."

**Frustum and Occlusion Culling**:
- Only generate/render visible chunks
- Use simpler representations for distant chunks
- Remove empty chunks from render list

**Dynamic Data Structures**:
> "Don't statically allocate chunk data. Adding and removing chunks from a static array becomes very CPU intensive."

### GoDig-Specific Recommendations

For a 16x16 chunk mining game:

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Chunk size | 16x16 tiles | Balance of granularity and overhead |
| Load radius | 3 chunks (48 tiles) | Covers visible area |
| Unload distance | 5 chunks | Hysteresis to avoid thrashing |
| Max loading per frame | 1-2 chunks | Prevents frame spikes |
| Thread pool | Background thread | Async generation |

**Sources**: [Wayline - Optimizing Game Performance: PCG Customization](https://www.wayline.io/blog/optimizing-game-performance-procedural-content-customization), [Medium - Building a High-Performance Voxel Engine](https://medium.com/@adamy1558/building-a-high-performance-voxel-engine-in-unity-a-step-by-step-guide-part-5-advanced-chunk-7060b4b6275c)

---

## 8. Texture and Asset Optimization

### Texture Guidelines

| Platform | Format | Notes |
|----------|--------|-------|
| Android | ETC2 | Best compression, wide support |
| iOS | ASTC | High quality, hardware supported |
| Both | Power of 2 dimensions | Required for some features |

### Compression Settings

**For sprites**:
- Use Lossless (PNG) for sprites with sharp edges
- Use VRAM Compressed for large backgrounds
- Enable mipmaps only if zooming

**For atlases**:
- Max 2048x2048 for mobile
- Pack efficiently (TexturePacker, etc.)
- One atlas per "zone" or "layer"

### Streaming Large Assets

> "Implement streaming of large textures and audio, and use Godot's ResourceLoader to dynamically load assets when needed."

```gdscript
# Async resource loading
var _loader: ResourceLoader

func _start_loading_chunk(path: String) -> void:
    ResourceLoader.load_threaded_request(path)

func _check_chunk_loaded(path: String) -> bool:
    var status = ResourceLoader.load_threaded_get_status(path)
    return status == ResourceLoader.THREAD_LOAD_LOADED
```

---

## 9. Profiling Checklist

### Before Optimization

1. [ ] Enable Godot profiler
2. [ ] Record baseline FPS on target device
3. [ ] Measure memory usage
4. [ ] Identify top 3 hotspots
5. [ ] Set specific improvement targets

### During Optimization

1. [ ] Change one thing at a time
2. [ ] Measure after each change
3. [ ] Document what works/doesn't
4. [ ] Test on lowest-spec target device

### Performance Red Flags

| Metric | Warning | Action |
|--------|---------|--------|
| FPS < 30 | Critical | Immediate optimization |
| Draw calls > 500 | High | Batch sprites, use atlases |
| Memory > 800MB | High | Reduce loaded assets |
| Physics time > 5ms | Medium | Reduce physics bodies |
| Script time > 10ms | Medium | Optimize hot loops |
| Frame spikes > 50ms | High | Find and fix stutters |

### Device Testing Matrix

| Device Category | Example Devices | Test Priority |
|-----------------|-----------------|---------------|
| **Low-end Android** | Redmi 9A, Samsung A03 | High |
| **Mid-range Android** | Pixel 6a, Samsung A52 | High |
| **High-end Android** | Pixel 8, Samsung S24 | Medium |
| **Older iPhone** | iPhone 8, SE 2nd gen | High |
| **Recent iPhone** | iPhone 13, 14 | Medium |

---

## Key Takeaways for GoDig

1. **Target 60 FPS** on mid-range+ devices, 30 FPS minimum on low-end
2. **Memory budget**: <500MB lobby, <800MB gameplay
3. **Use Mobile renderer** with Compatibility fallback
4. **Viewport scaling** over canvas_items for battery
5. **Avoid UI pitfalls**: No Panel, PanelContainer on mobile
6. **Cap particle FPS at 30**, pool particle effects
7. **Static typing** in GDScript for 10-20% speedup
8. **Async chunk loading**: 1-2 chunks per frame max
9. **Monitor thermal state**: Dynamic quality adjustment
10. **Profile on lowest-spec device**: Optimize for your floor

---

## Sources

### Godot Optimization
- [Godot Documentation - Performance](https://docs.godotengine.org/en/stable/tutorials/performance/index.html)
- [Norman's Oven - Godot 4 2D Mobile Optimization](https://www.normansoven.com/post/godot-4-2d-mobile-optimization)
- [Howik - Mastering Godot Mobile Game Performance 2025](https://howik.com/godot-mobile-game-performance)
- [Toxigon - Optimizing Godot for Mobile Games](https://toxigon.com/optimizing-godot-for-mobile-games)

### Mobile Benchmarks
- [Medium - Essential Performance Metrics for Mobile Development](https://foxsterdev.medium.com/level-up-your-game-essential-performance-metrics-for-top-tier-mobile-development-634deac4d1ee)
- [Medium - Mobile Game Performance Testing 2025](https://medium.com/@anuradhapal818/the-ultimate-guide-to-mobile-game-performance-testing-in-2025-metrics-tools-and-future-trends-01d16aa06229)
- [MoldStud - Optimizing Mobile Game Graphics](https://moldstud.com/articles/p-optimizing-mobile-game-graphics-for-various-devices-a-comprehensive-developer-guide)

### Battery & Thermal
- [Android Developers - Optimize Power](https://developer.android.com/games/optimize/power)
- [Android Developers - ADPF](https://developer.android.com/games/optimize/adpf)
- [DEV Community - Optimizing Android Game Performance](https://dev.to/krishanvijay/optimizing-android-game-performance-memory-gpu-battery-strategies-26pe)

### Chunk Management
- [Wayline - Optimizing Game Performance: PCG](https://www.wayline.io/blog/optimizing-game-performance-procedural-content-customization)
- [Medium - Building a High-Performance Voxel Engine](https://medium.com/@adamy1558/building-a-high-performance-voxel-engine-in-unity-a-step-by-step-guide-part-5-advanced-chunk-7060b4b6275c)
