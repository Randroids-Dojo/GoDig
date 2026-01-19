#!/usr/bin/env python3
"""
Generate a placeholder terrain atlas for GoDig.
Creates a 768x384 PNG (6 columns x 3 rows of 128x128 tiles).

Run: python3 scripts/setup/generate_terrain_atlas.py
Output: resources/tileset/terrain_atlas.png
"""

from PIL import Image, ImageDraw
import os

# Tile size
TILE_SIZE = 128
COLS = 6
ROWS = 3

# Colors for each tile (matching TileTypes colors)
TILES = {
    # Row 0: Base terrain
    (0, 0): ("Dirt", (139, 90, 43)),        # Brown
    (1, 0): ("Clay", (178, 119, 84)),       # Orange-brown
    (2, 0): ("Stone", (128, 128, 128)),     # Gray
    (3, 0): ("Granite", (96, 96, 96)),      # Dark gray
    (4, 0): ("Basalt", (64, 64, 64)),       # Very dark
    (5, 0): ("Obsidian", (25, 20, 45)),     # Black with purple

    # Row 1: Ores
    (0, 1): ("Coal", (33, 33, 33)),         # Black
    (1, 1): ("Copper", (184, 115, 51)),     # Copper orange
    (2, 1): ("Iron", (152, 150, 147)),      # Iron gray
    (3, 1): ("Silver", (192, 192, 192)),    # Silver
    (4, 1): ("Gold", (255, 215, 0)),        # Gold yellow
    (5, 1): ("Diamond", (135, 206, 235)),   # Sky blue

    # Row 2: Special tiles + gems
    (0, 2): ("Ladder", (139, 69, 19)),      # Wood brown
    (1, 2): ("Air", (0, 0, 0, 0)),          # Transparent
    (2, 2): ("Ruby", (224, 17, 95)),        # Ruby red
    (3, 2): ("Emerald", (80, 200, 120)),    # Emerald green
    (4, 2): ("Sapphire", (15, 82, 186)),    # Sapphire blue
    (5, 2): ("Amethyst", (153, 102, 204)),  # Purple
}


def create_tile(draw, x, y, color, name):
    """Draw a single tile with color and optional texture."""
    x0 = x * TILE_SIZE
    y0 = y * TILE_SIZE
    x1 = x0 + TILE_SIZE
    y1 = y0 + TILE_SIZE

    # Handle transparent tiles
    if len(color) == 4 and color[3] == 0:
        return  # Leave transparent

    # Fill base color
    draw.rectangle([x0, y0, x1 - 1, y1 - 1], fill=color)

    # Add some texture/pattern to make tiles more distinguishable
    accent_color = tuple(max(0, min(255, c + 20)) for c in color[:3])
    dark_color = tuple(max(0, min(255, c - 30)) for c in color[:3])

    # Add simple noise pattern
    import random
    random.seed(x * 100 + y)  # Deterministic per tile

    for i in range(20):
        px = x0 + random.randint(10, TILE_SIZE - 10)
        py = y0 + random.randint(10, TILE_SIZE - 10)
        size = random.randint(2, 8)
        shade = random.choice([accent_color, dark_color])
        draw.ellipse([px, py, px + size, py + size], fill=shade)

    # Add border to make grid visible
    draw.rectangle([x0, y0, x1 - 1, y1 - 1], outline=dark_color, width=2)


def main():
    # Create image with alpha channel
    width = COLS * TILE_SIZE
    height = ROWS * TILE_SIZE
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Draw all tiles
    for (x, y), (name, color) in TILES.items():
        if len(color) == 3:
            color = color + (255,)  # Add alpha
        create_tile(draw, x, y, color, name)

    # Ensure output directory exists
    output_dir = os.path.dirname(__file__)
    project_root = os.path.dirname(os.path.dirname(output_dir))
    output_path = os.path.join(project_root, "resources", "tileset", "terrain_atlas.png")

    # Also try relative path from current working directory
    if not os.path.exists(os.path.dirname(output_path)):
        output_path = "resources/tileset/terrain_atlas.png"
        os.makedirs(os.path.dirname(output_path), exist_ok=True)

    img.save(output_path)
    print(f"Generated terrain atlas: {output_path}")
    print(f"Size: {width}x{height} ({COLS} columns x {ROWS} rows of {TILE_SIZE}x{TILE_SIZE} tiles)")


if __name__ == "__main__":
    main()
