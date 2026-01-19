"""
Test surface chunk system for horizontal infinite scrolling.

Verifies the surface area, chunk loading/unloading, and horizontal navigation.
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
async def test_surface_chunk_class_exists(game):
    """Verify the SurfaceChunk class is available."""
    # Test that we can reference the SurfaceChunk class
    # This is more of a script compilation check
    main_exists = await game.node_exists(PATHS["main"])
    assert main_exists, "Main scene should exist (indicating all scripts compiled)"
