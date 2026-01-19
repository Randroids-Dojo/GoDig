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
    "touch_controls": "/root/Main/UI/TouchControls",
    "left_button": "/root/Main/UI/TouchControls/LeftButton",
    "right_button": "/root/Main/UI/TouchControls/RightButton",
    "down_button": "/root/Main/UI/TouchControls/DownButton",
    "jump_button": "/root/Main/UI/TouchControls/JumpButton",
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
