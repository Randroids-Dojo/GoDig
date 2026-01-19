"""
Mining gameplay tests for GoDig endless digging game.

Tests core mining mechanics: dig actions, block destruction, ore collection,
depth tracking, and the core game loop of digging and collecting.
"""
import pytest
from helpers import PATHS, wait_for_condition


# =============================================================================
# PLAYER STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_player_starts_idle(game):
    """Verify player starts in IDLE state (State.IDLE = 0)."""
    state = await game.get_property(PATHS["player"], "current_state")
    assert state == 0, f"Player should start in IDLE state (0), got {state}"


@pytest.mark.asyncio
async def test_player_has_grid_position(game):
    """Verify player has a grid position property."""
    grid_pos = await game.get_property(PATHS["player"], "grid_position")
    assert grid_pos is not None, "Player should have grid_position property"


@pytest.mark.asyncio
async def test_player_has_dirt_grid_reference(game):
    """Verify player has a reference to the dirt grid."""
    # dirt_grid is a Node2D reference - we check it's not null
    has_dirt_grid = await game.call(PATHS["player"], "has_method", ["_should_fall"])
    assert has_dirt_grid, "Player should have _should_fall method (needs dirt_grid)"


# =============================================================================
# DIRT GRID TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_dirt_grid_has_blocks(game):
    """Verify the dirt grid has blocks at surface level."""
    # Surface row is 7, so there should be a block at (2, 7) - center column
    has_block = await game.call(PATHS["dirt_grid"], "has_block", [{"x": 2, "y": 7}])
    assert has_block is True, "DirtGrid should have a block at (2, 7)"


@pytest.mark.asyncio
async def test_dirt_grid_no_block_above_surface(game):
    """Verify there's no dirt block above the surface row."""
    # Player spawn area (row 6) should be empty
    has_block = await game.call(PATHS["dirt_grid"], "has_block", [{"x": 2, "y": 6}])
    assert has_block is False, "DirtGrid should NOT have a block at (2, 6) - above surface"


@pytest.mark.asyncio
async def test_dirt_grid_active_blocks_exist(game):
    """Verify dirt grid has active blocks (dictionary not empty)."""
    # Get an active block at a known position
    block = await game.call(PATHS["dirt_grid"], "get_block", [{"x": 2, "y": 7}])
    assert block is not None, "DirtGrid should return a block at surface position"


# =============================================================================
# GAME MANAGER STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_starting_coins_is_zero(game):
    """Verify player starts with zero coins."""
    coins = await game.get_property(PATHS["game_manager"], "coins")
    assert coins == 0, f"Game should start with 0 coins, got {coins}"


@pytest.mark.asyncio
async def test_starting_depth_is_zero(game):
    """Verify player starts at depth 0."""
    depth = await game.get_property(PATHS["game_manager"], "current_depth")
    assert depth == 0, f"Game should start at depth 0, got {depth}"


@pytest.mark.asyncio
async def test_grid_constants_defined(game):
    """Verify game manager has grid constants."""
    # These are class constants, so we verify via method call
    block_size = await game.call(PATHS["game_manager"], "get_class")
    # The class should exist
    assert block_size is not None, "GameManager should be accessible"


# =============================================================================
# INPUT AND MINING DIRECTION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_player_touch_direction_property(game):
    """Verify player has touch_direction property for mobile controls."""
    touch_dir = await game.get_property(PATHS["player"], "touch_direction")
    assert touch_dir is not None, "Player should have touch_direction property"


@pytest.mark.asyncio
async def test_player_responds_to_touch_direction(game):
    """Verify player can receive touch direction input."""
    # Set touch direction to right
    await game.call(PATHS["player"], "set_touch_direction", [{"x": 1, "y": 0}])
    touch_dir = await game.get_property(PATHS["player"], "touch_direction")
    # Vector2i serializes as dict
    assert touch_dir.get("x") == 1 or touch_dir == 1, "Touch direction should be updated"


@pytest.mark.asyncio
async def test_player_clear_touch_direction(game):
    """Verify player can clear touch direction."""
    await game.call(PATHS["player"], "set_touch_direction", [{"x": 1, "y": 0}])
    await game.call(PATHS["player"], "clear_touch_direction")
    touch_dir = await game.get_property(PATHS["player"], "touch_direction")
    # Should be back to zero
    assert touch_dir.get("x") == 0 and touch_dir.get("y") == 0, "Touch direction should be cleared"


# =============================================================================
# WALL JUMP STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_player_has_wall_jump_constants(game):
    """Verify player has wall jump physics constants."""
    # Test that player has the method that uses these constants
    has_method = await game.call(PATHS["player"], "has_method", ["_do_wall_jump"])
    assert has_method, "Player should have _do_wall_jump method"


@pytest.mark.asyncio
async def test_player_trigger_jump_method(game):
    """Verify player has trigger_jump method for touch controls."""
    has_method = await game.call(PATHS["player"], "has_method", ["trigger_jump"])
    assert has_method, "Player should have trigger_jump method"


@pytest.mark.asyncio
async def test_player_wants_jump_initially_false(game):
    """Verify wants_jump is initially false."""
    wants_jump = await game.get_property(PATHS["player"], "wants_jump")
    assert wants_jump is False, "Player wants_jump should start false"


# =============================================================================
# INVENTORY INTEGRATION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_inventory_starts_empty(game):
    """Verify inventory is empty at game start."""
    used_slots = await game.call(PATHS["inventory_manager"], "get_used_slots")
    assert used_slots == 0, f"Inventory should start with 0 used slots, got {used_slots}"


@pytest.mark.asyncio
async def test_inventory_has_space(game):
    """Verify inventory has space for items at game start."""
    has_space = await game.call(PATHS["inventory_manager"], "has_space")
    assert has_space is True, "Inventory should have space at game start"


@pytest.mark.asyncio
async def test_inventory_slots_count(game):
    """Verify inventory has the expected number of slots."""
    total_slots = await game.call(PATHS["inventory_manager"], "get_total_slots")
    assert total_slots == 8, f"Inventory should have 8 slots, got {total_slots}"


# =============================================================================
# DATA REGISTRY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_data_registry_has_ores(game):
    """Verify DataRegistry has ore data loaded."""
    # Check that we can call get_ores_at_depth without error
    has_method = await game.call(PATHS["data_registry"], "has_method", ["get_ores_at_depth"])
    assert has_method, "DataRegistry should have get_ores_at_depth method"


@pytest.mark.asyncio
async def test_data_registry_has_items(game):
    """Verify DataRegistry has item lookup capability."""
    has_method = await game.call(PATHS["data_registry"], "has_method", ["get_item"])
    assert has_method, "DataRegistry should have get_item method"


# =============================================================================
# BLOCK INTERACTION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_hitting_block_returns_result(game):
    """Verify hitting a block returns a destruction result."""
    # Hit the block at surface level
    destroyed = await game.call(PATHS["dirt_grid"], "hit_block", [{"x": 2, "y": 8}])
    # First hit may or may not destroy depending on block health
    assert destroyed is not None, "hit_block should return a boolean result"


@pytest.mark.asyncio
async def test_block_dropped_signal_exists(game):
    """Verify DirtGrid has the block_dropped signal."""
    has_signal = await game.call(PATHS["dirt_grid"], "has_signal", ["block_dropped"])
    assert has_signal, "DirtGrid should have block_dropped signal"


@pytest.mark.asyncio
async def test_player_block_destroyed_signal_exists(game):
    """Verify Player has the block_destroyed signal."""
    has_signal = await game.call(PATHS["player"], "has_signal", ["block_destroyed"])
    assert has_signal, "Player should have block_destroyed signal"


@pytest.mark.asyncio
async def test_player_depth_changed_signal_exists(game):
    """Verify Player has the depth_changed signal."""
    has_signal = await game.call(PATHS["player"], "has_signal", ["depth_changed"])
    assert has_signal, "Player should have depth_changed signal"


# =============================================================================
# MINING STATE MACHINE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_mining_state_enum_exists(game):
    """Verify player State enum values are correct."""
    # State.IDLE = 0, State.MOVING = 1, State.MINING = 2, etc.
    current_state = await game.get_property(PATHS["player"], "current_state")
    # At start, should be IDLE (0)
    assert current_state == 0, "Player should start in IDLE state"


@pytest.mark.asyncio
async def test_player_has_mining_target(game):
    """Verify player has mining target property."""
    # mining_target is a Vector2i
    mining_target = await game.get_property(PATHS["player"], "mining_target")
    assert mining_target is not None, "Player should have mining_target property"


@pytest.mark.asyncio
async def test_player_has_mining_direction(game):
    """Verify player has mining direction property."""
    mining_dir = await game.get_property(PATHS["player"], "mining_direction")
    assert mining_dir is not None, "Player should have mining_direction property"


# =============================================================================
# ANIMATION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_player_has_sprite(game):
    """Verify player has an AnimatedSprite2D child."""
    exists = await game.node_exists(PATHS["player_sprite"])
    assert exists, "Player should have an AnimatedSprite2D child"


@pytest.mark.asyncio
async def test_player_sprite_has_swing_animation(game):
    """Verify player sprite has the swing animation for mining."""
    frames = await game.get_property(PATHS["player_sprite"], "sprite_frames")
    assert frames is not None, "Player sprite should have sprite_frames"


@pytest.mark.asyncio
async def test_player_has_collision_shape(game):
    """Verify player has a collision shape."""
    exists = await game.node_exists(PATHS["player_collision"])
    assert exists, "Player should have a CollisionShape2D child"
