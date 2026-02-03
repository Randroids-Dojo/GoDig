# Web Build Performance Optimization for Godot 4

## Overview

Research into Godot 4 web export considerations including SharedArrayBuffer requirements, threading limitations, mobile browser performance, and persistence patterns.

## SharedArrayBuffer and Cross-Origin Isolation

### The Problem

Godot 4.x initially required SharedArrayBuffer for web builds, which needs:

1. **Secure Context:** Served over HTTPS
2. **Cross-Origin-Opener-Policy (COOP):** `same-origin`
3. **Cross-Origin-Embedder-Policy (COEP):** `require-corp`

**Why This Matters:**
> "Due to Spectre and Meltdown exploits, browsers greatly reduced where and how you can use the SharedArrayBuffer API."

**The Trade-off:**
> "When isolated, it unlocks SharedArrayBuffers, but at the cost of having capacity to make remote calls to other websites - meaning no game monetization and no interacting with external APIs."

### The Solution (Godot 4.3+)

Godot 4.3 introduced **single-threaded builds**:
- Export without SharedArrayBuffer requirement
- No special headers needed
- Game runs anywhere on the web

**Export Settings:**
- Disable "Thread Support" in export options
- Build runs on single thread
- Broader platform compatibility

### Platform Support Status

| Platform | SharedArrayBuffer Support | Notes |
|----------|--------------------------|-------|
| itch.io | Experimental option | Uses `coep:credentialless` |
| Newgrounds | Has option to enable | Works well |
| Safari | Limited | `coep:credentialless` not supported |
| Firefox Android | Limited | `coep:credentialless` not supported |
| Custom server | Full control | Set headers manually |

### Service Worker Workaround

If threading is needed but headers can't be set:

1. Export as Progressive Web App (PWA)
2. Service Worker intercepts requests
3. Injects COOP/COEP headers
4. Threading enabled without server changes

**Plugin:** [godot-coi-serviceworker](https://github.com/nisovin/godot-coi-serviceworker)

## Threading Limitations

### Single-Threaded Build Issues

**Audio Problems:**
> "Audio rendering is tied with frame rate in single-threaded builds. If it drops, there's not enough audio frames to fill the buffer, hence audio glitches occur."

**Symptoms:**
- Audio crackling on low-end devices
- Audio glitches during frame drops
- Worse on laptops and phones

### What to Disable Without Threading

| Feature | Impact | Recommendation |
|---------|--------|----------------|
| Threaded chunk generation | Can't background load | Load synchronously, smaller chunks |
| Physics multithreading | Crashes on web | Disable in project settings |
| Background resource loading | Won't work | Preload essential resources |
| Parallel processing | Not available | Sequential processing only |

### Compatibility Rendering Mode

Web platform always uses Compatibility rendering:
- No 3D decals
- No compute shaders
- WebGL 2.0 required
- Some visual effects unavailable

## Mobile Browser Performance

### iOS Safari Challenges

**Historical Issues:**
> "Safari is often described as 'the new IE' - it lags behind in performance, and every webview on iOS is Safari-based."

**iOS 15+ Improvements:**
- Metal ANGLE backend
- Better WebGL performance
- Many upstream issues resolved

**Device Variance:**
- Same iOS version, different performance
- iPhone X may outperform iPhone 11 Pro on web
- Test on multiple devices

### Optimization Tips

**1. Reduce Viewport Resolution**
```gdscript
# In Project Settings or code
get_viewport().size = Vector2(1280, 720)  # or lower
```
> "On mobile, you often want to use a reduced viewport resolution (1280×720 or lower)."

**2. Fullscreen Considerations**
- Fullscreen can hurt performance on iOS
- Consider windowed mode option
- Smaller viewport = better FPS

**3. Export Settings**
- Use GLES2/Compatibility mode
- Disable HiDPI if not needed
- Test both fullscreen and windowed

### Mobile-Specific Godot Settings

Godot automatically uses low-end-friendly settings on mobile:
- Reduced quality defaults
- Simpler shaders
- Lower resource usage

## Save Data Persistence

### How Web Saves Work

**User Path Mapping:**
> "When creating web games in Godot, you write to a file in the 'user://' path. This will be mapped to html local storage (in the user's browser)."

**IndexedDB:**
- Primary storage for web builds
- Browser-specific (not cross-browser)
- Persists until browser data cleared

### Storage Limitations

| Browser | Typical Limit | Notes |
|---------|---------------|-------|
| Chrome | ~80% of disk | Generous but varies |
| Firefox | ~50% of disk | Or 2GB, whichever smaller |
| Safari | 1GB+ | Varies by device |
| Mobile | Usually less | Device storage matters |

**Practical Limit:** Plan for ~50MB safe maximum for game data.

### Persistence Challenges

**Known Issues:**
- `OS.is_userfs_persistent()` may return false
- Data not visible in file system
- No direct file download (security sandbox)

**itch.io Note:**
> "itch.io provides local storage for your game, but it's browser-specific. If you need persistent saves across devices, you'll need cloud saving separately."

### Save Strategy for Web

```gdscript
# Check if persistent storage available
func can_save() -> bool:
    return OS.has_feature("web") and OS.is_userfs_persistent()

# Save to user://
func save_game():
    var save_file = FileAccess.open("user://save.json", FileAccess.WRITE)
    save_file.store_string(JSON.stringify(game_data))
    save_file.close()
```

## Recommendations for GoDig

### Export Configuration

**For Maximum Compatibility (Recommended):**
```
Thread Support: Disabled
Rendering: Compatibility
Viewport: 1280x720 or dynamic
Export Type: Regular HTML5 (not PWA)
```

**For Better Performance (Requires Headers):**
```
Thread Support: Enabled
Export Type: PWA
Server: Must set COOP/COEP headers
```

### Performance Optimizations

**1. Chunk Loading**
```gdscript
# Single-threaded: Load chunks synchronously
# Smaller chunks = less frame spikes
const WEB_CHUNK_SIZE := 8  # vs 16 for native

func _ready():
    if OS.has_feature("web"):
        ChunkManager.chunk_size = WEB_CHUNK_SIZE
```

**2. Audio Handling**
```gdscript
# Detect web platform for audio settings
if OS.has_feature("web"):
    # Use larger audio buffers
    AudioServer.set_bus_layout(preload("res://audio_bus_web.tres"))
```

**3. Visual Quality**
```gdscript
# Reduce quality on web
if OS.has_feature("web"):
    # Disable particles or reduce count
    particle_system.amount = particle_system.amount / 2
    # Simpler shaders
    material.shader = preload("res://shaders/simple_web.gdshader")
```

### Save System for Web

**Current GoDig Implementation:**
- Already uses `user://` path
- Should work with IndexedDB
- Add web-specific checks

**Enhancements:**
```gdscript
# In save_manager.gd
func save_game() -> void:
    if OS.has_feature("web"):
        # Web-specific save handling
        _save_web()
    else:
        _save_native()

func _save_web() -> void:
    # Save smaller chunks more frequently
    # Verify persistence after save
    var test = FileAccess.file_exists("user://save.json")
    if not test:
        push_warning("Web save may not persist")
```

### Feature Detection

```gdscript
# Check capabilities at runtime
func get_platform_features() -> Dictionary:
    return {
        "is_web": OS.has_feature("web"),
        "has_threads": not OS.has_feature("web") or _has_shared_array_buffer(),
        "persistent_storage": OS.is_userfs_persistent(),
        "is_mobile_web": OS.has_feature("web") and OS.has_feature("mobile"),
    }

func _has_shared_array_buffer() -> bool:
    # Check via JavaScript
    if OS.has_feature("web"):
        var js_result = JavaScriptBridge.eval("typeof SharedArrayBuffer !== 'undefined'")
        return js_result == true
    return false
```

### Testing Checklist

**Before Web Release:**
- [ ] Test on Chrome desktop
- [ ] Test on Firefox desktop
- [ ] Test on Safari desktop
- [ ] Test on Chrome mobile (Android)
- [ ] Test on Safari mobile (iOS)
- [ ] Test save/load persistence
- [ ] Test after browser restart
- [ ] Test with slow connection
- [ ] Test audio quality
- [ ] Verify frame rate acceptable

### What to Disable for Web

| Feature | Web Status | Alternative |
|---------|------------|-------------|
| Threaded chunk gen | Disable | Sync loading, smaller chunks |
| Complex shaders | Simplify | Compatibility shaders |
| High particle counts | Reduce | 50% of native |
| DirAccess scanning | Doesn't work | Preload registry |
| Background loading | Limited | Loading screens |

### Local Testing

**GoDig already has `build/serve.py`:**
```bash
cd build && python3 serve.py
# Opens at http://localhost:8080
```

**Required Headers (in serve.py):**
```python
self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
```

## Sources

- [Godot Engine - Web Export in 4.3](https://godotengine.org/article/progress-report-web-export-in-4-3/)
- [Rafael Epplée - Deploying Godot 4 HTML Exports](https://www.rafa.ee/articles/deploying-godot-4-html-exports/)
- [Godot Forum - Godot 4.3 Web Builds Fix](https://forum.godotengine.org/t/godot-4-3-will-finally-fix-web-builds-no-sharedarraybuffers-required/38885)
- [GitHub Issue - Running Godot Without Threads on Web](https://github.com/godotengine/godot/issues/85938)
- [GitHub - godot-coi-serviceworker Plugin](https://github.com/nisovin/godot-coi-serviceworker)
- [Godot Docs - Exporting for the Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
- [Godot Docs - General Optimization Tips](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html)
- [GitHub Issue - Poor Mobile Performance on HTML5](https://github.com/godotengine/godot/issues/58836)
- [GitHub Issue - iOS 20 FPS Limit](https://github.com/godotengine/godot/issues/52304)
- [Godot Forum - Optimize HTML5 for Mobiles](https://forum.godotengine.org/t/how-to-optimize-html5-game-version-for-mobiles/11747)
- [Godot Forum - Store Data in Browser](https://forum.godotengine.org/t/store-data-in-the-browser/9675)

## Related Implementation Tasks

- Web build testing dot: GoDig-web-build-testing-56e0bc7b
- DEV: Threaded chunk generation: GoDig-dev-threaded-chunk-648dcec7
- Existing: `build/serve.py` for local testing
