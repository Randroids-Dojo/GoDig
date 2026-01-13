"""
Hello World test for GoDig.

This is an example PlayGodot test that verifies the basic game setup works.
"""
import pytest
from helpers import PATHS


@pytest.mark.asyncio
async def test_main_scene_loads(game):
    """Verify the main scene loads correctly."""
    # Check that the main scene node exists
    exists = await game.node_exists(PATHS["main"])
    assert exists["exists"], "Main scene should exist"


@pytest.mark.asyncio
async def test_title_label_shows_godig(game):
    """Verify the title label displays 'GoDig'."""
    # Get the title label text
    result = await game.get_property(PATHS["title_label"], "text")
    assert result["value"] == "GoDig", f"Expected 'GoDig', got '{result['value']}'"


@pytest.mark.asyncio
async def test_subtitle_shows_hello_world(game):
    """Verify the subtitle label displays 'Hello World!'."""
    result = await game.get_property(PATHS["subtitle_label"], "text")
    assert result["value"] == "Hello World!", f"Expected 'Hello World!', got '{result['value']}'"


@pytest.mark.asyncio
async def test_status_label_initialized(game):
    """Verify the status label is initialized."""
    result = await game.get_property(PATHS["status_label"], "text")
    assert result["value"] == "Game initialized!", f"Expected 'Game initialized!', got '{result['value']}'"


@pytest.mark.asyncio
async def test_game_manager_exists(game):
    """Verify the GameManager autoload exists."""
    exists = await game.node_exists(PATHS["game_manager"])
    assert exists["exists"], "GameManager autoload should exist"


@pytest.mark.asyncio
async def test_game_manager_not_running_initially(game):
    """Verify the game is not running on startup."""
    result = await game.get_property(PATHS["game_manager"], "is_running")
    assert result["value"] is False, "Game should not be running initially"


@pytest.mark.asyncio
async def test_can_call_main_get_title(game):
    """Verify we can call methods on the main scene."""
    result = await game.call(PATHS["main"], "get_title")
    assert result["value"] == "GoDig", f"Expected 'GoDig', got '{result['value']}'"


@pytest.mark.asyncio
async def test_can_call_main_get_status(game):
    """Verify we can call get_status on the main scene."""
    result = await game.call(PATHS["main"], "get_status")
    assert result["value"] == "Game initialized!", f"Expected 'Game initialized!', got '{result['value']}'"
