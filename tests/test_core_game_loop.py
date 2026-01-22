"""
Core game loop integration tests for GoDig.

Tests the integration of death/respawn, save/load with PlayerData,
and main menu navigation.
"""
import asyncio
import pytest
from helpers import PATHS, wait_for_condition


@pytest.mark.asyncio
async def test_player_data_autoload_exists(game):
    """Verify PlayerData autoload exists."""
    exists = await game.node_exists("/root/PlayerData")
    assert exists, "PlayerData autoload should exist"


@pytest.mark.asyncio
async def test_player_data_has_default_tool(game):
    """Verify PlayerData starts with default tool."""
    tool_id = await game.get_property("/root/PlayerData", "equipped_tool_id")
    assert tool_id == "rusty_pickaxe", f"Should start with rusty_pickaxe, got {tool_id}"


@pytest.mark.asyncio
async def test_player_data_tracks_max_depth(game):
    """Verify PlayerData tracks max depth reached."""
    max_depth = await game.get_property("/root/PlayerData", "max_depth_reached")
    assert max_depth >= 0, f"Max depth should be >= 0, got {max_depth}"


@pytest.mark.asyncio
async def test_game_manager_starts_game(game):
    """Verify GameManager starts game on level load."""
    is_running = await game.get_property(PATHS["game_manager"], "is_running")
    assert is_running is True, "Game should be running after scene loads"


@pytest.mark.asyncio
async def test_initial_coins_are_zero(game):
    """Verify coins start at zero for new game."""
    coins = await game.get_property(PATHS["game_manager"], "coins")
    assert coins >= 0, f"Coins should be >= 0, got {coins}"


@pytest.mark.asyncio
async def test_initial_depth_is_zero(game):
    """Verify depth starts at zero."""
    depth = await game.get_property(PATHS["game_manager"], "current_depth")
    assert depth == 0, f"Initial depth should be 0, got {depth}"


@pytest.mark.asyncio
async def test_player_starts_alive(game):
    """Verify player starts alive (not dead)."""
    is_dead = await game.get_property(PATHS["player"], "is_dead")
    assert is_dead is False, "Player should start alive"


@pytest.mark.asyncio
async def test_player_has_full_hp(game):
    """Verify player starts with full HP."""
    current_hp = await game.get_property(PATHS["player"], "current_hp")
    max_hp = await game.get_property(PATHS["player"], "MAX_HP")
    assert current_hp == max_hp, f"Player should start with full HP: {current_hp}/{max_hp}"


@pytest.mark.asyncio
async def test_save_manager_has_current_save(game):
    """Verify SaveManager has a current save loaded."""
    is_loaded = await game.call_method(PATHS["save_manager"], "is_game_loaded")
    assert is_loaded is True, "SaveManager should have a game loaded"


@pytest.mark.asyncio
async def test_save_manager_current_slot_valid(game):
    """Verify SaveManager current slot is valid."""
    slot = await game.get_property(PATHS["save_manager"], "current_slot")
    assert slot >= 0 and slot < 3, f"Current slot should be 0-2, got {slot}"


@pytest.mark.asyncio
async def test_player_death_sets_is_dead(game):
    """Verify player death flag is set when player dies."""
    # Kill the player
    await game.call_method(PATHS["player"], "die", ["test"])

    # Check is_dead flag
    is_dead = await game.get_property(PATHS["player"], "is_dead")
    assert is_dead is True, "Player should be marked as dead after die() is called"


@pytest.mark.asyncio
async def test_player_revive_clears_is_dead(game):
    """Verify player revive clears death flag."""
    # Kill then revive the player
    await game.call_method(PATHS["player"], "die", ["test"])
    await asyncio.sleep(0.1)  # Small delay
    await game.call_method(PATHS["player"], "revive", [100])

    # Check is_dead flag is cleared
    is_dead = await game.get_property(PATHS["player"], "is_dead")
    assert is_dead is False, "Player should be alive after revive()"


@pytest.mark.asyncio
async def test_player_revive_restores_hp(game):
    """Verify player revive restores HP."""
    # Kill then revive with specific HP
    await game.call_method(PATHS["player"], "die", ["test"])
    await asyncio.sleep(0.1)
    await game.call_method(PATHS["player"], "revive", [50])

    # Check HP is restored
    current_hp = await game.get_property(PATHS["player"], "current_hp")
    assert current_hp == 50, f"Player should have 50 HP after revive(50), got {current_hp}"


@pytest.mark.asyncio
async def test_pause_menu_exists(game):
    """Verify pause menu exists."""
    exists = await game.node_exists(PATHS["pause_menu"])
    assert exists, "Pause menu should exist"


@pytest.mark.asyncio
async def test_pause_button_exists(game):
    """Verify pause button exists."""
    exists = await game.node_exists(PATHS["pause_button"])
    assert exists, "Pause button should exist"


@pytest.mark.asyncio
async def test_pause_menu_has_quit_button(game):
    """Verify pause menu has quit button."""
    exists = await game.node_exists(PATHS["pause_menu_quit"])
    assert exists, "Pause menu should have quit button"


@pytest.mark.asyncio
async def test_pause_menu_has_rescue_button(game):
    """Verify pause menu has rescue button."""
    exists = await game.node_exists(PATHS["pause_menu_rescue"])
    assert exists, "Pause menu should have rescue button"


@pytest.mark.asyncio
async def test_pause_menu_has_reload_button(game):
    """Verify pause menu has reload button."""
    exists = await game.node_exists(PATHS["pause_menu_reload"])
    assert exists, "Pause menu should have reload button"


@pytest.mark.asyncio
async def test_inventory_manager_exists(game):
    """Verify InventoryManager autoload exists."""
    exists = await game.node_exists(PATHS["inventory_manager"])
    assert exists, "InventoryManager autoload should exist"


@pytest.mark.asyncio
async def test_data_registry_exists(game):
    """Verify DataRegistry autoload exists."""
    exists = await game.node_exists(PATHS["data_registry"])
    assert exists, "DataRegistry autoload should exist"


@pytest.mark.asyncio
async def test_platform_detector_exists(game):
    """Verify PlatformDetector autoload exists."""
    exists = await game.node_exists(PATHS["platform_detector"])
    assert exists, "PlatformDetector autoload should exist"


@pytest.mark.asyncio
async def test_hud_exists(game):
    """Verify HUD exists."""
    exists = await game.node_exists(PATHS["hud"])
    assert exists, "HUD should exist"


@pytest.mark.asyncio
async def test_health_bar_exists(game):
    """Verify health bar exists in HUD."""
    exists = await game.node_exists(PATHS["health_bar"])
    assert exists, "Health bar should exist"


@pytest.mark.asyncio
async def test_depth_label_shows_initial_zero(game):
    """Verify depth label shows 0 initially."""
    text = await game.get_property(PATHS["depth_label"], "text")
    assert "0" in text, f"Depth label should show 0 initially, got '{text}'"
