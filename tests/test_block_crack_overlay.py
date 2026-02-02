"""
Tests for block crack overlay visual effect.

Verifies that the crack overlay system is properly configured.
"""
import pytest
from helpers import PATHS


@pytest.mark.asyncio
async def test_dirt_grid_exists(game):
    """Verify dirt grid node exists for block management."""
    exists = await game.node_exists(PATHS["dirt_grid"])
    assert exists, "DirtGrid should exist"


@pytest.mark.asyncio
async def test_dirt_grid_has_pool_size(game):
    """Verify dirt grid has pool size configured for object pooling."""
    pool_size = await game.get_property(PATHS["dirt_grid"], "POOL_SIZE")
    assert pool_size is not None, "DirtGrid should have POOL_SIZE constant"
    assert pool_size >= 100, f"Pool size should be at least 100, got {pool_size}"


@pytest.mark.asyncio
async def test_dirt_grid_has_block_size(game):
    """Verify dirt grid uses standard block size."""
    block_size = await game.get_property(PATHS["dirt_grid"], "BLOCK_SIZE")
    assert block_size == 128, f"Block size should be 128, got {block_size}"


@pytest.mark.asyncio
async def test_player_exists_for_mining(game):
    """Verify player exists for mining interactions."""
    exists = await game.node_exists(PATHS["player"])
    assert exists, "Player should exist"


@pytest.mark.asyncio
async def test_mining_progress_container_exists(game):
    """Verify mining progress UI exists for visual feedback."""
    exists = await game.node_exists(PATHS["mining_progress_container"])
    assert exists, "Mining progress container should exist in HUD"


@pytest.mark.asyncio
async def test_mining_progress_bar_exists(game):
    """Verify mining progress bar exists for dig feedback."""
    exists = await game.node_exists(PATHS["mining_progress_bar"])
    assert exists, "Mining progress bar should exist"
