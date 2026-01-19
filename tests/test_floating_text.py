"""
Tests for floating text pickup feedback.

Verifies that the floating text system exists and is set up correctly.
"""
import pytest
from tests.helpers import PATHS


# =============================================================================
# FLOATING TEXT LAYER EXISTS
# =============================================================================

@pytest.mark.asyncio
async def test_floating_text_layer_exists(game):
    """Floating text layer node exists in the scene."""
    exists = await game.node_exists(PATHS["floating_text_layer"])
    assert exists, "FloatingTextLayer should exist in Main scene"


@pytest.mark.asyncio
async def test_floating_text_layer_has_high_layer(game):
    """Floating text layer renders above other UI."""
    layer = await game.get_property(PATHS["floating_text_layer"], "layer")
    assert layer >= 10, f"FloatingTextLayer should have layer >= 10, got {layer}"


# =============================================================================
# INVENTORY MANAGER SIGNAL EXISTS
# =============================================================================

@pytest.mark.asyncio
async def test_inventory_manager_exists(game):
    """InventoryManager autoload exists."""
    exists = await game.node_exists(PATHS["inventory_manager"])
    assert exists, "InventoryManager should exist"


@pytest.mark.asyncio
async def test_inventory_manager_has_slots(game):
    """InventoryManager has slots configured."""
    max_slots = await game.get_property(PATHS["inventory_manager"], "max_slots")
    assert max_slots > 0, f"InventoryManager should have slots, got {max_slots}"
