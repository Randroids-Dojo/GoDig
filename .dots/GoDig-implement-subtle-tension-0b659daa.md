---
title: "implement: Subtle tension audio layer"
status: open
priority: 3
issue-type: task
created-at: "2026-02-01T02:17:39.226550-06:00"
---

## Description
Add ambient audio that shifts based on combined risk factors, creating subconscious pressure without being annoying.

## Context
Research shows audio cues are powerful for building tension. Dome Keeper and horror games use ambient audio layers that intensify based on player state. This should be SUBTLE - players may not consciously notice, but will feel the tension.

## Affected Files
- `scripts/autoload/sound_manager.gd` - Add tension audio system
- `scripts/ui/hud.gd` - Connect risk state to sound manager

## Implementation Notes
### Risk Factors to Monitor
1. Inventory fill percentage (weight: 40%)
2. Current depth (weight: 30%)
3. Ladder count vs safe threshold (weight: 30%)

### Combined Risk Score
```
risk_score = (inventory_fill * 0.4) + (depth_risk * 0.3) + (ladder_risk * 0.3)
where:
  inventory_fill = current_items / max_items
  depth_risk = clamp(depth / 100, 0, 1)
  ladder_risk = 1.0 - (current_ladders / safe_ladders)
```

### Audio Layers
| Risk Score | Audio Effect |
|------------|--------------|
| 0.0-0.3 | Normal ambient (peaceful) |
| 0.3-0.5 | Slight low rumble added |
| 0.5-0.7 | Heartbeat-like pulse (slow) |
| 0.7-0.85 | Heartbeat faster, rumble louder |
| 0.85-1.0 | Urgent, dramatic tension |

### Technical Approach
1. Create AudioStreamPlayer for tension layer
2. Use crossfade between intensity levels
3. Update risk score on relevant events (not every frame)
4. Volume should be LOW - this is ambient, not alert
5. Option in settings to disable

## Verify
- [ ] No tension audio at low risk
- [ ] Subtle rumble begins at moderate risk
- [ ] Heartbeat/pulse audible at high risk
- [ ] Audio intensity matches risk level
- [ ] Transitions are smooth (no jarring cuts)
- [ ] Can be disabled in settings
- [ ] Does not interfere with other game audio
