# GoDig Testing Guide

This project uses **PlayGodot** for E2E automated testing. PlayGodot enables Python-based tests that control the game via a WebSocket automation protocol.

## IMPORTANT: Godot Automation Fork Required

**You cannot run PlayGodot tests with standard Godot Engine.**

PlayGodot requires our custom Godot fork with automation protocol support. This fork adds WebSocket-based automation capabilities that standard Godot does not have.

### Local Development

For local testing, use the sibling `../godot` directory:

```
Documents/Dev/Godot/
├── godot/          # Automation fork (required for testing)
│   └── bin/
│       └── godot.macos.editor.arm64  # Built binary
└── GoDig/          # This project
```

### Quick Setup

```bash
# 1. Clone the automation fork as a sibling directory
git clone https://github.com/Randroids-Dojo/godot.git ../godot
cd ../godot
git checkout automation

# 2. Build for your platform
# macOS Apple Silicon:
scons platform=macos arch=arm64 target=editor -j8

# macOS Intel:
scons platform=macos arch=x86_64 target=editor -j8

# Linux:
scons platform=linuxbsd target=editor -j8

# 3. Create .godot-path in GoDig (auto-detected, but explicit is better)
cd ../GoDig
echo '../godot/bin/godot.macos.editor.arm64' > .godot-path
```

### CI/CD

The GitHub Actions workflow automatically:
1. Downloads a pre-built automation-enabled Godot from [Randroids-Dojo/godot releases](https://github.com/Randroids-Dojo/godot/releases/tag/automation-latest)
2. Uses `godot.linuxbsd.editor.x86_64.mono` for Linux runners
3. Runs tests in headless mode with Xvfb

You don't need to configure anything for CI - it handles the automation fork automatically.

## Godot Path Configuration

The test framework searches for Godot in this order:

1. **`GODOT_PATH` environment variable** - Explicit override
2. **`.godot-path` file** - Project-local config (gitignored)
3. **`../godot/bin/`** - Sibling directory (recommended for local dev)
4. **Well-known locations** - `~/Documents/Dev/Godot/godot/bin/`, etc.

### Recommended: Use .godot-path

Create a `.godot-path` file pointing to your built automation fork:

```bash
# macOS Apple Silicon
echo '/Users/yourname/Documents/Dev/Godot/godot/bin/godot.macos.editor.arm64' > .godot-path

# macOS Intel
echo '/Users/yourname/Documents/Dev/Godot/godot/bin/godot.macos.editor.x86_64' > .godot-path

# Linux
echo '/home/yourname/godot/bin/godot.linuxbsd.editor.x86_64' > .godot-path
```

## Installing PlayGodot Python Library

```bash
# Clone PlayGodot
git clone https://github.com/Randroids-Dojo/PlayGodot.git

# Install the Python library
cd PlayGodot/python
pip install -e .

# Install test dependencies
pip install pytest pytest-asyncio pytest-xdist
```

## Running Tests

```bash
# Run all tests
pytest tests/ -v

# Run with parallel workers (faster)
pytest tests/ -v -n 4

# Run a specific test
pytest tests/test_hello_world.py -v

# Run with verbose output
pytest tests/ -v --tb=long
```

## Writing Tests

Tests use Python's `pytest` with `pytest-asyncio` for async support.

### Basic Test Structure

```python
import pytest

@pytest.mark.asyncio
async def test_something(game):
    """Test description."""
    # Check if a node exists (returns bool)
    exists = await game.node_exists("/root/Main")
    assert exists

    # Get a property (returns value directly)
    text = await game.get_property("/root/Main/Label", "text")
    assert text == "Expected Text"

    # Call a method (returns result directly)
    result = await game.call("/root/Main", "some_method")
    assert result == expected_value

    # Simulate input
    await game.press_action("fire")
    await game.click(100, 200)
```

### Available Commands

- `game.node_exists(path)` - Check if node exists (returns bool)
- `game.get_property(path, property)` - Get a node property (returns value)
- `game.set_property(path, property, value)` - Set a node property
- `game.call(path, method, args=[])` - Call a method on a node (returns result)
- `game.press_action(action)` - Press an input action
- `game.hold_action(action, duration)` - Hold an input action
- `game.click(x, y)` - Click at coordinates
- `game.tap(x, y)` - Touch tap at coordinates
- `game.swipe(from_x, from_y, to_x, to_y)` - Swipe gesture
- `game.wait_seconds(seconds)` - Wait for time
- `game.wait_frames(count)` - Wait for frames
- `game.screenshot()` - Capture screenshot

## Troubleshooting

### "GODOT AUTOMATION FORK NOT FOUND"

You're trying to run tests without the automation fork. See setup instructions above.

### Tests hang or timeout

- Ensure you're using the automation fork, not standard Godot
- Check that the game scene loads correctly in the editor first
- Verify node paths in your tests match the actual scene structure

### "Node not found" errors

- Double-check node paths using the Godot editor's scene tree
- Remember paths start from `/root/` not the scene root
- Autoloads are at `/root/AutoloadName`
