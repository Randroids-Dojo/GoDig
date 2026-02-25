"""
Smoke tests for the main game scene.

These run in CI to catch script compilation failures and regressions
in core game nodes. If test_level.tscn fails to load (e.g. due to a
GDScript parse error), the game fixture will time out and these tests
will fail with a clear signal.

Keep this file fast and minimal — one Godot instance, just enough checks
to confirm the game scene and its scripts compiled and loaded correctly.
"""
import pytest
from helpers import PATHS


# =============================================================================
# SCENE LOAD (catches all script compile errors)
# =============================================================================

@pytest.mark.asyncio
async def test_game_scene_loads(game):
    """Game scene loads without script errors.

    If any GDScript in test_level.tscn (or its dependencies) has a parse
    error, the scene will never reach /root/Main and this test fails.
    """
    exists = await game.node_exists(PATHS["main"])
    assert exists, "Main scene should load — a failure here usually means a script compile error"


@pytest.mark.asyncio
async def test_player_exists(game):
    """Player node is present in the loaded scene."""
    exists = await game.node_exists(PATHS["player"])
    assert exists, "Player should exist in game scene"


@pytest.mark.asyncio
async def test_dirt_grid_exists(game):
    """DirtGrid node is present."""
    exists = await game.node_exists(PATHS["dirt_grid"])
    assert exists, "DirtGrid should exist"


# =============================================================================
# HUD
# =============================================================================

@pytest.mark.asyncio
async def test_hud_exists(game):
    """HUD node exists."""
    exists = await game.node_exists(PATHS["hud"])
    assert exists, "HUD should exist"


@pytest.mark.asyncio
async def test_pause_button_exists(game):
    """Pause button exists in HUD."""
    exists = await game.node_exists(PATHS["hud_pause_button"])
    assert exists, "PauseButton should exist"


@pytest.mark.asyncio
async def test_pause_button_focus_mode_none(game):
    """Pause button has FOCUS_NONE so spacebar doesn't trigger it."""
    focus = await game.get_property(PATHS["hud_pause_button"], "focus_mode")
    assert focus == 0, f"PauseButton focus_mode should be FOCUS_NONE (0), got {focus}"


@pytest.mark.asyncio
async def test_hud_has_keyboard_hints(game):
    """HUD shows keyboard hints label for desktop players."""
    exists = await game.node_exists(PATHS["hud"] + "/KeyboardHintsLabel")
    assert exists, "KeyboardHintsLabel should exist in HUD"


@pytest.mark.asyncio
async def test_keyboard_hints_show_inventory_key(game):
    """Keyboard hints label mentions the I key for inventory."""
    text = await game.get_property(PATHS["hud"] + "/KeyboardHintsLabel", "text")
    assert "I" in text, f"Hints should mention I key, got: '{text}'"


# =============================================================================
# INVENTORY PANEL
# =============================================================================

@pytest.mark.asyncio
async def test_inventory_panel_exists(game):
    """InventoryPanel node exists in the scene."""
    exists = await game.node_exists(PATHS["inventory_panel"])
    assert exists, "InventoryPanel should exist"


@pytest.mark.asyncio
async def test_inventory_panel_starts_hidden(game):
    """InventoryPanel is hidden on game start."""
    visible = await game.get_property(PATHS["inventory_panel"], "visible")
    assert not visible, "InventoryPanel should be hidden at game start"


# =============================================================================
# AUTOLOADS
# =============================================================================

@pytest.mark.asyncio
async def test_game_manager_exists(game):
    """GameManager autoload is available."""
    exists = await game.node_exists(PATHS["game_manager"])
    assert exists, "GameManager should exist"


@pytest.mark.asyncio
async def test_inventory_manager_exists(game):
    """InventoryManager autoload is available."""
    exists = await game.node_exists(PATHS["inventory_manager"])
    assert exists, "InventoryManager should exist"
