"""
Fall Damage System Tests

Tests for the player fall damage calculation system including constants and tracking variables.
Note: Method-level tests require the method to be triggered via gameplay, which is not
easily testable in E2E tests. These tests verify the implementation has the correct
constants and tracking variables.
"""
import pytest
from helpers import PATHS


# =============================================================================
# FALL DAMAGE CONSTANT TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_has_fall_damage_threshold(game):
    """Player should have FALL_DAMAGE_THRESHOLD constant of 3 blocks."""
    result = await game.get_property(PATHS["player"], "FALL_DAMAGE_THRESHOLD")
    assert result == 3, f"FALL_DAMAGE_THRESHOLD should be 3, got {result}"


@pytest.mark.asyncio
async def test_player_has_damage_per_block(game):
    """Player should have DAMAGE_PER_BLOCK constant of 10.0."""
    result = await game.get_property(PATHS["player"], "DAMAGE_PER_BLOCK")
    assert result == 10.0, f"DAMAGE_PER_BLOCK should be 10.0, got {result}"


@pytest.mark.asyncio
async def test_player_has_max_fall_damage(game):
    """Player should have MAX_FALL_DAMAGE constant of 100.0."""
    result = await game.get_property(PATHS["player"], "MAX_FALL_DAMAGE")
    assert result == 100.0, f"MAX_FALL_DAMAGE should be 100.0, got {result}"


# =============================================================================
# FALL TRACKING PROPERTY TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_has_fall_start_y(game):
    """Player should have _fall_start_y tracking variable."""
    result = await game.get_property(PATHS["player"], "_fall_start_y")
    assert result is not None, "Player should have _fall_start_y property"


@pytest.mark.asyncio
async def test_player_has_is_tracking_fall(game):
    """Player should have _is_tracking_fall property."""
    result = await game.get_property(PATHS["player"], "_is_tracking_fall")
    assert result is not None, "Player should have _is_tracking_fall property"


@pytest.mark.asyncio
async def test_player_not_tracking_fall_at_start(game):
    """Player should not be tracking fall at game start."""
    result = await game.get_property(PATHS["player"], "_is_tracking_fall")
    assert result is False, "Player should not be tracking fall at start"


# =============================================================================
# FALL DAMAGE CALCULATION VERIFICATION
# Tests verify the constants are set correctly for the documented damage table:
# | Blocks Fallen | Damage (no boots) |
# |---------------|-------------------|
# | 0-3 | 0 |
# | 4 | 10 |
# | 5 | 20 |
# | 6 | 30 |
# | 7 | 40 |
# | 8 | 50 |
# | 10 | 70 |
# | 13+ | 100 (lethal) |
# =============================================================================


@pytest.mark.asyncio
async def test_fall_damage_math_4_blocks(game):
    """Verify fall damage for 4 blocks: (4 - 3) * 10 = 10 damage."""
    threshold = await game.get_property(PATHS["player"], "FALL_DAMAGE_THRESHOLD")
    damage_per_block = await game.get_property(PATHS["player"], "DAMAGE_PER_BLOCK")

    fall_blocks = 4
    expected_damage = (fall_blocks - threshold) * damage_per_block
    assert expected_damage == 10.0, f"4 block fall should be 10 damage, calculated {expected_damage}"


@pytest.mark.asyncio
async def test_fall_damage_math_10_blocks(game):
    """Verify fall damage for 10 blocks: (10 - 3) * 10 = 70 damage."""
    threshold = await game.get_property(PATHS["player"], "FALL_DAMAGE_THRESHOLD")
    damage_per_block = await game.get_property(PATHS["player"], "DAMAGE_PER_BLOCK")

    fall_blocks = 10
    expected_damage = (fall_blocks - threshold) * damage_per_block
    assert expected_damage == 70.0, f"10 block fall should be 70 damage, calculated {expected_damage}"


@pytest.mark.asyncio
async def test_fall_damage_math_13_blocks_lethal(game):
    """Verify fall damage for 13 blocks: (13 - 3) * 10 = 100 damage (lethal)."""
    threshold = await game.get_property(PATHS["player"], "FALL_DAMAGE_THRESHOLD")
    damage_per_block = await game.get_property(PATHS["player"], "DAMAGE_PER_BLOCK")
    max_damage = await game.get_property(PATHS["player"], "MAX_FALL_DAMAGE")
    max_hp = await game.get_property(PATHS["player"], "MAX_HP")

    fall_blocks = 13
    expected_damage = (fall_blocks - threshold) * damage_per_block
    capped_damage = min(expected_damage, max_damage)

    assert capped_damage == 100.0, f"13 block fall should be 100 damage, calculated {capped_damage}"
    assert capped_damage >= max_hp, f"13 block fall ({capped_damage}) should be lethal (>= {max_hp} HP)"


@pytest.mark.asyncio
async def test_fall_damage_capped_at_max(game):
    """Verify fall damage is capped at MAX_FALL_DAMAGE for extreme falls."""
    threshold = await game.get_property(PATHS["player"], "FALL_DAMAGE_THRESHOLD")
    damage_per_block = await game.get_property(PATHS["player"], "DAMAGE_PER_BLOCK")
    max_damage = await game.get_property(PATHS["player"], "MAX_FALL_DAMAGE")

    fall_blocks = 20  # Would be 170 damage without cap
    raw_damage = (fall_blocks - threshold) * damage_per_block
    capped_damage = min(raw_damage, max_damage)

    assert capped_damage == max_damage, f"20 block fall should be capped at {max_damage}, got {capped_damage}"
    assert raw_damage > max_damage, f"20 block fall raw damage ({raw_damage}) should exceed cap ({max_damage})"


# =============================================================================
# WALL SLIDE INTERACTION (state verification)
# =============================================================================


@pytest.mark.asyncio
async def test_player_has_wall_sliding_state(game):
    """Player should have current_state property for state machine."""
    state = await game.get_property(PATHS["player"], "current_state")
    # State enum exists if we get a value (should be IDLE at start)
    assert state is not None, "Player should have current_state property"


@pytest.mark.asyncio
async def test_player_starts_in_idle_state(game):
    """Player should start in IDLE state (0)."""
    state = await game.get_property(PATHS["player"], "current_state")
    # State.IDLE = 0
    assert state == 0, f"Player should start in IDLE state (0), got {state}"
