---
title: "implement: Chunk loading priority (vertical)"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T00:59:08.603755-06:00\""
closed-at: "2026-01-19T19:34:24.927477-06:00"
close-reason: Chunk loading in dirt_grid.gd
---

## Description

NOTE: This functionality is already specified in `GoDig-dev-chunkmanager-load-11c71de3` (ChunkManager spec). See `_chunk_priority_sort()` method.

This dot documents the priority algorithm for reference.

## Already Specified in ChunkManager

The ChunkManager spec includes `_chunk_priority_sort()`:

```gdscript
func _chunk_priority_sort(a: Vector2i, b: Vector2i) -> bool:
    # Prioritize chunks below player (y increases downward)
    var a_below := a.y > _player_chunk.y
    var b_below := b.y > _player_chunk.y
    if a_below != b_below:
        return a_below  # Below comes first

    # Then by distance
    var dist_a := (a - _player_chunk).length()
    var dist_b := (b - _player_chunk).length()
    return dist_a < dist_b
```

## Priority Order

1. **Chunks below player** - Primary play direction is digging down
2. **Same Y-level chunks** - Horizontal exploration
3. **Chunks above player** - Rarely needed (escape routes)

Within each tier, closer chunks load first.

## Rationale

- Mining games primarily involve downward movement
- Players rarely go back up (surface return uses teleport/elevator)
- Loading chunks ahead of the player prevents pop-in
- If player is digging left at depth 500, chunk at (x-1, 500) loads before (x, 499)

## Alternative: Direction-Aware Priority

Could enhance to consider player's recent movement direction:

```gdscript
var _last_move_direction: Vector2i = Vector2i(0, 1)  # Default: down

func _chunk_priority_sort(a: Vector2i, b: Vector2i) -> bool:
    # Score based on alignment with movement direction
    var score_a := (a - _player_chunk).dot(_last_move_direction)
    var score_b := (b - _player_chunk).dot(_last_move_direction)
    if score_a != score_b:
        return score_a > score_b  # Higher alignment = higher priority
    # Fallback to distance
    return (a - _player_chunk).length() < (b - _player_chunk).length()
```

This is a v1.0 enhancement, not MVP.

## Verify

- [ ] ChunkManager spec includes priority sort
- [ ] Chunks below player load before chunks above
- [ ] Distance is used as tiebreaker
- [ ] No visible pop-in when digging downward
