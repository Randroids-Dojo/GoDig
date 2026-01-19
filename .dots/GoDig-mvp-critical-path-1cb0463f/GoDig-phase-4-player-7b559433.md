---
title: "research: Player Core"
status: closed
priority: 0
issue-type: task
created-at: "\"2026-01-16T00:41:38.175838-06:00\""
closed-at: "2026-01-19T10:05:50.188157-06:00"
close-reason: "Expanded 4 player-related implementation specs: grid digging, wall-jump, floating pickup, inventory tests"
---

## Summary

Player core research is complete. Implementation specs have been expanded with detailed guidance.

## Completed Research

### Grid Movement (Implemented)
- Player moves tile-by-tile on 128x128 grid
- State machine: IDLE -> MOVING -> MINING -> FALLING
- Tween-based movement for smooth transitions
- Touch and keyboard input support
- Implementation: `scripts/player/player.gd` (exists)

### Mining System (Implemented)
- Dig directions: Down, Left, Right (not up initially)
- Block hardness determines hits required
- Tool damage affects break speed
- Animation-driven hit timing
- Auto-move into destroyed block's space
- Implementation spec: `GoDig-dev-player-grid-02b8c1b9`

### Wall-Jump (Implemented)
- Core traversal mechanic (available from start)
- Wall-slide: Slow descent when pressed against wall
- Wall-jump: Launch away from wall with upward momentum
- Cooldown prevents instant re-grab
- Implementation spec: `GoDig-dev-player-wall-c3a0a39a`

### Inventory System (Implemented)
- InventoryManager singleton
- Slot-based storage with stacking
- 8-30 slots (upgradeable)
- Signals for UI feedback
- Save/load serialization
- Implementation: `scripts/autoload/inventory_manager.gd` (exists)
- Test spec: `GoDig-dev-inventory-system-bbefbf8d`

### Auto-Pickup (Implemented)
- Block destruction triggers `block_dropped` signal
- Item automatically added to inventory
- InventoryManager emits `item_added` for feedback
- Already implemented in `scripts/test_level.gd`
- Status: `GoDig-dev-auto-pickup-9886859c` (done)

### Floating Pickup Text
- Visual feedback when items collected
- Text floats up and fades out
- Rarity-based colors
- Screen space rendering
- Implementation spec: `GoDig-dev-floating-pickup-509c2d53`

## Implementation Spec Status

| Spec | Status |
|------|--------|
| Player grid digging | Expanded this session |
| Wall-jump ability | Expanded this session |
| Auto-pickup | Already implemented |
| Floating pickup text | Expanded this session |
| Inventory tests | Expanded this session |

## Player State Machine

```
IDLE
├── Direction pressed + no block -> MOVING
├── Direction pressed + block -> MINING
└── No ground below -> FALLING

MOVING
└── Tween complete -> Check ground -> IDLE or FALLING

MINING
├── Block destroyed -> MOVING (into space)
├── Block survives + still pressing -> Continue swing
└── Release direction -> IDLE

FALLING
├── Land on ground -> IDLE
├── Press toward wall -> WALL_SLIDING
└── Continue falling...

WALL_SLIDING
├── Press jump -> WALL_JUMPING
├── Release direction -> FALLING
└── Wall disappears -> FALLING

WALL_JUMPING
└── Apply forces -> FALLING
```

## Dependencies

Player system depends on:
- DirtGrid for block detection and mining
- DataRegistry for block hardness
- PlayerData for tool damage
- InventoryManager for item pickup
- GameManager for grid constants

## Questions Resolved

- Grid movement: Tile-based, 128px tiles
- Dig directions: Down/Left/Right (Up requires Drill upgrade at 500m)
- Wall-jump: Available from start (core mechanic)
- Inventory: Slot-based with stacking
- Auto-pickup: Immediate, no dropped items on ground

## Future Considerations (v1.0+)

- Drill upgrade to dig upward
- Fall damage system
- Ladders (placeable traversal)
- Rope item (consumable)
- Grappling hook (permanent tool)
- Player HP system
