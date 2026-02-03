"""
Tests for the two-layer cave system with hidden back areas.

The CaveLayerManager provides a Spelunky 2-style two-layer cave system
with a front (visible) layer and back (hidden) layer requiring special
items to reveal.
"""
import pytest
from helpers import PATHS


@pytest.mark.asyncio
async def test_cave_layer_manager_exists(main_menu):
    """CaveLayerManager autoload should exist even on main menu."""
    # Autoloads exist regardless of current scene
    exists = await main_menu.node_exists(PATHS["cave_layer_manager"])
    assert exists is True, "CaveLayerManager autoload should exist"


@pytest.mark.asyncio
async def test_cave_layer_manager_ready(main_menu):
    """CaveLayerManager should be ready and accessible."""
    # Verify the node exists and can be queried
    exists = await main_menu.node_exists(PATHS["cave_layer_manager"])
    assert exists is True, "CaveLayerManager should be ready"

    # Verify it's a Node (autoload)
    class_name = await main_menu.get_property(PATHS["cave_layer_manager"], "name")
    assert class_name == "CaveLayerManager", "Node should be named CaveLayerManager"
