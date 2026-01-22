"""
Test surface area scene for GoDig.

Verifies that the surface scene loads correctly with sky, ground, shop building,
mine entrance, and spawn point. Also tests that player spawns at the correct position.
"""
import asyncio
import pytest
from helpers import PATHS


@pytest.mark.asyncio
async def test_surface_scene_exists(game):
    """Verify the surface scene exists in the level."""
    exists = await game.node_exists(PATHS["surface"])
    assert exists, "Surface scene should exist"


@pytest.mark.asyncio
async def test_surface_sky_exists(game):
    """Verify the sky ColorRect exists."""
    exists = await game.node_exists(PATHS["surface_sky"])
    assert exists, "Surface sky should exist"


@pytest.mark.asyncio
async def test_surface_ground_exists(game):
    """Verify the ground ColorRect exists."""
    exists = await game.node_exists(PATHS["surface_ground"])
    assert exists, "Surface ground should exist"


@pytest.mark.asyncio
async def test_surface_spawn_point_exists(game):
    """Verify the spawn point marker exists."""
    exists = await game.node_exists(PATHS["surface_spawn_point"])
    assert exists, "Surface spawn point should exist"


@pytest.mark.asyncio
async def test_surface_shop_building_exists(game):
    """Verify the shop building exists on the surface."""
    exists = await game.node_exists(PATHS["surface_shop_building"])
    assert exists, "Shop building should exist on surface"


@pytest.mark.asyncio
async def test_surface_mine_entrance_exists(game):
    """Verify the mine entrance visual exists."""
    exists = await game.node_exists(PATHS["surface_mine_entrance"])
    assert exists, "Mine entrance should exist on surface"


@pytest.mark.asyncio
async def test_surface_sky_color(game):
    """Verify the sky has a blue color."""
    color = await game.get_property(PATHS["surface_sky"], "color")
    assert color is not None, "Sky should have a color property"
    # Color should be bluish (high blue component)
    assert color["b"] > 0.8, f"Sky should be blue, got {color}"


@pytest.mark.asyncio
async def test_surface_ground_color(game):
    """Verify the ground has a green color."""
    color = await game.get_property(PATHS["surface_ground"], "color")
    assert color is not None, "Ground should have a color property"
    # Color should be greenish (high green component)
    assert color["g"] > 0.5, f"Ground should be green, got {color}"


@pytest.mark.asyncio
async def test_spawn_point_position(game):
    """Verify the spawn point is at a reasonable position."""
    position = await game.get_property(PATHS["surface_spawn_point"], "position")
    assert position is not None, "Spawn point should have a position"
    # Y position should be near row 6 (768px = 6 * 128)
    assert 700 <= position["y"] <= 800, f"Spawn point Y should be near 768px, got {position['y']}"


@pytest.mark.asyncio
async def test_player_spawns_at_surface(game):
    """Verify the player spawns at the surface spawn point."""
    player_pos = await game.get_property(PATHS["player"], "position")
    spawn_pos = await game.get_property(PATHS["surface_spawn_point"], "position")

    assert player_pos is not None, "Player should have a position"
    assert spawn_pos is not None, "Spawn point should have a position"

    # Player should spawn at or very near the spawn point
    # Allow some tolerance for positioning
    assert abs(player_pos["x"] - spawn_pos["x"]) < 10, \
        f"Player X should be near spawn X ({spawn_pos['x']}), got {player_pos['x']}"
    assert abs(player_pos["y"] - spawn_pos["y"]) < 10, \
        f"Player Y should be near spawn Y ({spawn_pos['y']}), got {player_pos['y']}"


@pytest.mark.asyncio
async def test_player_starts_above_dirt_grid(game):
    """Verify the player starts above the dirt grid (row 7)."""
    player_pos = await game.get_property(PATHS["player"], "position")
    assert player_pos is not None, "Player should have a position"

    # SURFACE_ROW is 7, which means dirt starts at 896px (7 * 128)
    # Player should be above this (Y < 896)
    assert player_pos["y"] < 896, \
        f"Player should start above dirt grid (Y < 896), got {player_pos['y']}"


@pytest.mark.asyncio
async def test_surface_shop_building_position(game):
    """Verify the shop building is positioned on the surface."""
    shop_pos = await game.get_property(PATHS["surface_shop_building"], "position")
    assert shop_pos is not None, "Shop building should have a position"

    # Shop should be on the surface (Y around 576-768 px)
    assert 400 <= shop_pos["y"] <= 900, \
        f"Shop building should be on surface, got Y={shop_pos['y']}"


@pytest.mark.asyncio
async def test_surface_mine_entrance_position(game):
    """Verify the mine entrance is positioned on the surface."""
    mine_pos = await game.get_property(PATHS["surface_mine_entrance"], "position")
    assert mine_pos is not None, "Mine entrance should have a position"

    # Mine entrance should be on the surface near row 6-7 (768-896px)
    assert 600 <= mine_pos["y"] <= 900, \
        f"Mine entrance should be on surface, got Y={mine_pos['y']}"


@pytest.mark.asyncio
async def test_surface_elements_horizontal_spread(game):
    """Verify surface elements are spread out horizontally."""
    spawn_pos = await game.get_property(PATHS["surface_spawn_point"], "position")
    shop_pos = await game.get_property(PATHS["surface_shop_building"], "position")
    mine_pos = await game.get_property(PATHS["surface_mine_entrance"], "position")

    assert spawn_pos is not None, "Spawn point should have a position"
    assert shop_pos is not None, "Shop building should have a position"
    assert mine_pos is not None, "Mine entrance should have a position"

    # Elements should have different X positions (not stacked on top of each other)
    assert abs(spawn_pos["x"] - shop_pos["x"]) > 100, \
        "Spawn point and shop should be separated horizontally"
    assert abs(spawn_pos["x"] - mine_pos["x"]) > 100, \
        "Spawn point and mine entrance should be separated horizontally"
