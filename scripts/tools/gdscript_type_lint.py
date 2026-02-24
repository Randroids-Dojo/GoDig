#!/usr/bin/env python3
"""
GDScript type inference linter.

Catches patterns like:
    @onready var foo: Node2D = $Foo
    var result := foo.some_method()   # ERROR on web/export

When a variable is typed as a base Godot class (not a class_name script),
GDScript 4.6 cannot infer the return type of method calls on it.
Use explicit types instead: `var result: bool = foo.some_method()`
"""

import re
import sys
from pathlib import Path

# Base Godot node/object types that don't carry script method return types
BASE_GODOT_TYPES = {
    "Node", "Node2D", "Node3D", "CanvasItem", "CanvasLayer",
    "Control", "Container", "BoxContainer", "VBoxContainer", "HBoxContainer",
    "GridContainer", "MarginContainer", "ScrollContainer", "PanelContainer",
    "FlowContainer", "SplitContainer", "HSplitContainer", "VSplitContainer",
    "TabContainer", "AspectRatioContainer", "SubViewportContainer", "CenterContainer",
    "Sprite2D", "Sprite3D", "AnimatedSprite2D", "AnimatedSprite3D",
    "Label", "RichTextLabel", "Button", "LinkButton", "CheckBox", "CheckButton",
    "OptionButton", "MenuButton", "SpinBox", "TextEdit", "LineEdit",
    "Panel", "TextureRect", "NinePatchRect", "ColorRect", "VideoStreamPlayer",
    "ProgressBar", "Slider", "HSlider", "VSlider", "ScrollBar",
    "Tree", "ItemList", "PopupMenu", "PopupPanel", "Window", "AcceptDialog",
    "ConfirmationDialog", "FileDialog", "SubViewport", "Viewport",
    "Camera2D", "Camera3D",
    "Area2D", "Area3D",
    "CollisionShape2D", "CollisionShape3D", "CollisionPolygon2D",
    "CharacterBody2D", "CharacterBody3D",
    "RigidBody2D", "RigidBody3D",
    "StaticBody2D", "StaticBody3D",
    "AnimatableBody2D", "AnimatableBody3D",
    "KinematicBody2D",  # Godot 3 compat name
    "PhysicsBody2D", "PhysicsBody3D",
    "TileMap", "TileMapLayer",
    "Path2D", "PathFollow2D", "Path3D", "PathFollow3D",
    "NavigationAgent2D", "NavigationAgent3D",
    "NavigationRegion2D", "NavigationRegion3D",
    "AnimationPlayer", "AnimationTree",
    "AudioStreamPlayer", "AudioStreamPlayer2D", "AudioStreamPlayer3D",
    "Timer", "Tween",
    "Line2D", "Polygon2D", "MeshInstance2D", "MeshInstance3D",
    "Light2D", "DirectionalLight2D", "PointLight2D",
    "GPUParticles2D", "GPUParticles3D", "CPUParticles2D", "CPUParticles3D",
    "RayCast2D", "RayCast3D", "ShapeCast2D", "ShapeCast3D",
    "MultiplayerSynchronizer", "MultiplayerSpawner",
    "WorldEnvironment", "Environment",
    "CanvasModulate", "BackBufferCopy",
    "RemoteTransform2D", "RemoteTransform3D",
    "Skeleton2D", "Bone2D",
    "TouchScreenButton",
}

# Built-in Godot methods that always have known return types — safe to use with :=
# These are inherited by all Node/Control subclasses; GDScript knows their signatures.
BUILTIN_METHODS = {
    # Node
    "get_node", "get_node_or_null", "find_child", "find_children",
    "get_child", "get_children", "get_parent", "get_owner",
    "get_tree", "get_viewport", "get_window", "get_multiplayer",
    "duplicate", "get_path", "get_path_to",
    "get_meta", "get_meta_list", "get_signal_list",
    "get_script", "get_class", "get_index", "get_child_count",
    # CanvasItem / Control
    "get_global_transform", "get_global_transform_with_canvas",
    "get_transform", "get_canvas_transform",
    "get_rect", "get_global_rect", "get_minimum_size", "get_combined_minimum_size",
    "get_focus_owner",
    # Object
    "get_instance_id", "get_property_list",
    # Tween / Timer
    "get_total_elapsed_time",
}

# Regex patterns
ONREADY_DECL = re.compile(
    r'@onready\s+var\s+(\w+)\s*:\s*(\w+)\s*='
)
VAR_DECL = re.compile(
    r'^\s*var\s+(\w+)\s*:\s*(\w+)\s*='
)
INFER_ASSIGN = re.compile(
    r'^\s*var\s+(\w+)\s*:=\s*(\w+)\.(\w+)\s*\('
)


def collect_base_typed_vars(lines: list[str]) -> dict[str, str]:
    """Return {var_name: godot_type} for vars typed as base Godot classes."""
    vars_: dict[str, str] = {}
    for line in lines:
        m = ONREADY_DECL.search(line)
        if m:
            name, typ = m.group(1), m.group(2)
            if typ in BASE_GODOT_TYPES:
                vars_[name] = typ
            continue
        m = VAR_DECL.search(line)
        if m:
            name, typ = m.group(1), m.group(2)
            if typ in BASE_GODOT_TYPES:
                vars_[name] = typ
    return vars_


def lint_file(path: Path) -> list[str]:
    """Return list of error strings for a single .gd file."""
    errors = []
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as e:
        return [f"{path}: cannot read: {e}"]

    base_vars = collect_base_typed_vars(lines)
    if not base_vars:
        return []

    for lineno, line in enumerate(lines, start=1):
        m = INFER_ASSIGN.match(line)
        if not m:
            continue
        result_var, obj_var, method = m.group(1), m.group(2), m.group(3)
        if obj_var in base_vars and method not in BUILTIN_METHODS:
            godot_type = base_vars[obj_var]
            errors.append(
                f"{path}:{lineno}: '{obj_var}' is typed as base class '{godot_type}' — "
                f"cannot infer return type of '{method}()'. "
                f"Use explicit type: `var {result_var}: <type> = {obj_var}.{method}(...)`"
            )

    return errors


def main(paths: list[str]) -> int:
    all_errors: list[str] = []

    if paths:
        files = [Path(p) for p in paths if p.endswith(".gd")]
    else:
        root = Path(__file__).parent.parent.parent
        files = list(root.rglob("*.gd"))

    for f in files:
        all_errors.extend(lint_file(f))

    if all_errors:
        print("GDScript type inference errors found:\n")
        for err in all_errors:
            print(f"  {err}")
        print(f"\n{len(all_errors)} error(s). Fix by adding explicit type annotations.")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
