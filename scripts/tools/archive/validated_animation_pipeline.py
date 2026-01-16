#!/opt/homebrew/bin/python3.11
"""
Validated Animation Pipeline for GoDig

Multi-pass generation pipeline with LLM-based quality validation.
Uses ComfyUI + IP-Adapter for generation and Claude for validation.

Pipeline stages:
1. Reference Analysis - Extract character specification from reference
2. Multi-Candidate Generation - Generate N candidates per frame
3. Individual Frame Validation - Score each candidate
4. Cross-Frame Consistency Check - Ensure frames work together
5. Regeneration Loop - Fix problematic frames
6. Final Assembly - Create sprite sheet

Requirements:
    - ComfyUI running at http://127.0.0.1:8188
    - IP-Adapter Plus installed
    - ANTHROPIC_API_KEY environment variable (optional, for automated validation)
    - Or: manual validation mode

Usage:
    python validated_animation_pipeline.py reference.png --frames 8 --candidates 3
"""

import json
import urllib.request
import urllib.parse
import time
import base64
import sys
import os
import hashlib
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional
from PIL import Image
import io

# Configuration
COMFYUI_URL = "http://127.0.0.1:8188"
PROJECT_ROOT = Path(__file__).parent.parent.parent
SPRITES_DIR = PROJECT_ROOT / "resources" / "sprites"
OUTPUT_DIR = SPRITES_DIR / "validated_animation"

# Quality thresholds
MIN_INDIVIDUAL_SCORE = 3.5  # Out of 5
MIN_CONSISTENCY_SCORE = 3.5
MAX_REGENERATION_ATTEMPTS = 3


@dataclass
class FrameEvaluation:
    """Evaluation result for a single frame."""
    frame_index: int
    candidate_index: int
    style_score: float = 0.0
    quality_score: float = 0.0
    pose_score: float = 0.0
    overall_score: float = 0.0
    issues: list = field(default_factory=list)
    feedback: str = ""


@dataclass
class ConsistencyEvaluation:
    """Evaluation of consistency across all frames."""
    overall_score: float = 0.0
    size_consistent: bool = True
    color_consistent: bool = True
    style_consistent: bool = True
    problematic_frames: list = field(default_factory=list)
    feedback: str = ""


@dataclass
class CharacterSpec:
    """Character specification extracted from reference."""
    description: str = ""
    colors: list = field(default_factory=list)
    proportions: str = ""
    style: str = ""
    key_features: list = field(default_factory=list)


class ComfyUIClient:
    """Client for interacting with ComfyUI API."""

    def __init__(self, url: str = COMFYUI_URL):
        self.url = url

    def upload_image(self, image_path: Path) -> str:
        """Upload an image to ComfyUI."""
        with open(image_path, 'rb') as f:
            image_data = f.read()

        boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW'
        filename = image_path.name

        body = (
            f'--{boundary}\r\n'
            f'Content-Disposition: form-data; name="image"; filename="{filename}"\r\n'
            f'Content-Type: image/png\r\n\r\n'
        ).encode('utf-8') + image_data + f'\r\n--{boundary}--\r\n'.encode('utf-8')

        req = urllib.request.Request(
            f"{self.url}/upload/image",
            data=body,
            headers={'Content-Type': f'multipart/form-data; boundary={boundary}'},
            method='POST'
        )

        response = json.loads(urllib.request.urlopen(req).read())
        return response.get("name", filename)

    def create_workflow(self, ref_name: str, prompt: str, seed: int,
                       width: int = 512, height: int = 512,
                       ipadapter_weight: float = 0.95) -> dict:
        """Create ComfyUI workflow with IP-Adapter."""
        return {
            "1": {
                "class_type": "CheckpointLoaderSimple",
                "inputs": {"ckpt_name": "v1-5-pruned-emaonly.safetensors"}
            },
            "2": {
                "class_type": "IPAdapterUnifiedLoader",
                "inputs": {"model": ["1", 0], "preset": "PLUS (high strength)"}
            },
            "3": {
                "class_type": "LoadImage",
                "inputs": {"image": ref_name}
            },
            "4": {
                "class_type": "IPAdapter",
                "inputs": {
                    "model": ["2", 0],
                    "ipadapter": ["2", 1],
                    "image": ["3", 0],
                    "weight": ipadapter_weight,
                    "start_at": 0.0,
                    "end_at": 1.0,
                    "weight_type": "standard"
                }
            },
            "5": {
                "class_type": "CLIPTextEncode",
                "inputs": {
                    "text": prompt,
                    "clip": ["1", 1]
                }
            },
            "6": {
                "class_type": "CLIPTextEncode",
                "inputs": {
                    "text": "blurry, realistic, 3d render, photo, multiple characters, "
                           "text, watermark, artifact, deformed, bad anatomy, "
                           "different character, inconsistent style, wrong colors",
                    "clip": ["1", 1]
                }
            },
            "7": {
                "class_type": "EmptyLatentImage",
                "inputs": {"width": width, "height": height, "batch_size": 1}
            },
            "8": {
                "class_type": "KSampler",
                "inputs": {
                    "model": ["4", 0],
                    "positive": ["5", 0],
                    "negative": ["6", 0],
                    "latent_image": ["7", 0],
                    "seed": seed,
                    "steps": 35,
                    "cfg": 7.5,
                    "sampler_name": "euler",
                    "scheduler": "normal",
                    "denoise": 1.0
                }
            },
            "9": {
                "class_type": "VAEDecode",
                "inputs": {"samples": ["8", 0], "vae": ["1", 2]}
            },
            "10": {
                "class_type": "SaveImage",
                "inputs": {"images": ["9", 0], "filename_prefix": "validated"}
            }
        }

    def queue_prompt(self, workflow: dict) -> str:
        """Queue a workflow and return prompt ID."""
        data = json.dumps({
            "prompt": workflow,
            "client_id": "validated_pipeline"
        }).encode('utf-8')

        req = urllib.request.Request(
            f"{self.url}/prompt",
            data=data,
            headers={"Content-Type": "application/json"}
        )

        response = json.loads(urllib.request.urlopen(req).read())
        return response.get("prompt_id")

    def wait_for_completion(self, prompt_id: str, timeout: int = 300) -> dict:
        """Wait for a prompt to complete."""
        start_time = time.time()

        while time.time() - start_time < timeout:
            url = f"{self.url}/history/{prompt_id}"
            response = urllib.request.urlopen(url)
            history = json.loads(response.read())

            if prompt_id in history:
                return history[prompt_id]

            time.sleep(1)

        raise TimeoutError(f"Generation timed out after {timeout}s")

    def download_image(self, filename: str, subfolder: str = "",
                      folder_type: str = "output") -> bytes:
        """Download an image from ComfyUI."""
        params = urllib.parse.urlencode({
            "filename": filename,
            "subfolder": subfolder,
            "type": folder_type
        })

        url = f"{self.url}/view?{params}"
        response = urllib.request.urlopen(url)
        return response.read()

    def generate_frame(self, ref_name: str, prompt: str, seed: int,
                      output_path: Path, ipadapter_weight: float = 0.95) -> Path:
        """Generate a single frame and save it."""
        workflow = self.create_workflow(ref_name, prompt, seed,
                                        ipadapter_weight=ipadapter_weight)
        prompt_id = self.queue_prompt(workflow)
        result = self.wait_for_completion(prompt_id)

        outputs = result.get("outputs", {})
        if "10" in outputs:
            images = outputs["10"].get("images", [])
            if images:
                img_info = images[0]
                img_data = self.download_image(
                    img_info["filename"],
                    img_info.get("subfolder", ""),
                    img_info.get("type", "output")
                )

                with open(output_path, 'wb') as f:
                    f.write(img_data)

                return output_path

        raise RuntimeError("Failed to generate frame")


class LLMEvaluator:
    """LLM-based frame evaluator using Claude API."""

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.environ.get("ANTHROPIC_API_KEY")
        self.has_api = bool(self.api_key)

        if not self.has_api:
            print("Note: ANTHROPIC_API_KEY not set. Using manual evaluation mode.")
            print("Set the key for automated validation.")

    def _encode_image(self, image_path: Path) -> str:
        """Encode image to base64."""
        with open(image_path, 'rb') as f:
            return base64.standard_b64encode(f.read()).decode('utf-8')

    def _call_claude_api(self, messages: list, max_tokens: int = 2000) -> str:
        """Call Claude API with vision support."""
        if not self.has_api:
            raise RuntimeError("No API key available")

        data = json.dumps({
            "model": "claude-sonnet-4-20250514",
            "max_tokens": max_tokens,
            "messages": messages
        }).encode('utf-8')

        req = urllib.request.Request(
            "https://api.anthropic.com/v1/messages",
            data=data,
            headers={
                "Content-Type": "application/json",
                "x-api-key": self.api_key,
                "anthropic-version": "2023-06-01"
            }
        )

        response = urllib.request.urlopen(req)
        result = json.loads(response.read())
        return result["content"][0]["text"]

    def analyze_reference(self, reference_path: Path) -> CharacterSpec:
        """Analyze reference image to extract character specification."""
        if not self.has_api:
            # Return default spec for manual mode
            return CharacterSpec(
                description="Pixel art miner character",
                colors=["skin tone", "blue pants", "black pickaxe head", "brown handle"],
                proportions="chibi style, large head, small body",
                style="pixel art, game sprite, clean edges",
                key_features=["bald/short hair", "pickaxe tool", "mining outfit"]
            )

        image_b64 = self._encode_image(reference_path)

        messages = [{
            "role": "user",
            "content": [
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/png",
                        "data": image_b64
                    }
                },
                {
                    "type": "text",
                    "text": """Analyze this reference sprite and extract a character specification.

Provide a JSON response with:
{
    "description": "Brief description of the character",
    "colors": ["list of key colors used"],
    "proportions": "Body proportions and style (e.g., chibi, realistic)",
    "style": "Art style description",
    "key_features": ["distinctive features that must be consistent"]
}

Be specific about colors (e.g., "blue jeans", "tan skin", "black boots").
Focus on details that must remain consistent across animation frames."""
                }
            ]
        }]

        response = self._call_claude_api(messages)

        # Parse JSON from response
        try:
            # Find JSON in response
            start = response.find('{')
            end = response.rfind('}') + 1
            if start >= 0 and end > start:
                spec_dict = json.loads(response[start:end])
                return CharacterSpec(**spec_dict)
        except json.JSONDecodeError:
            pass

        return CharacterSpec(description=response)

    def evaluate_frame(self, reference_path: Path, candidate_path: Path,
                      char_spec: CharacterSpec, frame_index: int,
                      pose_description: str) -> FrameEvaluation:
        """Evaluate a single candidate frame."""
        eval_result = FrameEvaluation(frame_index=frame_index, candidate_index=0)

        if not self.has_api:
            # Manual mode - save for later evaluation
            eval_result.feedback = f"Manual evaluation required for {candidate_path.name}"
            eval_result.overall_score = 0  # Will be set manually
            return eval_result

        ref_b64 = self._encode_image(reference_path)
        cand_b64 = self._encode_image(candidate_path)

        messages = [{
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "REFERENCE IMAGE (the standard to match):"
                },
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/png",
                        "data": ref_b64
                    }
                },
                {
                    "type": "text",
                    "text": f"CANDIDATE FRAME (to evaluate):"
                },
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/png",
                        "data": cand_b64
                    }
                },
                {
                    "type": "text",
                    "text": f"""Evaluate this animation frame candidate.

Character Specification:
- Description: {char_spec.description}
- Colors: {', '.join(char_spec.colors)}
- Style: {char_spec.style}
- Key Features: {', '.join(char_spec.key_features)}

Expected pose: {pose_description}

Rate 1-5 on each dimension and provide JSON response:
{{
    "style_score": <1-5, how well it matches the reference art style>,
    "quality_score": <1-5, absence of artifacts, clean edges>,
    "pose_score": <1-5, how well it matches expected pose>,
    "issues": ["list of specific problems"],
    "feedback": "specific suggestions for improvement"
}}

Be strict - only give 5 for perfect matches. Common issues:
- Wrong colors (hair, clothes, skin)
- Different proportions
- Missing/wrong features
- Artifacts or blurry areas
- Pose doesn't match description"""
                }
            ]
        }]

        response = self._call_claude_api(messages)

        try:
            start = response.find('{')
            end = response.rfind('}') + 1
            if start >= 0 and end > start:
                eval_dict = json.loads(response[start:end])
                eval_result.style_score = eval_dict.get("style_score", 0)
                eval_result.quality_score = eval_dict.get("quality_score", 0)
                eval_result.pose_score = eval_dict.get("pose_score", 0)
                eval_result.issues = eval_dict.get("issues", [])
                eval_result.feedback = eval_dict.get("feedback", "")
                eval_result.overall_score = (
                    eval_result.style_score * 0.4 +
                    eval_result.quality_score * 0.3 +
                    eval_result.pose_score * 0.3
                )
        except json.JSONDecodeError:
            eval_result.feedback = response

        return eval_result

    def check_consistency(self, reference_path: Path,
                         frame_paths: list[Path],
                         char_spec: CharacterSpec) -> ConsistencyEvaluation:
        """Check consistency across all selected frames."""
        eval_result = ConsistencyEvaluation()

        if not self.has_api:
            eval_result.feedback = "Manual consistency check required"
            return eval_result

        # Build message with all images
        content = [
            {
                "type": "text",
                "text": "REFERENCE IMAGE:"
            },
            {
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": "image/png",
                    "data": self._encode_image(reference_path)
                }
            },
            {
                "type": "text",
                "text": "ANIMATION FRAMES (in order):"
            }
        ]

        for i, path in enumerate(frame_paths):
            content.append({
                "type": "text",
                "text": f"Frame {i+1}:"
            })
            content.append({
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": "image/png",
                    "data": self._encode_image(path)
                }
            })

        content.append({
            "type": "text",
            "text": f"""Evaluate consistency across all these animation frames.

Character Specification:
- Description: {char_spec.description}
- Colors: {', '.join(char_spec.colors)}
- Key Features: {', '.join(char_spec.key_features)}

Check for:
1. Size consistency - are all characters the same size?
2. Color consistency - do colors match across frames?
3. Style consistency - same art style throughout?
4. Feature consistency - same face, body parts?

Provide JSON response:
{{
    "overall_score": <1-5, overall consistency>,
    "size_consistent": <true/false>,
    "color_consistent": <true/false>,
    "style_consistent": <true/false>,
    "problematic_frames": [<list of frame numbers with issues, 1-indexed>],
    "feedback": "detailed feedback on consistency issues"
}}

Be strict - list ALL frames that differ from the reference."""
        })

        messages = [{"role": "user", "content": content}]
        response = self._call_claude_api(messages, max_tokens=3000)

        try:
            start = response.find('{')
            end = response.rfind('}') + 1
            if start >= 0 and end > start:
                eval_dict = json.loads(response[start:end])
                eval_result.overall_score = eval_dict.get("overall_score", 0)
                eval_result.size_consistent = eval_dict.get("size_consistent", False)
                eval_result.color_consistent = eval_dict.get("color_consistent", False)
                eval_result.style_consistent = eval_dict.get("style_consistent", False)
                eval_result.problematic_frames = eval_dict.get("problematic_frames", [])
                eval_result.feedback = eval_dict.get("feedback", "")
        except json.JSONDecodeError:
            eval_result.feedback = response

        return eval_result

    def generate_evaluation_report(self, reference_path: Path,
                                   frame_paths: list[Path],
                                   output_path: Path) -> str:
        """Generate a human-readable evaluation report for manual review."""
        report = []
        report.append("=" * 60)
        report.append("ANIMATION FRAME EVALUATION REPORT")
        report.append("=" * 60)
        report.append(f"\nReference: {reference_path}")
        report.append(f"Frames to evaluate: {len(frame_paths)}")
        report.append("\nEVALUATION CRITERIA:")
        report.append("-" * 40)
        report.append("""
For each frame, evaluate on a scale of 1-5:

1. STYLE CONSISTENCY (weight: 40%)
   - Does it match the reference art style?
   - Same pixel density, line weight, shading?

2. QUALITY (weight: 30%)
   - Clean edges, no artifacts?
   - Proper transparency?
   - No blurry or deformed areas?

3. POSE CORRECTNESS (weight: 30%)
   - Does the pose match the animation sequence?
   - Natural motion flow?

SCORING GUIDE:
5 = Perfect match, no issues
4 = Minor issues, acceptable
3 = Notable issues, borderline
2 = Significant problems
1 = Major issues, reject
""")
        report.append("\nFRAMES TO EVALUATE:")
        report.append("-" * 40)

        for i, path in enumerate(frame_paths):
            report.append(f"\nFrame {i+1}: {path.name}")
            report.append(f"  Style Score:   ___/5")
            report.append(f"  Quality Score: ___/5")
            report.append(f"  Pose Score:    ___/5")
            report.append(f"  Issues: ")
            report.append(f"  Feedback: ")

        report.append("\n" + "=" * 60)
        report.append("CROSS-FRAME CONSISTENCY CHECK")
        report.append("=" * 60)
        report.append("""
Review all frames together:

1. Size Consistent?     [ ] Yes  [ ] No
2. Colors Consistent?   [ ] Yes  [ ] No
3. Style Consistent?    [ ] Yes  [ ] No

Problematic Frames: _______________

Overall Consistency Score: ___/5

Feedback:
""")

        report_text = "\n".join(report)

        with open(output_path, 'w') as f:
            f.write(report_text)

        return report_text


class AnimationPipeline:
    """Main pipeline orchestrator."""

    def __init__(self, reference_path: Path, output_dir: Path = OUTPUT_DIR):
        self.reference_path = reference_path
        self.output_dir = output_dir
        self.output_dir.mkdir(parents=True, exist_ok=True)

        self.comfy = ComfyUIClient()
        self.evaluator = LLMEvaluator()

        self.char_spec: Optional[CharacterSpec] = None
        self.ref_name: Optional[str] = None

    def define_swing_animation(self) -> list[dict]:
        """Define the pickaxe swing animation frames."""
        return [
            {
                "index": 0,
                "name": "ready",
                "prompt": "pixel art miner character, ready stance, standing straight, "
                         "holding pickaxe vertically at side, relaxed pose, facing right, "
                         "game sprite, centered, clean edges, white background"
            },
            {
                "index": 1,
                "name": "windup_start",
                "prompt": "pixel art miner character, starting wind up, lifting pickaxe, "
                         "arms beginning to raise, weight shifting back, facing right, "
                         "game sprite, centered, clean edges, white background"
            },
            {
                "index": 2,
                "name": "windup_mid",
                "prompt": "pixel art miner character, mid wind up, pickaxe raised to shoulder, "
                         "arms bent, preparing to swing, facing right, "
                         "game sprite, centered, clean edges, white background"
            },
            {
                "index": 3,
                "name": "windup_full",
                "prompt": "pixel art miner character, full wind up, pickaxe raised high overhead, "
                         "arms extended up, maximum height, about to swing, facing right, "
                         "game sprite, centered, clean edges, white background"
            },
            {
                "index": 4,
                "name": "swing_start",
                "prompt": "pixel art miner character, beginning swing, pickaxe starting downward, "
                         "arms swinging forward, dynamic pose, facing right, "
                         "game sprite, centered, clean edges, white background"
            },
            {
                "index": 5,
                "name": "swing_mid",
                "prompt": "pixel art miner character, mid swing, pickaxe at chest level, "
                         "arms extended forward, powerful motion, facing right, "
                         "game sprite, centered, clean edges, white background"
            },
            {
                "index": 6,
                "name": "swing_low",
                "prompt": "pixel art miner character, low swing, pickaxe near ground, "
                         "arms reaching down, about to impact, facing right, "
                         "game sprite, centered, clean edges, white background"
            },
            {
                "index": 7,
                "name": "impact",
                "prompt": "pixel art miner character, impact pose, pickaxe hitting ground, "
                         "slight crouch, follow through position, facing right, "
                         "game sprite, centered, clean edges, white background"
            }
        ]

    def run(self, num_candidates: int = 3, max_iterations: int = 3) -> Path:
        """Run the full pipeline."""
        print("=" * 60)
        print("VALIDATED ANIMATION PIPELINE")
        print("=" * 60)

        # Stage 1: Reference Analysis
        print("\n[Stage 1] Analyzing reference image...")
        self.char_spec = self.evaluator.analyze_reference(self.reference_path)
        print(f"  Character: {self.char_spec.description}")
        print(f"  Style: {self.char_spec.style}")
        print(f"  Colors: {', '.join(self.char_spec.colors)}")

        # Upload reference
        print("\n  Uploading reference to ComfyUI...")
        self.ref_name = self.comfy.upload_image(self.reference_path)
        print(f"  Uploaded as: {self.ref_name}")

        # Define animation frames
        animation = self.define_swing_animation()

        # Stage 2: Multi-Candidate Generation
        print(f"\n[Stage 2] Generating {num_candidates} candidates per frame...")
        candidates_dir = self.output_dir / "candidates"
        candidates_dir.mkdir(exist_ok=True)

        all_candidates: dict[int, list[Path]] = {}

        for frame_def in animation:
            idx = frame_def["index"]
            name = frame_def["name"]
            prompt = frame_def["prompt"]

            print(f"\n  Frame {idx} ({name}):")
            all_candidates[idx] = []

            for c in range(num_candidates):
                seed = 10000 + idx * 100 + c * 7
                output_path = candidates_dir / f"frame_{idx:02d}_{name}_c{c}.png"

                print(f"    Generating candidate {c+1}/{num_candidates}...", end=" ")
                try:
                    self.comfy.generate_frame(
                        self.ref_name, prompt, seed, output_path,
                        ipadapter_weight=0.95
                    )
                    all_candidates[idx].append(output_path)
                    print("Done")
                except Exception as e:
                    print(f"Failed: {e}")

        # Stage 3: Individual Frame Validation
        print(f"\n[Stage 3] Evaluating candidates...")
        selected_frames: dict[int, Path] = {}

        if self.evaluator.has_api:
            # Automated evaluation
            for idx, candidates in all_candidates.items():
                best_score = -1
                best_path = None

                for cand_path in candidates:
                    eval_result = self.evaluator.evaluate_frame(
                        self.reference_path, cand_path,
                        self.char_spec, idx,
                        animation[idx]["prompt"]
                    )

                    if eval_result.overall_score > best_score:
                        best_score = eval_result.overall_score
                        best_path = cand_path

                selected_frames[idx] = best_path
                print(f"  Frame {idx}: Selected {best_path.name} (score: {best_score:.2f})")
        else:
            # Manual mode - select first candidate and generate report
            print("  (Manual mode - selecting first candidate of each)")
            for idx, candidates in all_candidates.items():
                if candidates:
                    selected_frames[idx] = candidates[0]

            # Generate evaluation report
            report_path = self.output_dir / "evaluation_report.txt"
            frame_paths = [selected_frames[i] for i in sorted(selected_frames.keys())]
            self.evaluator.generate_evaluation_report(
                self.reference_path, frame_paths, report_path
            )
            print(f"\n  Generated evaluation report: {report_path}")
            print("  Please review and score the frames manually.")

        # Stage 4: Cross-Frame Consistency Check
        print(f"\n[Stage 4] Checking cross-frame consistency...")
        frame_paths = [selected_frames[i] for i in sorted(selected_frames.keys())]

        if self.evaluator.has_api:
            consistency = self.evaluator.check_consistency(
                self.reference_path, frame_paths, self.char_spec
            )
            print(f"  Overall consistency: {consistency.overall_score}/5")
            print(f"  Size consistent: {consistency.size_consistent}")
            print(f"  Color consistent: {consistency.color_consistent}")
            print(f"  Style consistent: {consistency.style_consistent}")

            if consistency.problematic_frames:
                print(f"  Problematic frames: {consistency.problematic_frames}")

                # Stage 5: Regeneration Loop
                print(f"\n[Stage 5] Regenerating problematic frames...")
                for iteration in range(max_iterations):
                    if not consistency.problematic_frames:
                        break

                    print(f"\n  Iteration {iteration + 1}/{max_iterations}")

                    for frame_num in consistency.problematic_frames:
                        idx = frame_num - 1  # Convert to 0-indexed
                        if idx < 0 or idx >= len(animation):
                            continue

                        print(f"    Regenerating frame {frame_num}...")

                        # Try with different parameters
                        new_seed = 50000 + idx * 100 + iteration * 17
                        new_weight = 0.97 + iteration * 0.01  # Increase weight

                        output_path = candidates_dir / f"frame_{idx:02d}_regen_{iteration}.png"

                        try:
                            self.comfy.generate_frame(
                                self.ref_name,
                                animation[idx]["prompt"],
                                new_seed,
                                output_path,
                                ipadapter_weight=min(new_weight, 1.0)
                            )

                            # Evaluate new candidate
                            eval_result = self.evaluator.evaluate_frame(
                                self.reference_path, output_path,
                                self.char_spec, idx,
                                animation[idx]["prompt"]
                            )

                            if eval_result.overall_score >= MIN_INDIVIDUAL_SCORE:
                                selected_frames[idx] = output_path
                                print(f"      Improved (score: {eval_result.overall_score:.2f})")
                            else:
                                print(f"      Still below threshold ({eval_result.overall_score:.2f})")
                        except Exception as e:
                            print(f"      Failed: {e}")

                    # Re-check consistency
                    frame_paths = [selected_frames[i] for i in sorted(selected_frames.keys())]
                    consistency = self.evaluator.check_consistency(
                        self.reference_path, frame_paths, self.char_spec
                    )

                    print(f"\n    New consistency score: {consistency.overall_score}/5")

                    if consistency.overall_score >= MIN_CONSISTENCY_SCORE:
                        print("    Consistency threshold met!")
                        break
        else:
            print("  (Manual mode - skipping automated consistency check)")

        # Stage 6: Final Assembly
        print(f"\n[Stage 6] Assembling final sprite sheet...")

        # Process frames (remove background, resize)
        from rembg import remove

        processed_frames = []
        final_size = (128, 128)

        for idx in sorted(selected_frames.keys()):
            path = selected_frames[idx]
            print(f"  Processing frame {idx}...")

            with open(path, 'rb') as f:
                img_data = f.read()

            # Remove background
            nobg_data = remove(img_data)

            # Resize
            img = Image.open(io.BytesIO(nobg_data))
            img = img.resize(final_size, Image.Resampling.NEAREST)

            processed_frames.append(img)

            # Save processed frame
            processed_path = self.output_dir / f"final_frame_{idx:02d}.png"
            img.save(processed_path, "PNG")

        # Create sprite sheet
        num_frames = len(processed_frames)
        sheet_width = final_size[0] * num_frames
        sheet_height = final_size[1]

        sprite_sheet = Image.new('RGBA', (sheet_width, sheet_height), (0, 0, 0, 0))

        for i, frame in enumerate(processed_frames):
            sprite_sheet.paste(frame, (i * final_size[0], 0))

        sheet_path = SPRITES_DIR / "miner_swing_validated.png"
        sprite_sheet.save(sheet_path, "PNG")

        print(f"\n{'=' * 60}")
        print(f"PIPELINE COMPLETE")
        print(f"{'=' * 60}")
        print(f"Sprite sheet saved: {sheet_path}")
        print(f"Size: {sprite_sheet.size}")
        print(f"Frames: {num_frames}")

        return sheet_path


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="Validated animation generation pipeline",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Run with automated validation (requires ANTHROPIC_API_KEY)
    %(prog)s reference.png --candidates 3

    # Run in manual mode
    %(prog)s reference.png --manual
"""
    )
    parser.add_argument("reference", help="Path to reference character image")
    parser.add_argument("--frames", type=int, default=8, help="Number of animation frames")
    parser.add_argument("--candidates", type=int, default=3, help="Candidates per frame")
    parser.add_argument("--iterations", type=int, default=3, help="Max regeneration iterations")
    parser.add_argument("--output", help="Output directory")
    parser.add_argument("--manual", action="store_true", help="Force manual evaluation mode")

    args = parser.parse_args()

    reference_path = Path(args.reference)
    if not reference_path.exists():
        reference_path = SPRITES_DIR / args.reference
        if not reference_path.exists():
            print(f"Error: Reference image not found: {args.reference}")
            sys.exit(1)

    output_dir = Path(args.output) if args.output else OUTPUT_DIR

    # Check ComfyUI
    try:
        urllib.request.urlopen(f"{COMFYUI_URL}/system_stats")
    except Exception:
        print("Error: ComfyUI is not running!")
        print("Start it with: cd ~/ComfyUI && /opt/homebrew/bin/python3.11 main.py")
        sys.exit(1)

    # Force manual mode if requested
    if args.manual:
        os.environ["ANTHROPIC_API_KEY"] = ""

    # Run pipeline
    pipeline = AnimationPipeline(reference_path, output_dir)
    pipeline.run(num_candidates=args.candidates, max_iterations=args.iterations)


if __name__ == "__main__":
    main()
