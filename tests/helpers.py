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
    "title_label": "/root/Main/CenterContainer/VBoxContainer/TitleLabel",
    "subtitle_label": "/root/Main/CenterContainer/VBoxContainer/SubtitleLabel",
    "status_label": "/root/Main/CenterContainer/VBoxContainer/StatusLabel",
    "game_manager": "/root/GameManager",
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
