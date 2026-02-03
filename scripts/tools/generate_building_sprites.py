#!/usr/bin/env python3
"""
Generate building sprites for GoDig surface shops.

Uses procedural pixel art generation for consistent building sprites.
Each building type has a distinct visual style and color palette.

Run: python3 scripts/tools/generate_building_sprites.py
Output: resources/sprites/buildings/
"""

import os
import random
import math
from PIL import Image, ImageDraw
from typing import Tuple, List, Dict, Optional
from dataclasses import dataclass


# Building sprite size (256x192 as per shop_building.tscn)
BUILDING_WIDTH = 256
BUILDING_HEIGHT = 192


@dataclass
class BuildingPalette:
    """Color palette for a building type."""
    name: str
    wall_base: Tuple[int, int, int]       # Main wall color
    wall_light: Tuple[int, int, int]      # Wall highlight
    wall_dark: Tuple[int, int, int]       # Wall shadow
    roof_base: Tuple[int, int, int]       # Main roof color
    roof_dark: Tuple[int, int, int]       # Roof shadow
    trim: Tuple[int, int, int]            # Trim/accent color
    door: Tuple[int, int, int]            # Door color
    window: Tuple[int, int, int]          # Window color
    icon_color: Tuple[int, int, int]      # Icon/sign color


# Palettes for each building type
BUILDING_PALETTES = {
    "general_store": BuildingPalette(
        name="General Store",
        wall_base=(180, 150, 120),    # Warm tan wood
        wall_light=(210, 180, 150),
        wall_dark=(140, 110, 80),
        roof_base=(139, 69, 19),      # Saddle brown
        roof_dark=(99, 49, 9),
        trim=(220, 200, 160),         # Light tan trim
        door=(100, 60, 30),           # Dark wood door
        window=(180, 220, 255),       # Light blue glass
        icon_color=(255, 215, 0),     # Gold coin
    ),
    "supply_store": BuildingPalette(
        name="Supply Store",
        wall_base=(160, 140, 130),    # Gray-brown
        wall_light=(190, 170, 160),
        wall_dark=(120, 100, 90),
        roof_base=(80, 80, 90),       # Dark slate
        roof_dark=(50, 50, 60),
        trim=(140, 120, 100),
        door=(80, 60, 50),
        window=(170, 210, 240),
        icon_color=(200, 150, 100),   # Wooden crate brown
    ),
    "blacksmith": BuildingPalette(
        name="Blacksmith",
        wall_base=(100, 90, 85),      # Dark stone
        wall_light=(140, 130, 125),
        wall_dark=(60, 50, 45),
        roof_base=(50, 50, 55),       # Charcoal
        roof_dark=(30, 30, 35),
        trim=(150, 100, 50),          # Bronze/copper
        door=(70, 50, 40),
        window=(255, 150, 50),        # Forge glow
        icon_color=(255, 100, 0),     # Fire orange
    ),
    "equipment_shop": BuildingPalette(
        name="Equipment Shop",
        wall_base=(130, 110, 140),    # Dusty purple
        wall_light=(160, 140, 170),
        wall_dark=(90, 70, 100),
        roof_base=(100, 70, 120),     # Darker purple
        roof_dark=(60, 40, 80),
        trim=(200, 180, 150),         # Leather tan
        door=(80, 50, 60),
        window=(200, 220, 240),
        icon_color=(180, 150, 100),   # Leather brown
    ),
    "gem_appraiser": BuildingPalette(
        name="Gem Appraiser",
        wall_base=(200, 200, 210),    # Light gray
        wall_light=(230, 230, 240),
        wall_dark=(160, 160, 170),
        roof_base=(80, 60, 100),      # Deep purple
        roof_dark=(50, 30, 70),
        trim=(220, 200, 100),         # Gold
        door=(60, 40, 60),
        window=(220, 180, 255),       # Amethyst glow
        icon_color=(135, 206, 235),   # Diamond blue
    ),
    "warehouse": BuildingPalette(
        name="Warehouse",
        wall_base=(140, 130, 120),    # Weathered wood
        wall_light=(170, 160, 150),
        wall_dark=(100, 90, 80),
        roof_base=(120, 100, 80),     # Brown metal
        roof_dark=(80, 60, 40),
        trim=(100, 80, 60),
        door=(90, 70, 50),
        window=(150, 170, 180),
        icon_color=(150, 130, 100),   # Crate brown
    ),
    "gadget_shop": BuildingPalette(
        name="Gadget Shop",
        wall_base=(70, 90, 110),      # Blue-gray
        wall_light=(100, 120, 140),
        wall_dark=(40, 60, 80),
        roof_base=(50, 60, 80),       # Dark blue
        roof_dark=(30, 40, 60),
        trim=(180, 200, 220),         # Light metal
        door=(40, 50, 60),
        window=(100, 255, 200),       # Tech green glow
        icon_color=(100, 255, 150),   # Green tech
    ),
    "elevator": BuildingPalette(
        name="Elevator",
        wall_base=(100, 100, 110),    # Industrial gray
        wall_light=(140, 140, 150),
        wall_dark=(60, 60, 70),
        roof_base=(80, 80, 90),       # Metal
        roof_dark=(50, 50, 60),
        trim=(200, 180, 100),         # Brass
        door=(70, 70, 80),
        window=(200, 200, 100),       # Yellow indicator
        icon_color=(255, 220, 100),   # Brass yellow
    ),
    "rest_station": BuildingPalette(
        name="Rest Station",
        wall_base=(150, 130, 120),    # Warm brown
        wall_light=(180, 160, 150),
        wall_dark=(110, 90, 80),
        roof_base=(160, 80, 60),      # Terracotta
        roof_dark=(120, 50, 30),
        trim=(200, 180, 140),
        door=(100, 70, 50),
        window=(255, 240, 200),       # Warm light
        icon_color=(255, 200, 100),   # Warm glow
    ),
    "research_lab": BuildingPalette(
        name="Research Lab",
        wall_base=(180, 180, 190),    # Light gray
        wall_light=(210, 210, 220),
        wall_dark=(140, 140, 150),
        roof_base=(60, 70, 90),       # Dark blue
        roof_dark=(30, 40, 60),
        trim=(200, 220, 255),         # Light blue
        door=(50, 60, 70),
        window=(100, 200, 255),       # Blue glow
        icon_color=(50, 200, 255),    # Bright blue
    ),
}


def draw_wood_texture(
    draw: ImageDraw.Draw,
    x: int, y: int,
    width: int, height: int,
    base: Tuple[int, int, int],
    light: Tuple[int, int, int],
    dark: Tuple[int, int, int],
    seed: int,
    horizontal: bool = True
):
    """Draw wood plank texture."""
    random.seed(seed)

    # Draw base
    draw.rectangle([x, y, x + width, y + height], fill=base + (255,))

    # Add planks
    if horizontal:
        plank_height = 16
        for py in range(y, y + height, plank_height):
            # Plank line
            draw.line([(x, py), (x + width, py)], fill=dark + (255,), width=2)
            # Random vertical grain lines
            for _ in range(random.randint(3, 8)):
                gx = random.randint(x, x + width)
                glen = random.randint(8, 20)
                gy_start = py + 2
                draw.line(
                    [(gx, gy_start), (gx, min(gy_start + glen, py + plank_height - 2))],
                    fill=dark + (200,),
                    width=1
                )
    else:
        plank_width = 20
        for px in range(x, x + width, plank_width):
            draw.line([(px, y), (px, y + height)], fill=dark + (255,), width=2)
            # Horizontal grain
            for _ in range(random.randint(2, 5)):
                gy = random.randint(y, y + height)
                glen = random.randint(6, 15)
                draw.line(
                    [(px + 2, gy), (min(px + glen, px + plank_width - 2), gy)],
                    fill=dark + (200,),
                    width=1
                )


def draw_stone_texture(
    draw: ImageDraw.Draw,
    x: int, y: int,
    width: int, height: int,
    base: Tuple[int, int, int],
    light: Tuple[int, int, int],
    dark: Tuple[int, int, int],
    seed: int
):
    """Draw stone brick texture."""
    random.seed(seed)

    # Draw base
    draw.rectangle([x, y, x + width, y + height], fill=base + (255,))

    # Draw brick pattern
    brick_h = 20
    brick_w = 40
    offset = False

    for by in range(y, y + height, brick_h):
        bx_start = x - (brick_w // 2 if offset else 0)
        for bx in range(bx_start, x + width, brick_w):
            # Brick outline
            draw.rectangle(
                [max(x, bx), by, min(x + width, bx + brick_w - 2), min(by + brick_h - 2, y + height)],
                outline=dark + (255,),
                width=2
            )
            # Random highlight
            if random.random() > 0.7:
                hx = max(x, bx + 3)
                hy = by + 3
                draw.ellipse([hx, hy, hx + 8, hy + 8], fill=light + (100,))
        offset = not offset


def draw_roof(
    draw: ImageDraw.Draw,
    x: int, y: int,
    width: int, height: int,
    palette: BuildingPalette,
    roof_style: str = "peaked",
    seed: int = 0
):
    """Draw building roof."""
    random.seed(seed)

    if roof_style == "peaked":
        # Triangular peaked roof
        peak_x = x + width // 2
        peak_y = y - height // 2

        # Left slope
        draw.polygon([
            (x - 16, y),
            (peak_x, peak_y),
            (peak_x, y)
        ], fill=palette.roof_base + (255,))

        # Right slope (darker)
        draw.polygon([
            (peak_x, peak_y),
            (x + width + 16, y),
            (peak_x, y)
        ], fill=palette.roof_dark + (255,))

        # Roof shingles/lines
        for i in range(0, height // 2, 8):
            # Left side shingles
            y_pos = y - i - 4
            draw.line(
                [(x - 16 + i * 0.6, y - i), (peak_x - i * 0.3, y - i)],
                fill=palette.roof_dark + (180,),
                width=1
            )

    elif roof_style == "flat":
        # Flat industrial roof
        draw.rectangle(
            [x - 8, y - height // 3, x + width + 8, y],
            fill=palette.roof_base + (255,)
        )
        draw.rectangle(
            [x - 8, y - height // 3, x + width + 8, y - height // 3 + 8],
            fill=palette.roof_dark + (255,)
        )

    elif roof_style == "dome":
        # Dome roof for special buildings
        draw.ellipse(
            [x, y - height * 2 // 3, x + width, y + height // 3],
            fill=palette.roof_base + (255,)
        )
        draw.ellipse(
            [x + width // 4, y - height // 2, x + width * 3 // 4, y],
            fill=palette.roof_dark + (180,)
        )


def draw_window(
    draw: ImageDraw.Draw,
    x: int, y: int,
    width: int, height: int,
    palette: BuildingPalette,
    glowing: bool = False
):
    """Draw a window."""
    # Frame
    draw.rectangle(
        [x - 2, y - 2, x + width + 2, y + height + 2],
        fill=palette.trim + (255,)
    )

    # Glass
    if glowing:
        # Inner glow
        draw.rectangle(
            [x, y, x + width, y + height],
            fill=palette.window + (255,)
        )
        # Brighter center
        draw.rectangle(
            [x + 4, y + 4, x + width - 4, y + height - 4],
            fill=tuple(min(255, c + 40) for c in palette.window) + (255,)
        )
    else:
        draw.rectangle(
            [x, y, x + width, y + height],
            fill=palette.window + (255,)
        )

    # Window panes
    mid_x = x + width // 2
    mid_y = y + height // 2
    draw.line([(x, mid_y), (x + width, mid_y)], fill=palette.trim + (255,), width=2)
    draw.line([(mid_x, y), (mid_x, y + height)], fill=palette.trim + (255,), width=2)


def draw_door(
    draw: ImageDraw.Draw,
    x: int, y: int,
    width: int, height: int,
    palette: BuildingPalette,
    has_window: bool = True
):
    """Draw a door."""
    # Door frame
    draw.rectangle(
        [x - 4, y - 4, x + width + 4, y + height],
        fill=palette.trim + (255,)
    )

    # Door panel
    draw.rectangle(
        [x, y, x + width, y + height],
        fill=palette.door + (255,)
    )

    # Door detail lines
    draw.rectangle(
        [x + 4, y + 4, x + width - 4, y + height - 4],
        outline=tuple(max(0, c - 30) for c in palette.door) + (255,),
        width=2
    )

    # Door handle
    handle_x = x + width - 12
    handle_y = y + height // 2
    draw.ellipse(
        [handle_x, handle_y - 4, handle_x + 8, handle_y + 4],
        fill=palette.trim + (255,)
    )

    # Optional door window
    if has_window:
        win_x = x + width // 4
        win_y = y + 10
        win_w = width // 2
        win_h = height // 4
        draw.rectangle(
            [win_x, win_y, win_x + win_w, win_y + win_h],
            fill=palette.window + (200,)
        )


def draw_icon(
    draw: ImageDraw.Draw,
    x: int, y: int,
    building_type: str,
    palette: BuildingPalette,
    size: int = 32
):
    """Draw building-specific icon/sign."""
    color = palette.icon_color

    if building_type == "general_store":
        # Coin icon
        draw.ellipse([x, y, x + size, y + size], fill=color + (255,))
        draw.ellipse(
            [x + 4, y + 4, x + size - 4, y + size - 4],
            fill=tuple(max(0, c - 40) for c in color) + (255,)
        )
        # Dollar sign
        mid_x = x + size // 2
        draw.line([(mid_x, y + 6), (mid_x, y + size - 6)], fill=color + (255,), width=2)

    elif building_type == "supply_store":
        # Crate icon
        draw.rectangle([x, y, x + size, y + size], fill=color + (255,))
        # Cross lines
        draw.line([(x, y + size // 2), (x + size, y + size // 2)],
                  fill=tuple(max(0, c - 40) for c in color) + (255,), width=3)
        draw.line([(x + size // 2, y), (x + size // 2, y + size)],
                  fill=tuple(max(0, c - 40) for c in color) + (255,), width=3)

    elif building_type == "blacksmith":
        # Anvil/hammer icon
        # Anvil base
        draw.polygon([
            (x + 4, y + size - 4),
            (x + size - 4, y + size - 4),
            (x + size - 8, y + size // 2),
            (x + 8, y + size // 2)
        ], fill=(100, 100, 110, 255))
        # Hammer
        draw.rectangle([x + size // 2 - 4, y + 2, x + size // 2 + 4, y + size // 2],
                       fill=color + (255,))

    elif building_type == "equipment_shop":
        # Helmet icon
        draw.ellipse([x + 4, y + 4, x + size - 4, y + size - 8], fill=color + (255,))
        draw.rectangle([x + 4, y + size // 2, x + size - 4, y + size - 4],
                       fill=color + (255,))
        # Visor
        draw.rectangle([x + 8, y + size // 2 - 4, x + size - 8, y + size // 2 + 4],
                       fill=tuple(max(0, c - 40) for c in color) + (255,))

    elif building_type == "gem_appraiser":
        # Diamond icon
        points = [
            (x + size // 2, y),
            (x + size, y + size // 3),
            (x + size * 3 // 4, y + size),
            (x + size // 4, y + size),
            (x, y + size // 3)
        ]
        draw.polygon(points, fill=color + (255,))
        # Facet lines
        draw.polygon([
            (x + size // 2, y),
            (x + size * 3 // 4, y + size // 3),
            (x + size // 2, y + size // 2),
            (x + size // 4, y + size // 3)
        ], fill=tuple(min(255, c + 30) for c in color) + (255,))

    elif building_type == "warehouse":
        # Stack of crates
        for i in range(3):
            bx = x + (i % 2) * (size // 3)
            by = y + size - (i + 1) * (size // 3)
            bsize = size // 3
            draw.rectangle([bx, by, bx + bsize - 2, by + bsize - 2], fill=color + (255,))

    elif building_type == "gadget_shop":
        # Gear icon
        center_x = x + size // 2
        center_y = y + size // 2
        # Outer gear
        for i in range(8):
            angle = i * 45
            rad = math.radians(angle)
            tooth_x = center_x + int((size // 2 - 4) * math.cos(rad))
            tooth_y = center_y + int((size // 2 - 4) * math.sin(rad))
            draw.ellipse([tooth_x - 4, tooth_y - 4, tooth_x + 4, tooth_y + 4],
                         fill=color + (255,))
        # Center circle
        draw.ellipse([center_x - 8, center_y - 8, center_x + 8, center_y + 8],
                     fill=color + (255,))
        draw.ellipse([center_x - 4, center_y - 4, center_x + 4, center_y + 4],
                     fill=tuple(max(0, c - 60) for c in color) + (255,))

    elif building_type == "elevator":
        # Elevator arrows
        mid = size // 2
        # Up arrow
        draw.polygon([
            (x + mid, y + 4),
            (x + mid + 8, y + 12),
            (x + mid - 8, y + 12)
        ], fill=color + (255,))
        # Down arrow
        draw.polygon([
            (x + mid, y + size - 4),
            (x + mid + 8, y + size - 12),
            (x + mid - 8, y + size - 12)
        ], fill=color + (255,))

    elif building_type == "rest_station":
        # Bed/rest icon
        draw.rectangle([x + 2, y + size * 2 // 3, x + size - 2, y + size - 4],
                       fill=color + (255,))
        # Pillow
        draw.ellipse([x + 4, y + size * 2 // 3 - 8, x + size // 3, y + size * 2 // 3 + 4],
                     fill=tuple(min(255, c + 30) for c in color) + (255,))

    elif building_type == "research_lab":
        # Flask/beaker icon
        # Flask body
        draw.polygon([
            (x + size // 3, y + size // 3),
            (x + size * 2 // 3, y + size // 3),
            (x + size - 4, y + size - 4),
            (x + 4, y + size - 4)
        ], fill=color + (200,))
        # Flask neck
        draw.rectangle([x + size // 3 + 2, y + 4, x + size * 2 // 3 - 2, y + size // 3],
                       fill=color + (200,))
        # Liquid
        draw.polygon([
            (x + size // 3 + 8, y + size * 2 // 3),
            (x + size * 2 // 3 - 8, y + size * 2 // 3),
            (x + size - 8, y + size - 8),
            (x + 8, y + size - 8)
        ], fill=tuple(max(0, c - 60) for c in color) + (255,))


def create_building_sprite(
    building_type: str,
    seed: int = 42
) -> Image.Image:
    """Create a building sprite for the specified type."""

    if building_type not in BUILDING_PALETTES:
        raise ValueError(f"Unknown building type: {building_type}")

    palette = BUILDING_PALETTES[building_type]

    img = Image.new("RGBA", (BUILDING_WIDTH, BUILDING_HEIGHT), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    random.seed(seed)

    # Building dimensions
    wall_y = 40
    wall_h = BUILDING_HEIGHT - wall_y

    # Choose texture style based on building type
    if building_type in ["blacksmith", "gem_appraiser", "research_lab"]:
        # Stone texture
        draw_stone_texture(
            draw, 0, wall_y, BUILDING_WIDTH, wall_h,
            palette.wall_base, palette.wall_light, palette.wall_dark,
            seed
        )
    else:
        # Wood texture
        draw_wood_texture(
            draw, 0, wall_y, BUILDING_WIDTH, wall_h,
            palette.wall_base, palette.wall_light, palette.wall_dark,
            seed,
            horizontal=True
        )

    # Choose roof style
    if building_type in ["warehouse", "elevator"]:
        roof_style = "flat"
    elif building_type in ["gem_appraiser", "research_lab"]:
        roof_style = "dome"
    else:
        roof_style = "peaked"

    draw_roof(draw, 0, wall_y, BUILDING_WIDTH, 80, palette, roof_style, seed)

    # Door
    door_w = 56
    door_h = 88
    door_x = (BUILDING_WIDTH - door_w) // 2
    door_y = BUILDING_HEIGHT - door_h
    draw_door(draw, door_x, door_y, door_w, door_h, palette)

    # Windows
    window_w = 36
    window_h = 44

    # Left window
    draw_window(
        draw, 30, wall_y + 30, window_w, window_h, palette,
        glowing=(building_type in ["blacksmith", "gadget_shop", "research_lab"])
    )

    # Right window
    draw_window(
        draw, BUILDING_WIDTH - 30 - window_w, wall_y + 30, window_w, window_h, palette,
        glowing=(building_type in ["blacksmith", "gadget_shop", "research_lab"])
    )

    # Sign with icon
    sign_x = BUILDING_WIDTH // 2 - 24
    sign_y = wall_y - 20 if roof_style == "peaked" else wall_y + 8

    # Sign background
    draw.rectangle(
        [sign_x - 8, sign_y - 8, sign_x + 56, sign_y + 48],
        fill=palette.trim + (255,)
    )
    draw.rectangle(
        [sign_x - 4, sign_y - 4, sign_x + 52, sign_y + 44],
        fill=(250, 240, 220, 255)
    )

    # Building icon
    draw_icon(draw, sign_x + 8, sign_y + 4, building_type, palette, 32)

    return img


def generate_all_buildings(seed: int = 42, output_dir: Optional[str] = None) -> Dict[str, str]:
    """Generate sprites for all building types."""

    if output_dir is None:
        script_dir = os.path.dirname(__file__)
        project_root = os.path.dirname(os.path.dirname(script_dir))
        output_dir = os.path.join(project_root, "resources", "sprites", "buildings")

    os.makedirs(output_dir, exist_ok=True)

    output_files = {}

    print(f"Generating building sprites to: {output_dir}")

    for building_type, palette in BUILDING_PALETTES.items():
        sprite = create_building_sprite(building_type, seed + hash(building_type) % 1000)

        output_path = os.path.join(output_dir, f"{building_type}.png")
        sprite.save(output_path)
        output_files[building_type] = output_path

        print(f"  Generated: {palette.name} -> {output_path}")

    # Also generate an atlas image for preview
    atlas_cols = 5
    atlas_rows = 2
    atlas_w = atlas_cols * BUILDING_WIDTH
    atlas_h = atlas_rows * BUILDING_HEIGHT
    atlas = Image.new("RGBA", (atlas_w, atlas_h), (100, 150, 200, 255))  # Sky blue background

    building_types = list(BUILDING_PALETTES.keys())
    for i, building_type in enumerate(building_types):
        col = i % atlas_cols
        row = i // atlas_cols

        sprite = create_building_sprite(building_type, seed + hash(building_type) % 1000)
        atlas.paste(sprite, (col * BUILDING_WIDTH, row * BUILDING_HEIGHT), sprite)

    atlas_path = os.path.join(output_dir, "buildings_atlas.png")
    atlas.save(atlas_path)
    print(f"\nGenerated atlas preview: {atlas_path}")

    return output_files


def generate_single_building(
    building_type: str,
    seed: int = 42,
    output_path: Optional[str] = None
) -> str:
    """Generate a single building sprite."""

    sprite = create_building_sprite(building_type, seed)

    if output_path is None:
        output_path = f"{building_type}_building.png"

    sprite.save(output_path)
    print(f"Saved {building_type} building to: {output_path}")

    return output_path


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Generate building sprites for GoDig")
    parser.add_argument("--seed", type=int, default=42, help="Random seed for generation")
    parser.add_argument("--output", type=str, help="Output directory for sprites")
    parser.add_argument("--single", type=str, help="Generate a single building (type name)")
    parser.add_argument("--list-types", action="store_true", help="List available building types")

    args = parser.parse_args()

    if args.list_types:
        print("Available building types:")
        for name, palette in BUILDING_PALETTES.items():
            print(f"  - {name}: {palette.name}")
    elif args.single:
        generate_single_building(args.single, args.seed, args.output)
    else:
        generate_all_buildings(args.seed, args.output)
