"""
Player state machine tests for GoDig.

Verifies player states (IDLE, MOVING, MINING, FALLING, WALL_SLIDING, WALL_JUMPING)
and their associated constants for the wall-jump and grid-based digging mechanics.
"""
import pytest
from helpers import PATHS


# =============================================================================
# STATE ENUM TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_starts_idle(game):
    """Verify the player starts in the IDLE state (0)."""
    current_state = await game.get_property(PATHS["player"], "current_state")
    assert current_state is not None, "Player should have current_state property"
    # State.IDLE = 0
    assert current_state == 0, f"Player should start in IDLE state (0), got {current_state}"


@pytest.mark.asyncio
async def test_player_state_enum_idle(game):
    """Verify IDLE state constant equals 0."""
    # This is validated through current_state starting at 0
    current_state = await game.get_property(PATHS["player"], "current_state")
    assert current_state == 0, "IDLE state should be 0"


@pytest.mark.asyncio
async def test_player_has_mining_state_properties(game):
    """Verify the player has mining-related state properties."""
    # Check mining_direction exists
    mining_direction = await game.get_property(PATHS["player"], "mining_direction")
    assert mining_direction is not None, "Player should have mining_direction property"

    # Check mining_target exists
    mining_target = await game.get_property(PATHS["player"], "mining_target")
    assert mining_target is not None, "Player should have mining_target property"


# =============================================================================
# WALL-JUMP CONSTANTS TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_wall_slide_speed_constant(game):
    """Verify the player has WALL_SLIDE_SPEED constant with correct value."""
    speed = await game.get_property(PATHS["player"], "WALL_SLIDE_SPEED")
    assert speed is not None, "Player should have WALL_SLIDE_SPEED constant"
    assert speed == 50.0, f"WALL_SLIDE_SPEED should be 50.0, got {speed}"


@pytest.mark.asyncio
async def test_player_wall_jump_force_x_constant(game):
    """Verify the player has WALL_JUMP_FORCE_X constant with correct value."""
    force = await game.get_property(PATHS["player"], "WALL_JUMP_FORCE_X")
    assert force is not None, "Player should have WALL_JUMP_FORCE_X constant"
    assert force == 200.0, f"WALL_JUMP_FORCE_X should be 200.0, got {force}"


@pytest.mark.asyncio
async def test_player_wall_jump_force_y_constant(game):
    """Verify the player has WALL_JUMP_FORCE_Y constant with correct value."""
    force = await game.get_property(PATHS["player"], "WALL_JUMP_FORCE_Y")
    assert force is not None, "Player should have WALL_JUMP_FORCE_Y constant"
    assert force == 450.0, f"WALL_JUMP_FORCE_Y should be 450.0, got {force}"


@pytest.mark.asyncio
async def test_player_wall_jump_cooldown_constant(game):
    """Verify the player has WALL_JUMP_COOLDOWN constant with correct value."""
    cooldown = await game.get_property(PATHS["player"], "WALL_JUMP_COOLDOWN")
    assert cooldown is not None, "Player should have WALL_JUMP_COOLDOWN constant"
    assert cooldown == 0.2, f"WALL_JUMP_COOLDOWN should be 0.2, got {cooldown}"


@pytest.mark.asyncio
async def test_player_gravity_constant(game):
    """Verify the player has GRAVITY constant for physics."""
    gravity = await game.get_property(PATHS["player"], "GRAVITY")
    assert gravity is not None, "Player should have GRAVITY constant"
    assert gravity == 980.0, f"GRAVITY should be 980.0, got {gravity}"


# =============================================================================
# WALL-JUMP STATE PROPERTIES TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_wall_direction_property(game):
    """Verify the player has _wall_direction property for wall detection."""
    wall_dir = await game.get_property(PATHS["player"], "_wall_direction")
    assert wall_dir is not None, "Player should have _wall_direction property"
    # Should start at 0 (no wall)
    assert wall_dir == 0, f"_wall_direction should start at 0 (no wall), got {wall_dir}"


@pytest.mark.asyncio
async def test_player_wall_jump_timer_property(game):
    """Verify the player has _wall_jump_timer property for cooldown tracking."""
    timer = await game.get_property(PATHS["player"], "_wall_jump_timer")
    assert timer is not None, "Player should have _wall_jump_timer property"
    # Should start at 0.0
    assert timer == 0.0, f"_wall_jump_timer should start at 0.0, got {timer}"


# =============================================================================
# MOVEMENT CONSTANTS TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_block_size_constant(game):
    """Verify the player has BLOCK_SIZE constant matching the 128x128 grid."""
    block_size = await game.get_property(PATHS["player"], "BLOCK_SIZE")
    assert block_size is not None, "Player should have BLOCK_SIZE constant"
    assert block_size == 128, f"BLOCK_SIZE should be 128, got {block_size}"


@pytest.mark.asyncio
async def test_player_move_duration_constant(game):
    """Verify the player has MOVE_DURATION constant for grid movement timing."""
    duration = await game.get_property(PATHS["player"], "MOVE_DURATION")
    assert duration is not None, "Player should have MOVE_DURATION constant"
    assert duration == 0.15, f"MOVE_DURATION should be 0.15, got {duration}"


# =============================================================================
# GRID POSITION TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_has_grid_position(game):
    """Verify the player has grid_position property for grid-based movement."""
    grid_pos = await game.get_property(PATHS["player"], "grid_position")
    assert grid_pos is not None, "Player should have grid_position property"


@pytest.mark.asyncio
async def test_player_has_target_grid_position(game):
    """Verify the player has target_grid_position for movement targets."""
    target_pos = await game.get_property(PATHS["player"], "target_grid_position")
    assert target_pos is not None, "Player should have target_grid_position property"


# =============================================================================
# INPUT PROPERTIES TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_touch_direction_property(game):
    """Verify the player has touch_direction property for mobile controls."""
    touch_dir = await game.get_property(PATHS["player"], "touch_direction")
    assert touch_dir is not None, "Player should have touch_direction property"


@pytest.mark.asyncio
async def test_player_wants_jump_property(game):
    """Verify the player has wants_jump property for jump input."""
    wants_jump = await game.get_property(PATHS["player"], "wants_jump")
    assert wants_jump is not None, "Player should have wants_jump property"
    # Should start as False
    assert wants_jump is False, f"wants_jump should start as False, got {wants_jump}"


@pytest.mark.asyncio
async def test_player_wants_dig_property(game):
    """Verify the player has wants_dig property for dig input."""
    wants_dig = await game.get_property(PATHS["player"], "wants_dig")
    assert wants_dig is not None, "Player should have wants_dig property"
    # Should start as False
    assert wants_dig is False, f"wants_dig should start as False, got {wants_dig}"


# =============================================================================
# FALL TRACKING TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_has_fall_tracking_property(game):
    """Verify the player has _is_tracking_fall property for fall damage."""
    is_tracking = await game.get_property(PATHS["player"], "_is_tracking_fall")
    assert is_tracking is not None, "Player should have _is_tracking_fall property"
    # Should start as False
    assert is_tracking is False, f"_is_tracking_fall should start as False, got {is_tracking}"


@pytest.mark.asyncio
async def test_player_has_fall_start_property(game):
    """Verify the player has _fall_start_y property for fall distance tracking."""
    fall_start = await game.get_property(PATHS["player"], "_fall_start_y")
    assert fall_start is not None, "Player should have _fall_start_y property"
