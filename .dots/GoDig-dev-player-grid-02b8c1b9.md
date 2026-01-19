---
title: "implement: Player grid-based digging"
status: open
priority: 1
issue-type: task
created-at: "2026-01-16T00:38:04.468055-06:00"
---

## Description

Implement grid-based movement and mining for the player. Player moves tile-by-tile on a grid, mining adjacent blocks in down/left/right directions. Each block takes multiple hits based on hardness, and the player moves into the block's space once destroyed.

## Context

Grid-based movement is already implemented in `player.gd` with states:
- `State.IDLE` - Player stationary, ready for input
- `State.MOVING` - Tween-based movement between tiles
- `State.MINING` - Swinging pickaxe at adjacent block

Key design decisions (from mining-mechanics.md):
- Tiles are player-sized (128x128 pixels)
- Can dig down, left, right (NOT up initially - Drill upgrade required)
- Multiple hits required based on block hardness
- Player must hold direction key to continue mining

## Affected Files

- `scripts/player/player.gd` - Core movement and mining logic (exists)
- `scripts/world/dirt_grid.gd` - Block health and destruction
- `scripts/autoload/data_registry.gd` - Block hardness lookup
- `scripts/autoload/player_data.gd` - Tool damage lookup

## Implementation Notes

### Current Implementation (in player.gd)

```gdscript
const BLOCK_SIZE := 128
const MOVE_DURATION := 0.15  # Seconds per tile movement

enum State { IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING }

var current_state: State = State.IDLE
var grid_position: Vector2i
var mining_direction: Vector2i
var mining_target: Vector2i
```

### Input Direction Detection

```gdscript
func _get_input_direction() -> Vector2i:
    # Check touch controls first
    if touch_direction != Vector2i.ZERO:
        return touch_direction

    # Fall back to keyboard
    if Input.is_action_pressed("move_down"):
        return Vector2i(0, 1)
    elif Input.is_action_pressed("move_left"):
        return Vector2i(-1, 0)
    elif Input.is_action_pressed("move_right"):
        return Vector2i(1, 0)
    return Vector2i.ZERO
```

### Movement vs Mining Decision

```gdscript
func _try_move_or_mine(direction: Vector2i) -> void:
    var target := grid_position + direction

    # Check bounds
    if target.x < 0 or target.x >= GameManager.GRID_WIDTH:
        return

    # Check if target has a block
    if dirt_grid and dirt_grid.has_block(target):
        _start_mining(direction, target)
    else:
        _start_move(target)
```

### Mining State

```gdscript
func _start_mining(direction: Vector2i, target_block: Vector2i) -> void:
    current_state = State.MINING
    mining_direction = direction
    mining_target = target_block

    # Flip sprite based on direction
    if direction.x != 0:
        sprite.flip_h = (direction.x < 0)

    sprite.play("swing")
```

### Block Hit on Animation Complete

```gdscript
func _on_animation_finished() -> void:
    if current_state != State.MINING:
        return

    if dirt_grid == null:
        current_state = State.IDLE
        return

    var destroyed: bool = dirt_grid.hit_block(mining_target)

    if destroyed:
        block_destroyed.emit(mining_target)
        _start_move(mining_target)  # Move into destroyed space
    else:
        # Continue mining if still pressing
        var dir := _get_input_direction()
        if dir == mining_direction:
            sprite.play("swing")
        else:
            current_state = State.IDLE
```

### Block Health System (in dirt_grid.gd)

```gdscript
func hit_block(pos: Vector2i, tool_damage: float = -1.0) -> bool:
    if not _active.has(pos):
        return true  # Already gone

    var block = _active[pos]

    # Get tool damage from PlayerData
    var damage := tool_damage
    if damage < 0:
        if PlayerData != null:
            damage = PlayerData.get_tool_damage()
        else:
            damage = 10.0  # Default

    var destroyed: bool = block.take_hit(damage)

    if destroyed:
        var ore_id := _ore_map.get(pos, "") as String
        block_dropped.emit(pos, ore_id)
        if _ore_map.has(pos):
            _ore_map.erase(pos)
        _release(pos)

    return destroyed
```

### Block Hardness (in dirt_block.gd)

```gdscript
func activate(grid_pos: Vector2i) -> void:
    _grid_position = grid_pos
    visible = true

    # Get hardness from layer
    _max_health = DataRegistry.get_block_hardness(grid_pos)
    _health = _max_health

func take_hit(damage: float) -> bool:
    _health -= damage
    # Visual feedback: flash or crack
    return _health <= 0
```

### Dig Direction Restriction

Currently: Down, Left, Right only
Future: Up (requires Drill upgrade at 500m depth)

```gdscript
func _get_input_direction() -> Vector2i:
    # Future: check for drill upgrade before allowing up
    # if Input.is_action_pressed("move_up") and PlayerData.has_drill():
    #     return Vector2i(0, -1)

    if Input.is_action_pressed("move_down"):
        return Vector2i(0, 1)
    # ... etc
```

### Falling After Mining

```gdscript
func _on_move_complete() -> void:
    grid_position = target_grid_position
    _update_depth()

    # Check if there's ground below
    if _should_fall():
        _start_falling()
    else:
        current_state = State.IDLE
```

## Edge Cases

- Mining at world edge: Check bounds before mining
- Mining block with ore: Drop ore item via signal
- Block destroyed while in MINING state: Move into space
- Multiple blocks in queue: Only mine one at a time
- Tool breakage (future): Check durability before mining

## Verify

- [ ] Build succeeds with no errors
- [ ] Player moves one tile when pressing direction (no block)
- [ ] Player mines when pressing direction (block exists)
- [ ] Multiple hits required for harder blocks
- [ ] Better tools break blocks faster
- [ ] Player moves into block's space after destruction
- [ ] Player falls if no ground below after mining
- [ ] Releasing direction key stops mining
- [ ] Works with both keyboard and touch controls
