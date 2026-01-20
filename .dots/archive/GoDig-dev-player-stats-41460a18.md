---
title: "implement: Player statistics tracking"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-16T01:08:15.657203-06:00\""
closed-at: "2026-01-19T19:34:38.754058-06:00"
close-reason: Player stats in player_data.gd
---

Track max_depth_reached, total_coins_earned, blocks_mined, time_played. Save with player data for achievements.

## Description

Implement a statistics tracking system that records player accomplishments throughout gameplay. These stats feed into achievements, leaderboards (future), and provide satisfying "you've played X hours" type metrics.

## Context

- No player stats tracking currently exists
- SaveManager spec includes some stats in SaveData but nothing populates them
- Achievements and depth milestones need stat data
- Tool tier tracking is also needed here (see GoDig-implement-wire-tool-e8875437)

## Affected Files

- `scripts/autoload/game_manager.gd` - Add stats tracking here OR
- `scripts/autoload/player_stats.gd` - NEW: Dedicated stats singleton
- `resources/save/save_data.gd` - Stats need to be serialized

## Implementation Notes

### Option A: Extend GameManager (Simpler)

Add stats tracking directly to GameManager since it already handles coins and depth:

```gdscript
# game_manager.gd additions

signal stat_updated(stat_name: String, value: Variant)
signal milestone_reached(stat_name: String, value: int)

# Statistics
var stats := {
    "max_depth_reached": 0,
    "total_coins_earned": 0,
    "blocks_mined": 0,
    "ores_collected": 0,
    "time_played": 0.0,
    "deaths": 0,
    "tool_upgrades_purchased": 0,
    "inventory_upgrades_purchased": 0,
}

# Tool/equipment state
var current_tool_tier: int = 1
var current_tool_damage: float = 1.0

const TOOL_DAMAGE_BY_TIER := [1.0, 2.0, 3.5, 5.0]

# Milestone thresholds for notifications
const DEPTH_MILESTONES := [10, 25, 50, 100, 200, 500, 1000]
const COINS_MILESTONES := [100, 500, 1000, 5000, 10000]


func _process(delta: float) -> void:
    if is_running:
        stats.time_played += delta


func update_depth(depth: int) -> void:
    current_depth = depth
    depth_updated.emit(depth)

    # Track max depth
    if depth > stats.max_depth_reached:
        stats.max_depth_reached = depth
        stat_updated.emit("max_depth_reached", depth)

        # Check milestones
        for milestone in DEPTH_MILESTONES:
            if stats.max_depth_reached >= milestone and depth - 1 < milestone:
                milestone_reached.emit("max_depth_reached", milestone)


func add_coins(amount: int) -> void:
    if amount <= 0:
        return
    coins += amount
    stats.total_coins_earned += amount
    stat_updated.emit("total_coins_earned", stats.total_coins_earned)
    coins_added.emit(amount)
    coins_changed.emit(coins)


func record_block_mined(ore_id: String = "") -> void:
    stats.blocks_mined += 1
    if not ore_id.is_empty():
        stats.ores_collected += 1
    stat_updated.emit("blocks_mined", stats.blocks_mined)


func record_death() -> void:
    stats.deaths += 1
    stat_updated.emit("deaths", stats.deaths)


func upgrade_tool() -> void:
    if current_tool_tier < TOOL_DAMAGE_BY_TIER.size():
        current_tool_tier += 1
        current_tool_damage = TOOL_DAMAGE_BY_TIER[current_tool_tier - 1]
        stats.tool_upgrades_purchased += 1
        tool_upgraded.emit(current_tool_tier, current_tool_damage)


func get_tool_tier() -> int:
    return current_tool_tier


func get_tool_damage() -> float:
    return current_tool_damage


# Serialization for save/load
func get_stats_data() -> Dictionary:
    return stats.duplicate()


func load_stats_data(data: Dictionary) -> void:
    for key in data:
        if stats.has(key):
            stats[key] = data[key]
```

### Option B: Dedicated PlayerStats Singleton

If stats grow complex, separate them:

```gdscript
# player_stats.gd
extends Node

signal stat_updated(stat_name: String, value: Variant)
signal milestone_reached(stat_name: String, value: int)

var stats := {}  # Same structure as above
var milestones := {}  # Same structure

# ... similar implementation
```

Recommendation: Start with Option A (extend GameManager) since it's simpler and avoids another autoload. Refactor to separate singleton only if it becomes unwieldy.

### Integration Points

Where stats get updated:
- `blocks_mined`: DirtGrid.hit_block() when block destroyed
- `ores_collected`: DirtGrid.hit_block() when ore_id not empty
- `max_depth`: GameManager.update_depth() (already called by player)
- `total_coins_earned`: GameManager.add_coins() (already exists)
- `time_played`: GameManager._process() when is_running
- `deaths`: Death/respawn system (future)
- `tool_upgrades_purchased`: Shop._on_tool_upgrade()

### Save Integration

SaveData.gd should include:
```gdscript
@export var stats: Dictionary = {}
@export var current_tool_tier: int = 1
```

SaveManager._collect_game_state():
```gdscript
current_save.stats = GameManager.get_stats_data()
current_save.current_tool_tier = GameManager.current_tool_tier
```

## Verify

- [ ] time_played increases while game is running
- [ ] max_depth_reached updates when player goes deeper
- [ ] max_depth_reached does NOT decrease when player returns to surface
- [ ] blocks_mined increments on each block destroyed
- [ ] ores_collected only counts ore blocks, not dirt
- [ ] total_coins_earned is cumulative (not current balance)
- [ ] Stats persist across save/load
- [ ] Milestone signals fire at correct thresholds
- [ ] Tool tier and damage accessible via GameManager
