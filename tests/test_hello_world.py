"""
Test level tests for GoDig endless digging game.

Verifies the game setup, player, dirt grid, and basic mechanics.
"""
import pytest
from helpers import PATHS


@pytest.mark.asyncio
async def test_main_scene_loads(game):
    """Verify the main scene loads correctly."""
    exists = await game.node_exists(PATHS["main"])
    assert exists, "Main scene should exist"


@pytest.mark.asyncio
async def test_player_exists(game):
    """Verify the player node exists."""
    exists = await game.node_exists(PATHS["player"])
    assert exists, "Player node should exist"


@pytest.mark.asyncio
async def test_dirt_grid_exists(game):
    """Verify the dirt grid node exists."""
    exists = await game.node_exists(PATHS["dirt_grid"])
    assert exists, "DirtGrid node should exist"


@pytest.mark.asyncio
async def test_camera_exists(game):
    """Verify the camera node exists."""
    exists = await game.node_exists(PATHS["camera"])
    assert exists, "Camera2D node should exist"


@pytest.mark.asyncio
async def test_depth_label_exists(game):
    """Verify the depth label UI exists."""
    exists = await game.node_exists(PATHS["depth_label"])
    assert exists, "DepthLabel UI should exist"


@pytest.mark.asyncio
async def test_game_manager_exists(game):
    """Verify the GameManager autoload exists."""
    exists = await game.node_exists(PATHS["game_manager"])
    assert exists, "GameManager autoload should exist"


@pytest.mark.asyncio
async def test_game_is_running(game):
    """Verify the game is running after scene loads."""
    is_running = await game.get_property(PATHS["game_manager"], "is_running")
    assert is_running is True, "Game should be running after scene loads"


@pytest.mark.asyncio
async def test_depth_label_shows_depth(game):
    """Verify the depth label displays depth info."""
    text = await game.get_property(PATHS["depth_label"], "text")
    assert "Depth:" in text, f"Depth label should show 'Depth:', got '{text}'"
