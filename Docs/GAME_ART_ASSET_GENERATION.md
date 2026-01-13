# Game Art Asset Generation Guide

This document outlines researched approaches for generating 2D sprites and game assets for the GoDig Godot project.

## Table of Contents

- [Quick Recommendation](#quick-recommendation)
- [Tool Comparison](#tool-comparison)
- [Option 1: ComfyUI (Recommended)](#option-1-comfyui-recommended)
- [Option 2: Draw Things](#option-2-draw-things)
- [Option 3: MFLUX](#option-3-mflux)
- [Option 4: AUTOMATIC1111](#option-4-automatic1111)
- [Recommended Models for Pixel Art](#recommended-models-for-pixel-art)
- [Godot Integration](#godot-integration)
- [Workflow for Claude Code Integration](#workflow-for-claude-code-integration)
- [Post-Processing Pipeline](#post-processing-pipeline)

---

## Quick Recommendation

For GoDig's requirements (local, free, CLI-scriptable, consistent, Godot-compatible):

| Requirement | Best Option |
|------------|-------------|
| **Overall Best** | ComfyUI with Python API |
| **Easiest Setup** | Draw Things (App Store) |
| **Apple Silicon Optimized** | MFLUX |
| **Most Flexible** | ComfyUI |
| **Best for Automation** | ComfyUI API or Draw Things Scripting |

---

## Tool Comparison

| Tool | Local | Free | CLI/API | Brew Install | Animation | Ease of Use |
|------|-------|------|---------|--------------|-----------|-------------|
| **ComfyUI** | Yes | Yes | Yes (HTTP API) | Partial | Yes | Medium |
| **Draw Things** | Yes | Yes | Yes (JavaScript + gRPC) | No (App Store) | Limited | Easy |
| **MFLUX** | Yes | Yes | Yes (CLI) | Via pip | No | Medium |
| **AUTOMATIC1111** | Yes | Yes | Yes (API) | Partial | Via extensions | Medium |
| **DiffusionBee** | Yes | Yes | No | No | No | Very Easy |

---

## Option 1: ComfyUI (Recommended)

ComfyUI is a node-based Stable Diffusion interface with a powerful API, ideal for automated game asset generation.

### Installation

```bash
# Prerequisites
brew install cmake protobuf rust python@3.10 git wget

# Install ComfyUI via comfy-cli
pip install comfy-cli
comfy install

# Or manual installation
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
pip install -r requirements.txt

# For Apple Silicon optimization
pip install torch torchvision --extra-index-url https://download.pytorch.org/whl/cpu
```

### Running

```bash
# Start ComfyUI server
cd ComfyUI
python main.py

# Access at http://127.0.0.1:8188
```

### API Usage with Python

```python
import json
import urllib.request
import urllib.parse

COMFYUI_URL = "http://127.0.0.1:8188"

def queue_prompt(prompt_workflow):
    """Submit a workflow to ComfyUI for processing."""
    data = json.dumps({"prompt": prompt_workflow}).encode('utf-8')
    req = urllib.request.Request(f"{COMFYUI_URL}/prompt", data=data)
    return json.loads(urllib.request.urlopen(req).read())

def get_image(filename, subfolder, folder_type):
    """Retrieve generated image from ComfyUI."""
    params = urllib.parse.urlencode({
        "filename": filename,
        "subfolder": subfolder,
        "type": folder_type
    })
    with urllib.request.urlopen(f"{COMFYUI_URL}/view?{params}") as response:
        return response.read()
```

### Key Nodes for Game Assets

- **SpriteSheetMaker**: Arranges individual sprites into sheets
- **Background Removal**: Creates transparent PNGs
- **Image Grid**: Arranges frames for animation
- **ControlNet**: Maintain pose/style consistency

### Recommended Workflow

1. Load pixel art checkpoint/LoRA
2. Generate individual frames with consistent seed
3. Use Background Removal node
4. Arrange into sprite sheet with Image Grid
5. Export as PNG with transparency

---

## Option 2: Draw Things

A native macOS app with JavaScript scripting support.

### Installation

Download from the [Mac App Store](https://apps.apple.com/us/app/draw-things-ai-generation/id6444050820) (free).

### Scripting for Automation

Draw Things supports JavaScript scripting for batch processing:

```javascript
// Example: Batch generate sprites
const prompts = [
    "pixel art knight idle pose, transparent background",
    "pixel art knight walking, transparent background",
    "pixel art knight attacking, transparent background"
];

for (const prompt of prompts) {
    const result = pipeline.run({
        prompt: prompt,
        negativePrompt: "blurry, realistic, 3d",
        steps: 20,
        width: 128,
        height: 128
    });

    // Save to Pictures directory
    filesystem.pictures.write(`sprite_${Date.now()}.png`, result.image);
}
```

### gRPC CLI Server

Draw Things includes a gRPC server for external automation:

```bash
# The gRPCServerCLI is bundled with Draw Things
# Can be called from external scripts for headless generation
```

### Pros
- Native macOS app, highly optimized for Apple Silicon
- Easy model management
- Built-in scripting
- Supports FLUX, SDXL, SD 1.5

### Cons
- Limited to Draw Things ecosystem
- Scripting less flexible than ComfyUI
- No Homebrew install

---

## Option 3: MFLUX

MLX-native implementation of FLUX for Apple Silicon, optimized for performance.

### Installation

```bash
# Install via pip
pip install mflux

# Or with Homebrew dependencies
brew install python@3.11
pip3 install mflux
```

### CLI Usage

```bash
# Generate an image
mflux-generate \
    --prompt "pixel art sword, game asset, transparent background" \
    --model dev \
    --steps 4 \
    --seed 42 \
    --height 128 \
    --width 128 \
    --output sprite.png

# Use 4-bit quantization for lower memory (6GB vs 24GB)
mflux-generate --quantize 4 --prompt "pixel art character"
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

def generate_sprite(prompt, output_path, width=128, height=128):
    """Generate a sprite using mflux."""
    cmd = [
        "mflux-generate",
        "--prompt", prompt,
        "--model", "schnell",  # Faster model
        "--steps", "4",
        "--quantize", "8",
        "--width", str(width),
        "--height", str(height),
        "--output", output_path
    ]
    subprocess.run(cmd, check=True)
    return output_path
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

1. **Primary Tool**: ComfyUI with Python API
   - Most flexible for automation
   - Extensive node ecosystem for game assets
   - Active community and documentation

2. **Alternative**: Draw Things with JavaScript scripting
   - Easiest setup (App Store install)
   - Good scripting support
   - Native macOS optimization

3. **For Quick CLI Generation**: MFLUX
   - Simple command-line interface
   - Excellent for Apple Silicon
   - Fast with quantized models

4. **Essential Post-Processing**:
   - `rembg` for background removal
   - Pillow for image manipulation
   - Custom scripts for sprite sheet assembly

5. **Model Selection**:
   - Pixel Art Diffusion XL for high-quality output
   - 2D Pixel Toolkit LoRA for consistent game assets
