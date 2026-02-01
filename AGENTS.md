# GoDig Agent Instructions

## Integration Testing Requirements

**ALWAYS write or update PlayGodot integration tests when making changes.**

When implementing new features or modifying existing functionality:
1. Add tests to `tests/test_hello_world.py` (or create new test files in `tests/`)
2. Update `tests/helpers.py` with any new node paths
3. Run tests locally with `python3 -m pytest tests/ -v` before pushing
4. Ensure all tests pass before considering the task complete

### PlayGodot Test Patterns

```python
# tests/helpers.py - Define node paths
PATHS = {
    "main": "/root/Main",
    "player": "/root/Main/Player",
    "game_manager": "/root/GameManager",
}

# Test file - Use async tests with the game fixture
@pytest.mark.asyncio
async def test_node_exists(game):
    exists = await game.node_exists(PATHS["player"])
    assert exists, "Player node should exist"

@pytest.mark.asyncio
async def test_property_value(game):
    value = await game.get_property(PATHS["game_manager"], "is_running")
    assert value is True, "Game should be running"
```

### What to Test
- Scene structure (nodes exist at expected paths)
- Initial state (properties have correct default values)
- Game manager state
- UI elements display correct text
- New gameplay mechanics work as expected

## CI/CD Requirements

**CI is monitored automatically after every push.**

The post-push hook (`.claude/hooks/monitor-ci-after-push.sh`) automatically:
1. Finds the PR for your branch (with exponential backoff if PR doesn't exist yet)
2. Waits for CI to complete
3. Reports failures with actionable details

If CI fails, fix the issues and push again. The hook will report success or failure.

### Manual CI Troubleshooting

If you need to check CI manually:
```bash
gh run list --limit 1                    # See recent runs
gh run view <run-id> --log-failed        # See failure details
```

Do not consider a push successful until CI is green.

## Version Management

**Update the version before committing significant changes.**

The game version is stored in `project.godot`:

```ini
config/version="0.1.0"
```

### When to Update Version

- **Patch (0.0.X)**: Bug fixes, minor tweaks
- **Minor (0.X.0)**: New features, gameplay changes
- **Major (X.0.0)**: Breaking changes, major milestones

### How to Update

Edit `project.godot` line 14:

```bash
# Check current version
grep "config/version" project.godot

# Update manually or with sed
sed -i '' 's/config\/version="[^"]*"/config\/version="0.2.0"/' project.godot
```

Always update the version BEFORE committing, not after.

## Task Management with Dots

**Use `dot` for tracking work items during sessions.**

Dots is a lightweight task tracker for managing work. The `dot` CLI is automatically installed when you start a session (via `.claude/hooks/install-dots.sh`).

### Essential Session Workflow

**At the START of every session:**
```bash
dot ls          # Check ALL open tasks - see what needs to be done
dot ready       # Show tasks ready to work on (no blockers)
```

**BEFORE starting any task:**
```bash
dot on <id>     # Mark the task as in-progress
```

**AFTER completing any task:**
```bash
dot off <id> -r "What was done"   # Close with completion reason
```

This is mandatory. Never leave tasks open if you've completed them. Never start work without checking existing tasks first.

### Quick Reference

```bash
# Creating dots
dot "Fix the bug"                        # Quick add
dot add "Design API" -p 1 -d "Details"   # With priority and description
dot add "Subtask" -P dots-1              # As child of dots-1
dot add "After X" -a dots-2              # Depends on dots-2

# Working on dots
dot ls                    # List all open dots
dot ready                 # Show unblocked dots (ready to work)
dot on dots-3             # Start working on a dot
dot off dots-3            # Complete a dot
dot off dots-3 -r "Done"  # Complete with reason

# Viewing dots
dot show dots-1           # Show dot details
dot tree                  # Show hierarchy
dot find "query"          # Search dots
```

### Priority Levels

Use `-p` flag when creating dots:
- `0` = Critical (do now)
- `1` = High
- `2` = Medium (default)
- `3` = Low
- `4` = Backlog

### Closing Tasks Properly

**You MUST close tasks when done.** Every completed task needs:

1. `dot off <id>` - Mark it closed
2. `-r "reason"` - Explain what was done (helps future sessions)

Examples:
```bash
dot off dots-5 -r "Fixed null check in player.gd"
dot off dots-12 -r "Already implemented in previous session"
dot off dots-3 -r "Created PR #42, awaiting review"
```

### ALWAYS Update Dots After Changes

**After implementing any feature or fix, immediately update the corresponding dot.**

- When a task is complete: `dot off <id> -r "Brief description of what was done"`
- When discovering a task is already implemented: Close it with evidence
- When making partial progress: Add a note or create subtasks
- Before committing: Ensure all related dots are updated

This keeps the backlog accurate and prevents duplicate work across sessions.

### When to Use Dots vs TodoWrite

- **Dots**: Multi-step work, tasks that may span sessions, work with dependencies
- **TodoWrite**: Simple single-session execution tracking visible to user

## Randroid Loop Protection

**NEVER remove or cancel a Randroid loop without explicit user instruction.**

The Randroid loop file at `.claude/randroid-loop.local.md` controls iterative improvement tasks. When a Randroid loop is active:
1. Continue iterating until `max_iterations` is reached
2. Always keep the primer version as the quality baseline
3. Only update primer when improvements are validated
4. Do NOT delete the randroid-loop.local.md file
5. Do NOT run `/randroid:cancel` unless the user explicitly requests it

The Randroid loop is designed to run autonomously. Completion of work within an iteration does not mean the loop should stop.

## Asset Generation Pipeline

**Use the established procedural/composable pipelines for art assets.**

### Key Principle: Procedural > AI for Game Assets

| Asset Type | Tool | Location |
|------------|------|----------|
| **Terrain Tiles** | Procedural Generator | `scripts/tools/generate_dirt_textures.py` |
| **Character Animation** | Composable Sprite Builder | `scripts/tools/improved_sprite_builder_v4.py` |
| **Validation** | Texture/Component Validators | `scripts/tools/*_validator.py` |

### Quick Commands

```bash
# Generate terrain atlas
python scripts/tools/generate_dirt_textures.py --seed 42

# Validate terrain textures
python scripts/tools/texture_validator.py

# Generate single tile for testing
python scripts/tools/generate_dirt_textures.py --single dirt --seed 123

# Run all asset validators
python scripts/tools/validate_all.py
```

### Important Notes

1. **Procedural generation is preferred** for terrain tiles - it's faster, deterministic, and cross-platform
2. **MFLUX is macOS-only** - don't try to use it on Linux; use procedural generation instead
3. **Always validate** after generating assets - target score is 0.90+
4. **Document learnings** in `Docs/ASSET_GENERATION_LEARNINGS.md`
5. **Update quality report** in `Docs/ASSET_QUALITY_REPORT.md` after improvements

### Documentation

- `Docs/GAME_ART_ASSET_GENERATION.md` - Full pipeline documentation
- `Docs/ASSET_GENERATION_LEARNINGS.md` - Techniques and iteration insights
- `Docs/ASSET_QUALITY_REPORT.md` - Current quality metrics

## GDScript Common Pitfalls

**Avoid these common GDScript errors that cause test failures.**

### Node Name Mismatches

Script `@onready` references must match actual node names in scenes:

```gdscript
# In player.gd:
@onready var camera: Camera2D = $GameCamera  # Expects node named "GameCamera"

# In test_level.tscn - MUST match:
[node name="GameCamera" type="Camera2D" parent="Player"]  # ✓ Correct
[node name="Camera2D" type="Camera2D" parent="Player"]    # ✗ Will fail silently
```

**Fix**: When adding nodes in scenes, ensure names match script expectations exactly.

### Missing Function Definitions

If a function is called but not defined, Godot reports parse errors at all call sites:

```
SCRIPT ERROR: Parse Error: Function "_start_fall_tracking()" not found in base self.
          at: GDScript::reload (res://scripts/player/player.gd:515)
```

**Fix**: Search for all calls to the missing function and add the definition.

### Type Inference with Untyped Returns

When a method returns an untyped `Array`, using `:=` causes "Cannot infer type" errors in Godot 4.6+:

```gdscript
# BAD - Will fail with "Cannot infer the type of variable"
var items := some_method_returning_array()

# GOOD - Use = instead of := for untyped returns
var items = some_method_returning_array()

# BETTER - Add explicit type annotation
var items: Array = some_method_returning_array()
```

### Missing Method Cascades

A missing method causes script compilation to fail, which cascades to all dependent scripts:

```
SCRIPT ERROR: Parse Error: Cannot infer the type of "all_ores" variable...
   at: GDScript::reload (res://scripts/autoload/achievement_manager.gd:225)
SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
   at: GDScript::reload (res://scripts/autoload/save_manager.gd:0)
```

**Fix**: Always verify methods exist before calling them. Check autoload dependencies.

### Node Path Conventions

When scenes are nested (like HUD inside UI), paths must include the full hierarchy:

```gdscript
# BAD - Node is inside HUD, not directly in UI
@onready var depth_label: Label = $UI/DepthLabel

# GOOD - Include the intermediate node
@onready var depth_label: Label = $UI/HUD/DepthLabel
```

### Debugging GDScript Errors

Run Godot headless to see script errors that may not appear in test output:

```bash
godot --headless --path /path/to/project 2>&1 | head -50
```

Look for `SCRIPT ERROR:` lines to identify compilation issues.

## PlayGodot Troubleshooting

**Common issues and fixes for PlayGodot integration tests.**

### Scene Changes

The `change_scene` method works reliably with the latest PlayGodot and Godot automation releases:

```python
# Standard usage - works correctly
await game.change_scene("res://scenes/test_level.tscn")
```

### Resource Import Errors

If tests fail with "No loader found for resource", the project may not be imported:

```bash
# Run import before tests (CI does this automatically)
godot --headless --path . --import
```

### Godot 4 UID Files

Godot 4 creates `.uid` files to track resources with unique identifiers. **These files should be committed to version control** - they ensure consistent resource loading across machines and prevent UID conflicts.

```bash
# Track all .uid files
git add **/*.uid
```

Do NOT add `*.uid` to `.gitignore`.

### Diagnosing Test Failures

1. **Check Godot stderr** for script errors (compilation failures)
2. **Check timeouts** - increase if scene loading is slow
3. **Verify node paths** - use Godot editor to confirm exact paths
4. **Run single test** with verbose output: `pytest tests/test_file.py::test_name -v -s`

## Local Web Build Testing

**Test web builds locally before deploying to Vercel.**

### Building for Web

```bash
# Export web build (requires Godot 4.6+ non-Mono version)
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release "Web" build/index.html
```

**Note**: The Mono/C# version of Godot cannot export to web. Use the standard GDScript version.

### Running Locally with Required Headers

Godot web builds require `Cross-Origin-Opener-Policy` and `Cross-Origin-Embedder-Policy` headers for SharedArrayBuffer support. A simple Python server won't work.

Use the included server script:

```bash
cd build && python3 serve.py
# Opens at http://localhost:8080
```

Or create a server with headers:

```python
#!/usr/bin/env python3
from http.server import HTTPServer, SimpleHTTPRequestHandler

class CORSHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        SimpleHTTPRequestHandler.end_headers(self)

HTTPServer(('', 8080), CORSHandler).serve_forever()
```

### Web Export Compatibility

**DirAccess doesn't work in web builds.** Files are packed into `.pck` and can't be enumerated at runtime.

```gdscript
# BAD - DirAccess.open() returns null in web builds
var dir := DirAccess.open("res://resources/items/")
dir.list_dir_begin()  # Fails on web

# GOOD - Preload resources explicitly
const ITEM_RESOURCES := [
    preload("res://resources/items/rope.tres"),
    preload("res://resources/items/ladder.tres"),
]
```

See `scripts/autoload/data_registry.gd` for the pattern.

### Godot 4.6 Stricter Type Inference

Godot 4.6 is stricter about type inference. These patterns fail:

```gdscript
# BAD - for...else is Python syntax, not GDScript
for item in items:
    if condition:
        break
else:
    return false  # Parse error!

# GOOD - Use a flag
var found := false
for item in items:
    if condition:
        found = true
        break
if not found:
    return false
```

## UI Development Rules

**Follow these rules to prevent common UI issues.**

### Notification Stacking

Multiple notifications (achievements, pickups, hints) can trigger simultaneously. **Always implement stacking:**

```gdscript
# Track active notifications
var _active_notification_count: int = 0
const STACK_OFFSET := 40.0

func show_notification(text: String, base_pos: Vector2) -> void:
    var offset := _active_notification_count * STACK_OFFSET
    var pos := Vector2(base_pos.x, base_pos.y + offset)

    _active_notification_count += 1
    notification.tree_exited.connect(func():
        _active_notification_count = maxi(0, _active_notification_count - 1))

    notification.show(text, pos)
```

### UI Element Positioning

Position UI elements to avoid overlap:

| Element | Position | Notes |
|---------|----------|-------|
| Achievement notifications | Top center (y=60+) | Stack downward |
| Item pickups | Above player | Stack upward |
| Mining progress | Bottom center | Avoid notification areas |
| Tutorial overlays | True center | Auto-size to content |

### CanvasLayer Input Handling on Web

**Setting `visible = false` doesn't fully disable input on web builds.** Always explicitly disable input:

```gdscript
func hide_overlay() -> void:
    # CRITICAL: Disable input BEFORE hiding
    if background:
        background.mouse_filter = Control.MOUSE_FILTER_IGNORE

    # Then animate/hide
    visible = false

func show_overlay() -> void:
    visible = true
    # Re-enable input when showing
    if background:
        background.mouse_filter = Control.MOUSE_FILTER_STOP
```

### Auto-sizing Panels

Don't use fixed heights for content panels. Let them auto-size:

```gdscript
# BAD - Fixed size may be too tall or too short
panel.custom_minimum_size = Vector2(320, 180)

# GOOD - Min width only, height auto-sizes to content
panel.custom_minimum_size = Vector2(280, 0)

# Wait for layout before positioning
await get_tree().process_frame
var actual_size := panel.size
```

### Touch Events on Mobile Web

Handle both mouse and touch events for cross-platform support:

```gdscript
func _on_background_input(event: InputEvent) -> void:
    # Desktop mouse clicks
    if event is InputEventMouseButton and event.pressed:
        _handle_tap()
    # Mobile touch events
    elif event is InputEventScreenTouch and event.pressed:
        _handle_tap()
```

