"""
Test layer system for GoDig endless digging game.

Verifies DataRegistry layer loading and depth-based hardness values.
Tests that layer progression works correctly per the 3-4 Layer Types spec.

Note: Uses ID-based helper methods since PlayGodot cannot serialize Resource objects.
"""
import pytest
from helpers import PATHS


# =============================================================================
# DATAREGISTRY LAYER LOADING TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_dataregistry_exists(game):
    """Verify DataRegistry autoload exists."""
    exists = await game.node_exists(PATHS["data_registry"])
    assert exists, "DataRegistry autoload should exist"


@pytest.mark.asyncio
async def test_dataregistry_has_get_layer_method(game):
    """Verify DataRegistry has get_layer method."""
    has_method = await game.call(PATHS["data_registry"], "has_method", ["get_layer"])
    assert has_method, "DataRegistry should have get_layer method"


@pytest.mark.asyncio
async def test_dataregistry_has_get_layer_at_depth_method(game):
    """Verify DataRegistry has get_layer_at_depth method."""
    has_method = await game.call(PATHS["data_registry"], "has_method", ["get_layer_at_depth"])
    assert has_method, "DataRegistry should have get_layer_at_depth method"


@pytest.mark.asyncio
async def test_dataregistry_has_get_block_hardness_method(game):
    """Verify DataRegistry has get_block_hardness method."""
    has_method = await game.call(PATHS["data_registry"], "has_method", ["get_block_hardness"])
    assert has_method, "DataRegistry should have get_block_hardness method"


@pytest.mark.asyncio
async def test_dataregistry_has_get_block_color_method(game):
    """Verify DataRegistry has get_block_color method."""
    has_method = await game.call(PATHS["data_registry"], "has_method", ["get_block_color"])
    assert has_method, "DataRegistry should have get_block_color method"


@pytest.mark.asyncio
async def test_dataregistry_layer_count(game):
    """Verify DataRegistry loads at least 4 layer types."""
    count = await game.call(PATHS["data_registry"], "get_layer_count")
    assert count >= 4, f"DataRegistry should have at least 4 layer types, got {count}"


# =============================================================================
# LAYER EXISTENCE TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_has_layer_topsoil(game):
    """Verify DataRegistry has topsoil layer."""
    has_layer = await game.call(PATHS["data_registry"], "has_layer", ["topsoil"])
    assert has_layer is True, "DataRegistry should have 'topsoil' layer"


@pytest.mark.asyncio
async def test_has_layer_subsoil(game):
    """Verify DataRegistry has subsoil layer."""
    has_layer = await game.call(PATHS["data_registry"], "has_layer", ["subsoil"])
    assert has_layer is True, "DataRegistry should have 'subsoil' layer"


@pytest.mark.asyncio
async def test_has_layer_stone(game):
    """Verify DataRegistry has stone layer."""
    has_layer = await game.call(PATHS["data_registry"], "has_layer", ["stone"])
    assert has_layer is True, "DataRegistry should have 'stone' layer"


@pytest.mark.asyncio
async def test_has_layer_deep_stone(game):
    """Verify DataRegistry has deep_stone layer."""
    has_layer = await game.call(PATHS["data_registry"], "has_layer", ["deep_stone"])
    assert has_layer is True, "DataRegistry should have 'deep_stone' layer"


@pytest.mark.asyncio
async def test_has_layer_invalid_returns_false(game):
    """Verify has_layer returns false for invalid IDs."""
    has_layer = await game.call(PATHS["data_registry"], "has_layer", ["nonexistent_layer"])
    assert has_layer is False, "has_layer should return False for invalid ID"


# =============================================================================
# LAYER DEPTH BOUNDARY TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_topsoil_min_depth(game):
    """Verify topsoil min_depth is 0."""
    min_depth = await game.call(PATHS["data_registry"], "get_layer_min_depth", ["topsoil"])
    assert min_depth == 0, f"Topsoil min_depth should be 0, got {min_depth}"


@pytest.mark.asyncio
async def test_topsoil_max_depth(game):
    """Verify topsoil max_depth is 50."""
    max_depth = await game.call(PATHS["data_registry"], "get_layer_max_depth", ["topsoil"])
    assert max_depth == 50, f"Topsoil max_depth should be 50, got {max_depth}"


@pytest.mark.asyncio
async def test_subsoil_min_depth(game):
    """Verify subsoil min_depth is 50."""
    min_depth = await game.call(PATHS["data_registry"], "get_layer_min_depth", ["subsoil"])
    assert min_depth == 50, f"Subsoil min_depth should be 50, got {min_depth}"


@pytest.mark.asyncio
async def test_subsoil_max_depth(game):
    """Verify subsoil max_depth is 200."""
    max_depth = await game.call(PATHS["data_registry"], "get_layer_max_depth", ["subsoil"])
    assert max_depth == 200, f"Subsoil max_depth should be 200, got {max_depth}"


@pytest.mark.asyncio
async def test_stone_min_depth(game):
    """Verify stone min_depth is 200."""
    min_depth = await game.call(PATHS["data_registry"], "get_layer_min_depth", ["stone"])
    assert min_depth == 200, f"Stone min_depth should be 200, got {min_depth}"


@pytest.mark.asyncio
async def test_stone_max_depth(game):
    """Verify stone max_depth is 500."""
    max_depth = await game.call(PATHS["data_registry"], "get_layer_max_depth", ["stone"])
    assert max_depth == 500, f"Stone max_depth should be 500, got {max_depth}"


@pytest.mark.asyncio
async def test_deep_stone_min_depth(game):
    """Verify deep_stone min_depth is 500."""
    min_depth = await game.call(PATHS["data_registry"], "get_layer_min_depth", ["deep_stone"])
    assert min_depth == 500, f"Deep stone min_depth should be 500, got {min_depth}"


@pytest.mark.asyncio
async def test_deep_stone_max_depth_is_large(game):
    """Verify deep_stone max_depth is very large (infinite proxy)."""
    max_depth = await game.call(PATHS["data_registry"], "get_layer_max_depth", ["deep_stone"])
    assert max_depth >= 99999, f"Deep stone max_depth should be >= 99999, got {max_depth}"


# =============================================================================
# GET_LAYER_ID_AT_DEPTH TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_layer_at_depth_0_is_topsoil(game):
    """Verify get_layer_id_at_depth(0) returns 'topsoil'."""
    layer_id = await game.call(PATHS["data_registry"], "get_layer_id_at_depth", [0])
    assert layer_id == "topsoil", f"Layer at depth 0 should be 'topsoil', got '{layer_id}'"


@pytest.mark.asyncio
async def test_layer_at_depth_25_is_topsoil(game):
    """Verify get_layer_id_at_depth(25) returns 'topsoil' (middle of range)."""
    layer_id = await game.call(PATHS["data_registry"], "get_layer_id_at_depth", [25])
    assert layer_id == "topsoil", f"Layer at depth 25 should be 'topsoil', got '{layer_id}'"


@pytest.mark.asyncio
async def test_layer_at_depth_100_is_subsoil(game):
    """Verify get_layer_id_at_depth(100) returns 'subsoil'."""
    layer_id = await game.call(PATHS["data_registry"], "get_layer_id_at_depth", [100])
    assert layer_id == "subsoil", f"Layer at depth 100 should be 'subsoil', got '{layer_id}'"


@pytest.mark.asyncio
async def test_layer_at_depth_300_is_stone(game):
    """Verify get_layer_id_at_depth(300) returns 'stone'."""
    layer_id = await game.call(PATHS["data_registry"], "get_layer_id_at_depth", [300])
    assert layer_id == "stone", f"Layer at depth 300 should be 'stone', got '{layer_id}'"


@pytest.mark.asyncio
async def test_layer_at_depth_600_is_deep_stone(game):
    """Verify get_layer_id_at_depth(600) returns 'deep_stone'."""
    layer_id = await game.call(PATHS["data_registry"], "get_layer_id_at_depth", [600])
    assert layer_id == "deep_stone", f"Layer at depth 600 should be 'deep_stone', got '{layer_id}'"


@pytest.mark.asyncio
async def test_layer_at_extreme_depth_is_deep_stone(game):
    """Verify get_layer_id_at_depth(10000) returns 'deep_stone' (fallback)."""
    layer_id = await game.call(PATHS["data_registry"], "get_layer_id_at_depth", [10000])
    assert layer_id == "deep_stone", f"Layer at extreme depth should be 'deep_stone', got '{layer_id}'"


# =============================================================================
# LAYER HARDNESS TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_topsoil_base_hardness(game):
    """Verify topsoil has expected base hardness (10-15 range per spec)."""
    hardness = await game.call(PATHS["data_registry"], "get_layer_base_hardness", ["topsoil"])
    assert 10 <= hardness <= 15, f"Topsoil base_hardness should be 10-15, got {hardness}"


@pytest.mark.asyncio
async def test_subsoil_base_hardness(game):
    """Verify subsoil has expected base hardness (15-25 range per spec)."""
    hardness = await game.call(PATHS["data_registry"], "get_layer_base_hardness", ["subsoil"])
    assert 15 <= hardness <= 25, f"Subsoil base_hardness should be 15-25, got {hardness}"


@pytest.mark.asyncio
async def test_stone_base_hardness(game):
    """Verify stone has expected base hardness (30-50 range per spec)."""
    hardness = await game.call(PATHS["data_registry"], "get_layer_base_hardness", ["stone"])
    assert 30 <= hardness <= 50, f"Stone base_hardness should be 30-50, got {hardness}"


@pytest.mark.asyncio
async def test_deep_stone_base_hardness(game):
    """Verify deep_stone has expected base hardness (50-80 range per spec)."""
    hardness = await game.call(PATHS["data_registry"], "get_layer_base_hardness", ["deep_stone"])
    assert 50 <= hardness <= 80, f"Deep stone base_hardness should be 50-80, got {hardness}"


@pytest.mark.asyncio
async def test_hardness_increases_with_depth(game):
    """Verify hardness increases as layers get deeper (progression)."""
    topsoil_hardness = await game.call(PATHS["data_registry"], "get_layer_base_hardness", ["topsoil"])
    subsoil_hardness = await game.call(PATHS["data_registry"], "get_layer_base_hardness", ["subsoil"])
    stone_hardness = await game.call(PATHS["data_registry"], "get_layer_base_hardness", ["stone"])
    deep_stone_hardness = await game.call(PATHS["data_registry"], "get_layer_base_hardness", ["deep_stone"])

    assert topsoil_hardness < subsoil_hardness, \
        f"Topsoil ({topsoil_hardness}) should be softer than subsoil ({subsoil_hardness})"
    assert subsoil_hardness < stone_hardness, \
        f"Subsoil ({subsoil_hardness}) should be softer than stone ({stone_hardness})"
    assert stone_hardness < deep_stone_hardness, \
        f"Stone ({stone_hardness}) should be softer than deep_stone ({deep_stone_hardness})"


# =============================================================================
# LAYER DISPLAY NAME TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_topsoil_display_name(game):
    """Verify topsoil has a display name."""
    name = await game.call(PATHS["data_registry"], "get_layer_display_name", ["topsoil"])
    assert name and len(name) > 0, "Topsoil should have a display_name"
    assert name == "Topsoil", f"Topsoil display_name should be 'Topsoil', got '{name}'"


@pytest.mark.asyncio
async def test_subsoil_display_name(game):
    """Verify subsoil has a display name."""
    name = await game.call(PATHS["data_registry"], "get_layer_display_name", ["subsoil"])
    assert name and len(name) > 0, "Subsoil should have a display_name"
    assert name == "Subsoil", f"Subsoil display_name should be 'Subsoil', got '{name}'"


@pytest.mark.asyncio
async def test_stone_display_name(game):
    """Verify stone has a display name."""
    name = await game.call(PATHS["data_registry"], "get_layer_display_name", ["stone"])
    assert name and len(name) > 0, "Stone should have a display_name"
    assert name == "Stone", f"Stone display_name should be 'Stone', got '{name}'"


@pytest.mark.asyncio
async def test_deep_stone_display_name(game):
    """Verify deep_stone has a display name."""
    name = await game.call(PATHS["data_registry"], "get_layer_display_name", ["deep_stone"])
    assert name and len(name) > 0, "Deep stone should have a display_name"
    assert name == "Deep Stone", f"Deep stone display_name should be 'Deep Stone', got '{name}'"


# =============================================================================
# TRANSITION ZONE TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_is_transition_zone_method_exists(game):
    """Verify DataRegistry has is_transition_zone method."""
    has_method = await game.call(PATHS["data_registry"], "has_method", ["is_transition_zone"])
    assert has_method, "DataRegistry should have is_transition_zone method"


# =============================================================================
# LAYER ID LIST TESTS
# =============================================================================


@pytest.mark.asyncio
async def test_get_all_layer_ids_returns_list(game):
    """Verify get_all_layer_ids returns a list of layer IDs."""
    layer_ids = await game.call(PATHS["data_registry"], "get_all_layer_ids")
    assert layer_ids is not None, "get_all_layer_ids should return a list"
    assert len(layer_ids) >= 4, f"Should have at least 4 layer IDs, got {len(layer_ids)}"


@pytest.mark.asyncio
async def test_get_all_layer_ids_contains_expected_layers(game):
    """Verify get_all_layer_ids contains all expected layer IDs."""
    layer_ids = await game.call(PATHS["data_registry"], "get_all_layer_ids")
    expected_ids = ["topsoil", "subsoil", "stone", "deep_stone"]
    for expected in expected_ids:
        assert expected in layer_ids, f"Layer IDs should contain '{expected}'"
