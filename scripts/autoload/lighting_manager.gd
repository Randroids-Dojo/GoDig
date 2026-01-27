extends Node
## LightingManager autoload for depth-based ambient lighting.
##
## Controls ambient light levels and color tint based on player depth.
## Creates atmosphere and drives demand for helmet light upgrades.
## Lighting zones progress from surface daylight to deep darkness.

signal lighting_changed(ambient_level: float, tint: Color)

## Lighting zone definitions
const ZONES := {
	"surface": {"max_depth": 50, "ambient": 1.0, "tint": Color.WHITE},
	"shallow": {"max_depth": 200, "ambient": 0.8, "tint": Color.WHITE},
	"medium": {"max_depth": 500, "ambient": 0.5, "tint": Color(0.95, 0.95, 1.0)},
	"deep": {"max_depth": 1000, "ambient": 0.25, "tint": Color(0.9, 0.9, 1.0)},
	"dark": {"max_depth": 1500, "ambient": 0.1, "tint": Color(0.8, 0.8, 1.0)},
	"crystal": {"max_depth": 2000, "ambient": 0.15, "tint": Color(0.8, 0.9, 1.0)},
	"magma": {"max_depth": 3000, "ambient": 0.3, "tint": Color(1.0, 0.7, 0.5)},
	"void": {"max_depth": 999999, "ambient": 0.05, "tint": Color(0.7, 0.5, 0.8)},
}

## Current lighting state
var current_depth: int = 0
var current_ambient: float = 1.0
var current_tint: Color = Color.WHITE
var current_zone: String = "surface"

## CanvasModulate reference (created at runtime or assigned)
var _canvas_modulate: CanvasModulate = null

## Transition state
var _target_ambient: float = 1.0
var _target_tint: Color = Color.WHITE
var _transition_speed: float = 2.0  # Lighting change speed


func _ready() -> void:
	# Connect to GameManager depth changes if available
	if GameManager:
		if GameManager.has_signal("depth_updated"):
			GameManager.connect("depth_updated", _on_depth_changed)
	print("[LightingManager] Ready")


func _process(delta: float) -> void:
	# Smoothly transition lighting
	if _canvas_modulate:
		if absf(current_ambient - _target_ambient) > 0.001 or not current_tint.is_equal_approx(_target_tint):
			current_ambient = lerpf(current_ambient, _target_ambient, _transition_speed * delta)
			current_tint = current_tint.lerp(_target_tint, _transition_speed * delta)
			_apply_lighting()


## Called when player depth changes
func _on_depth_changed(depth: int) -> void:
	update_depth(depth)


## Update lighting based on current depth
func update_depth(depth: int) -> void:
	current_depth = depth
	_recalculate_lighting()


## Recalculate target lighting based on depth
func _recalculate_lighting() -> void:
	var old_zone := current_zone

	# Determine zone and calculate interpolated lighting
	if current_depth < 50:
		current_zone = "surface"
		_target_ambient = 1.0
		_target_tint = Color.WHITE
	elif current_depth < 200:
		current_zone = "shallow"
		var t := float(current_depth - 50) / 150.0
		_target_ambient = lerpf(1.0, 0.8, t)
		_target_tint = Color.WHITE
	elif current_depth < 500:
		current_zone = "medium"
		var t := float(current_depth - 200) / 300.0
		_target_ambient = lerpf(0.8, 0.5, t)
		_target_tint = Color.WHITE.lerp(Color(0.95, 0.95, 1.0), t)
	elif current_depth < 1000:
		current_zone = "deep"
		var t := float(current_depth - 500) / 500.0
		_target_ambient = lerpf(0.5, 0.25, t)
		_target_tint = Color(0.95, 0.95, 1.0).lerp(Color(0.9, 0.9, 1.0), t)
	elif current_depth < 1500:
		current_zone = "dark"
		var t := float(current_depth - 1000) / 500.0
		_target_ambient = lerpf(0.25, 0.1, t)
		_target_tint = Color(0.9, 0.9, 1.0).lerp(Color(0.8, 0.8, 1.0), t)
	elif current_depth < 2000:
		current_zone = "crystal"
		var t := float(current_depth - 1500) / 500.0
		_target_ambient = lerpf(0.1, 0.15, t)  # Slight increase from crystal glow
		_target_tint = Color(0.8, 0.8, 1.0).lerp(Color(0.8, 0.9, 1.0), t)
	elif current_depth < 3000:
		current_zone = "magma"
		var t := float(current_depth - 2000) / 1000.0
		_target_ambient = lerpf(0.15, 0.3, t)  # Red glow from lava
		_target_tint = Color(0.8, 0.9, 1.0).lerp(Color(1.0, 0.7, 0.5), t)
	else:
		current_zone = "void"
		_target_ambient = 0.05
		_target_tint = Color(0.7, 0.5, 0.8)  # Purple void

	# Emit signal for UI or other systems
	if old_zone != current_zone:
		print("[LightingManager] Entered zone: %s at depth %d" % [current_zone, current_depth])

	lighting_changed.emit(_target_ambient, _target_tint)


## Apply current lighting to CanvasModulate
func _apply_lighting() -> void:
	if _canvas_modulate:
		var final_color := current_tint * current_ambient
		_canvas_modulate.color = final_color


## Register a CanvasModulate node for lighting control
func register_canvas_modulate(modulate: CanvasModulate) -> void:
	_canvas_modulate = modulate
	_apply_lighting()


## Set lighting immediately without transition (for loading saves)
func set_lighting_immediate(ambient: float, tint: Color) -> void:
	current_ambient = ambient
	current_tint = tint
	_target_ambient = ambient
	_target_tint = tint
	_apply_lighting()
	lighting_changed.emit(ambient, tint)


## Get the current zone name for UI display
func get_current_zone_name() -> String:
	match current_zone:
		"surface": return "Surface"
		"shallow": return "Shallow Mines"
		"medium": return "Mining Tunnels"
		"deep": return "Deep Caves"
		"dark": return "The Depths"
		"crystal": return "Crystal Caverns"
		"magma": return "Magma Core"
		"void": return "The Void"
	return "Unknown"


## Get current ambient level (0.0 - 1.0)
func get_ambient_level() -> float:
	return current_ambient


## Check if player is in a dark zone (needs helmet light)
func is_dark_zone() -> bool:
	return current_ambient < 0.3
