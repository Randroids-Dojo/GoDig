#!/opt/homebrew/bin/python3.11
"""Debug arm + pickaxe combination."""

from PIL import Image
from pathlib import Path
import sys

PROJECT_ROOT = Path(__file__).parent.parent.parent
COMPONENTS_DIR = PROJECT_ROOT / "resources" / "sprites" / "components"

sys.path.insert(0, str(Path(__file__).parent))
from improved_sprite_builder_v4 import COLORS


def main():
    # Load components
    arm = Image.open(COMPONENTS_DIR / "arm.png")
    pickaxe = Image.open(COMPONENTS_DIR / "pickaxe.png")

    print(f"Arm size: {arm.size}")
    print(f"Pickaxe size: {pickaxe.size}")

    # Combine as in assemble_frame
    arm_pickaxe = Image.new('RGBA', (96, 28), COLORS["transparent"])
    arm_pickaxe.paste(arm, (0, 5), arm)
    arm_pickaxe.paste(pickaxe, (40, 2), pickaxe)

    # Save combined
    arm_pickaxe.save(COMPONENTS_DIR / "debug_arm_pickaxe.png")
    print(f"Saved combined arm+pickaxe to debug_arm_pickaxe.png")

    # Also save a scaled version for easier viewing
    scaled = arm_pickaxe.resize((arm_pickaxe.width * 4, arm_pickaxe.height * 4), Image.Resampling.NEAREST)
    scaled.save(COMPONENTS_DIR / "debug_arm_pickaxe_4x.png")
    print(f"Saved 4x scaled version")


if __name__ == "__main__":
    main()
