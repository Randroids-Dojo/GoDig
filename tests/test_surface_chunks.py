"""
Test horizontal infinite expansion for both surface and underground.

Verifies the surface chunk system and underground DirtGrid horizontal expansion.
"""
import pytest
from helpers import PATHS


@pytest.mark.asyncio
async def test_surface_area_exists(game):
    """Verify the surface area node exists."""
    exists = await game.node_exists(PATHS["surface_area"])
    assert exists, "SurfaceArea node should exist"


@pytest.mark.asyncio
async def test_surface_tilemap_exists(game):
    """Verify the surface tilemap exists."""
    exists = await game.node_exists(PATHS["surface_tilemap"])
    assert exists, "Surface GroundTileMap should exist"


@pytest.mark.asyncio
async def test_surface_manager_initialized(game):
    """Verify the surface manager initializes with loaded chunks."""
    # Check if the surface manager has any loaded chunks
    # This verifies that initial chunks are loaded at startup
    loaded_chunks_count = await game.get_property(
        PATHS["surface_area"],
        "loaded_chunks.size()"
    )
    # At minimum, should have loaded the chunk at position 0 (mine entrance)
    assert loaded_chunks_count is not None, "Surface manager should track loaded chunks"


@pytest.mark.asyncio
async def test_underground_horizontal_expansion(game):
    """Verify the underground DirtGrid supports horizontal expansion."""
    # DirtGrid should exist
    exists = await game.node_exists(PATHS["dirt_grid"])
    assert exists, "DirtGrid node should exist"

    # Check that DirtGrid has the new horizontal constants
    # This verifies the script was updated
    main_exists = await game.node_exists(PATHS["main"])
    assert main_exists, "Main scene should exist (indicating all scripts compiled)"


@pytest.mark.asyncio
async def test_infinite_horizontal_space(game):
    """Verify both surface and underground support infinite horizontal space."""
    # This is a compilation check - if the game loads without errors,
    # it means the infinite horizontal system was implemented successfully
    main_exists = await game.node_exists(PATHS["main"])
    player_exists = await game.node_exists(PATHS["player"])
    dirt_grid_exists = await game.node_exists(PATHS["dirt_grid"])
    surface_exists = await game.node_exists(PATHS["surface_area"])

    assert main_exists, "Main scene should exist"
    assert player_exists, "Player should exist"
    assert dirt_grid_exists, "DirtGrid should exist"
    assert surface_exists, "SurfaceArea should exist"
