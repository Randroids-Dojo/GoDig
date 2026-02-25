#!/usr/bin/env python3
"""Generate inventory item icons for GoDig.

Produces 64x64 PNG icons for non-ore items.
Output: resources/icons/items/<id>.png

Run: python3 scripts/tools/generate_item_icons.py
"""

import math
import os
from PIL import Image, ImageDraw

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "../../resources/icons/items")
SIZE = 64


def rarity_color(rarity: str) -> tuple:
    return {
        "common":    (160, 160, 160),
        "uncommon":  (80,  200, 80),
        "rare":      (60,  120, 220),
        "epic":      (160, 80,  220),
        "legendary": (220, 160, 40),
    }.get(rarity, (200, 200, 200))


def darken(c, factor=0.4):
    return tuple(int(v * factor) for v in c)


def lighten(c, factor=1.3):
    return tuple(min(255, int(v * factor)) for v in c)


def make_base(rarity: str) -> Image.Image:
    rc = rarity_color(rarity)
    bg = darken(rc, 0.25)
    img = Image.new("RGBA", (SIZE, SIZE), (*bg, 255))
    draw = ImageDraw.Draw(img)
    # rounded border in rarity color
    draw.rounded_rectangle([1, 1, SIZE - 2, SIZE - 2], radius=8,
                            outline=(*rc, 220), width=2)
    return img, draw, rc


# ── individual icon drawing functions ─────────────────────────────────────────

def draw_ladder(img, draw, rc):
    """Two vertical rails + horizontal rungs."""
    rail = (*rc,)
    # rails
    draw.rectangle([18, 8, 23, 56], fill=rail)
    draw.rectangle([41, 8, 46, 56], fill=rail)
    # rungs
    for y in range(12, 57, 10):
        draw.rectangle([18, y, 46, y + 3], fill=lighten(rc))


def draw_rope(img, draw, rc):
    """Coiled rope."""
    cx, cy = SIZE // 2, SIZE // 2
    for r in [22, 16, 10]:
        draw.ellipse([cx - r, cy - r, cx + r, cy + r],
                     outline=(*rc, 255), width=3)
    # knot at center
    draw.ellipse([cx - 4, cy - 4, cx + 4, cy + 4],
                 fill=lighten(rc), outline=(0, 0, 0, 180))


def draw_scroll(img, draw, rc):
    """Teleport scroll — rolled parchment with glow."""
    parch = (200, 180, 120, 255)
    light_rc = lighten(rc)
    # body
    draw.rounded_rectangle([16, 14, 48, 50], radius=6, fill=parch)
    # top/bottom roll cylinders
    draw.ellipse([14, 12, 50, 22], fill=lighten(parch, 1.1), outline=(120, 100, 60))
    draw.ellipse([14, 42, 50, 52], fill=lighten(parch, 1.1), outline=(120, 100, 60))
    # magic rune lines
    for i, y in enumerate([26, 30, 34, 38]):
        w = 22 - abs(i - 1) * 4
        x0 = SIZE // 2 - w // 2
        draw.line([(x0, y), (x0 + w, y)], fill=(*rc, 200), width=2)
    # glow dots
    for dx, dy in [(-6, -6), (6, -6), (-6, 6), (6, 6)]:
        cx, cy = SIZE // 2 + dx, SIZE // 2 + dy
        draw.ellipse([cx - 2, cy - 2, cx + 2, cy + 2],
                     fill=(*light_rc, 200))


def draw_fossil(img, draw, rc, detail_level=1):
    """Fossil bone shape with optional detail."""
    bone = lighten(rc, 1.6)
    shadow = darken(rc, 0.6)
    # diagonal bone
    for d in range(-1, 2):
        draw.line([(18 + d, 18), (46 + d, 46)], fill=shadow, width=5)
    draw.line([(18, 18), (46, 46)], fill=bone, width=4)
    # end knobs
    for cx, cy in [(18, 18), (46, 46)]:
        draw.ellipse([cx - 6, cy - 6, cx + 6, cy + 6], fill=bone, outline=shadow, width=1)
    if detail_level >= 2:
        # extra crack lines
        draw.line([(30, 22), (36, 30)], fill=shadow, width=1)
        draw.line([(28, 34), (34, 42)], fill=shadow, width=1)
    if detail_level >= 3:
        # highlight
        draw.line([(20, 20), (44, 44)], fill=(*lighten(bone), 120), width=2)


def draw_amber(img, draw, rc):
    """Amber — rounded gem with insect silhouette."""
    amber = (200, 130, 30, 255)
    highlight = (240, 190, 80, 200)
    # gem body
    draw.polygon([(32, 10), (50, 22), (52, 42), (32, 54), (12, 42), (14, 22)],
                 fill=amber, outline=(140, 80, 10), width=2)
    # highlight
    draw.ellipse([20, 16, 36, 30], fill=(*highlight,))
    # tiny trapped insect (cross)
    ix, iy = 34, 36
    draw.line([(ix - 4, iy), (ix + 4, iy)], fill=(60, 30, 0, 200), width=1)
    draw.line([(ix, iy - 5), (ix, iy + 3)], fill=(60, 30, 0, 200), width=1)


def draw_coin(img, draw, rc):
    """Ancient coin — circular with cross-hatch engraving."""
    gold = (210, 170, 30, 255)
    dark_gold = (140, 100, 15, 255)
    cx, cy, r = SIZE // 2, SIZE // 2, 22
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=gold, outline=dark_gold, width=3)
    # engrave lines
    for dx in [-6, -2, 2, 6]:
        draw.line([(cx + dx, cy - 14), (cx + dx, cy + 14)], fill=(*dark_gold,), width=1)
    for dy in [-6, -2, 2, 6]:
        draw.line([(cx - 14, cy + dy), (cx + 14, cy + dy)], fill=(*dark_gold,), width=1)
    # rim highlight
    draw.arc([cx - r, cy - r, cx + r, cy + r], start=210, end=340,
             fill=(255, 230, 120), width=2)


def draw_skull(img, draw, rc):
    """Crystal skull — translucent with facets."""
    crystal = (100, 160, 240, 200)
    edge = (60, 110, 200, 255)
    # cranium
    draw.ellipse([14, 10, 50, 42], fill=crystal, outline=edge, width=2)
    # jaw
    draw.polygon([(18, 38), (46, 38), (42, 52), (22, 52)],
                 fill=crystal, outline=edge, width=2)
    # eye sockets
    for ex in [22, 38]:
        draw.ellipse([ex - 5, 22, ex + 5, 32], fill=(20, 20, 60, 220))
    # facet lines
    draw.line([(32, 10), (32, 42)], fill=(180, 210, 255, 150), width=1)
    draw.line([(14, 26), (50, 26)], fill=(180, 210, 255, 150), width=1)


def draw_crown(img, draw, rc):
    """Fossilized crown — stone-textured crown shape."""
    stone = (160, 140, 100, 255)
    dark = (100, 85, 55, 255)
    gem_c = (*lighten(rc),)
    # base band
    draw.rectangle([10, 40, 54, 52], fill=stone, outline=dark, width=1)
    # crown points
    for px in [14, 24, 32, 40, 50]:
        h = 22 if px == 32 else 14
        draw.polygon([(px - 6, 40), (px, 40 - h), (px + 6, 40)],
                     fill=stone, outline=dark)
    # gemstones in band
    for gx in [18, 32, 46]:
        draw.ellipse([gx - 3, 42, gx + 3, 48], fill=gem_c)
    # crack texture
    draw.line([(16, 44), (20, 38)], fill=dark, width=1)
    draw.line([(42, 46), (48, 40)], fill=dark, width=1)


def draw_tablet(img, draw, rc):
    """Obsidian tablet — dark stone with carved runes."""
    obsidian = (40, 30, 50, 255)
    rune = (*rc,)
    highlight = (90, 70, 100, 200)
    # stone slab
    draw.rounded_rectangle([10, 8, 54, 56], radius=4, fill=obsidian,
                            outline=highlight, width=2)
    # carved rune rows (simple geometric shapes)
    patterns = [
        [(14, 14), (22, 14), (22, 20), (14, 20)],   # square
        [(28, 14), (38, 14), (33, 20)],               # triangle
        [(44, 14), (50, 14), (50, 20), (44, 20)],    # square
    ]
    for pts in patterns:
        if len(pts) == 4:
            draw.rectangle([pts[0], pts[2]], outline=rune, width=1)
        else:
            draw.polygon(pts, outline=rune)
    # middle row
    for x in range(14, 52, 8):
        draw.line([(x, 28), (x + 5, 28)], fill=rune, width=2)
    # bottom row glyphs
    draw.ellipse([14, 36, 24, 46], outline=rune, width=1)
    draw.line([(29, 36), (29, 46)], fill=rune, width=2)
    draw.line([(26, 41), (32, 41)], fill=rune, width=2)
    draw.rectangle([38, 36, 50, 46], outline=rune, width=1)
    draw.line([(44, 36), (44, 46)], fill=rune, width=1)


# ── item registry ─────────────────────────────────────────────────────────────

ITEMS = [
    ("ladder",               "common",    draw_ladder),
    ("rope",                 "common",    draw_rope),
    ("teleport_scroll",      "rare",      draw_scroll),
    ("fossil_common",        "uncommon",  lambda i, d, c: draw_fossil(i, d, c, 1)),
    ("fossil_rare",          "rare",      lambda i, d, c: draw_fossil(i, d, c, 2)),
    ("fossil_legendary",     "legendary", lambda i, d, c: draw_fossil(i, d, c, 3)),
    ("fossil_amber",         "uncommon",  draw_amber),
    ("artifact_ancient_coin",     "legendary", draw_coin),
    ("artifact_crystal_skull",    "legendary", draw_skull),
    ("artifact_fossilized_crown", "legendary", draw_crown),
    ("artifact_obsidian_tablet",  "rare",      draw_tablet),
]


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    for item_id, rarity, draw_fn in ITEMS:
        img, draw, rc = make_base(rarity)
        draw_fn(img, draw, rc)
        out_path = os.path.join(OUTPUT_DIR, f"{item_id}.png")
        img.save(out_path)
        print(f"  {item_id}.png")

    print(f"\nGenerated {len(ITEMS)} icons → {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
