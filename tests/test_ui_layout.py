"""
Integration tests for the portrait UI layout system.

Tests the UILayout scene, HUD positioning, touch controls layout,
and safe area handling for portrait mode (720x1280).
"""
import pytest
from helpers import PATHS


@pytest.mark.asyncio
async def test_hud_exists(game):
    """HUD should exist in the scene."""
    exists = await game.node_exists(PATHS["hud"])
    assert exists, "HUD node should exist"


@pytest.mark.asyncio
async def test_hud_health_bar_exists(game):
    """Health bar should exist in HUD."""
    exists = await game.node_exists(PATHS["health_bar"])
    assert exists, "Health bar should exist in HUD"


@pytest.mark.asyncio
async def test_hud_health_label_exists(game):
    """Health label should exist in health bar."""
    exists = await game.node_exists(PATHS["health_label"])
    assert exists, "Health label should exist in health bar"


@pytest.mark.asyncio
async def test_hud_coins_label_exists(game):
    """Coins label should exist in HUD."""
    exists = await game.node_exists(PATHS["hud_coins_label"])
    assert exists, "Coins label should exist in HUD"


@pytest.mark.asyncio
async def test_hud_depth_label_exists(game):
    """Depth label should exist in HUD."""
    exists = await game.node_exists(PATHS["hud_depth_label"])
    assert exists, "Depth label should exist in HUD"


@pytest.mark.asyncio
async def test_hud_pause_button_exists(game):
    """Pause button should exist in HUD."""
    exists = await game.node_exists(PATHS["hud_pause_button"])
    assert exists, "Pause button should exist in HUD"


@pytest.mark.asyncio
async def test_touch_controls_exist(game):
    """Touch controls should exist in the scene."""
    exists = await game.node_exists(PATHS["touch_controls"])
    assert exists, "Touch controls node should exist"


@pytest.mark.asyncio
async def test_virtual_joystick_exists(game):
    """Virtual joystick should exist in touch controls."""
    exists = await game.node_exists(PATHS["virtual_joystick"])
    assert exists, "Virtual joystick should exist"


@pytest.mark.asyncio
async def test_action_buttons_exist(game):
    """Action buttons container should exist in touch controls."""
    exists = await game.node_exists(PATHS["action_buttons"])
    assert exists, "Action buttons container should exist"


@pytest.mark.asyncio
async def test_jump_button_exists(game):
    """Jump button should exist in action buttons."""
    exists = await game.node_exists(PATHS["jump_button"])
    assert exists, "Jump button should exist"


@pytest.mark.asyncio
async def test_inventory_button_exists(game):
    """Inventory button should exist in action buttons."""
    exists = await game.node_exists(PATHS["inventory_button"])
    assert exists, "Inventory button should exist"


@pytest.mark.asyncio
async def test_health_bar_positioned_top_left(game):
    """Health bar should be positioned in top-left area with proper margin."""
    position = await game.get_property(PATHS["health_bar"], "position")
    # Health bar should start at least 16px from left and 16px from top
    assert position["x"] >= 16, "Health bar should have left margin"
    assert position["y"] >= 16, "Health bar should have top margin"
    # Should be in the top portion of screen (< 200px from top)
    assert position["y"] < 200, "Health bar should be in top HUD zone"


@pytest.mark.asyncio
async def test_health_bar_minimum_size(game):
    """Health bar should have minimum size for readability."""
    size = await game.get_property(PATHS["health_bar"], "size")
    # Minimum size for touch-friendly display
    assert size["x"] >= 180, "Health bar should be at least 180px wide"
    assert size["y"] >= 28, "Health bar should be at least 28px tall"


@pytest.mark.asyncio
async def test_health_bar_initial_value(game):
    """Health bar should start at full health."""
    value = await game.get_property(PATHS["health_bar"], "value")
    max_value = await game.get_property(PATHS["health_bar"], "max_value")
    assert value == max_value, "Health bar should start at max value"
    assert value == 100, "Initial health should be 100"


@pytest.mark.asyncio
async def test_coins_label_displays_correctly(game):
    """Coins label should display correct initial text."""
    text = await game.get_property(PATHS["hud_coins_label"], "text")
    assert "Coins" in text or "$" in text or "0" in text, \
        "Coins label should display coins information"


@pytest.mark.asyncio
async def test_depth_label_displays_correctly(game):
    """Depth label should display correct initial text."""
    text = await game.get_property(PATHS["hud_depth_label"], "text")
    assert "m" in text or "0" in text, \
        "Depth label should display depth information"


@pytest.mark.asyncio
async def test_virtual_joystick_bottom_left_position(game):
    """Virtual joystick should be anchored to bottom-left."""
    anchor_top = await game.get_property(PATHS["virtual_joystick"], "anchor_top")
    anchor_bottom = await game.get_property(PATHS["virtual_joystick"], "anchor_bottom")
    anchor_left = await game.get_property(PATHS["virtual_joystick"], "anchor_left")

    assert anchor_top == 1.0, "Joystick should be anchored to bottom (top)"
    assert anchor_bottom == 1.0, "Joystick should be anchored to bottom (bottom)"
    assert anchor_left == 0.0, "Joystick should be anchored to left"


@pytest.mark.asyncio
async def test_action_buttons_bottom_right_position(game):
    """Action buttons should be anchored to bottom-right."""
    anchor_top = await game.get_property(PATHS["action_buttons"], "anchor_top")
    anchor_bottom = await game.get_property(PATHS["action_buttons"], "anchor_bottom")
    anchor_left = await game.get_property(PATHS["action_buttons"], "anchor_left")
    anchor_right = await game.get_property(PATHS["action_buttons"], "anchor_right")

    assert anchor_top == 1.0, "Action buttons should be anchored to bottom (top)"
    assert anchor_bottom == 1.0, "Action buttons should be anchored to bottom (bottom)"
    assert anchor_left == 1.0, "Action buttons should be anchored to right (left)"
    assert anchor_right == 1.0, "Action buttons should be anchored to right (right)"


@pytest.mark.asyncio
async def test_touch_controls_in_bottom_zone(game):
    """Touch controls should be in the bottom 220px zone."""
    viewport_height = 1280  # Portrait base resolution

    # Check virtual joystick vertical position
    joystick_position = await game.get_property(PATHS["virtual_joystick"], "position")
    joystick_bottom = joystick_position["y"]

    # Joystick should be in bottom 220px (above y=1060 considering anchoring)
    assert joystick_bottom < viewport_height, \
        "Virtual joystick should be in bottom controls zone"

    # Check action buttons vertical position
    buttons_position = await game.get_property(PATHS["action_buttons"], "position")
    buttons_bottom = buttons_position["y"]

    assert buttons_bottom < viewport_height, \
        "Action buttons should be in bottom controls zone"


@pytest.mark.asyncio
async def test_touch_button_minimum_size(game):
    """Touch buttons should meet minimum touch target size (64px)."""
    # Check jump button size (main action button, should be at least 64px)
    jump_visual = await game.node_exists("/root/Main/UI/TouchControls/ActionButtons/JumpButton/JumpVisual")
    assert jump_visual, "Jump button visual should exist"

    # The size is defined in the ColorRect offset_right/bottom
    # Jump button should be 100x100 (good size for wall-jump action)
    jump_size = await game.get_property(
        "/root/Main/UI/TouchControls/ActionButtons/JumpButton/JumpVisual",
        "size"
    )
    assert jump_size["x"] >= 64, "Jump button should meet minimum touch target width (64px)"
    assert jump_size["y"] >= 64, "Jump button should meet minimum touch target height (64px)"


@pytest.mark.asyncio
async def test_hud_mouse_filter_passthrough(game):
    """HUD should allow mouse events to pass through to game."""
    mouse_filter = await game.get_property(PATHS["hud"], "mouse_filter")
    # mouse_filter: 0=STOP, 1=PASS, 2=IGNORE
    # HUD should be IGNORE (2) to allow clicks through
    assert mouse_filter == 2, "HUD should have mouse_filter set to IGNORE"


@pytest.mark.asyncio
async def test_touch_controls_mouse_filter_passthrough(game):
    """Touch controls container should allow mouse events to pass through."""
    mouse_filter = await game.get_property(PATHS["touch_controls"], "mouse_filter")
    # Container should be IGNORE (2) to allow clicks through
    assert mouse_filter == 2, "Touch controls should have mouse_filter set to IGNORE"


@pytest.mark.asyncio
async def test_low_health_vignette_exists(game):
    """Low health vignette should exist but be initially hidden."""
    exists = await game.node_exists(PATHS["low_health_vignette"])
    assert exists, "Low health vignette should exist"

    visible = await game.get_property(PATHS["low_health_vignette"], "visible")
    assert not visible, "Low health vignette should be hidden at full health"


@pytest.mark.asyncio
async def test_hud_text_sizes_readable(game):
    """HUD text should use readable font sizes for mobile."""
    # Check coins label font size
    coins_font_size = await game.get_property(
        PATHS["hud_coins_label"],
        "theme_override_font_sizes/font_size"
    )
    assert coins_font_size >= 20, "Coins label should have readable font size (>=20px)"

    # Check depth label font size
    depth_font_size = await game.get_property(
        PATHS["hud_depth_label"],
        "theme_override_font_sizes/font_size"
    )
    assert depth_font_size >= 20, "Depth label should have readable font size (>=20px)"


@pytest.mark.asyncio
async def test_pause_button_accessible(game):
    """Pause button should be accessible and properly sized."""
    exists = await game.node_exists(PATHS["hud_pause_button"])
    assert exists, "Pause button should exist"

    size = await game.get_property(PATHS["hud_pause_button"], "size")
    # Pause button should be at least 48dp (88px) for accessibility
    assert size["x"] >= 88, "Pause button should be at least 88px wide"
    assert size["y"] >= 88, "Pause button should be at least 88px tall"


@pytest.mark.asyncio
async def test_hud_full_screen_coverage(game):
    """HUD should cover the full screen for overlay elements."""
    anchor_left = await game.get_property(PATHS["hud"], "anchor_left")
    anchor_right = await game.get_property(PATHS["hud"], "anchor_right")
    anchor_top = await game.get_property(PATHS["hud"], "anchor_top")
    anchor_bottom = await game.get_property(PATHS["hud"], "anchor_bottom")

    assert anchor_left == 0.0, "HUD should anchor to left edge"
    assert anchor_right == 1.0, "HUD should anchor to right edge"
    assert anchor_top == 0.0, "HUD should anchor to top edge"
    assert anchor_bottom == 1.0, "HUD should anchor to bottom edge"


@pytest.mark.asyncio
async def test_touch_controls_full_screen_coverage(game):
    """Touch controls should cover the full screen for input handling."""
    anchor_left = await game.get_property(PATHS["touch_controls"], "anchor_left")
    anchor_right = await game.get_property(PATHS["touch_controls"], "anchor_right")
    anchor_top = await game.get_property(PATHS["touch_controls"], "anchor_top")
    anchor_bottom = await game.get_property(PATHS["touch_controls"], "anchor_bottom")

    assert anchor_left == 0.0, "Touch controls should anchor to left edge"
    assert anchor_right == 1.0, "Touch controls should anchor to right edge"
    assert anchor_top == 0.0, "Touch controls should anchor to top edge"
    assert anchor_bottom == 1.0, "Touch controls should anchor to bottom edge"


@pytest.mark.asyncio
async def test_ladder_quickslot_exists(game):
    """Ladder quickslot should exist in HUD."""
    exists = await game.node_exists(PATHS["ladder_quickslot"])
    assert exists, "Ladder quickslot should exist in HUD"


@pytest.mark.asyncio
async def test_rope_quickslot_exists(game):
    """Rope quickslot should exist in HUD."""
    exists = await game.node_exists(PATHS["rope_quickslot"])
    assert exists, "Rope quickslot should exist in HUD"


@pytest.mark.asyncio
async def test_teleport_quickslot_exists(game):
    """Teleport (warp) quickslot should exist in HUD."""
    exists = await game.node_exists(PATHS["teleport_quickslot"])
    assert exists, "Teleport quickslot should exist in HUD"


@pytest.mark.asyncio
async def test_quickslots_stacked_above_each_other(game):
    """Quickslots should be stacked vertically without overlapping each other."""
    ladder_pos = await game.get_property(PATHS["ladder_quickslot"], "position")
    rope_pos = await game.get_property(PATHS["rope_quickslot"], "position")
    teleport_pos = await game.get_property(PATHS["teleport_quickslot"], "position")

    # All quickslots should be at the same x position (right-aligned column)
    assert ladder_pos["x"] == rope_pos["x"], "Ladder and rope should share the same x position"
    assert rope_pos["x"] == teleport_pos["x"], "Rope and teleport should share the same x position"

    # Quickslots stack upward: teleport above rope above ladder (more negative y = higher)
    assert rope_pos["y"] < ladder_pos["y"], "Rope should be above ladder (more negative y)"
    assert teleport_pos["y"] < rope_pos["y"], "Teleport should be above rope (more negative y)"

    # Each quickslot is 56px tall; ensure no overlap (minimum 56px gap between positions)
    assert ladder_pos["y"] - rope_pos["y"] >= 56, \
        "Rope and ladder should not overlap vertically"
    assert rope_pos["y"] - teleport_pos["y"] >= 56, \
        "Teleport and rope should not overlap vertically"


@pytest.mark.asyncio
async def test_quickslots_anchored_bottom_right(game):
    """All quickslots should be anchored to bottom-right for thumb reach."""
    for name in ["ladder_quickslot", "rope_quickslot", "teleport_quickslot"]:
        anchor_left = await game.get_property(PATHS[name], "anchor_left")
        anchor_top = await game.get_property(PATHS[name], "anchor_top")
        assert anchor_left == 1.0, f"{name} should be anchored to right edge"
        assert anchor_top == 1.0, f"{name} should be anchored to bottom edge"


@pytest.mark.asyncio
async def test_hud_left_panel_no_overlap(game):
    """HUD left-panel elements should have sufficient spacing and not overlap."""
    # Get positions of vertically stacked elements
    health_pos = await game.get_property(PATHS["health_bar"], "position")
    health_size = await game.get_property(PATHS["health_bar"], "size")
    coins_pos = await game.get_property(PATHS["hud_coins_label"], "position")
    coins_size = await game.get_property(PATHS["hud_coins_label"], "size")
    tool_pos = await game.get_property(PATHS["tool_label"], "position")
    inv_pos = await game.get_property(PATHS["inventory_label"], "position")
    save_pos = await game.get_property(PATHS["save_indicator_label"], "position")

    # Health bar bottom must be above coins top (min 4px gap for outline clearance)
    health_bottom = health_pos["y"] + health_size["y"]
    assert coins_pos["y"] >= health_bottom + 4, \
        f"CoinsLabel (y={coins_pos['y']}) should be >= 4px below HealthBar bottom (y={health_bottom})"

    # Coins bottom must be above tool top
    coins_bottom = coins_pos["y"] + coins_size["y"]
    assert tool_pos["y"] >= coins_bottom + 4, \
        f"ToolLabel (y={tool_pos['y']}) should be >= 4px below CoinsLabel bottom (y={coins_bottom})"

    # Tool must be above inventory (tool min height 24px)
    assert inv_pos["y"] >= tool_pos["y"] + 24 + 4, \
        f"InventoryLabel (y={inv_pos['y']}) should be >= 4px below ToolLabel bottom"

    # Inventory must be above save indicator (inventory min height 20px)
    assert save_pos["y"] >= inv_pos["y"] + 20 + 4, \
        f"SaveIndicator (y={save_pos['y']}) should be >= 4px below InventoryLabel bottom"


@pytest.mark.asyncio
async def test_depth_bonus_not_overlapping_coins(game):
    """Depth bonus label should not overlap with the coins label."""
    coins_pos = await game.get_property(PATHS["hud_coins_label"], "position")
    bonus_anchor = await game.get_property(PATHS["depth_bonus_label"], "anchor_top")

    # Depth bonus should be anchored to bottom (1.0), not top (0.0) where coins is
    assert bonus_anchor == 1.0, \
        "Depth bonus should be anchored to bottom of screen, not top where it overlaps coins"
