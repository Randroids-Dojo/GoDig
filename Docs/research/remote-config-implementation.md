# Remote Config Implementation Research

> Research into implementing HTTPRequest-based remote configuration for the economy system in GoDig, with focus on error handling, caching, and mobile-specific considerations.

## Executive Summary

Remote configuration allows updating game balance parameters (ore values, tool costs, etc.) without requiring app store updates. This is critical for mobile games where iteration speed is limited by app review processes. Godot 4's HTTPRequest node provides the foundation, but requires careful implementation of caching, offline fallback, and error handling.

**Key Insight for GoDig**: Our economy_config.gd has placeholders for remote config. Implementation should prioritize reliability and fail gracefully to local defaults - players should never notice when remote config is unavailable.

---

## HTTPRequest in Godot 4

### Basic Usage

```gdscript
var http_request := HTTPRequest.new()

func _ready() -> void:
    add_child(http_request)
    http_request.request_completed.connect(_on_request_completed)

    # Make request
    var error := http_request.request("https://api.example.com/config")
    if error != OK:
        push_error("Failed to start request: %s" % error_string(error))


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
    if result != HTTPRequest.RESULT_SUCCESS:
        _handle_request_error(result)
        return

    if response_code != 200:
        push_warning("HTTP error: %d" % response_code)
        return

    var json = JSON.parse_string(body.get_string_from_utf8())
    if json == null:
        push_error("Failed to parse JSON response")
        return

    _apply_config(json)
```

### Timeout Configuration

The `timeout` property controls how long to wait for a response:

| Use Case | Recommended Timeout |
|----------|-------------------|
| REST API calls | 5-10 seconds |
| Large downloads | 0 (disabled) |
| Mobile with poor connection | 15-20 seconds |

```gdscript
http_request.timeout = 10.0  # 10 second timeout
```

**Important**: Setting timeout to 0 disables it entirely - the request will wait indefinitely.

### Request Error Codes

| Result Code | Meaning | Recommended Action |
|-------------|---------|-------------------|
| RESULT_SUCCESS | Request completed | Process response |
| RESULT_CONNECTION_ERROR | Cannot connect | Retry with backoff, use cached data |
| RESULT_TLS_HANDSHAKE_ERROR | SSL/TLS failed | Check certificate, use cached data |
| RESULT_NO_RESPONSE | Server didn't respond | Retry, use cached data |
| RESULT_TIMEOUT | Request timed out | Retry with longer timeout |
| RESULT_BODY_SIZE_LIMIT_EXCEEDED | Response too large | Increase body_size_limit |

### Known Issues

1. **Connection error persistence**: HTTPRequest can enter a state where it repeatedly fails until the app restarts. Workaround: Create a new HTTPRequest node on persistent errors.

2. **No built-in retry**: Manual retry logic required.

3. **No built-in caching**: Must implement file-based caching manually.

---

## Recommended Implementation Pattern

### Architecture

```
Remote Config Flow:
1. Check cache validity (age, existence)
2. If cache valid -> use cached config
3. If cache stale -> fetch remote, update cache
4. If fetch fails -> use cached config (even if stale)
5. If no cache -> use local defaults (bundled in app)
```

### Caching Strategy

```gdscript
const CACHE_PATH := "user://config_cache.json"
const CACHE_MAX_AGE_SECONDS := 3600  # 1 hour

func _is_cache_valid() -> bool:
    if not FileAccess.file_exists(CACHE_PATH):
        return false

    var file := FileAccess.open(CACHE_PATH, FileAccess.READ)
    if file == null:
        return false

    # Check file modification time
    var modified_time := FileAccess.get_modified_time(CACHE_PATH)
    var current_time := int(Time.get_unix_time_from_system())

    return (current_time - modified_time) < CACHE_MAX_AGE_SECONDS


func _load_cached_config() -> Dictionary:
    if not FileAccess.file_exists(CACHE_PATH):
        return {}

    var file := FileAccess.open(CACHE_PATH, FileAccess.READ)
    if file == null:
        return {}

    var json = JSON.parse_string(file.get_as_text())
    file.close()

    if json is Dictionary:
        return json
    return {}


func _save_to_cache(config: Dictionary) -> void:
    var file := FileAccess.open(CACHE_PATH, FileAccess.WRITE)
    if file == null:
        push_warning("[RemoteConfig] Failed to write cache")
        return

    file.store_string(JSON.stringify(config))
    file.close()
```

### Retry Logic with Exponential Backoff

```gdscript
var _retry_count: int = 0
const MAX_RETRIES := 3
const BASE_RETRY_DELAY := 2.0  # seconds

func _fetch_with_retry() -> void:
    _retry_count = 0
    _attempt_fetch()


func _attempt_fetch() -> void:
    var error := http_request.request(REMOTE_CONFIG_URL)
    if error != OK:
        _schedule_retry()


func _schedule_retry() -> void:
    _retry_count += 1
    if _retry_count > MAX_RETRIES:
        print("[RemoteConfig] Max retries reached, using cached/local config")
        _use_fallback_config()
        return

    # Exponential backoff: 2s, 4s, 8s
    var delay := BASE_RETRY_DELAY * pow(2, _retry_count - 1)
    var timer := get_tree().create_timer(delay)
    timer.timeout.connect(_attempt_fetch)
    print("[RemoteConfig] Retry %d in %.1fs" % [_retry_count, delay])
```

### Complete Implementation Example

```gdscript
extends Node
## Remote config manager with caching, retry, and offline fallback.

signal config_loaded(config: Dictionary)
signal config_error(error: String)

const REMOTE_CONFIG_URL := "https://api.godig.game/config/v1"
const CACHE_PATH := "user://remote_config_cache.json"
const CACHE_MAX_AGE := 3600  # 1 hour
const REQUEST_TIMEOUT := 10.0
const MAX_RETRIES := 3
const BASE_RETRY_DELAY := 2.0

var _http_request: HTTPRequest = null
var _retry_count: int = 0
var _is_fetching: bool = false
var _current_config: Dictionary = {}

func _ready() -> void:
    _setup_http_request()
    load_config()


func _setup_http_request() -> void:
    if _http_request:
        _http_request.queue_free()

    _http_request = HTTPRequest.new()
    _http_request.timeout = REQUEST_TIMEOUT
    _http_request.accept_gzip = true
    _http_request.request_completed.connect(_on_request_completed)
    add_child(_http_request)


func load_config() -> void:
    # Check if cache is fresh enough
    if _is_cache_valid():
        var cached := _load_cache()
        if not cached.is_empty():
            print("[RemoteConfig] Using cached config")
            _current_config = cached
            config_loaded.emit(_current_config)
            return

    # Cache stale or missing - fetch remote
    _fetch_remote()


func _fetch_remote() -> void:
    if _is_fetching:
        return

    if REMOTE_CONFIG_URL.is_empty():
        print("[RemoteConfig] No remote URL configured, using defaults")
        config_loaded.emit({})
        return

    _is_fetching = true
    _retry_count = 0
    _attempt_fetch()


func _attempt_fetch() -> void:
    print("[RemoteConfig] Fetching remote config...")
    var error := _http_request.request(REMOTE_CONFIG_URL)
    if error != OK:
        push_warning("[RemoteConfig] Request failed to start: %s" % error_string(error))
        _handle_fetch_failure()


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
    _is_fetching = false

    if result != HTTPRequest.RESULT_SUCCESS:
        push_warning("[RemoteConfig] Request failed: result=%d" % result)
        _handle_fetch_failure()
        return

    if response_code != 200:
        push_warning("[RemoteConfig] HTTP error: %d" % response_code)
        _handle_fetch_failure()
        return

    var json = JSON.parse_string(body.get_string_from_utf8())
    if json == null or not json is Dictionary:
        push_error("[RemoteConfig] Invalid JSON response")
        _handle_fetch_failure()
        return

    # Success! Update cache and apply
    _save_cache(json)
    _current_config = json
    _retry_count = 0
    print("[RemoteConfig] Config loaded successfully")
    config_loaded.emit(_current_config)


func _handle_fetch_failure() -> void:
    _retry_count += 1

    if _retry_count <= MAX_RETRIES:
        var delay := BASE_RETRY_DELAY * pow(2, _retry_count - 1)
        print("[RemoteConfig] Retry %d/%d in %.1fs" % [_retry_count, MAX_RETRIES, delay])
        var timer := get_tree().create_timer(delay)
        timer.timeout.connect(_attempt_fetch)
        return

    # Max retries exceeded - use fallback
    print("[RemoteConfig] Max retries reached, using fallback")
    _use_fallback()


func _use_fallback() -> void:
    _is_fetching = false

    # Try cache first (even if stale)
    var cached := _load_cache()
    if not cached.is_empty():
        print("[RemoteConfig] Using stale cache as fallback")
        _current_config = cached
        config_loaded.emit(_current_config)
        return

    # No cache - emit empty config (caller uses local defaults)
    print("[RemoteConfig] No cache available, using local defaults")
    config_loaded.emit({})


func _is_cache_valid() -> bool:
    if not FileAccess.file_exists(CACHE_PATH):
        return false

    var modified := FileAccess.get_modified_time(CACHE_PATH)
    var now := int(Time.get_unix_time_from_system())
    return (now - modified) < CACHE_MAX_AGE


func _load_cache() -> Dictionary:
    if not FileAccess.file_exists(CACHE_PATH):
        return {}

    var file := FileAccess.open(CACHE_PATH, FileAccess.READ)
    if file == null:
        return {}

    var content := file.get_as_text()
    file.close()

    var json = JSON.parse_string(content)
    if json is Dictionary:
        return json
    return {}


func _save_cache(config: Dictionary) -> void:
    var file := FileAccess.open(CACHE_PATH, FileAccess.WRITE)
    if file == null:
        push_warning("[RemoteConfig] Failed to write cache")
        return

    file.store_string(JSON.stringify(config))
    file.close()


## Get current config value with fallback to default
func get_value(key: String, default_value: Variant = null) -> Variant:
    return _current_config.get(key, default_value)
```

---

## Mobile-Specific Considerations

### Network Connectivity

Mobile networks are unreliable. Always assume requests can fail:

1. **Check connectivity first** (optional, as request failure handles this)
2. **Use shorter timeouts** - users don't want to wait
3. **Cache aggressively** - minimize network calls
4. **Background fetch** - load config before needed

### Battery Considerations

- Don't poll frequently - once per session is usually enough
- Disable fetch when app is backgrounded
- Use compression (gzip) to reduce data transfer

### Platform Differences

| Platform | Consideration |
|----------|--------------|
| iOS | Requires HTTPS |
| Android | May need internet permission |
| Web | CORS restrictions apply |

---

## Integration with economy_config.gd

The existing `economy_config.gd` already has a placeholder for remote config. The implementation should:

1. Add HTTPRequest node management
2. Implement caching to `user://economy_config_cache.json`
3. Add retry logic with exponential backoff
4. Call `_apply_config()` on successful fetch
5. Emit `config_loaded` signal when ready
6. Keep local defaults as ultimate fallback

### Suggested Changes

Replace the `_fetch_remote_config()` placeholder with the full implementation pattern above, adapting the key names to match the existing `_apply_config()` method.

---

## Alternative: Firebase Remote Config

For more sophisticated needs (A/B testing, user segmentation), consider:

- [GodotNuts/GodotFirebase](https://github.com/GodotNuts/GodotFirebase) - Pure GDScript Firebase SDK
- [DrMoriarty Firebase Plugin](https://github.com/DrMoriarty/godot-firebase-remoteconfig) - Remote Config specifically
- [Joystick Remote Config](https://docs.getjoystick.com/sdk-joystick-godot/) - Game-focused alternative

Firebase offers:
- A/B testing with analytics integration
- User segmentation (by version, locale, etc.)
- Gradual rollouts
- Real-time updates

However, Firebase adds complexity and external dependencies. For GoDig's needs (economy tuning), a simple JSON endpoint is likely sufficient.

---

## Security Considerations

1. **Use HTTPS** - Always encrypt remote config traffic
2. **Validate responses** - Check data types, ranges
3. **Don't trust client** - Server should validate purchases independently
4. **Rate limit requests** - Prevent abuse (server-side)
5. **Sign responses** (optional) - Detect tampering for sensitive values

```gdscript
# Example: Validate ore value multiplier is within expected range
func _apply_config(config: Dictionary) -> void:
    if config.has("ore_value_multiplier"):
        var mult = config["ore_value_multiplier"]
        if mult is float and mult >= 0.1 and mult <= 10.0:
            ore_value_multiplier = mult
        else:
            push_warning("[RemoteConfig] Invalid ore_value_multiplier: %s" % str(mult))
```

---

## Sources

- [Godot HTTPRequest Documentation](https://docs.godotengine.org/en/stable/classes/class_httprequest.html)
- [Making HTTP Requests Tutorial](https://docs.godotengine.org/en/stable/tutorials/networking/http_request_class.html)
- [HTTPRequest Timeout Issue](https://github.com/godotengine/godot/issues/30276)
- [Connection Error Bug](https://github.com/godotengine/godot/issues/103202)
- [GodotNuts Firebase](https://github.com/GodotNuts/GodotFirebase)
- [Firebase Remote Config](https://firebase.google.com/docs/remote-config)
- [Joystick Remote Config for Godot](https://docs.getjoystick.com/sdk-joystick-godot/)
