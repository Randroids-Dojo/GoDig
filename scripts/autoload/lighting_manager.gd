extends Node
## LightingManager autoload for depth-based ambient lighting.
##
## Controls ambient light levels and color tint based on player depth.
## Creates atmosphere and drives demand for helmet light upgrades.
## Uses layer-specific data for visual unfamiliarity gradient (Subnautica-inspired).
##
## Visual Design Philosophy:
## - Surface: Warm, inviting, HOME - players should feel comfort returning
## - Shallow: Still familiar, slight cooling begins
## - Mid-depths: Noticeably cooler, reduced visibility
## - Deep: Blue-gray alienation, low visibility
## - Extreme depths: Purple/void tones, maximum unfamiliarity

signal lighting_changed(ambient_level: float, tint: Color)
signal layer_changed(layer_id: String, display_name: String)
signal fog_changed(fog_intensity: float, fog_color: Color)

## Current lighting state
var current_depth: int = 0
var current_ambient: float = 1.0
var current_tint: Color = Color.WHITE
var current_zone: String = "surface"
var current_layer_id: String = ""

## Current fog state (from layer data)
var current_fog_intensity: float = 0.0
var current_fog_color: Color = Color(0.5, 0.5, 0.5, 0.5)

## Base ambient (before helmet bonus)
var base_ambient: float = 1.0

## CanvasModulate reference (created at runtime or assigned)
var _canvas_modulate: CanvasModulate = null

## Fog ColorRect reference (optional - for depth fog rendering)
var _fog_overlay: ColorRect = null

## Transition state
var _target_ambient: float = 1.0
var _target_tint: Color = Color.WHITE
var _target_fog_intensity: float = 0.0
var _target_fog_color: Color = Color(0.5, 0.5, 0.5, 0.5)
var _transition_speed: float = 2.0  # Lighting change speed
var _fog_transition_speed: float = 1.5  # Slower fog transitions for atmosphere

## Helmet light bonus (0.0 = no bonus, 300 = max light radius from Crystal Helm)
var _helmet_light_bonus: float = 0.0

## Surface warmth constants - surface should feel like HOME
const SURFACE_TINT := Color(1.0, 0.98, 0.95, 1.0)  # Slight warm amber
const SURFACE_AMBIENT := 1.0

## Unfamiliarity gradient multipliers
const DEPTH_AMBIENT_FALLOFF := 0.0008  # Ambient decrease per depth unit
const DEPTH_SATURATION_FALLOFF := 0.0005  # Color warmth decrease per depth unit


func _ready() -> void:
	# Connect to GameManager depth changes if available
	if GameManager:
		if GameManager.has_signal("depth_updated"):
			GameManager.connect("depth_updated", _on_depth_changed)
	# Connect to PlayerData equipment changes for helmet light bonus
	if PlayerData:
		if PlayerData.has_signal("equipment_changed"):
			PlayerData.connect("equipment_changed", _on_equipment_changed)
		# Initialize helmet bonus from current equipment
		_update_helmet_bonus()
	print("[LightingManager] Ready with layer-based unfamiliarity gradient")


func _process(delta: float) -> void:
	# Smoothly transition lighting
	if _canvas_modulate:
		if absf(current_ambient - _target_ambient) > 0.001 or not current_tint.is_equal_approx(_target_tint):
			current_ambient = lerpf(current_ambient, _target_ambient, _transition_speed * delta)
			current_tint = current_tint.lerp(_target_tint, _transition_speed * delta)
			_apply_lighting()

	# Smoothly transition fog
	if absf(current_fog_intensity - _target_fog_intensity) > 0.001 or not current_fog_color.is_equal_approx(_target_fog_color):
		current_fog_intensity = lerpf(current_fog_intensity, _target_fog_intensity, _fog_transition_speed * delta)
		current_fog_color = current_fog_color.lerp(_target_fog_color, _fog_transition_speed * delta)
		_apply_fog()


## Called when player depth changes
func _on_depth_changed(depth: int) -> void:
	update_depth(depth)


## Called when player equipment changes
func _on_equipment_changed(_slot: int, _equipment) -> void:
	_update_helmet_bonus()
	_recalculate_lighting()


## Update helmet light bonus from PlayerData
func _update_helmet_bonus() -> void:
	if PlayerData == null:
		_helmet_light_bonus = 0.0
		return
	_helmet_light_bonus = PlayerData.get_light_radius_bonus()


## Update lighting based on current depth
func update_depth(depth: int) -> void:
	current_depth = depth
	_recalculate_lighting()


## Recalculate target lighting based on depth using layer data
func _recalculate_lighting() -> void:
	var old_layer_id := current_layer_id

	# Get current layer from DataRegistry
	var layer = DataRegistry.get_layer_at_depth(current_depth) if DataRegistry else null

	if layer == null:
		# Fallback to surface settings if no layer data
		current_zone = "surface"
		current_layer_id = ""
		_target_ambient = SURFACE_AMBIENT
		_target_tint = SURFACE_TINT
		_target_fog_intensity = 0.0
		_target_fog_color = Color(0.5, 0.5, 0.5, 0.5)
	else:
		current_zone = layer.id
		current_layer_id = layer.id

		# Calculate ambient from layer's ambient_light_emission
		# Higher emission = more light, but we invert the "unfamiliarity" feel
		# Surface has high emission (0.3), deep has low emission (0.0-0.1)
		var layer_ambient := _calculate_layer_ambient(layer)
		_target_ambient = layer_ambient

		# Calculate tint from layer's color palette
		# Use the layer's color_shadow for environmental tinting (creates atmosphere)
		var layer_tint := _calculate_layer_tint(layer)
		_target_tint = layer_tint

		# Get fog settings directly from layer
		_target_fog_intensity = layer.fog_intensity
		_target_fog_color = layer.fog_color

		# Handle transition zones - blend between layers
		if layer.is_transition_zone(current_depth):
			var next_layer = DataRegistry.get_layer_at_depth(current_depth + 15)
			if next_layer != null and next_layer != layer:
				var transition_progress := _get_transition_progress(layer, current_depth)
				var next_ambient := _calculate_layer_ambient(next_layer)
				var next_tint := _calculate_layer_tint(next_layer)

				_target_ambient = lerpf(_target_ambient, next_ambient, transition_progress)
				_target_tint = _target_tint.lerp(next_tint, transition_progress)
				_target_fog_intensity = lerpf(_target_fog_intensity, next_layer.fog_intensity, transition_progress)
				_target_fog_color = _target_fog_color.lerp(next_layer.fog_color, transition_progress)

	# Store base ambient before helmet bonus
	base_ambient = _target_ambient

	# Apply helmet light bonus (helmet light_radius_bonus ranges from 50 to 300)
	# Convert to ambient boost: 50 = +0.1 ambient, 300 = +0.5 ambient
	if _helmet_light_bonus > 0:
		var helmet_boost := _helmet_light_bonus / 600.0  # 300 max / 600 = 0.5 max boost
		_target_ambient = minf(_target_ambient + helmet_boost, 1.0)

	# Emit signals for UI or other systems
	if old_layer_id != current_layer_id:
		var layer_name: String = layer.display_name if layer else "Surface"
		print("[LightingManager] Entered layer: %s at depth %d (ambient: %.2f, fog: %.2f)" % [
			current_layer_id, current_depth, _target_ambient, _target_fog_intensity
		])
		layer_changed.emit(current_layer_id, layer_name)

	lighting_changed.emit(_target_ambient, _target_tint)
	fog_changed.emit(_target_fog_intensity, _target_fog_color)


## Calculate ambient light level from layer data
## Creates the "unfamiliarity gradient" - surface bright and warm, depths dark and alien
func _calculate_layer_ambient(layer) -> float:
	# Base ambient from layer's ambient_light_emission
	# Surface (0.3) -> bright, Deep (0.0) -> very dark
	var base: float = 0.4 + layer.ambient_light_emission * 2.0  # Scale emission to 0.4-1.0 range

	# Apply depth-based falloff for increasing darkness
	var depth_into_layer: int = current_depth - layer.min_depth
	var depth_penalty: float = float(depth_into_layer) * DEPTH_AMBIENT_FALLOFF
	base = maxf(0.05, base - depth_penalty)

	# Special handling for glowing layers (crystal caves, magma)
	if layer.atmosphere_particles in ["embers", "crystal_sparkle"]:
		# These layers have environmental glow that provides some visibility
		base = maxf(base, 0.15 + layer.ambient_light_emission)

	return clampf(base, 0.05, 1.0)


## Calculate color tint from layer data
## Warm colors near surface, cool/alien colors in depths
func _calculate_layer_tint(layer) -> Color:
	# Start with white, then tint based on layer colors
	var tint := Color.WHITE

	# Use layer's color_shadow as base tint (it represents the "atmosphere" of the layer)
	var layer_tint: Color = layer.color_shadow

	# Normalize the layer tint to a reasonable brightness for modulation
	# We want it to tint, not darken dramatically
	var tint_strength := 0.3 + (float(current_depth) / 1500.0) * 0.4  # 0.3 at surface, 0.7 at depth 1500
	tint_strength = clampf(tint_strength, 0.3, 0.7)

	# Create a tint color that shifts white toward the layer's atmosphere
	# Surface layers should feel warm, deep layers should feel cool/alien
	var warm_factor := 1.0 - (float(current_depth) / 2000.0)  # 1.0 at surface, 0.0 at 2000
	warm_factor = clampf(warm_factor, 0.0, 1.0)

	# Blend between warm surface tint and layer's natural tint
	var surface_warmth := SURFACE_TINT
	var layer_coldness := Color(
		0.7 + layer_tint.r * 0.3,
		0.7 + layer_tint.g * 0.3,
		0.8 + layer_tint.b * 0.2,
		1.0
	)

	tint = surface_warmth.lerp(layer_coldness, 1.0 - warm_factor)

	# Special handling for magma zones - warm red glow
	if layer.atmosphere_particles == "embers" or layer.id == "magma_zone":
		tint = tint.lerp(Color(1.0, 0.85, 0.7, 1.0), 0.5)

	# Special handling for crystal caves - slight blue glow
	if layer.atmosphere_particles == "crystal_sparkle" or layer.id == "crystal_caves":
		tint = tint.lerp(Color(0.9, 0.95, 1.0, 1.0), 0.3)

	# Special handling for void - purple alienation
	if layer.id == "void_depths" or layer.id == "obsidian_core":
		tint = tint.lerp(Color(0.8, 0.7, 0.9, 1.0), 0.4)

	return tint


## Get transition progress within a layer's transition zone (0.0 to 1.0)
func _get_transition_progress(layer, depth: int) -> float:
	const TRANSITION_RANGE: int = 10
	var distance_to_end: int = layer.max_depth - depth
	if distance_to_end >= TRANSITION_RANGE:
		return 0.0
	return 1.0 - (float(distance_to_end) / float(TRANSITION_RANGE))


## Apply current lighting to CanvasModulate
func _apply_lighting() -> void:
	if _canvas_modulate:
		var final_color := current_tint * current_ambient
		_canvas_modulate.color = final_color


## Apply current fog settings to fog overlay
func _apply_fog() -> void:
	if _fog_overlay:
		var fog_color := current_fog_color
		fog_color.a = current_fog_intensity * 0.6  # Scale alpha by intensity
		_fog_overlay.color = fog_color
		_fog_overlay.visible = current_fog_intensity > 0.01


## Register a CanvasModulate node for lighting control
func register_canvas_modulate(modulate: CanvasModulate) -> void:
	_canvas_modulate = modulate
	_apply_lighting()


## Register a ColorRect node for fog overlay rendering
func register_fog_overlay(overlay: ColorRect) -> void:
	_fog_overlay = overlay
	_apply_fog()


## Set lighting immediately without transition (for loading saves)
func set_lighting_immediate(ambient: float, tint: Color) -> void:
	current_ambient = ambient
	current_tint = tint
	_target_ambient = ambient
	_target_tint = tint
	_apply_lighting()
	lighting_changed.emit(ambient, tint)


## Set fog immediately without transition (for loading saves)
func set_fog_immediate(intensity: float, fog_color: Color) -> void:
	current_fog_intensity = intensity
	current_fog_color = fog_color
	_target_fog_intensity = intensity
	_target_fog_color = fog_color
	_apply_fog()
	fog_changed.emit(intensity, fog_color)


## Get the current zone name for UI display
## Now uses layer data for dynamic names
func get_current_zone_name() -> String:
	if current_layer_id.is_empty():
		return "Surface"

	var layer = DataRegistry.get_layer(current_layer_id) if DataRegistry else null
	if layer:
		return layer.display_name

	# Fallback for legacy zone names
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


## Get current fog intensity (0.0 - 1.0)
func get_fog_intensity() -> float:
	return current_fog_intensity


## Get current fog color
func get_fog_color() -> Color:
	return current_fog_color


## Check if player is in a dark zone (needs helmet light)
func is_dark_zone() -> bool:
	return current_ambient < 0.3


## Check if player is in a foggy zone
func is_foggy_zone() -> bool:
	return current_fog_intensity > 0.15


## Get the current layer's visual description for atmosphere
func get_layer_description() -> String:
	if current_layer_id.is_empty():
		return "The familiar surface world above."

	var layer = DataRegistry.get_layer(current_layer_id) if DataRegistry else null
	if layer and not layer.visual_description.is_empty():
		return layer.visual_description

	return "Unknown depths..."


## Get the "unfamiliarity level" (0.0 = home, 1.0 = maximum alienation)
## Useful for UI and audio systems to adjust accordingly
func get_unfamiliarity_level() -> float:
	# Based on depth and layer characteristics
	var depth_factor := clampf(float(current_depth) / 1000.0, 0.0, 1.0)
	var ambient_factor := 1.0 - clampf(current_ambient, 0.0, 1.0)
	var fog_factor := clampf(current_fog_intensity * 2.0, 0.0, 1.0)

	# Combine factors with weights
	return clampf(depth_factor * 0.4 + ambient_factor * 0.4 + fog_factor * 0.2, 0.0, 1.0)


## Check if the player is near the surface (feels like "home")
func is_near_surface() -> bool:
	return current_depth < 50 or current_layer_id in ["topsoil", "clay"]
