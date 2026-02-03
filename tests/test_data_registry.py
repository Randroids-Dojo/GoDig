"""
DataRegistry tests for GoDig endless digging game.

Tests verify that DataRegistry:
1. Exists as an autoload singleton
2. Loads and provides access to layer definitions
3. Loads and provides access to ore definitions
4. Loads and provides access to item definitions
5. Loads and provides access to tool definitions
6. Loads and provides access to equipment definitions
7. Loads and provides access to sidegrade definitions
8. Loads and provides access to lore definitions
9. Has proper helper methods for tests
"""
import pytest
from helpers import PATHS


# Path to data registry
DATA_REGISTRY_PATH = PATHS.get("data_registry", "/root/DataRegistry")


# =============================================================================
# SINGLETON EXISTENCE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_data_registry_exists(game):
    """DataRegistry autoload should exist."""
    result = await game.node_exists(DATA_REGISTRY_PATH)
    assert result.get("exists") is True, "DataRegistry autoload should exist"


# =============================================================================
# RESOURCE CONSTANT TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_has_layer_resources_constant(game):
    """DataRegistry should have LAYER_RESOURCES constant."""
    result = await game.get_property(DATA_REGISTRY_PATH, "LAYER_RESOURCES")
    assert result is not None, "LAYER_RESOURCES should exist"
    assert isinstance(result, list), f"LAYER_RESOURCES should be list, got {type(result)}"


@pytest.mark.asyncio
async def test_has_ore_resources_constant(game):
    """DataRegistry should have ORE_RESOURCES constant."""
    result = await game.get_property(DATA_REGISTRY_PATH, "ORE_RESOURCES")
    assert result is not None, "ORE_RESOURCES should exist"
    assert isinstance(result, list), f"ORE_RESOURCES should be list, got {type(result)}"


@pytest.mark.asyncio
async def test_has_gem_resources_constant(game):
    """DataRegistry should have GEM_RESOURCES constant."""
    result = await game.get_property(DATA_REGISTRY_PATH, "GEM_RESOURCES")
    assert result is not None, "GEM_RESOURCES should exist"
    assert isinstance(result, list), f"GEM_RESOURCES should be list, got {type(result)}"


@pytest.mark.asyncio
async def test_has_item_resources_constant(game):
    """DataRegistry should have ITEM_RESOURCES constant."""
    result = await game.get_property(DATA_REGISTRY_PATH, "ITEM_RESOURCES")
    assert result is not None, "ITEM_RESOURCES should exist"
    assert isinstance(result, list), f"ITEM_RESOURCES should be list, got {type(result)}"


@pytest.mark.asyncio
async def test_has_tool_resources_constant(game):
    """DataRegistry should have TOOL_RESOURCES constant."""
    result = await game.get_property(DATA_REGISTRY_PATH, "TOOL_RESOURCES")
    assert result is not None, "TOOL_RESOURCES should exist"
    assert isinstance(result, list), f"TOOL_RESOURCES should be list, got {type(result)}"


@pytest.mark.asyncio
async def test_has_equipment_resources_constant(game):
    """DataRegistry should have EQUIPMENT_RESOURCES constant."""
    result = await game.get_property(DATA_REGISTRY_PATH, "EQUIPMENT_RESOURCES")
    assert result is not None, "EQUIPMENT_RESOURCES should exist"
    assert isinstance(result, list), f"EQUIPMENT_RESOURCES should be list, got {type(result)}"


@pytest.mark.asyncio
async def test_has_sidegrade_resources_constant(game):
    """DataRegistry should have SIDEGRADE_RESOURCES constant."""
    result = await game.get_property(DATA_REGISTRY_PATH, "SIDEGRADE_RESOURCES")
    assert result is not None, "SIDEGRADE_RESOURCES should exist"
    assert isinstance(result, list), f"SIDEGRADE_RESOURCES should be list, got {type(result)}"


@pytest.mark.asyncio
async def test_has_lore_resources_constant(game):
    """DataRegistry should have LORE_RESOURCES constant."""
    result = await game.get_property(DATA_REGISTRY_PATH, "LORE_RESOURCES")
    assert result is not None, "LORE_RESOURCES should exist"
    assert isinstance(result, list), f"LORE_RESOURCES should be list, got {type(result)}"


# =============================================================================
# LAYER SYSTEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_layer_count(game):
    """get_layer_count should return positive number."""
    result = await game.call(DATA_REGISTRY_PATH, "get_layer_count")
    assert result is not None, "get_layer_count should return a value"
    assert isinstance(result, int), f"get_layer_count should return int, got {type(result)}"
    assert result > 0, f"Should have at least one layer, got {result}"


@pytest.mark.asyncio
async def test_layer_count_matches_resources(game):
    """Layer count should match LAYER_RESOURCES length."""
    count = await game.call(DATA_REGISTRY_PATH, "get_layer_count")
    resources = await game.get_property(DATA_REGISTRY_PATH, "LAYER_RESOURCES")
    assert count == len(resources), f"Layer count {count} should match resources {len(resources)}"


@pytest.mark.asyncio
async def test_get_all_layer_ids_returns_array(game):
    """get_all_layer_ids should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_layer_ids")
    assert result is not None, "get_all_layer_ids should return a value"
    assert isinstance(result, list), f"get_all_layer_ids should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_has_layer_returns_bool(game):
    """has_layer should return a boolean."""
    result = await game.call(DATA_REGISTRY_PATH, "has_layer", ["topsoil"])
    assert isinstance(result, bool), f"has_layer should return bool, got {type(result)}"


@pytest.mark.asyncio
async def test_has_layer_topsoil(game):
    """has_layer should return true for 'topsoil'."""
    result = await game.call(DATA_REGISTRY_PATH, "has_layer", ["topsoil"])
    assert result is True, "Should have 'topsoil' layer"


@pytest.mark.asyncio
async def test_has_layer_invalid(game):
    """has_layer should return false for invalid layer."""
    result = await game.call(DATA_REGISTRY_PATH, "has_layer", ["nonexistent_layer"])
    assert result is False, "Should not have 'nonexistent_layer'"


@pytest.mark.asyncio
async def test_get_layer_id_at_depth_0(game):
    """get_layer_id_at_depth(0) should return first layer."""
    result = await game.call(DATA_REGISTRY_PATH, "get_layer_id_at_depth", [0])
    assert result is not None, "get_layer_id_at_depth should return a value"
    assert isinstance(result, str), f"get_layer_id_at_depth should return string, got {type(result)}"
    assert len(result) > 0, "Layer ID should not be empty"


@pytest.mark.asyncio
async def test_get_layer_display_name(game):
    """get_layer_display_name should return a string."""
    result = await game.call(DATA_REGISTRY_PATH, "get_layer_display_name", ["topsoil"])
    assert result is not None, "get_layer_display_name should return a value"
    assert isinstance(result, str), f"get_layer_display_name should return string, got {type(result)}"


@pytest.mark.asyncio
async def test_get_layer_min_depth(game):
    """get_layer_min_depth should return an integer."""
    result = await game.call(DATA_REGISTRY_PATH, "get_layer_min_depth", ["topsoil"])
    assert result is not None, "get_layer_min_depth should return a value"
    assert isinstance(result, int), f"get_layer_min_depth should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_get_layer_max_depth(game):
    """get_layer_max_depth should return an integer."""
    result = await game.call(DATA_REGISTRY_PATH, "get_layer_max_depth", ["topsoil"])
    assert result is not None, "get_layer_max_depth should return a value"
    assert isinstance(result, int), f"get_layer_max_depth should return int, got {type(result)}"


@pytest.mark.asyncio
async def test_get_layer_base_hardness(game):
    """get_layer_base_hardness should return a float."""
    result = await game.call(DATA_REGISTRY_PATH, "get_layer_base_hardness", ["topsoil"])
    assert result is not None, "get_layer_base_hardness should return a value"
    assert isinstance(result, (int, float)), f"get_layer_base_hardness should return number, got {type(result)}"


@pytest.mark.asyncio
async def test_is_transition_zone_returns_bool(game):
    """is_transition_zone should return a boolean."""
    result = await game.call(DATA_REGISTRY_PATH, "is_transition_zone", [{"x": 0, "y": 10}])
    assert isinstance(result, bool), f"is_transition_zone should return bool, got {type(result)}"


# =============================================================================
# ORE SYSTEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_ores_property_exists(game):
    """ores property should exist and be a dictionary."""
    result = await game.get_property(DATA_REGISTRY_PATH, "ores")
    assert result is not None, "ores should exist"
    assert isinstance(result, dict), f"ores should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_ores_has_entries(game):
    """ores dictionary should have entries."""
    result = await game.get_property(DATA_REGISTRY_PATH, "ores")
    assert len(result) > 0, "ores should have entries"


@pytest.mark.asyncio
async def test_get_all_ore_ids_returns_array(game):
    """get_all_ore_ids should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_ore_ids")
    assert result is not None, "get_all_ore_ids should return a value"
    assert isinstance(result, list), f"get_all_ore_ids should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_ore_ids_has_entries(game):
    """get_all_ore_ids should return ore IDs."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_ore_ids")
    assert len(result) > 0, "Should have ore IDs"


@pytest.mark.asyncio
async def test_common_ore_exists(game):
    """Common ore like 'coal' should exist."""
    ores = await game.get_property(DATA_REGISTRY_PATH, "ores")
    assert "coal" in ores, "Should have 'coal' ore"


@pytest.mark.asyncio
async def test_copper_ore_exists(game):
    """Copper ore should exist."""
    ores = await game.get_property(DATA_REGISTRY_PATH, "ores")
    assert "copper" in ores, "Should have 'copper' ore"


@pytest.mark.asyncio
async def test_get_all_ores_returns_array(game):
    """get_all_ores should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_ores")
    assert result is not None, "get_all_ores should return a value"
    assert isinstance(result, list), f"get_all_ores should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_ores_at_depth_returns_array(game):
    """get_ores_at_depth should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_ores_at_depth", [10])
    assert result is not None, "get_ores_at_depth should return a value"
    assert isinstance(result, list), f"get_ores_at_depth should return list, got {type(result)}"


# =============================================================================
# ITEM SYSTEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_items_property_exists(game):
    """items property should exist and be a dictionary."""
    result = await game.get_property(DATA_REGISTRY_PATH, "items")
    assert result is not None, "items should exist"
    assert isinstance(result, dict), f"items should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_items_has_entries(game):
    """items dictionary should have entries."""
    result = await game.get_property(DATA_REGISTRY_PATH, "items")
    assert len(result) > 0, "items should have entries"


@pytest.mark.asyncio
async def test_get_all_item_ids_returns_array(game):
    """get_all_item_ids should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_item_ids")
    assert result is not None, "get_all_item_ids should return a value"
    assert isinstance(result, list), f"get_all_item_ids should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_items_returns_array(game):
    """get_all_items should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_items")
    assert result is not None, "get_all_items should return a value"
    assert isinstance(result, list), f"get_all_items should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_ladder_item_exists(game):
    """Ladder item should exist."""
    items = await game.get_property(DATA_REGISTRY_PATH, "items")
    assert "ladder" in items, "Should have 'ladder' item"


@pytest.mark.asyncio
async def test_get_all_artifacts_returns_array(game):
    """get_all_artifacts should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_artifacts")
    assert result is not None, "get_all_artifacts should return a value"
    assert isinstance(result, list), f"get_all_artifacts should return list, got {type(result)}"


# =============================================================================
# TOOL SYSTEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_tools_property_exists(game):
    """tools property should exist and be a dictionary."""
    result = await game.get_property(DATA_REGISTRY_PATH, "tools")
    assert result is not None, "tools should exist"
    assert isinstance(result, dict), f"tools should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_tools_has_entries(game):
    """tools dictionary should have entries."""
    result = await game.get_property(DATA_REGISTRY_PATH, "tools")
    assert len(result) > 0, "tools should have entries"


@pytest.mark.asyncio
async def test_get_all_tool_ids_returns_array(game):
    """get_all_tool_ids should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_tool_ids")
    assert result is not None, "get_all_tool_ids should return a value"
    assert isinstance(result, list), f"get_all_tool_ids should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_tools_returns_array(game):
    """get_all_tools should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_tools")
    assert result is not None, "get_all_tools should return a value"
    assert isinstance(result, list), f"get_all_tools should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_rusty_pickaxe_exists(game):
    """Rusty pickaxe (starter tool) should exist."""
    tools = await game.get_property(DATA_REGISTRY_PATH, "tools")
    assert "rusty_pickaxe" in tools, "Should have 'rusty_pickaxe' tool"


@pytest.mark.asyncio
async def test_copper_pickaxe_exists(game):
    """Copper pickaxe should exist."""
    tools = await game.get_property(DATA_REGISTRY_PATH, "tools")
    assert "copper_pickaxe" in tools, "Should have 'copper_pickaxe' tool"


@pytest.mark.asyncio
async def test_get_tools_at_depth_returns_array(game):
    """get_tools_at_depth should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_tools_at_depth", [0])
    assert result is not None, "get_tools_at_depth should return a value"
    assert isinstance(result, list), f"get_tools_at_depth should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_tools_at_depth_includes_starter(game):
    """get_tools_at_depth(0) should include starter tool."""
    result = await game.call(DATA_REGISTRY_PATH, "get_tools_at_depth", [0])
    # Result is array of resources, check it's not empty
    assert len(result) > 0, "Should have at least one tool available at depth 0"


# =============================================================================
# EQUIPMENT SYSTEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_equipment_property_exists(game):
    """equipment property should exist and be a dictionary."""
    result = await game.get_property(DATA_REGISTRY_PATH, "equipment")
    assert result is not None, "equipment should exist"
    assert isinstance(result, dict), f"equipment should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_equipment_has_entries(game):
    """equipment dictionary should have entries."""
    result = await game.get_property(DATA_REGISTRY_PATH, "equipment")
    assert len(result) > 0, "equipment should have entries"


@pytest.mark.asyncio
async def test_get_all_equipment_ids_returns_array(game):
    """get_all_equipment_ids should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_equipment_ids")
    assert result is not None, "get_all_equipment_ids should return a value"
    assert isinstance(result, list), f"get_all_equipment_ids should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_equipment_returns_array(game):
    """get_all_equipment should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_equipment")
    assert result is not None, "get_all_equipment should return a value"
    assert isinstance(result, list), f"get_all_equipment should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_boots_returns_array(game):
    """get_all_boots should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_boots")
    assert result is not None, "get_all_boots should return a value"
    assert isinstance(result, list), f"get_all_boots should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_helmets_returns_array(game):
    """get_all_helmets should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_helmets")
    assert result is not None, "get_all_helmets should return a value"
    assert isinstance(result, list), f"get_all_helmets should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_equipment_at_depth_returns_array(game):
    """get_equipment_at_depth should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_equipment_at_depth", [0])
    assert result is not None, "get_equipment_at_depth should return a value"
    assert isinstance(result, list), f"get_equipment_at_depth should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_equipment_by_slot_returns_array(game):
    """get_equipment_by_slot should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_equipment_by_slot", [0])  # BOOTS slot
    assert result is not None, "get_equipment_by_slot should return a value"
    assert isinstance(result, list), f"get_equipment_by_slot should return list, got {type(result)}"


# =============================================================================
# SIDEGRADE SYSTEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_sidegrades_property_exists(game):
    """sidegrades property should exist and be a dictionary."""
    result = await game.get_property(DATA_REGISTRY_PATH, "sidegrades")
    assert result is not None, "sidegrades should exist"
    assert isinstance(result, dict), f"sidegrades should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_sidegrades_has_entries(game):
    """sidegrades dictionary should have entries."""
    result = await game.get_property(DATA_REGISTRY_PATH, "sidegrades")
    assert len(result) > 0, "sidegrades should have entries"


@pytest.mark.asyncio
async def test_get_all_sidegrade_ids_returns_array(game):
    """get_all_sidegrade_ids should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_sidegrade_ids")
    assert result is not None, "get_all_sidegrade_ids should return a value"
    assert isinstance(result, list), f"get_all_sidegrade_ids should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_sidegrades_returns_array(game):
    """get_all_sidegrades should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_sidegrades")
    assert result is not None, "get_all_sidegrades should return a value"
    assert isinstance(result, list), f"get_all_sidegrades should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_sidegrades_at_depth_returns_array(game):
    """get_sidegrades_at_depth should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_sidegrades_at_depth", [100])
    assert result is not None, "get_sidegrades_at_depth should return a value"
    assert isinstance(result, list), f"get_sidegrades_at_depth should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_sidegrades_by_category_returns_array(game):
    """get_sidegrades_by_category should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_sidegrades_by_category", [0])  # MINING category
    assert result is not None, "get_sidegrades_by_category should return a value"
    assert isinstance(result, list), f"get_sidegrades_by_category should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_sidegrades_conflict_returns_bool(game):
    """sidegrades_conflict should return a boolean."""
    result = await game.call(DATA_REGISTRY_PATH, "sidegrades_conflict", ["precision_miner", "speed_demon"])
    assert isinstance(result, bool), f"sidegrades_conflict should return bool, got {type(result)}"


# =============================================================================
# LORE SYSTEM TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_lore_property_exists(game):
    """lore property should exist and be a dictionary."""
    result = await game.get_property(DATA_REGISTRY_PATH, "lore")
    assert result is not None, "lore should exist"
    assert isinstance(result, dict), f"lore should be dict, got {type(result)}"


@pytest.mark.asyncio
async def test_lore_has_entries(game):
    """lore dictionary should have entries."""
    result = await game.get_property(DATA_REGISTRY_PATH, "lore")
    assert len(result) > 0, "lore should have entries"


@pytest.mark.asyncio
async def test_get_all_lore_ids_returns_array(game):
    """get_all_lore_ids should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_lore_ids")
    assert result is not None, "get_all_lore_ids should return a value"
    assert isinstance(result, list), f"get_all_lore_ids should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_all_lore_returns_array(game):
    """get_all_lore should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_all_lore")
    assert result is not None, "get_all_lore should return a value"
    assert isinstance(result, list), f"get_all_lore should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_lore_at_depth_returns_array(game):
    """get_lore_at_depth should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_lore_at_depth", [50])
    assert result is not None, "get_lore_at_depth should return a value"
    assert isinstance(result, list), f"get_lore_at_depth should return list, got {type(result)}"


@pytest.mark.asyncio
async def test_get_lore_by_type_returns_array(game):
    """get_lore_by_type should return an array."""
    result = await game.call(DATA_REGISTRY_PATH, "get_lore_by_type", ["journal"])
    assert result is not None, "get_lore_by_type should return a value"
    assert isinstance(result, list), f"get_lore_by_type should return list, got {type(result)}"


# =============================================================================
# BLOCK HELPER TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_get_block_hardness_returns_float(game):
    """get_block_hardness should return a number."""
    result = await game.call(DATA_REGISTRY_PATH, "get_block_hardness", [{"x": 0, "y": 10}])
    assert result is not None, "get_block_hardness should return a value"
    assert isinstance(result, (int, float)), f"get_block_hardness should return number, got {type(result)}"


@pytest.mark.asyncio
async def test_get_block_color_returns_color(game):
    """get_block_color should return a value."""
    result = await game.call(DATA_REGISTRY_PATH, "get_block_color", [{"x": 0, "y": 10}])
    assert result is not None, "get_block_color should return a value"
