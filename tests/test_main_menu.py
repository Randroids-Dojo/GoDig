"""
Main Menu integration tests.

Tests the main menu scene including:
- UI elements display correctly
- New Game button starts a new game
- Continue button visibility based on save status
- Settings button opens settings
"""
import pytest
from helpers import MAIN_MENU_PATHS


# =============================================================================
# MAIN MENU SCENE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_main_menu_loads(main_menu):
    """Main menu scene loads as the initial scene."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu"])
    assert exists, "MainMenu root node should exist"


@pytest.mark.asyncio
async def test_main_menu_has_title(main_menu):
    """Main menu displays the game title."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_title"])
    assert exists, "Title label should exist"


@pytest.mark.asyncio
async def test_main_menu_title_text(main_menu):
    """Main menu title shows 'GoDig'."""
    text = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_title"], "text")
    assert text == "GoDig", f"Title should be 'GoDig', got '{text}'"


@pytest.mark.asyncio
async def test_main_menu_has_subtitle(main_menu):
    """Main menu has a subtitle label."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_subtitle"])
    assert exists, "Subtitle label should exist"


@pytest.mark.asyncio
async def test_main_menu_has_new_game_button(main_menu):
    """Main menu has a New Game button."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_new_game"])
    assert exists, "New Game button should exist"


@pytest.mark.asyncio
async def test_main_menu_new_game_button_text(main_menu):
    """New Game button has correct text."""
    text = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_new_game"], "text")
    assert text == "New Game", f"Button text should be 'New Game', got '{text}'"


@pytest.mark.asyncio
async def test_main_menu_has_continue_button(main_menu):
    """Main menu has a Continue button."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_continue"])
    assert exists, "Continue button should exist"


@pytest.mark.asyncio
async def test_main_menu_continue_button_text(main_menu):
    """Continue button has correct text."""
    text = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_continue"], "text")
    assert text == "Continue", f"Button text should be 'Continue', got '{text}'"


@pytest.mark.asyncio
async def test_main_menu_has_settings_button(main_menu):
    """Main menu has a Settings button."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_settings"])
    assert exists, "Settings button should exist"


@pytest.mark.asyncio
async def test_main_menu_settings_button_text(main_menu):
    """Settings button has correct text."""
    text = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_settings"], "text")
    assert text == "Settings", f"Button text should be 'Settings', got '{text}'"


@pytest.mark.asyncio
async def test_main_menu_has_version_label(main_menu):
    """Main menu shows version number."""
    exists = await main_menu.node_exists(MAIN_MENU_PATHS["main_menu_version"])
    assert exists, "Version label should exist"


@pytest.mark.asyncio
async def test_main_menu_version_has_v_prefix(main_menu):
    """Version label starts with 'v'."""
    text = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_version"], "text")
    assert text.startswith("v"), f"Version should start with 'v', got '{text}'"


@pytest.mark.asyncio
async def test_main_menu_is_visible(main_menu):
    """MainMenu root node is visible."""
    visible = await main_menu.get_property(MAIN_MENU_PATHS["main_menu"], "visible")
    assert visible, "MainMenu should be visible"


@pytest.mark.asyncio
async def test_main_menu_buttons_are_visible(main_menu):
    """All main menu buttons should be visible (except Continue without saves)."""
    # New Game should always be visible
    new_game_visible = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_new_game"], "visible")
    assert new_game_visible, "New Game button should be visible"

    # Settings should always be visible
    settings_visible = await main_menu.get_property(MAIN_MENU_PATHS["main_menu_settings"], "visible")
    assert settings_visible, "Settings button should be visible"


# =============================================================================
# GAME SCENE TESTS (verify game fixture properly loads scene)
# =============================================================================

@pytest.mark.asyncio
async def test_game_scene_loads_via_change_scene(game):
    """Game scene loads when navigating from main menu."""
    exists = await game.node_exists("/root/Main")
    assert exists, "Game scene should load"


@pytest.mark.asyncio
async def test_game_scene_has_player(game):
    """Game scene contains the player."""
    exists = await game.node_exists("/root/Main/Player")
    assert exists, "Player should exist in game scene"
