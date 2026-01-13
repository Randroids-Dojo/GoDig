# GoDig Testing Guide

This project uses **PlayGodot** for E2E automated testing. PlayGodot enables Python-based tests that control the game via a WebSocket automation protocol.

## Prerequisites

PlayGodot requires a custom Godot fork with automation support. This is **not** the standard Godot Engine.

### Option 1: Download Pre-built Binary (Recommended)

Download the automation-enabled Godot from our releases:
- [godot-automation releases](https://github.com/Randroids-Dojo/godot/releases/tag/automation-latest)

### Option 2: Build from Source

```bash
# Clone the automation fork
git clone https://github.com/Randroids-Dojo/godot.git ../godot
cd ../godot
git checkout automation

# Build for your platform
# macOS (Apple Silicon)
scons platform=macos arch=arm64 target=editor -j8

# macOS (Intel)
scons platform=macos arch=x86_64 target=editor -j8

# Linux
scons platform=linuxbsd target=editor -j8

# Windows
scons platform=windows target=editor -j8
```

## Setup

### 1. Configure Godot Path

Create a `.godot-path` file in the project root pointing to your automation-enabled Godot:

```bash
# macOS example
echo '/Users/yourname/Documents/Dev/Godot/godot/bin/godot.macos.editor.arm64' > .godot-path

# Or set environment variable
export GODOT_PATH=/path/to/godot/bin/godot.macos.editor.arm64
```

### 2. Install PlayGodot Python Library

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

# Run with parallel workers
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
from helpers import PATHS

@pytest.mark.asyncio
async def test_something(game):
    """Test description."""
    # Check if a node exists
    exists = await game.node_exists("/root/Main")
    assert exists["exists"]

    # Get a property
    result = await game.get_property("/root/Main/Label", "text")
    assert result["value"] == "Expected Text"

    # Call a method
    result = await game.call("/root/Main", "some_method")
    assert result["value"] == expected_value

    # Simulate input
    await game.press_action("fire")
    await game.click(100, 200)
```

### Available Commands

- `game.node_exists(path)` - Check if node exists
- `game.get_property(path, property)` - Get a node property
- `game.set_property(path, property, value)` - Set a node property
- `game.call(path, method, *args)` - Call a method on a node
- `game.press_action(action)` - Press an input action
- `game.hold_action(action, duration)` - Hold an input action
- `game.click(x, y)` - Click at coordinates
- `game.tap(x, y)` - Touch tap at coordinates
- `game.swipe(from_x, from_y, to_x, to_y)` - Swipe gesture
- `game.wait_seconds(seconds)` - Wait for time
- `game.wait_frames(count)` - Wait for frames
- `game.screenshot()` - Capture screenshot

## CI/CD

Tests run automatically in GitHub Actions. The workflow:

1. Downloads pre-built Godot automation binary
2. Installs PlayGodot Python library
3. Imports the Godot project
4. Runs all tests with 4 parallel workers
5. Uploads screenshots on failure

To disable tests in CI, set the repository variable `ENABLE_PLAYGODOT_TESTS=false`.
