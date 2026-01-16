# Testing & QA Strategy Research

## Sources
- [Godot Unit Testing](https://docs.godotengine.org/en/stable/tutorials/scripting/unit_testing.html)
- [GdUnit4 Framework](https://mikeschulze.github.io/gdUnit4/)
- [Mobile Game Testing Best Practices](https://www.browserstack.com/guide/mobile-game-testing)

## Testing Layers

### 1. Unit Tests
Test individual functions and classes in isolation.

**What to Unit Test:**
- Inventory add/remove/stack logic
- Currency calculations
- Damage formulas
- Upgrade cost calculations
- Save/load serialization

**GdUnit4 Example:**
```gdscript
# test_inventory.gd
extends GdUnitTestSuite

func test_add_item_to_empty_inventory():
    var inventory = Inventory.new()
    inventory.add_item("coal", 5)
    assert_int(inventory.get_count("coal")).is_equal(5)

func test_stack_items():
    var inventory = Inventory.new()
    inventory.add_item("coal", 5)
    inventory.add_item("coal", 3)
    assert_int(inventory.get_count("coal")).is_equal(8)

func test_inventory_full():
    var inventory = Inventory.new()
    inventory.max_slots = 2
    inventory.add_item("coal", 10)
    inventory.add_item("iron", 10)
    var result = inventory.add_item("gold", 5)
    assert_bool(result).is_false()
```

### 2. Integration Tests
Test systems working together.

**What to Integration Test:**
- Chunk generation + ore spawning
- Player movement + collision
- Shop buy/sell + inventory + currency
- Save game + load game round-trip

**PlayGodot Integration:**
```python
# tests/test_game_integration.py
import pytest
from playgodot import PlayGodot

@pytest.mark.asyncio
async def test_player_can_dig():
    async with PlayGodot() as game:
        await game.load_scene("res://scenes/main.tscn")
        
        # Get initial depth
        initial_depth = await game.get_property("/root/Main/Player", "depth")
        
        # Simulate dig action
        await game.call_method("/root/Main/Player", "dig", [Vector2.DOWN])
        await game.wait(0.5)
        
        # Check depth increased
        new_depth = await game.get_property("/root/Main/Player", "depth")
        assert new_depth > initial_depth

@pytest.mark.asyncio
async def test_sell_resources():
    async with PlayGodot() as game:
        await game.load_scene("res://scenes/main.tscn")
        
        # Add items to inventory
        await game.call_method("/root/Main/Player", "add_to_inventory", ["coal", 10])
        
        # Enter shop and sell
        await game.call_method("/root/Main/Shop", "sell_item", ["coal", 10])
        
        # Verify coins increased
        coins = await game.get_property("/root/Main/Player", "coins")
        assert coins > 0
```

### 3. Visual/Screenshot Tests
Verify UI looks correct.

**Tools:**
- Godot's `get_viewport().get_texture().get_image()`
- Image comparison libraries
- Visual regression testing

### 4. Performance Tests
Ensure game runs well on target devices.

**Metrics to Test:**
- FPS during chunk generation
- Memory usage over time
- Load times
- Battery drain rate

**Automated Performance Test:**
```gdscript
func test_chunk_generation_performance():
    var start_time = Time.get_ticks_msec()
    
    for i in range(100):
        ChunkManager.generate_chunk(Vector2i(i, 0))
    
    var elapsed = Time.get_ticks_msec() - start_time
    assert(elapsed < 5000, "Chunk generation too slow: %dms" % elapsed)
```

### 5. Device Testing
Test on real devices.

**Test Matrix:**
| Device Type | Examples | Priority |
|-------------|----------|----------|
| Low-end Android | Redmi 9, Moto G | High |
| Mid-range Android | Pixel 4a, Samsung A52 | High |
| High-end Android | Pixel 7, Samsung S23 | Medium |
| iPhone SE | Older iOS | High |
| iPhone 14+ | Latest iOS | Medium |
| Tablet | iPad, Android tablet | Low |

## Test Categories

### Smoke Tests (Every Build)
Quick sanity checks:
- [x] Smoke: Game launches without crash
- [x] Smoke: Player movement works
- [x] Smoke: Digging functional
- [x] Smoke: Shop UI opens
- [x] Smoke: Save creates file

### Regression Tests (Before Release)
Full test suite:
- [x] Regression: All unit tests pass
- [x] Regression: All integration tests pass
- [x] Regression: 30-min stability test
- [x] Regression: Save/load round-trip
- [x] Regression: All shops tested

### Compatibility Tests
- [x] Compatibility: Multiple screen sizes
- [x] Compatibility: Portrait mode verified
- [x] Compatibility: Low memory graceful handling
- [x] Compatibility: Interrupt handling (auto-pause)
- [x] Compatibility: Background/resume cycle

## Beta Testing Strategy

### Internal Alpha
- Team testing only
- Focus on bugs and crashes
- No public access

### Closed Beta
**Platform Options:**
- TestFlight (iOS)
- Google Play Internal Testing
- itch.io password-protected

**Beta Tester Recruitment:**
- Discord community
- Reddit r/playmygame
- Friends and family

**Beta Size:** 50-100 testers

### Open Beta
**Platform Options:**
- Google Play Open Testing
- TestFlight public link
- Web build on itch.io

**Size:** 500-1000 testers

### Beta Feedback Collection
```
Beta Feedback Form:
1. Device model: ___
2. OS version: ___
3. Play time: ___
4. Bugs encountered: ___
5. What did you enjoy? ___
6. What was frustrating? ___
7. Would you play after launch? [1-5]
```

## Bug Tracking

### Categories
- **Critical**: Crash, data loss, unplayable
- **Major**: Feature broken, major annoyance
- **Minor**: Visual glitch, small issue
- **Enhancement**: Nice to have

### Bug Report Template
```
Title: [Brief description]
Severity: [Critical/Major/Minor]
Device: [Model, OS version]
Steps to Reproduce:
1. ...
2. ...
3. ...
Expected: [What should happen]
Actual: [What happened]
Screenshot/Video: [Attach]
```

### Tools
- GitHub Issues (free, integrated)
- Linear (modern, fast)
- Trello (simple, visual)

## CI/CD Testing

### GitHub Actions Pipeline
```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1
        with:
          version: 4.3
      - name: Run GdUnit4 tests
        run: godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd

  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Python
        uses: actions/setup-python@v4
      - name: Install PlayGodot
        run: pip install playgodot pytest-asyncio
      - name: Run integration tests
        run: pytest tests/ -v
```

## Test Schedule

### During Development
- Unit tests: On every commit
- Integration tests: Daily
- Manual play: Weekly

### Pre-Release
- Full regression: 2 weeks before
- Beta testing: 4 weeks before launch
- Device testing: 1 week before

### Post-Release
- Monitor crash reports
- Hot-fix critical bugs
- Continue beta for updates

## Questions to Resolve
- [x] Test framework → GdUnit4 for unit tests
- [x] Beta size → 50-100 closed, 500+ open
- [x] Beta duration → 4 weeks minimum
- [x] Must-test → Low-end Android, iPhone SE, mid-range
- [x] Bug bounty → Credit in game, no monetary
