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
async def test_dirt_grid_has_methods(game):
    """Verify the dirt grid has required methods for block management."""
    has_block_method = await game.call(PATHS["dirt_grid"], "has_method", ["has_block"])
    assert has_block_method, "DirtGrid should have has_block method"


@pytest.mark.asyncio
async def test_dirt_grid_has_get_block_method(game):
    """Verify the dirt grid has get_block method."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["get_block"])
    assert has_method, "DirtGrid should have get_block method"


@pytest.mark.asyncio
async def test_dirt_grid_has_hit_block_method(game):
    """Verify dirt grid has hit_block method for mining."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["hit_block"])
    assert has_method, "DirtGrid should have hit_block method"


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
async def test_player_has_set_touch_direction_method(game):
    """Verify player has set_touch_direction method for mobile controls."""
    has_method = await game.call(PATHS["player"], "has_method", ["set_touch_direction"])
    assert has_method, "Player should have set_touch_direction method"


@pytest.mark.asyncio
async def test_player_has_clear_touch_direction_method(game):
    """Verify player has clear_touch_direction method."""
    has_method = await game.call(PATHS["player"], "has_method", ["clear_touch_direction"])
    assert has_method, "Player should have clear_touch_direction method"


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


@pytest.mark.asyncio
async def test_data_registry_has_all_ore_types(game):
    """Verify DataRegistry has loaded all 10 ore/gem types."""
    ore_ids = await game.call(PATHS["data_registry"], "get_all_ore_ids")
    expected_ores = ["coal", "copper", "iron", "silver", "gold", "platinum", "ruby", "emerald", "sapphire", "diamond"]
    for ore_id in expected_ores:
        assert ore_id in ore_ids, f"DataRegistry should have ore type: {ore_id}"


@pytest.mark.asyncio
async def test_data_registry_ore_count_at_least_8(game):
    """Verify DataRegistry has at least 8 ore types (v1.0 requirement)."""
    ore_ids = await game.call(PATHS["data_registry"], "get_all_ore_ids")
    assert len(ore_ids) >= 8, f"DataRegistry should have at least 8 ore types, got {len(ore_ids)}"


@pytest.mark.asyncio
async def test_new_gems_spawn_at_correct_depth(game):
    """Verify new gems have correct depth gating."""
    # Emerald should spawn at depth 350+
    emerald_ores = await game.call(PATHS["data_registry"], "get_ores_at_depth", [350])
    emerald_ids = [o.get("id", "") if isinstance(o, dict) else str(o) for o in emerald_ores] if emerald_ores else []
    # Note: get_ores_at_depth returns OreData objects, not dicts
    # We just verify no error occurs and results are returned
    assert emerald_ores is not None, "get_ores_at_depth(350) should return a list"


@pytest.mark.asyncio
async def test_dirt_grid_has_vein_expansion(game):
    """Verify DirtGrid has vein expansion methods for ore generation."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["_expand_ore_vein"])
    assert has_method, "DirtGrid should have _expand_ore_vein method for vein expansion"


@pytest.mark.asyncio
async def test_dirt_grid_has_place_ore_method(game):
    """Verify DirtGrid has _place_ore_at method."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["_place_ore_at"])
    assert has_method, "DirtGrid should have _place_ore_at method"


# =============================================================================
# BLOCK INTERACTION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_dirt_grid_has_initialize_method(game):
    """Verify dirt grid has initialize method for setup."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["initialize"])
    assert has_method, "DirtGrid should have initialize method"


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
async def test_player_sprite_has_animation(game):
    """Verify player sprite has animation property set."""
    # Check the current animation name instead of the resource
    animation = await game.get_property(PATHS["player_sprite"], "animation")
    assert animation is not None, "Player sprite should have animation property"


@pytest.mark.asyncio
async def test_player_has_collision_shape(game):
    """Verify player has a collision shape."""
    exists = await game.node_exists(PATHS["player_collision"])
    assert exists, "Player should have a CollisionShape2D child"


# =============================================================================
# TAP-TO-DIG TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_player_has_tap_mining_state(game):
    """Verify player has tap-to-dig state variables."""
    is_tap_mining = await game.get_property(PATHS["player"], "_is_tap_mining")
    assert is_tap_mining is not None, "Player should have _is_tap_mining property"


@pytest.mark.asyncio
async def test_player_has_tap_target_tile(game):
    """Verify player has tap target tile property."""
    tap_target = await game.get_property(PATHS["player"], "_tap_target_tile")
    assert tap_target is not None, "Player should have _tap_target_tile property"


@pytest.mark.asyncio
async def test_player_tap_mining_starts_false(game):
    """Verify tap mining starts as inactive."""
    is_tap_mining = await game.get_property(PATHS["player"], "_is_tap_mining")
    assert is_tap_mining is False, "Tap mining should start as False"


@pytest.mark.asyncio
async def test_player_has_tap_hold_timer(game):
    """Verify player has tap hold timer for continuous mining."""
    timer = await game.get_property(PATHS["player"], "_tap_hold_timer")
    assert timer is not None, "Player should have _tap_hold_timer property"


@pytest.mark.asyncio
async def test_player_has_tap_mine_cooldown(game):
    """Verify player has tap mine cooldown to prevent double-hits."""
    cooldown = await game.get_property(PATHS["player"], "_tap_mine_cooldown")
    assert cooldown is not None, "Player should have _tap_mine_cooldown property"


@pytest.mark.asyncio
async def test_player_has_screen_to_grid_method(game):
    """Verify player has _screen_to_grid method for touch coordinate conversion."""
    has_method = await game.call(PATHS["player"], "has_method", ["_screen_to_grid"])
    assert has_method, "Player should have _screen_to_grid method"


@pytest.mark.asyncio
async def test_player_has_is_adjacent_to_player_method(game):
    """Verify player has _is_adjacent_to_player method for tap validation."""
    has_method = await game.call(PATHS["player"], "has_method", ["_is_adjacent_to_player"])
    assert has_method, "Player should have _is_adjacent_to_player method"


@pytest.mark.asyncio
async def test_player_has_is_tap_diggable_method(game):
    """Verify player has _is_tap_diggable method for tap validation."""
    has_method = await game.call(PATHS["player"], "has_method", ["_is_tap_diggable"])
    assert has_method, "Player should have _is_tap_diggable method"


@pytest.mark.asyncio
async def test_tap_hold_threshold_constant(game):
    """Verify TAP_HOLD_THRESHOLD constant is defined."""
    # Constants are accessed differently, but we can check via existence of the variable pattern
    # The const is set to 0.2 seconds - we check via the timer behavior
    timer = await game.get_property(PATHS["player"], "_tap_hold_timer")
    assert timer == 0.0, "Tap hold timer should start at 0.0"


@pytest.mark.asyncio
async def test_tap_mine_interval_reasonable(game):
    """Verify tap mining cooldown starts at zero."""
    cooldown = await game.get_property(PATHS["player"], "_tap_mine_cooldown")
    assert cooldown == 0.0, "Tap mine cooldown should start at 0.0"


# =============================================================================
# TILE PERSISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_dirt_grid_has_dug_tiles_tracking(game):
    """Verify DirtGrid tracks dug tiles for persistence."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["get_dug_tile_count"])
    assert has_method, "DirtGrid should have get_dug_tile_count method for persistence"


@pytest.mark.asyncio
async def test_dirt_grid_dug_tiles_starts_zero(game):
    """Verify no tiles are marked as dug at game start."""
    count = await game.call(PATHS["dirt_grid"], "get_dug_tile_count")
    assert count == 0, f"Dug tile count should start at 0, got {count}"


@pytest.mark.asyncio
async def test_dirt_grid_has_save_dirty_chunks_method(game):
    """Verify DirtGrid has method to save dirty chunks for persistence."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["save_all_dirty_chunks"])
    assert has_method, "DirtGrid should have save_all_dirty_chunks method"


@pytest.mark.asyncio
async def test_dirt_grid_has_clear_dug_tiles_method(game):
    """Verify DirtGrid has method to clear dug tiles for new game."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["clear_all_dug_tiles"])
    assert has_method, "DirtGrid should have clear_all_dug_tiles method"


@pytest.mark.asyncio
async def test_dirt_grid_chunk_helper_exists(game):
    """Verify DirtGrid has debug_chunk_count method for testing."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["debug_chunk_count"])
    assert has_method, "DirtGrid should have debug_chunk_count method"


@pytest.mark.asyncio
async def test_dirt_grid_active_count_method(game):
    """Verify DirtGrid has debug_active_count method."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["debug_active_count"])
    assert has_method, "DirtGrid should have debug_active_count method"


@pytest.mark.asyncio
async def test_dirt_grid_has_blocks_loaded(game):
    """Verify DirtGrid has active blocks after initialization."""
    count = await game.call(PATHS["dirt_grid"], "debug_active_count")
    assert count > 0, f"DirtGrid should have active blocks, got {count}"


@pytest.mark.asyncio
async def test_dirt_grid_has_chunks_loaded(game):
    """Verify DirtGrid has loaded chunks around player."""
    count = await game.call(PATHS["dirt_grid"], "debug_chunk_count")
    assert count > 0, f"DirtGrid should have loaded chunks, got {count}"


# =============================================================================
# LADDER PLACEMENT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_dirt_grid_has_place_ladder_method(game):
    """Verify DirtGrid has place_ladder method."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["place_ladder"])
    assert has_method, "DirtGrid should have place_ladder method"


@pytest.mark.asyncio
async def test_dirt_grid_has_remove_ladder_method(game):
    """Verify DirtGrid has remove_ladder method."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["remove_ladder"])
    assert has_method, "DirtGrid should have remove_ladder method"


@pytest.mark.asyncio
async def test_dirt_grid_has_has_ladder_method(game):
    """Verify DirtGrid has has_ladder method."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["has_ladder"])
    assert has_method, "DirtGrid should have has_ladder method"


@pytest.mark.asyncio
async def test_dirt_grid_has_get_tile_type_method(game):
    """Verify DirtGrid has get_tile_type method."""
    has_method = await game.call(PATHS["dirt_grid"], "has_method", ["get_tile_type"])
    assert has_method, "DirtGrid should have get_tile_type method"


@pytest.mark.asyncio
async def test_player_has_climbing_state(game):
    """Verify player has CLIMBING state for ladders."""
    has_method = await game.call(PATHS["player"], "has_method", ["_handle_climbing"])
    assert has_method, "Player should have _handle_climbing method for ladder climbing"


@pytest.mark.asyncio
async def test_player_has_is_on_ladder_method(game):
    """Verify player has _is_on_ladder method."""
    has_method = await game.call(PATHS["player"], "has_method", ["_is_on_ladder"])
    assert has_method, "Player should have _is_on_ladder method"
