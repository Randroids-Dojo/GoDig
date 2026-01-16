#!/opt/homebrew/bin/python3.11
"""
Select best candidates and process them into a sprite sheet.
Then regenerate problematic frames if needed.
"""

from pathlib import Path
from PIL import Image
from rembg import remove
import io

PROJECT_ROOT = Path(__file__).parent.parent.parent
SPRITES_DIR = PROJECT_ROOT / "resources" / "sprites"
CANDIDATES_DIR = SPRITES_DIR / "polished_animation"
OUTPUT_DIR = SPRITES_DIR / "polished_animation" / "selected"

# LLM-selected best candidates (updated with regenerated frames)
BEST_CANDIDATES = {
    0: ("frame_00_ready_c2.png", "ready"),
    1: ("frame_01_windup_1_c2.png", "windup_1"),
    2: ("frame_02_windup_2_c1.png", "windup_2"),
    3: ("frame_03_windup_full_c0.png", "windup_full"),
    4: ("frame_04_swing_start_c1.png", "swing_start"),
    5: ("regen/regen_05_swing_mid_c1.png", "swing_mid"),  # REGENERATED
    6: ("frame_06_swing_low_c1.png", "swing_low"),
    7: ("regen/regen_07_impact_c0.png", "impact"),  # REGENERATED
}


def process_frame(input_path: Path, output_path: Path, frame_size: tuple = (128, 128)):
    """Process a single frame: remove background and resize."""
    print(f"  Processing {input_path.name}...")

    with open(input_path, 'rb') as f:
        img_data = f.read()

    # Remove background
    nobg_data = remove(img_data)

    # Load and resize
    img = Image.open(io.BytesIO(nobg_data))
    img = img.resize(frame_size, Image.Resampling.NEAREST)

    # Save
    img.save(output_path, "PNG")
    return img


def create_sprite_sheet(frames: list, output_path: Path):
    """Create horizontal sprite sheet from frames."""
    if not frames:
        return None

    frame_width, frame_height = frames[0].size
    sheet_width = frame_width * len(frames)
    sheet_height = frame_height

    sheet = Image.new('RGBA', (sheet_width, sheet_height), (0, 0, 0, 0))

    for i, frame in enumerate(frames):
        sheet.paste(frame, (i * frame_width, 0))

    sheet.save(output_path, "PNG")
    print(f"\nSprite sheet saved: {output_path}")
    print(f"  Size: {sheet.size}")
    return sheet


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("=" * 60)
    print("PROCESSING SELECTED CANDIDATES")
    print("=" * 60)

    processed_frames = []

    for frame_idx in range(8):
        filename, frame_name = BEST_CANDIDATES[frame_idx]
        input_path = CANDIDATES_DIR / filename
        output_path = OUTPUT_DIR / f"selected_{frame_idx:02d}_{frame_name}.png"

        if not input_path.exists():
            print(f"  ERROR: {input_path} not found!")
            continue

        frame = process_frame(input_path, output_path)
        processed_frames.append(frame)

    # Create sprite sheet
    print("\n" + "=" * 60)
    print("CREATING SPRITE SHEET")
    print("=" * 60)

    sheet_path = SPRITES_DIR / "miner_swing_polished.png"
    create_sprite_sheet(processed_frames, sheet_path)

    return processed_frames


if __name__ == "__main__":
    main()
