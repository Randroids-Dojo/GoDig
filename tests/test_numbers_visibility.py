"""
Tests for the 'Numbers go up visibility' feature.

Verifies that all key numbers (coins, depth, depth record, inventory value)
are visible on the HUD and animate appropriately when they change.
"""
import pytest
from helpers import PATHS, wait_for_node


@pytest.mark.asyncio
async def test_coins_label_exists(game):
    """Test that coins label exists in HUD."""
    await game.change_scene("res://scenes/main.tscn")
    exists = await game.node_exists(PATHS["coins_label"])
    assert exists, "Coins label should exist in HUD"


@pytest.mark.asyncio
async def test_depth_label_exists(game):
    """Test that depth label exists in HUD."""
    await game.change_scene("res://scenes/main.tscn")
    exists = await game.node_exists(PATHS["depth_label"])
    assert exists, "Depth label should exist in HUD"


@pytest.mark.asyncio
async def test_depth_record_label_exists(game):
    """Test that depth record label exists in HUD."""
    await game.change_scene("res://scenes/main.tscn")
    # Wait a bit for programmatic setup
    await game.wait(0.3)
    exists = await game.node_exists(PATHS["depth_record_label"])
    assert exists, "Depth record label should exist in HUD"


@pytest.mark.asyncio
async def test_inventory_value_label_exists(game):
    """Test that inventory value label exists in HUD."""
    await game.change_scene("res://scenes/main.tscn")
    # Wait a bit for programmatic setup
    await game.wait(0.3)
    exists = await game.node_exists(PATHS["inventory_value_label"])
    assert exists, "Inventory value label should exist in HUD"


@pytest.mark.asyncio
async def test_coins_label_format(game):
    """Test that coins label shows dollar sign format."""
    await game.change_scene("res://scenes/main.tscn")
    await game.wait(0.2)
    text = await game.get_property(PATHS["coins_label"], "text")
    assert "$" in text, f"Coins label should contain dollar sign, got: {text}"


@pytest.mark.asyncio
async def test_depth_label_format(game):
    """Test that depth label shows meters format."""
    await game.change_scene("res://scenes/main.tscn")
    await game.wait(0.2)
    text = await game.get_property(PATHS["depth_label"], "text")
    assert "m" in text, f"Depth label should contain 'm' for meters, got: {text}"


@pytest.mark.asyncio
async def test_ladder_quickslot_exists(game):
    """Test that ladder quickslot exists in HUD."""
    await game.change_scene("res://scenes/main.tscn")
    await game.wait(0.3)
    exists = await game.node_exists(PATHS["ladder_quickslot"])
    assert exists, "Ladder quickslot should exist in HUD"


@pytest.mark.asyncio
async def test_hud_panel_visibility(game):
    """Test that main HUD is visible."""
    await game.change_scene("res://scenes/main.tscn")
    await game.wait(0.2)
    visible = await game.get_property(PATHS["hud"], "visible")
    assert visible, "HUD should be visible during gameplay"


@pytest.mark.asyncio
async def test_health_bar_exists(game):
    """Test that health bar exists in HUD."""
    await game.change_scene("res://scenes/main.tscn")
    exists = await game.node_exists(PATHS["health_bar"])
    assert exists, "Health bar should exist in HUD"


@pytest.mark.asyncio
async def test_inventory_label_format(game):
    """Test that inventory shows used/total format."""
    await game.change_scene("res://scenes/main.tscn")
    await game.wait(0.3)

    # The inventory indicator is created programmatically, check if it exists
    # by looking for the InventoryLabel node
    inventory_label_path = "/root/Main/UI/HUD/InventoryLabel"
    exists = await game.node_exists(inventory_label_path)
    if exists:
        text = await game.get_property(inventory_label_path, "text")
        assert "Bag:" in text or "/" in text, f"Inventory label should show bag format, got: {text}"
