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

**ALWAYS troubleshoot CI issues when pushing.**

After any `git push`, you must:
1. Check the CI workflow status using `gh run list --limit 1`
2. If the run fails, investigate with `gh run view <run-id> --log-failed`
3. Fix any failing tests or build issues before considering the task complete
4. Re-push and verify CI passes

Do not consider a push successful until CI is green.

## Task Management with Dots

**Use `dot` for tracking work items during sessions.**

Dots is a lightweight task tracker for managing work. Use it to track discrete tasks, bugs, and features.

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

### Workflow

1. **Starting a session**: Run `dot ready` to see available work
2. **Claiming work**: Run `dot on <id>` before starting
3. **Completing work**: Run `dot off <id>` when done
4. **Creating subtasks**: Use `-P parent-id` for hierarchical organization

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

### Diagnosing Test Failures

1. **Check Godot stderr** for script errors (compilation failures)
2. **Check timeouts** - increase if scene loading is slow
3. **Verify node paths** - use Godot editor to confirm exact paths
4. **Run single test** with verbose output: `pytest tests/test_file.py::test_name -v -s`

