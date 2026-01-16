# Traversal Mechanics Research

## Sources
- [Godot 4 2D Platformer Tutorial - Ladders](https://dev.to/christinec_dev/learn-godot-4-by-making-a-2d-platformer-part-5-level-creation-2-239g)
- [Godot 2D Platformer Climbing](https://github.com/mujtaba-io/godot-2d-platformer-climbing)
- [Godot Forum - Climbing a Ladder](https://forum.godotengine.org/t/climbing-a-ladder/51110)

## Ladder Implementation

### Node Structure
```
Ladder (Area2D)
├── Sprite2D - Visual representation
└── CollisionShape2D (RectangleShape2D) - Detection zone
```

### Core Logic Pattern
```gdscript
# Ladder.gd
extends Area2D

func _on_body_entered(body):
    if body.name == "Player":
        body.set_climbing(true)

func _on_body_exited(body):
    if body.name == "Player":
        body.set_climbing(false)
```

### Player Climbing State
```gdscript
# Player.gd
var is_climbing: bool = false

func set_climbing(value: bool):
    is_climbing = value
    if is_climbing:
        velocity.y = 0  # Stop falling

func _physics_process(delta):
    if is_climbing:
        _handle_climbing(delta)
    else:
        _handle_normal_movement(delta)

func _handle_climbing(delta):
    var input_dir = Input.get_axis("move_up", "move_down")
    velocity.y = input_dir * climb_speed
    # No gravity while climbing
    move_and_slide()
```

## Player-Placed Ladders

### Design Considerations for GoDig

**Option A: Instant Placement**
- Click/tap to place ladder segment
- Consumes resource from inventory
- Immediate use
- Simple but potentially exploitable

**Option B: Build Animation**
- Short delay to "build" ladder
- Player vulnerable during build
- More realistic feel
- Adds risk/reward

**Option C: Ladder Kit**
- Place bottom, auto-extends upward
- Limited height per kit
- Encourages planning

### Placement Code Pattern
```gdscript
# Player.gd
func place_ladder():
    if not has_ladder_in_inventory():
        return

    var tile_pos = get_tile_at_feet()
    if can_place_ladder_at(tile_pos):
        consume_ladder_from_inventory()
        world.place_ladder(tile_pos)
        # Optionally auto-climb
        is_climbing = true
```

### Ladder Persistence
- Ladders are permanent once placed
- Stored in chunk data alongside dug tiles
- Could break from hazards (lava, enemies?)

## Wall Jumping

### As Alternative/Complement to Ladders

```gdscript
# Player.gd
var wall_jump_force = Vector2(200, -300)
var is_on_wall: bool = false

func _physics_process(delta):
    is_on_wall = is_on_wall_only()

    if is_on_wall and Input.is_action_just_pressed("jump"):
        velocity = wall_jump_force
        # Flip direction
        wall_jump_force.x *= -1
```

### Wall Slide (Slow Fall)
```gdscript
func _handle_wall_slide(delta):
    if is_on_wall and velocity.y > 0:
        velocity.y = min(velocity.y, wall_slide_speed)
```

## Rope Mechanics

### Deployable Rope (Consumable)
- Player throws rope upward
- Attaches to ceiling/anchor point
- Climbable like ladder
- Single use

### Grappling Hook (Permanent Tool)
- Aim and fire
- Pull player toward anchor
- Cooldown between uses
- Upgrade to increase range

### Rope Code Concept
```gdscript
func deploy_rope():
    var rope = RopeScene.instantiate()
    rope.position = position
    rope.extend_upward(max_rope_length)
    get_parent().add_child(rope)
    # Auto-grab
    is_climbing = true
    current_rope = rope
```

## Return-to-Surface Strategies

### Problem
Player digs deep, needs to get back up. Core tension of genre.

### Solutions (In Order of Game Progression)

1. **Basic: Walk/Jump Back**
   - Early game only
   - Forces player to dig smart paths
   - Creates route-planning gameplay

2. **Ladders (Consumable)**
   - Carry limited supply
   - Place strategically
   - Creates resource management

3. **Wall Jump (Skill Unlock)**
   - Requires dug walls (not solid rock)
   - Rewarding mastery skill
   - Always available once learned

4. **Ropes (Consumable)**
   - Faster than ladders
   - More expensive
   - Mid-game convenience

5. **Teleport Item (Rare)**
   - Instant return to surface
   - Expensive / rare find
   - Emergency escape

6. **Elevator Shaft (Building)**
   - Permanent fast travel
   - Must dig to connect
   - Major progression milestone

7. **Portal (Late Game)**
   - Place waypoint underground
   - Teleport back to it
   - Premium upgrade

## Fall Damage

### Design Decision
- Adds risk to deep falls
- Creates need for ladders/ropes
- Without it, player just falls to bottom

### Implementation
```gdscript
var fall_start_y: float = 0
var is_falling: bool = false
const FALL_DAMAGE_THRESHOLD = 200  # pixels
const DAMAGE_PER_UNIT = 0.1

func _physics_process(delta):
    if not is_on_floor() and velocity.y > 0:
        if not is_falling:
            is_falling = true
            fall_start_y = position.y
    elif is_on_floor() and is_falling:
        is_falling = false
        var fall_distance = position.y - fall_start_y
        if fall_distance > FALL_DAMAGE_THRESHOLD:
            take_fall_damage(fall_distance)

func take_fall_damage(distance: float):
    var excess = distance - FALL_DAMAGE_THRESHOLD
    var damage = excess * DAMAGE_PER_UNIT
    health -= damage
```

### Mitigation Options
- Boots upgrade reduces fall damage
- Landing on soft materials (dirt vs stone)
- Featherfall potion (temporary)
- Parachute item (late game)

## Questions to Resolve
- [x] Ladder segments or full ladder items? → Single segment per tile
- [x] Wall jump from start or unlock? → Available from start (core mechanic)
- [x] Fall damage severity curve → None in MVP, v1.0 feature
- [x] Rope vs Grappling hook vs both? → Both (rope consumable, hook permanent)
- [x] Touch controls for ladder placement → Tap tile + quick-slot HUD
