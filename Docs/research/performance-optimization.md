# Performance Optimization for Mobile Research

## Sources
- [Godot 4 Mobile Optimization Guide](https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_for_size.html)
- [Mobile Game Performance Best Practices](https://developer.android.com/games/optimize)
- [Godot TileMap Performance](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html)

## Target Performance

### Mobile Targets
| Device Tier | Target FPS | Min RAM | Example |
|-------------|------------|---------|---------|
| Low-end | 30 FPS | 2GB | Budget Android |
| Mid-range | 60 FPS | 4GB | iPhone SE, Pixel 4a |
| High-end | 60 FPS | 6GB+ | iPhone 14, Pixel 7 |

### Web Targets
- Desktop browser: 60 FPS
- Mobile browser: 30-60 FPS
- Initial load: <5 seconds

## Chunk System Optimization

### Chunk Size Decision
| Size | Tiles | Pros | Cons |
|------|-------|------|------|
| 8x8 | 64 | Fine granularity, quick load | More chunks to manage |
| 16x16 | 256 | Good balance | **Recommended** |
| 32x32 | 1024 | Fewer chunks | Slower generation |

**Recommendation**: 16x16 chunks for mobile

### Chunk Loading Strategy
```gdscript
# chunk_manager.gd
const CHUNK_SIZE = 16
const LOAD_RADIUS = 2      # Chunks around player
const UNLOAD_RADIUS = 4    # When to unload
const MAX_LOADED = 25      # Hard limit

var loaded_chunks: Dictionary = {}
var chunk_queue: Array = []

func _process(delta):
    # Process one chunk per frame max
    if chunk_queue.size() > 0:
        var chunk_pos = chunk_queue.pop_front()
        _generate_chunk(chunk_pos)

func update_chunks(player_pos: Vector2):
    var player_chunk = world_to_chunk(player_pos)
    
    # Queue chunks to load (prioritize vertical)
    for y in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
        for x in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
            var pos = player_chunk + Vector2i(x, y)
            if pos not in loaded_chunks and pos not in chunk_queue:
                chunk_queue.append(pos)
    
    # Sort queue: prioritize below player
    chunk_queue.sort_custom(func(a, b):
        return a.y > b.y  # Lower chunks first
    )
    
    # Unload distant chunks
    _unload_distant_chunks(player_chunk)
```

### Chunk Persistence
```gdscript
# Only save modified chunks
var modified_chunks: Dictionary = {}

func mark_modified(chunk_pos: Vector2i):
    modified_chunks[chunk_pos] = true

func save_modified_chunks():
    for pos in modified_chunks:
        _save_chunk_to_file(pos)
    modified_chunks.clear()
```

## TileMap Optimization

### Use TileMapLayers (Godot 4)
```gdscript
# Separate layers for different update frequencies
# Layer 0: Static terrain (rarely updates)
# Layer 1: Ores (updates on dig)
# Layer 2: Player-placed objects (ladders, etc.)
```

### Visibility Culling
```gdscript
# Only render visible tiles
func _ready():
    # TileMap handles culling automatically in Godot 4
    # But we can help by not updating off-screen chunks
    pass

func is_chunk_visible(chunk_pos: Vector2i) -> bool:
    var screen_rect = get_viewport_rect()
    var chunk_rect = Rect2(
        chunk_pos * CHUNK_SIZE * TILE_SIZE,
        Vector2(CHUNK_SIZE, CHUNK_SIZE) * TILE_SIZE
    )
    return screen_rect.intersects(chunk_rect)
```

## Threading for Generation

### Background Chunk Generation
```gdscript
# chunk_generator.gd
var generation_thread: Thread
var pending_chunks: Array = []
var completed_chunks: Array = []
var mutex: Mutex

func _ready():
    mutex = Mutex.new()
    generation_thread = Thread.new()
    generation_thread.start(_generation_loop)

func _generation_loop():
    while true:
        mutex.lock()
        if pending_chunks.size() > 0:
            var chunk_pos = pending_chunks.pop_front()
            mutex.unlock()
            
            var chunk_data = _generate_chunk_data(chunk_pos)
            
            mutex.lock()
            completed_chunks.append({"pos": chunk_pos, "data": chunk_data})
            mutex.unlock()
        else:
            mutex.unlock()
            OS.delay_msec(10)  # Avoid busy-wait

func _process(delta):
    # Apply completed chunks on main thread
    mutex.lock()
    while completed_chunks.size() > 0:
        var chunk = completed_chunks.pop_front()
        _apply_chunk_to_tilemap(chunk.pos, chunk.data)
    mutex.unlock()
```

## Object Pooling

### Particle Pool
```gdscript
# particle_pool.gd
var pool: Array[GPUParticles2D] = []
var pool_size = 20

func _ready():
    for i in range(pool_size):
        var particles = DigParticles.instantiate()
        particles.emitting = false
        particles.visible = false
        add_child(particles)
        pool.append(particles)

func get_particles() -> GPUParticles2D:
    for p in pool:
        if not p.emitting:
            return p
    # Pool exhausted - reuse oldest
    return pool[0]

func emit_at(pos: Vector2, color: Color):
    var p = get_particles()
    p.position = pos
    p.modulate = color
    p.visible = true
    p.emitting = true
```

### Floating Text Pool
```gdscript
# Same pattern for damage numbers, pickup text, etc.
var text_pool: Array[Label] = []
```

## Memory Management

### Texture Atlases
```
# Combine sprites into atlases
terrain_atlas.png (512x512)
├── dirt tiles
├── stone tiles
├── ore tiles
└── gem tiles

ui_atlas.png (256x256)
├── buttons
├── icons
└── frames
```

### Audio Streaming
```gdscript
# Use streaming for music, preload for SFX
var music_stream: AudioStreamOggVorbis  # Streamed
var dig_sfx: AudioStreamWAV  # Preloaded (small)
```

### Chunk Data Compression
```gdscript
# Store only differences from base generation
func compress_chunk(chunk_data: Dictionary) -> PackedByteArray:
    var modified_tiles: Array = []
    for pos in chunk_data:
        if chunk_data[pos] != get_expected_tile(pos):
            modified_tiles.append([pos.x, pos.y, chunk_data[pos]])
    return var_to_bytes(modified_tiles)
```

## Rendering Optimization

### Limit Draw Calls
- Use texture atlases
- Batch similar sprites
- Minimize CanvasItem nodes

### Shader Considerations
```gdscript
# Avoid complex shaders on mobile
# Simple lighting shader
shader_type canvas_item;

uniform float light_radius = 100.0;
uniform vec2 light_pos;

void fragment() {
    float dist = distance(FRAGCOORD.xy, light_pos);
    float light = clamp(1.0 - dist / light_radius, 0.0, 1.0);
    COLOR.rgb *= light;
}
```

### Disable Unused Features
```
# In Project Settings
rendering/2d/snap/snap_2d_vertices_to_pixel = true
rendering/2d/snap/snap_2d_transforms_to_pixel = true
rendering/anti_aliasing/quality/msaa_2d = disabled
```

## Battery Optimization (Mobile)

### Frame Rate Limiting
```gdscript
# Cap FPS when not actively playing
func _on_game_paused():
    Engine.max_fps = 30

func _on_game_resumed():
    Engine.max_fps = 60
```

### Background Handling
```gdscript
func _notification(what):
    match what:
        NOTIFICATION_APPLICATION_FOCUS_OUT:
            # Reduce processing when backgrounded
            get_tree().paused = true
            Engine.max_fps = 1
        NOTIFICATION_APPLICATION_FOCUS_IN:
            get_tree().paused = false
            Engine.max_fps = 60
```

### Reduce Update Frequency
```gdscript
# Not everything needs 60Hz updates
var slow_update_timer = 0.0

func _process(delta):
    slow_update_timer += delta
    if slow_update_timer >= 0.1:  # 10Hz for non-critical
        slow_update_timer = 0
        _update_ambient_particles()
        _update_distant_chunks()
```

## Profiling Checklist

### Key Metrics to Monitor
- [ ] Frame time (target: <16ms for 60fps)
- [ ] Draw calls (target: <100)
- [ ] Physics bodies (target: <200)
- [ ] Memory usage (target: <200MB)
- [ ] Chunk load time (target: <50ms)

### Godot Profiler Usage
```gdscript
# Enable in editor: Debugger > Profiler
# Or in code:
func _ready():
    if OS.is_debug_build():
        Performance.get_monitor(Performance.TIME_FPS)
        Performance.get_monitor(Performance.MEMORY_STATIC)
        Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS)
```

## Export Size Optimization

### Android APK
- Enable APK compression
- Strip debug symbols
- Use AAB for Play Store

### Web Export
- Enable threads (SharedArrayBuffer)
- Compress with gzip/brotli
- Lazy load audio assets

### Target Sizes
| Platform | Target Size |
|----------|-------------|
| Android APK | <50MB |
| iOS IPA | <100MB |
| Web (initial) | <20MB |

## Questions to Resolve
- [ ] 16x16 or 8x8 chunks for mobile?
- [ ] How many chunks to keep loaded?
- [ ] Threading for generation or main thread?
- [ ] Target minimum device specs?
- [ ] Web export with or without threads?
