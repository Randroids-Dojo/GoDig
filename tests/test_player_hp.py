"""
Player HP System Tests

Tests for the player health points system including HP properties and HUD display.
"""
import pytest
from helpers import PATHS


# =============================================================================
# HUD STRUCTURE TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_hud_exists(game):
    """HUD node should exist in the scene."""
    exists = await game.node_exists(PATHS["hud"])
    assert exists, "HUD node should exist"


@pytest.mark.asyncio
async def test_health_bar_exists(game):
    """Health bar should exist in the HUD."""
    exists = await game.node_exists(PATHS["health_bar"])
    assert exists, "Health bar should exist in HUD"


@pytest.mark.asyncio
async def test_health_label_exists(game):
    """Health label should exist in the HUD."""
    exists = await game.node_exists(PATHS["health_label"])
    assert exists, "Health label should exist in HUD"


@pytest.mark.asyncio
async def test_low_health_vignette_exists(game):
    """Low health vignette should exist in the HUD."""
    exists = await game.node_exists(PATHS["low_health_vignette"])
    assert exists, "Low health vignette should exist in HUD"


# =============================================================================
# PLAYER HP PROPERTY TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_player_has_max_hp_constant(game):
    """Player should have MAX_HP constant of 100."""
    result = await game.get_property(PATHS["player"], "MAX_HP")
    assert result == 100, f"Player MAX_HP should be 100, got {result}"


@pytest.mark.asyncio
async def test_player_has_current_hp(game):
    """Player should have current_hp property."""
    result = await game.get_property(PATHS["player"], "current_hp")
    assert result is not None, "Player should have current_hp property"
    assert isinstance(result, int), f"current_hp should be int, got {type(result)}"


@pytest.mark.asyncio
async def test_player_starts_with_full_hp(game):
    """Player should start with full HP (100)."""
    result = await game.get_property(PATHS["player"], "current_hp")
    assert result == 100, f"Player should start with 100 HP, got {result}"


@pytest.mark.asyncio
async def test_player_has_is_dead_property(game):
    """Player should have is_dead property."""
    result = await game.get_property(PATHS["player"], "is_dead")
    assert result is not None, "Player should have is_dead property"


@pytest.mark.asyncio
async def test_player_is_not_dead_at_start(game):
    """Player should not be dead at the start."""
    result = await game.get_property(PATHS["player"], "is_dead")
    assert result is False, "Player should not be dead at start"


@pytest.mark.asyncio
async def test_player_has_low_hp_threshold(game):
    """Player should have LOW_HP_THRESHOLD constant."""
    result = await game.get_property(PATHS["player"], "LOW_HP_THRESHOLD")
    assert result is not None, "Player should have LOW_HP_THRESHOLD constant"
    assert result == 0.25, f"LOW_HP_THRESHOLD should be 0.25, got {result}"


@pytest.mark.asyncio
async def test_player_has_damage_flash_duration(game):
    """Player should have DAMAGE_FLASH_DURATION constant."""
    result = await game.get_property(PATHS["player"], "DAMAGE_FLASH_DURATION")
    assert result is not None, "Player should have DAMAGE_FLASH_DURATION constant"
    assert result == 0.1, f"DAMAGE_FLASH_DURATION should be 0.1, got {result}"


# =============================================================================
# HUD DISPLAY TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_health_bar_has_max_value(game):
    """Health bar should have max_value set to 100."""
    result = await game.get_property(PATHS["health_bar"], "max_value")
    assert result == 100, f"Health bar max_value should be 100, got {result}"


@pytest.mark.asyncio
async def test_health_bar_has_correct_value(game):
    """Health bar should show current player HP."""
    health_value = await game.get_property(PATHS["health_bar"], "value")
    player_hp = await game.get_property(PATHS["player"], "current_hp")
    assert health_value == player_hp, f"Health bar value ({health_value}) should match player HP ({player_hp})"


@pytest.mark.asyncio
async def test_health_label_shows_hp(game):
    """Health label should show HP in format 'current/max'."""
    text = await game.get_property(PATHS["health_label"], "text")
    assert "/" in text, f"Health label should show HP in 'current/max' format, got '{text}'"
    assert "100" in text, f"Health label should show 100 at start, got '{text}'"


@pytest.mark.asyncio
async def test_low_health_vignette_hidden_at_full_hp(game):
    """Low health vignette should be hidden when at full HP."""
    is_visible = await game.get_property(PATHS["low_health_vignette"], "visible")
    assert is_visible is False, "Low health vignette should be hidden at full HP"


@pytest.mark.asyncio
async def test_hud_is_visible(game):
    """HUD should be visible by default."""
    is_visible = await game.get_property(PATHS["hud"], "visible")
    assert is_visible is True, "HUD should be visible"


@pytest.mark.asyncio
async def test_health_bar_is_visible(game):
    """Health bar should be visible by default."""
    is_visible = await game.get_property(PATHS["health_bar"], "visible")
    assert is_visible is True, "Health bar should be visible"
