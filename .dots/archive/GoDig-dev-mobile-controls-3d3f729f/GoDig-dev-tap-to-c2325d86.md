---
title: "implement: Tap-to-dig system"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:32:04.325708-06:00\""
closed-at: "2026-01-24T21:20:53.229682+00:00"
close-reason: Player has tap-to-dig system with hold for continuous mining
---

**STATUS: IMPLEMENTED** - See `scripts/player/player.gd` lines 500-635

Tap on adjacent blocks to dig them. World position to tile conversion. Adjacency check.

## Description

Implement a touch-friendly mining system where players can tap or hold on blocks to mine them. Support both single-tap (one hit) and hold-to-mine (continuous hits) for mobile UX.

## Context

Competitive analysis (see GoDig-research-competitive-analysis-6e5b16f9) shows player complaints about click fatigue in mining games. Players requested "hold down mouse button instead of needing to click for every stab." This is essential for mobile where repeated tapping causes hand strain.

## Affected Files

- `scripts/player/player.gd` - Add touch input handling
- `scripts/player/player_dig.gd` (if exists) - Mining logic
- `scripts/world/tilemap_controller.gd` - Block hit/break logic
- `scripts/ui/touch_controls.gd` - Touch input processing

## Implementation Notes

### Touch Input Detection

```gdscript
var _touch_hold_timer: float = 0.0
var _is_touch_held: bool = false
var _touch_target_tile: Vector2i = Vector2i(-1, -1)
const HOLD_THRESHOLD: float = 0.2  # seconds before continuous mining
const HOLD_MINE_INTERVAL: float = 0.15  # time between hits when holding

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _on_touch_start(event.position)
        else:
            _on_touch_end()
    elif event is InputEventScreenDrag:
        _on_touch_drag(event.position)

func _on_touch_start(screen_pos: Vector2) -> void:
    var world_pos = get_viewport().canvas_transform.affine_inverse() * screen_pos
    var tile_pos = tilemap.local_to_map(tilemap.to_local(world_pos))

    if _is_adjacent_to_player(tile_pos) and _can_dig_tile(tile_pos):
        _touch_target_tile = tile_pos
        _touch_hold_timer = 0.0
        _is_touch_held = true
        _hit_tile(tile_pos)  # Immediate first hit on tap

func _process(delta: float) -> void:
    if _is_touch_held and _touch_target_tile != Vector2i(-1, -1):
        _touch_hold_timer += delta
        if _touch_hold_timer >= HOLD_THRESHOLD:
            # Continuous mining while held
            _touch_hold_timer -= HOLD_MINE_INTERVAL
            _hit_tile(_touch_target_tile)
```

### Adjacency Check

```gdscript
func _is_adjacent_to_player(tile_pos: Vector2i) -> bool:
    var player_tile = tilemap.local_to_map(tilemap.to_local(player.global_position))
    var diff = tile_pos - player_tile
    # Allow down, left, right (not up in MVP)
    return abs(diff.x) <= 1 and abs(diff.y) <= 1 and not (diff.x == 0 and diff.y == 0)
```

### Visual Feedback

- Show mining progress indicator on held block
- Haptic feedback on each hit (if enabled)
- Different feedback for tap vs hold

## Verify

- [ ] Build succeeds
- [ ] Tapping adjacent block hits it once
- [ ] Holding on block for 0.2+ seconds starts continuous mining
- [ ] Releasing touch stops mining
- [ ] Dragging away from block stops mining that block
- [ ] Non-adjacent blocks cannot be mined (no response)
- [ ] Works with both touch and mouse input (for testing)
