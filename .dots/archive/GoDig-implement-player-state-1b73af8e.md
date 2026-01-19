---
title: "implement: Player state machine tests"
status: closed
priority: 1
issue-type: task
created-at: "\"2026-01-18T23:33:11.237293-06:00\""
closed-at: "2026-01-19T11:38:45.295363-06:00"
close-reason: Added 19 player state machine tests - CI passing
---

## Description

Add PlayGodot tests verifying player state transitions from the Wall-Jump spec (GoDig-mvp-wall-jump-476ebfdb) and Grid-Based Digging.

## Context

The player has states (IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING) but only the initial IDLE state is tested. These tests verify state transitions work correctly.

## Affected Files

- `tests/test_player_states.py` - NEW: Player state tests
- `tests/helpers.py` - MAY MODIFY: Add state enum constants

## Implementation Notes

### Required Tests

1. **test_player_starts_idle** - current_state == 0 (IDLE) at start
2. **test_player_enters_mining_state** - Simulate dig, verify state == MINING
3. **test_player_enters_falling_state** - No block below, state == FALLING
4. **test_player_wall_slide_constants_exist** - WALL_SLIDE_SPEED, WALL_JUMP_FORCE exist
5. **test_player_state_enum_values** - Verify all 6 states defined

### State Enum Reference

```gdscript
enum State { IDLE=0, MOVING=1, MINING=2, FALLING=3, WALL_SLIDING=4, WALL_JUMPING=5 }
```

### PlayGodot Pattern

```python
@pytest.mark.asyncio
async def test_player_wall_slide_constant(game):
    speed = await game.get_property(PATHS['player'], 'WALL_SLIDE_SPEED')
    assert speed == 50.0, 'Wall slide speed should be 50'
```

### Notes

- State transitions require game simulation (dig block, fall into void)
- Some tests may need to wait for physics/tweens
- Focus on verifiable constants first, then state transitions

## Verify

- [ ] Build succeeds
- [ ] All 5 player state tests pass
- [ ] State constants match spec values
- [ ] CI workflow passes
