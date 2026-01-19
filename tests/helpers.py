"""
Shared test helper functions for PlayGodot tests.

This module contains utilities used across multiple test files to avoid duplication.
"""
import asyncio


# Timeout for waiting operations (seconds)
WAIT_TIMEOUT = 5.0


# =============================================================================
# NODE PATHS
# =============================================================================
PATHS = {
    "main": "/root/Main",
    "player": "/root/Main/Player",
    "dirt_grid": "/root/Main/DirtGrid",
    "camera": "/root/Main/Player/Camera2D",
    "depth_label": "/root/Main/UI/DepthLabel",
    "coins_label": "/root/Main/UI/CoinsLabel",
    "shop_button": "/root/Main/UI/ShopButton",
    "shop": "/root/Main/UI/Shop",
    "game_manager": "/root/GameManager",
    "data_registry": "/root/DataRegistry",
    "inventory_manager": "/root/InventoryManager",
    "save_manager": "/root/SaveManager",
    "settings_manager": "/root/SettingsManager",
    "platform_detector": "/root/PlatformDetector",
    "touch_controls": "/root/Main/UI/TouchControls",
    "virtual_joystick": "/root/Main/UI/TouchControls/VirtualJoystick",
    "action_buttons": "/root/Main/UI/TouchControls/ActionButtons",
    "jump_button": "/root/Main/UI/TouchControls/ActionButtons/JumpButton",
    "dig_button": "/root/Main/UI/TouchControls/ActionButtons/DigButton",
    "inventory_button": "/root/Main/UI/TouchControls/ActionButtons/InventoryButton",
    "player_sprite": "/root/Main/Player/AnimatedSprite2D",
    "player_collision": "/root/Main/Player/CollisionShape2D",
    "pause_button": "/root/Main/UI/PauseButton",
    "pause_menu": "/root/Main/PauseMenu",
    "pause_menu_resume": "/root/Main/PauseMenu/Panel/VBox/ResumeButton",
    "pause_menu_settings": "/root/Main/PauseMenu/Panel/VBox/SettingsButton",
    "pause_menu_rescue": "/root/Main/PauseMenu/Panel/VBox/RescueButton",
    "pause_menu_reload": "/root/Main/PauseMenu/Panel/VBox/ReloadButton",
    "pause_menu_quit": "/root/Main/PauseMenu/Panel/VBox/QuitButton",
    "pause_menu_confirm_dialog": "/root/Main/PauseMenu/ConfirmDialog",
}


# =============================================================================
# WAIT HELPERS
# =============================================================================
async def wait_for_condition(game, check_fn, timeout=WAIT_TIMEOUT):
    """Wait for a condition function to return True with timeout.

    Args:
        game: The PlayGodot game instance
        check_fn: Async function that returns True when condition is met
        timeout: Maximum wait time in seconds

    Returns:
        True if condition was met, False if timeout
    """
    elapsed = 0
    while elapsed < timeout:
        if await check_fn():
            return True
        await asyncio.sleep(0.1)
        elapsed += 0.1
    return False


async def wait_for_node(game, path, timeout=WAIT_TIMEOUT):
    """Wait for a node to exist.

    Args:
        game: The PlayGodot game instance
        path: Node path to wait for
        timeout: Maximum wait time in seconds

    Returns:
        True if node exists, False if timeout
    """
    async def node_exists():
        result = await game.node_exists(path)
        return result.get("exists", False)

    return await wait_for_condition(game, node_exists, timeout)
