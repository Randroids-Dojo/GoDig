#!/usr/bin/env python3
"""
Generate improved dirt textures for GoDig terrain tiles.

Uses proper pixel art techniques:
- Multi-shade palettes (3-4 tones per material)
- Layered noise for natural variation
- Dithering patterns for retro aesthetic
- Optional detail elements (rocks, roots, ore specks)

Run: python3 scripts/tools/generate_dirt_textures.py
Output: resources/tileset/terrain_atlas.png
"""

import os
import random
import math
from PIL import Image, ImageDraw
from typing import Tuple, List, Dict, Optional
from dataclasses import dataclass


# Tile configuration
TILE_SIZE = 128
COLS = 6
ROWS = 3


@dataclass
class MaterialPalette:
    """Color palette for a material with multiple shades."""
    name: str
    base: Tuple[int, int, int]       # Main color
    light: Tuple[int, int, int]      # Highlight
    dark: Tuple[int, int, int]       # Shadow
    accent: Optional[Tuple[int, int, int]] = None  # Optional detail color

    def get_colors(self) -> List[Tuple[int, int, int]]:
        """Return all colors in the palette."""
        colors = [self.dark, self.base, self.light]
        if self.accent:
            colors.append(self.accent)
        return colors


# Define palettes for each terrain type (3-4 tone shading as recommended)
PALETTES = {
    # Row 0: Base terrain - earthy tones with natural variation
    "dirt": MaterialPalette(
        name="Dirt",
        base=(139, 90, 43),
        light=(169, 120, 73),
        dark=(99, 60, 23),
        accent=(79, 50, 18)  # Dark roots/organic matter
    ),
    "clay": MaterialPalette(
        name="Clay",
        base=(178, 119, 84),
        light=(208, 149, 114),
        dark=(138, 89, 54),
        accent=(158, 99, 64)
    ),
    "stone": MaterialPalette(
        name="Stone",
        base=(128, 128, 128),
        light=(168, 168, 168),
        dark=(88, 88, 88),
        accent=(108, 108, 108)
    ),
    "granite": MaterialPalette(
        name="Granite",
        base=(96, 96, 96),
        light=(136, 136, 136),
        dark=(56, 56, 56),
        accent=(76, 76, 86)  # Slight blue tint
    ),
    "basalt": MaterialPalette(
        name="Basalt",
        base=(64, 64, 64),
        light=(94, 94, 94),
        dark=(34, 34, 34),
        accent=(54, 54, 64)
    ),
    "obsidian": MaterialPalette(
        name="Obsidian",
        base=(25, 20, 45),
        light=(55, 45, 75),
        dark=(15, 10, 25),
        accent=(45, 35, 85)  # Purple sheen
    ),

    # Row 1: Ores - distinct colored deposits
    "coal": MaterialPalette(
        name="Coal",
        base=(33, 33, 33),
        light=(63, 63, 63),
        dark=(13, 13, 13),
        accent=(43, 43, 53)  # Slight shine
    ),
    "copper": MaterialPalette(
        name="Copper",
        base=(184, 115, 51),
        light=(214, 155, 91),
        dark=(134, 75, 21),
        accent=(234, 175, 111)  # Bright ore vein
    ),
    "iron": MaterialPalette(
        name="Iron",
        base=(152, 150, 147),
        light=(182, 180, 177),
        dark=(112, 110, 107),
        accent=(192, 170, 157)  # Rust tint
    ),
    "silver": MaterialPalette(
        name="Silver",
        base=(192, 192, 192),
        light=(232, 232, 232),
        dark=(142, 142, 142),
        accent=(255, 255, 255)  # Bright shine
    ),
    "gold": MaterialPalette(
        name="Gold",
        base=(255, 215, 0),
        light=(255, 245, 100),
        dark=(205, 165, 0),
        accent=(255, 255, 150)  # Bright vein
    ),
    "diamond": MaterialPalette(
        name="Diamond",
        base=(135, 206, 235),
        light=(185, 236, 255),
        dark=(85, 156, 185),
        accent=(225, 255, 255)  # Sparkle
    ),

    # Row 2: Special tiles + gems
    "ladder": MaterialPalette(
        name="Ladder",
        base=(139, 69, 19),
        light=(179, 109, 59),
        dark=(99, 49, 9),
        accent=(119, 59, 14)
    ),
    "ruby": MaterialPalette(
        name="Ruby",
        base=(224, 17, 95),
        light=(255, 67, 145),
        dark=(164, 0, 55),
        accent=(255, 120, 170)
    ),
    "emerald": MaterialPalette(
        name="Emerald",
        base=(80, 200, 120),
        light=(130, 250, 170),
        dark=(40, 140, 70),
        accent=(180, 255, 200)
    ),
    "sapphire": MaterialPalette(
        name="Sapphire",
        base=(15, 82, 186),
        light=(65, 132, 236),
        dark=(0, 42, 126),
        accent=(115, 182, 255)
    ),
    "amethyst": MaterialPalette(
        name="Amethyst",
        base=(153, 102, 204),
        light=(193, 152, 244),
        dark=(103, 52, 154),
        accent=(223, 182, 255)
    ),
}


def generate_noise_layer(
    width: int,
    height: int,
    scale: float = 8.0,
    seed: int = 0
) -> List[List[float]]:
    """Generate a simple value noise layer."""
    random.seed(seed)

    # Create grid of random values
    grid_w = int(width / scale) + 2
    grid_h = int(height / scale) + 2
    grid = [[random.random() for _ in range(grid_w)] for _ in range(grid_h)]

    # Interpolate to full resolution
    noise = []
    for y in range(height):
        row = []
        for x in range(width):
            # Get grid coordinates
            gx = x / scale
            gy = y / scale

            # Integer and fractional parts
            x0 = int(gx)
            y0 = int(gy)
            fx = gx - x0
            fy = gy - y0

            # Smooth interpolation
            fx = fx * fx * (3 - 2 * fx)
            fy = fy * fy * (3 - 2 * fy)

            # Bilinear interpolation
            v00 = grid[y0][x0]
            v10 = grid[y0][x0 + 1]
            v01 = grid[y0 + 1][x0]
            v11 = grid[y0 + 1][x0 + 1]

            v0 = v00 + (v10 - v00) * fx
            v1 = v01 + (v11 - v01) * fx
            value = v0 + (v1 - v0) * fy

            row.append(value)
        noise.append(row)

    return noise


def combine_noise_layers(
    width: int,
    height: int,
    octaves: int = 3,
    seed: int = 0
) -> List[List[float]]:
    """Combine multiple noise layers for natural-looking texture."""
    combined = [[0.0 for _ in range(width)] for _ in range(height)]

    amplitude = 1.0
    total_amplitude = 0.0
    scale = 16.0

    for i in range(octaves):
        layer = generate_noise_layer(width, height, scale, seed + i * 1000)

        for y in range(height):
            for x in range(width):
                combined[y][x] += layer[y][x] * amplitude

        total_amplitude += amplitude
        amplitude *= 0.5
        scale *= 0.5

    # Normalize
    for y in range(height):
        for x in range(width):
            combined[y][x] /= total_amplitude

    return combined


def apply_dithering(
    img: Image.Image,
    colors: List[Tuple[int, int, int]],
    pattern: str = "ordered"
) -> Image.Image:
    """Apply dithering pattern to image."""
    width, height = img.size
    pixels = img.load()

    # Bayer 4x4 matrix for ordered dithering
    bayer_4x4 = [
        [0, 8, 2, 10],
        [12, 4, 14, 6],
        [3, 11, 1, 9],
        [15, 7, 13, 5]
    ]

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]

            if a == 0:
                continue

            # Find closest color
            min_dist = float('inf')
            closest = colors[0]

            for color in colors:
                dist = (r - color[0])**2 + (g - color[1])**2 + (b - color[2])**2
                if dist < min_dist:
                    min_dist = dist
                    closest = color

            # Apply ordered dithering threshold
            if pattern == "ordered":
                threshold = (bayer_4x4[y % 4][x % 4] / 16.0 - 0.5) * 30

                # Adjust color based on threshold
                adjusted = tuple(
                    max(0, min(255, c + int(threshold)))
                    for c in closest
                )

                # Find new closest after adjustment
                min_dist = float('inf')
                for color in colors:
                    dist = sum((adjusted[i] - color[i])**2 for i in range(3))
                    if dist < min_dist:
                        min_dist = dist
                        closest = color

            pixels[x, y] = closest + (255,)

    return img


def draw_rock_detail(
    draw: ImageDraw.Draw,
    x: int,
    y: int,
    size: int,
    palette: MaterialPalette
):
    """Draw a small rock detail element."""
    # Draw darker base
    draw.ellipse(
        [x, y + 1, x + size, y + size + 1],
        fill=palette.dark + (255,)
    )
    # Draw main rock
    draw.ellipse(
        [x, y, x + size, y + size],
        fill=palette.base + (255,)
    )
    # Draw highlight
    if size > 3:
        draw.ellipse(
            [x + 1, y + 1, x + size // 2, y + size // 2],
            fill=palette.light + (255,)
        )


def draw_ore_vein(
    draw: ImageDraw.Draw,
    x: int,
    y: int,
    length: int,
    palette: MaterialPalette,
    seed: int
):
    """Draw an ore vein pattern."""
    random.seed(seed)

    points = [(x, y)]
    cx, cy = x, y

    for _ in range(length):
        # Random walk
        cx += random.randint(-2, 3)
        cy += random.randint(-1, 2)
        points.append((cx, cy))

    # Draw vein with varying thickness
    for i, (px, py) in enumerate(points):
        size = random.randint(2, 5)

        # Use accent color for bright spots
        if random.random() > 0.7 and palette.accent:
            color = palette.accent
        else:
            color = palette.light

        draw.ellipse(
            [px, py, px + size, py + size],
            fill=color + (255,)
        )


def create_dirt_tile(
    x_offset: int,
    y_offset: int,
    palette: MaterialPalette,
    tile_seed: int,
    is_ore: bool = False
) -> Image.Image:
    """Create a single dirt/terrain tile with proper pixel art aesthetics."""
    tile = Image.new("RGBA", (TILE_SIZE, TILE_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(tile)

    # Generate multi-layer noise
    noise = combine_noise_layers(TILE_SIZE, TILE_SIZE, octaves=3, seed=tile_seed)

    # Get palette colors
    colors = palette.get_colors()

    # First pass: Base color fill with noise-based shading
    for y in range(TILE_SIZE):
        for x in range(TILE_SIZE):
            value = noise[y][x]

            # Map noise to color index
            if value < 0.35:
                color = palette.dark
            elif value < 0.65:
                color = palette.base
            else:
                color = palette.light

            tile.putpixel((x, y), color + (255,))

    # Second pass: Apply dithering for pixel art look
    tile = apply_dithering(tile, colors, pattern="ordered")

    # Third pass: Add detail elements
    random.seed(tile_seed + 500)

    if is_ore:
        # Add ore veins for ore tiles
        num_veins = random.randint(2, 4)
        for i in range(num_veins):
            vx = random.randint(10, TILE_SIZE - 30)
            vy = random.randint(10, TILE_SIZE - 30)
            draw_ore_vein(draw, vx, vy, random.randint(8, 15), palette, tile_seed + i)
    else:
        # Add small rocks/details for terrain
        num_rocks = random.randint(4, 8)
        for _ in range(num_rocks):
            rx = random.randint(5, TILE_SIZE - 15)
            ry = random.randint(5, TILE_SIZE - 15)
            size = random.randint(3, 8)
            draw_rock_detail(draw, rx, ry, size, palette)

    # Fourth pass: Add subtle border shading for depth
    border_width = 4
    for y in range(TILE_SIZE):
        for x in range(TILE_SIZE):
            # Distance from edge
            dist_from_edge = min(x, y, TILE_SIZE - 1 - x, TILE_SIZE - 1 - y)

            if dist_from_edge < border_width:
                # Darken pixels near edge
                r, g, b, a = tile.getpixel((x, y))
                factor = 0.7 + (dist_from_edge / border_width) * 0.3
                r = int(r * factor)
                g = int(g * factor)
                b = int(b * factor)
                tile.putpixel((x, y), (r, g, b, a))

    return tile


def create_ladder_tile(palette: MaterialPalette, seed: int) -> Image.Image:
    """Create a ladder tile."""
    tile = Image.new("RGBA", (TILE_SIZE, TILE_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(tile)

    # Ladder parameters
    rung_width = 80
    rung_height = 8
    rung_spacing = 24
    side_width = 12

    x_start = (TILE_SIZE - rung_width) // 2

    # Draw side rails
    for side_x in [x_start, x_start + rung_width - side_width]:
        # Shadow
        draw.rectangle(
            [side_x + 2, 0, side_x + side_width + 2, TILE_SIZE],
            fill=palette.dark + (255,)
        )
        # Main rail
        draw.rectangle(
            [side_x, 0, side_x + side_width, TILE_SIZE],
            fill=palette.base + (255,)
        )
        # Highlight
        draw.rectangle(
            [side_x, 0, side_x + 3, TILE_SIZE],
            fill=palette.light + (255,)
        )

    # Draw rungs
    for rung_y in range(rung_spacing // 2, TILE_SIZE, rung_spacing):
        # Shadow
        draw.rectangle(
            [x_start + side_width, rung_y + 2,
             x_start + rung_width - side_width, rung_y + rung_height + 2],
            fill=palette.dark + (255,)
        )
        # Main rung
        draw.rectangle(
            [x_start + side_width, rung_y,
             x_start + rung_width - side_width, rung_y + rung_height],
            fill=palette.base + (255,)
        )
        # Highlight
        draw.rectangle(
            [x_start + side_width, rung_y,
             x_start + rung_width - side_width, rung_y + 2],
            fill=palette.light + (255,)
        )

    return tile


def create_gem_tile(palette: MaterialPalette, seed: int) -> Image.Image:
    """Create a gem tile with crystal formations."""
    # Start with stone background
    stone_palette = PALETTES["stone"]
    tile = create_dirt_tile(0, 0, stone_palette, seed, is_ore=False)
    draw = ImageDraw.Draw(tile)

    random.seed(seed)

    # Add gem crystals
    num_gems = random.randint(3, 6)

    for _ in range(num_gems):
        cx = random.randint(20, TILE_SIZE - 40)
        cy = random.randint(20, TILE_SIZE - 40)
        size = random.randint(12, 25)

        # Draw hexagonal gem shape
        points = []
        for i in range(6):
            angle = i * 60 + random.randint(-10, 10)
            rad = math.radians(angle)
            px = cx + int(size * math.cos(rad))
            py = cy + int(size * math.sin(rad))
            points.append((px, py))

        # Draw gem with shading
        draw.polygon(points, fill=palette.base + (255,))

        # Add facet highlights
        inner_points = [
            (cx - size//3, cy - size//4),
            (cx + size//4, cy - size//3),
            (cx, cy)
        ]
        draw.polygon(inner_points, fill=palette.light + (255,))

        # Add sparkle
        if palette.accent:
            draw.ellipse(
                [cx - 2, cy - size//2 - 2, cx + 2, cy - size//2 + 2],
                fill=palette.accent + (255,)
            )

    return tile


# Tile layout mapping
TILE_LAYOUT = {
    # Row 0: Base terrain
    (0, 0): ("dirt", False, "terrain"),
    (1, 0): ("clay", False, "terrain"),
    (2, 0): ("stone", False, "terrain"),
    (3, 0): ("granite", False, "terrain"),
    (4, 0): ("basalt", False, "terrain"),
    (5, 0): ("obsidian", False, "terrain"),

    # Row 1: Ores
    (0, 1): ("coal", True, "ore"),
    (1, 1): ("copper", True, "ore"),
    (2, 1): ("iron", True, "ore"),
    (3, 1): ("silver", True, "ore"),
    (4, 1): ("gold", True, "ore"),
    (5, 1): ("diamond", True, "ore"),

    # Row 2: Special + gems
    (0, 2): ("ladder", False, "special"),
    (1, 2): ("air", False, "special"),  # Transparent
    (2, 2): ("ruby", False, "gem"),
    (3, 2): ("emerald", False, "gem"),
    (4, 2): ("sapphire", False, "gem"),
    (5, 2): ("amethyst", False, "gem"),
}


def generate_terrain_atlas(seed: int = 42, output_path: Optional[str] = None) -> str:
    """Generate the complete terrain atlas with improved textures."""

    # Create atlas image
    width = COLS * TILE_SIZE
    height = ROWS * TILE_SIZE
    atlas = Image.new("RGBA", (width, height), (0, 0, 0, 0))

    print(f"Generating {COLS}x{ROWS} terrain atlas ({width}x{height} pixels)...")

    for (col, row), (material_name, is_ore, tile_type) in TILE_LAYOUT.items():
        x_offset = col * TILE_SIZE
        y_offset = row * TILE_SIZE
        tile_seed = seed + col * 100 + row * 1000

        if material_name == "air":
            # Leave transparent
            print(f"  [{col},{row}] Air - transparent")
            continue

        palette = PALETTES.get(material_name)
        if not palette:
            print(f"  [{col},{row}] {material_name} - MISSING PALETTE, skipping")
            continue

        # Generate tile based on type
        if tile_type == "special" and material_name == "ladder":
            tile = create_ladder_tile(palette, tile_seed)
        elif tile_type == "gem":
            tile = create_gem_tile(palette, tile_seed)
        else:
            tile = create_dirt_tile(x_offset, y_offset, palette, tile_seed, is_ore)

        # Paste tile into atlas
        atlas.paste(tile, (x_offset, y_offset))
        print(f"  [{col},{row}] {palette.name} - generated")

    # Determine output path
    if output_path is None:
        script_dir = os.path.dirname(__file__)
        project_root = os.path.dirname(os.path.dirname(script_dir))
        output_path = os.path.join(project_root, "resources", "tileset", "terrain_atlas.png")

    # Ensure directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    # Save atlas
    atlas.save(output_path)
    print(f"\nSaved terrain atlas to: {output_path}")
    print(f"Size: {width}x{height} ({COLS} columns x {ROWS} rows of {TILE_SIZE}x{TILE_SIZE} tiles)")

    return output_path


def generate_single_tile(
    material: str,
    seed: int = 42,
    output_path: Optional[str] = None
) -> str:
    """Generate a single tile for testing."""

    if material not in PALETTES:
        raise ValueError(f"Unknown material: {material}. Available: {list(PALETTES.keys())}")

    palette = PALETTES[material]

    # Determine if it's an ore
    is_ore = material in ["coal", "copper", "iron", "silver", "gold", "diamond"]
    is_gem = material in ["ruby", "emerald", "sapphire", "amethyst"]

    if material == "ladder":
        tile = create_ladder_tile(palette, seed)
    elif is_gem:
        tile = create_gem_tile(palette, seed)
    else:
        tile = create_dirt_tile(0, 0, palette, seed, is_ore)

    if output_path is None:
        output_path = f"{material}_tile.png"

    tile.save(output_path)
    print(f"Saved {material} tile to: {output_path}")

    return output_path


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Generate improved dirt textures for GoDig")
    parser.add_argument("--seed", type=int, default=42, help="Random seed for generation")
    parser.add_argument("--output", type=str, help="Output path for atlas")
    parser.add_argument("--single", type=str, help="Generate a single tile (material name)")
    parser.add_argument("--list-materials", action="store_true", help="List available materials")

    args = parser.parse_args()

    if args.list_materials:
        print("Available materials:")
        for name, palette in PALETTES.items():
            print(f"  - {name}: {palette.name}")
    elif args.single:
        generate_single_tile(args.single, args.seed, args.output)
    else:
        generate_terrain_atlas(args.seed, args.output)
