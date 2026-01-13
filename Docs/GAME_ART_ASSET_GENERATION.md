# Game Art Asset Generation Guide

This document outlines researched approaches for generating 2D sprites and game assets for the GoDig Godot project.

## Table of Contents

- [Quick Recommendation](#quick-recommendation)
- [Consistent Character Animation](#consistent-character-animation-critical)
- [Option 1: PixelLab MCP (Recommended)](#option-1-pixellab-mcp-recommended)
- [Option 2: ComfyUI + IP-Adapter](#option-2-comfyui--ip-adapter)
- [Option 3: MFLUX (Static Assets Only)](#option-3-mflux-static-assets-only)
- [Godot Integration](#godot-integration)
- [Post-Processing Pipeline](#post-processing-pipeline)

---

## Quick Recommendation

For GoDig's requirements (consistent, automated, Godot-compatible):

| Requirement | Best Option |
|------------|-------------|
| **Consistent Characters** | PixelLab MCP (Claude Code integration) |
| **Animated Sprites** | PixelLab MCP (built-in animation) |
| **Static Assets** | MFLUX Z-Image-Turbo (local, free) |
| **Full Local Control** | ComfyUI + IP-Adapter + ControlNet |
| **Best for Automation** | PixelLab MCP (direct Claude Code tool) |

---

## Consistent Character Animation (CRITICAL)

**The #1 challenge in AI sprite generation is maintaining character consistency across animation frames.** Standard text-to-image generation produces different-looking characters for each frame.

### Solutions for Consistency

| Approach | Consistency | Setup Complexity | Cost |
|----------|-------------|------------------|------|
| **PixelLab MCP** | Excellent | Very Easy | Free tier + $12/mo |
| **ComfyUI + IP-Adapter** | Good | Complex | Free (local) |
| **Train Custom LoRA** | Excellent | Very Complex | Free (local) |
| **MFLUX (no solution)** | Poor | Easy | Free |

### Why PixelLab is Recommended

1. **MCP Integration**: Works directly as a Claude Code tool
2. **Built-in Consistency**: Designed specifically for game sprites
3. **Animation Support**: Generate walk/run/idle/attack animations
4. **Multi-directional**: Create 4 or 8 directional character views
5. **Free Tier**: 40 fast generations, then 5 daily

---

## Tool Comparison

| Tool | Consistent Chars | Animation | Claude Code Integration | Local | Free |
|------|------------------|-----------|------------------------|-------|------|
| **PixelLab MCP** | Excellent | Yes | Yes (MCP) | Cloud | Free tier |
| **ComfyUI + IP-Adapter** | Good | Manual | Via API | Yes | Yes |
| **MFLUX** | Poor | No | Via script | Yes | Yes |
| **Draw Things** | Poor | No | Via script | Yes | Yes |

---

## Option 1: PixelLab MCP (Recommended)

PixelLab provides an MCP (Model Context Protocol) server that integrates directly with Claude Code, enabling consistent pixel art character generation with built-in animation support.

### Why PixelLab for GoDig

- **Consistent Characters**: Designed specifically to maintain character appearance across frames
- **Built-in Animations**: Walk, run, idle, attack cycles with frame consistency
- **Multi-directional**: Generate 4 or 8 directional views automatically
- **MCP Integration**: Works as a native Claude Code tool
- **No Local GPU**: Runs on cloud GPUs

### Setup for Claude Code

1. Sign up at [PixelLab.ai](https://www.pixellab.ai/) (free tier: 40 generations)
2. Get your API token from the dashboard
3. Add to Claude Code MCP configuration:

```bash
# Add PixelLab MCP server to Claude Code
claude mcp add pixellab \
  --transport http \
  --url https://api.pixellab.ai/mcp \
  --header "Authorization: Bearer YOUR_API_TOKEN"
```

Or add manually to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "pixellab": {
      "url": "https://api.pixellab.ai/mcp",
      "transport": "http",
      "headers": {
        "Authorization": "Bearer YOUR_API_TOKEN"
      }
    }
  }
}
```

### Available MCP Tools

Once configured, Claude Code gains access to:

```python
# Create a consistent character with multiple directions
create_character(
    description="pixel art miner with hard hat and pickaxe",
    n_directions=4  # or 8 for 8-directional
)

# Add animation to an existing character
animate_character(
    character_id="abc123",
    animation="swing"  # walk, run, idle, attack, etc.
)

# Create tilesets for environments
create_tileset(
    lower="underground cave floor",
    upper="rocky cave wall"
)
```

### Pricing

| Tier | Cost | Features |
|------|------|----------|
| **Free Trial** | $0 | 40 fast generations, then 5 daily (up to 200x200) |
| **Pixel Apprentice** | $12/month | Up to 320x320, animation tools |
| **Pixel Architect** | $50/month | Highest priority, team features |

### Resources

- [PixelLab MCP GitHub](https://github.com/pixellab-code/pixellab-mcp)
- [Interactive Setup Guide](https://www.pixellab.ai/vibe-coding)
- [Documentation](https://www.pixellab.ai/docs)

---

## Option 2: ComfyUI + IP-Adapter

For fully local generation with character consistency, use ComfyUI with IP-Adapter. IP-Adapter uses a reference image to maintain character appearance across frames.

### How IP-Adapter Enables Consistency

1. **Reference Image**: Provide a single character image as reference
2. **CLIP Vision**: Encodes the reference into feature embeddings
3. **IP-Adapter**: Conditions generation on those embeddings
4. **ControlNet (optional)**: Adds pose control for animation frames

### Installation on Apple Silicon

```bash
# Install ComfyUI
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
pip install -r requirements.txt

# Install IP-Adapter Plus custom nodes
cd custom_nodes
git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git

# Download required models to ComfyUI/models/
# - ipadapter/ip-adapter-plus_sdxl_vit-h.bin
# - clip_vision/CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors
```

### Workflow for Animation Frames

```python
# Pseudocode workflow
1. Generate or draw a single reference character image
2. Load reference into IP-Adapter (weight 0.8-1.0)
3. Use ControlNet with pose images for each animation frame
4. Generate frames - IP-Adapter maintains character appearance
5. Post-process: background removal, resize
```

### Pros
- Fully local, no API costs
- Good consistency with reference image
- Flexible pose control with ControlNet

### Cons
- Complex setup
- Requires manual pose creation
- Not as seamless as PixelLab for animations
- Apple Silicon support can have issues

### Resources

- [ComfyUI_IPAdapter_plus](https://github.com/cubiq/ComfyUI_IPAdapter_plus)
- [Flux + IPAdapter on Apple Silicon Guide](https://medium.com/@tchpnk/flux-ipadapter-comfyui-on-apple-silicon-2024-9577b0f0e91f)
- [Consistent Character Tutorial](https://stable-diffusion-art.com/consistent-character-view-angle/)

---

## Option 3: MFLUX (Static Assets Only)

> **Warning**: MFLUX cannot maintain character consistency across frames. Use only for static assets like backgrounds, items, or single-pose characters.

### MFLUX Details

MLX-native implementation of FLUX for Apple Silicon, optimized for performance.

> **Note**: MFLUX requires Python 3.10+ due to modern type hint syntax. Use Homebrew Python.

### Installation

```bash
# Install Python 3.11 via Homebrew (required - system Python 3.9 won't work)
brew install python@3.11

# Install MFLUX and dependencies
/opt/homebrew/bin/pip3.11 install mflux rembg pillow onnxruntime
```

### CLI Usage

```bash
# Use Z-Image-Turbo model (no HuggingFace auth required!)
/opt/homebrew/bin/mflux-generate-z-image-turbo \
    --prompt "pixel art sword, game asset, transparent background" \
    --steps 9 \
    --seed 42 \
    --height 256 \
    --width 256 \
    --quantize 4 \
    --output sprite.png

# Note: FLUX Schnell/Dev models require HuggingFace authentication
# Z-Image-Turbo is recommended for automation as it works without login
```

### Performance

| Mac Model | 8-bit Quantized | Non-quantized |
|-----------|-----------------|---------------|
| M1 Pro 32GB | ~15-30s | ~30-60s |
| M2 Pro | ~10-20s | ~20-40s |
| M3 Max | ~5-10s | ~10-20s |

### Python Integration

```python
import subprocess
from pathlib import Path

MFLUX_BIN = Path("/opt/homebrew/bin/mflux-generate-z-image-turbo")

def generate_sprite(prompt, output_path, width=256, height=256, seed=None):
    """Generate a sprite using mflux Z-Image-Turbo."""
    cmd = [
        str(MFLUX_BIN),
        "--prompt", prompt,
        "--steps", "9",
        "--quantize", "4",  # Low memory mode
        "--width", str(width),
        "--height", str(height),
        "--output", output_path
    ]
    if seed is not None:
        cmd.extend(["--seed", str(seed)])
    subprocess.run(cmd, check=True)
    return output_path
```

### GoDig Sprite Generation Script

A complete sprite generation script is available at `scripts/tools/generate_sprite.py`:

```bash
# Generate a miner sprite
/opt/homebrew/bin/python3.11 scripts/tools/generate_sprite.py \
    miner_swing "miner character swinging a pickaxe" --seed 42

# Generate a weapon
/opt/homebrew/bin/python3.11 scripts/tools/generate_sprite.py \
    sword "medieval sword weapon" --width 64 --height 64

# Generate a background (skip background removal)
/opt/homebrew/bin/python3.11 scripts/tools/generate_sprite.py \
    cave "underground cave scene" --no-remove-bg --width 720 --height 1280
```

### Pros
- Excellent Apple Silicon optimization
- Simple CLI interface
- Low memory with quantization
- Fast generation times

### Cons
- FLUX models only (no SD 1.5/SDXL)
- Limited animation/sprite sheet features
- Requires separate post-processing

---

## Option 4: AUTOMATIC1111

The most feature-rich Stable Diffusion WebUI.

### Installation

```bash
# Prerequisites
brew install cmake protobuf rust python@3.10 git wget

# Clone and setup
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui

# Launch (downloads models on first run)
./webui.sh
```

### Apple Silicon Optimization

```bash
# Set environment variables for M1/M2/M3
export COMMANDLINE_ARGS="--skip-torch-cuda-test --upcast-sampling --no-half-vae --opt-sub-quad-attention --use-cpu interrogate"
./webui.sh
```

### API Usage

```python
import requests
import base64

A1111_URL = "http://127.0.0.1:7860"

def generate_image(prompt, width=128, height=128):
    """Generate image via A1111 API."""
    payload = {
        "prompt": prompt,
        "negative_prompt": "blurry, realistic, 3d render",
        "steps": 20,
        "width": width,
        "height": height,
        "sampler_name": "Euler a"
    }

    response = requests.post(
        f"{A1111_URL}/sdapi/v1/txt2img",
        json=payload
    )

    # Decode base64 image
    image_data = base64.b64decode(response.json()['images'][0])
    return image_data
```

---

## Recommended Models for Pixel Art

### Checkpoints

| Model | Base | Best For |
|-------|------|----------|
| **Pixel Art Diffusion XL** | SDXL | High-quality pixel art |
| **Pixel Art XL** | SDXL | True pixel aesthetics |
| **Pixel Art Sprite Diffusion** | SD 1.5 | Multi-angle sprites |
| **SD_PixelArt_SpriteSheet_Generator** | SD 1.5 | Direct sprite sheets |

### LoRAs

| LoRA | Purpose |
|------|---------|
| **2D Pixel Toolkit** | Characters, weapons, items at 64x64/128x128 |
| **Pixel Art XL LoRA** | General pixel art enhancement |
| **Microverse LoRA** | Detailed pixel environments |

### Download Sources

- [Civitai](https://civitai.com/) - Largest model repository
- [Hugging Face](https://huggingface.co/) - Official model hosting

---

## Godot Integration

### Supported Formats

Godot supports these image formats for sprites:
- **PNG** (recommended) - Supports transparency
- **WebP** - Smaller file size, supports transparency

### Sprite2D Setup

```gdscript
# Load a generated sprite
var texture = load("res://assets/sprites/character.png")
var sprite = Sprite2D.new()
sprite.texture = texture
add_child(sprite)
```

### AnimatedSprite2D with Sprite Sheets

```gdscript
# For sprite sheet animations
var sprite_frames = SpriteFrames.new()
var sheet_texture = load("res://assets/sprites/character_walk.png")

# Configure frame size
sprite_frames.set_animation_speed("walk", 10)
for i in range(8):  # 8 frames
    var atlas = AtlasTexture.new()
    atlas.atlas = sheet_texture
    atlas.region = Rect2(i * 128, 0, 128, 128)
    sprite_frames.add_frame("walk", atlas)

var animated_sprite = AnimatedSprite2D.new()
animated_sprite.sprite_frames = sprite_frames
animated_sprite.play("walk")
```

### Recommended Asset Dimensions

| Asset Type | Resolution | Notes |
|------------|------------|-------|
| Characters | 64x64, 128x128 | Power of 2 for GPU efficiency |
| Items/Weapons | 32x32, 64x64 | Consistent scale |
| Tiles | 16x16, 32x32 | Must tile seamlessly |
| Backgrounds | 720x1280 | Match viewport (9:16) |
| UI Elements | Variable | Match UI scale |

---

## Workflow for Claude Code Integration

### Recommended Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Claude Code                        │
│                                                      │
│  1. Generate prompt based on asset requirements      │
│  2. Call image generation tool via subprocess/API   │
│  3. Post-process (background removal, scaling)       │
│  4. Save to Godot project assets directory          │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
           ┌────────────────────────┐
           │  ComfyUI / MFLUX /     │
           │  Draw Things           │
           │  (Local Generation)    │
           └────────────────────────┘
                        │
                        ▼
           ┌────────────────────────┐
           │  Post-Processing       │
           │  - rembg (background)  │
           │  - PIL/Pillow (resize) │
           │  - ImageMagick         │
           └────────────────────────┘
                        │
                        ▼
           ┌────────────────────────┐
           │  GoDig/assets/         │
           │  - sprites/            │
           │  - backgrounds/        │
           │  - effects/            │
           └────────────────────────┘
```

### Example Integration Script

```python
#!/usr/bin/env python3
"""
Asset generation script for GoDig.
Integrates with ComfyUI for sprite generation.
"""

import subprocess
import json
from pathlib import Path

ASSETS_DIR = Path(__file__).parent.parent / "resources" / "sprites"
COMFYUI_URL = "http://127.0.0.1:8188"

def generate_character_sprite(name: str, description: str):
    """Generate a character sprite with consistent style."""
    prompt = f"""
    pixel art {description},
    game sprite,
    transparent background,
    centered,
    clean edges,
    128x128 pixels,
    8-bit style
    """

    # Call ComfyUI API (implementation depends on workflow)
    # ...

    output_path = ASSETS_DIR / f"{name}.png"
    # Save and post-process
    return output_path

def generate_animation_frames(name: str, description: str, frame_count: int = 8):
    """Generate consistent animation frames."""
    frames = []
    base_seed = 42  # Use consistent seed for style

    for i in range(frame_count):
        # Modify prompt for each frame
        frame_prompt = f"{description}, frame {i+1} of {frame_count}"
        # Generate with same seed but different frame
        # ...

    return frames
```

---

## Post-Processing Pipeline

### Background Removal

```bash
# Install rembg
pip install rembg

# Remove background from generated image
rembg i input.png output.png
```

### Python Post-Processing

```python
from PIL import Image
from rembg import remove
import io

def process_sprite(image_data: bytes, target_size: tuple = (128, 128)) -> bytes:
    """Remove background and resize sprite."""
    # Remove background
    image = Image.open(io.BytesIO(image_data))
    image_no_bg = remove(image)

    # Resize with nearest-neighbor for pixel art
    image_resized = image_no_bg.resize(target_size, Image.NEAREST)

    # Save as PNG with transparency
    output = io.BytesIO()
    image_resized.save(output, format='PNG')
    return output.getvalue()
```

### Sprite Sheet Assembly

```python
from PIL import Image

def create_sprite_sheet(frames: list, columns: int = 8) -> Image:
    """Combine frames into a sprite sheet."""
    if not frames:
        return None

    frame_width, frame_height = frames[0].size
    rows = (len(frames) + columns - 1) // columns

    sheet = Image.new('RGBA',
                      (frame_width * columns, frame_height * rows),
                      (0, 0, 0, 0))

    for i, frame in enumerate(frames):
        x = (i % columns) * frame_width
        y = (i // columns) * frame_height
        sheet.paste(frame, (x, y))

    return sheet
```

---

## Asset Types Checklist

### Characters
- [ ] Idle animation (4-8 frames)
- [ ] Walk animation (8 frames)
- [ ] Attack animation (4-6 frames)
- [ ] Death animation (4-6 frames)
- [ ] Multiple directions (4 or 8 angles)

### Weapons/Items
- [ ] Ground/pickup state
- [ ] Equipped/held state
- [ ] Effect animations

### Backgrounds
- [ ] Parallax layers (3-5 layers)
- [ ] Seamless tiling for infinite scroll

### Visual Effects
- [ ] Particle sprites
- [ ] Impact effects
- [ ] Magic/ability effects

### UI Elements
- [ ] Buttons (normal, hover, pressed)
- [ ] Icons
- [ ] Health bars
- [ ] Inventory slots

---

## Resources

### Documentation
- [ComfyUI GitHub](https://github.com/comfyanonymous/ComfyUI)
- [Draw Things Documentation](https://docs.drawthings.ai/)
- [MFLUX GitHub](https://github.com/filipstrand/mflux)
- [Godot Sprite2D Docs](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html)
- [Godot 2D Animation Tutorial](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html)

### Model Sources
- [Civitai - Pixel Art Models](https://civitai.com/models?tag=pixel%20art)
- [Hugging Face - SD PixelArt SpriteSheet Generator](https://huggingface.co/Onodofthenorth/SD_PixelArt_SpriteSheet_Generator)

### Tutorials
- [ComfyUI Pixel Art Guide](https://www.kokutech.com/blog/gamedev/tips/art/pixel-art-generation-with-comfyui)
- [Generate Clean Spritesheets in ComfyUI](https://apatero.com/blog/generate-clean-spritesheets-comfyui-guide-2025)
- [Layer Diffusion for Transparent Backgrounds](https://stable-diffusion-art.com/transparent-background/)

---

## Summary

For GoDig, the recommended approach is:

### For Animated Characters (Consistent Frames)

1. **Primary Tool**: PixelLab MCP
   - Direct Claude Code integration via MCP
   - Built-in character consistency
   - Animation support (walk, run, idle, attack)
   - Free tier: 40 generations, then 5 daily
   - Setup: Add MCP server with API token

2. **Alternative (Local)**: ComfyUI + IP-Adapter
   - Fully local, no API costs
   - Use reference image for consistency
   - ControlNet for pose control
   - More complex setup required

### For Static Assets (Backgrounds, Items)

3. **MFLUX Z-Image-Turbo**: Good for single images
   - Fast local generation (~5s per image)
   - No authentication required
   - See `scripts/tools/generate_sprite.py`
   - **Not suitable for animation frames** (no consistency)

### Essential Post-Processing

- `rembg` for background removal
- Pillow for image manipulation
- Nearest-neighbor resampling for pixel art

### Key Insight

**Character consistency is the critical challenge.** Standard text-to-image tools like MFLUX, Draw Things, and basic Stable Diffusion will produce different-looking characters for each frame. For animation, you MUST use either:

1. PixelLab (designed for this)
2. IP-Adapter with reference image
3. Custom-trained LoRA on your character

### Resources

- [PixelLab MCP](https://github.com/pixellab-code/pixellab-mcp) - Claude Code integration
- [ComfyUI Spritesheet Guide](https://apatero.com/blog/generate-clean-spritesheets-comfyui-guide-2025)
- [IP-Adapter for Consistent Characters](https://stable-diffusion-art.com/consistent-character-view-angle/)
- [Sprite Sheet Diffusion Paper](https://arxiv.org/html/2412.03685v2)
