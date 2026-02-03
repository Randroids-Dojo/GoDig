class_name OreSparkleManager
extends Node2D
## Centralized manager for ore sparkle effects using MultiMesh batching.
##
## Replaces individual CPUParticles2D nodes with a single MultiMeshInstance2D
## that renders all sparkles in one draw call. Sparkles are pooled and reused.
##
## This provides significant performance improvements when many ore blocks are visible:
## - Individual sparkle nodes: ~100 draw calls for 100 ores
## - MultiMesh approach: 1 draw call for all sparkles
##
## Usage:
##   # Add to scene (typically as child of DirtGrid or Main)
##   var manager := OreSparkleManager.new()
##   add_child(manager)
##
##   # Register ore block sparkles
##   manager.register_sparkle(grid_pos, world_pos, ore_color, rarity)
##   manager.unregister_sparkle(grid_pos)

const BLOCK_SIZE := 128
const MAX_SPARKLES := 300
const SPARKLE_SIZE := Vector2(8, 8)

## Sparkle lifetime for animation
const SPARKLE_LIFETIME := 0.5

## Base interval between sparkles (modified by rarity)
const BASE_INTERVAL := 3.0

## Data for each registered ore block
## Key: Vector2i grid position
## Value: Dictionary with sparkle configuration
var _registered_ores: Dictionary = {}

## Data for each active sparkle particle
## Key: int pool index
## Value: Dictionary with animation state
var _active_sparkles: Dictionary = {}

## Pool indices that are emitting for each ore position
## Key: Vector2i grid position
## Value: Array of pool indices currently active for this ore
var _ore_active_sparkles: Dictionary = {}

## The MultiMesh pool for sparkle sprites
var _sparkle_pool: MultiMeshPool

## Timers for each registered ore (when to emit next sparkle)
## Key: Vector2i grid position
## Value: float time until next sparkle
var _sparkle_timers: Dictionary = {}

## Simple white texture for sparkles (can be replaced with actual sparkle sprite)
var _sparkle_texture: Texture2D


func _ready() -> void:
	_setup_sparkle_pool()


func _setup_sparkle_pool() -> void:
	## Initialize the MultiMesh pool for sparkles

	# Create a simple white square texture for sparkles
	_sparkle_texture = _create_sparkle_texture()

	# Create and configure the pool
	_sparkle_pool = MultiMeshPool.new()
	_sparkle_pool.pool_size = MAX_SPARKLES
	_sparkle_pool.sprite_size = SPARKLE_SIZE
	_sparkle_pool.texture = _sparkle_texture
	add_child(_sparkle_pool)

	# Set z-index to render above blocks
	_sparkle_pool.z_index = 10


func _create_sparkle_texture() -> ImageTexture:
	## Create a simple radial gradient texture for sparkles
	var size := 8
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)

	var center := Vector2(size / 2.0, size / 2.0)
	var max_dist := center.length()

	for x in size:
		for y in size:
			var pos := Vector2(x + 0.5, y + 0.5)
			var dist := pos.distance_to(center)
			var alpha := 1.0 - (dist / max_dist)
			alpha = clampf(alpha * 1.5, 0.0, 1.0)  # Boost center brightness
			image.set_pixel(x, y, Color(1, 1, 1, alpha))

	var texture := ImageTexture.create_from_image(image)
	return texture


func _process(delta: float) -> void:
	# Skip processing if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		return

	# Update sparkle timers and emit new sparkles
	_update_sparkle_timers(delta)

	# Animate active sparkles
	_update_active_sparkles(delta)


func _update_sparkle_timers(delta: float) -> void:
	## Update timers for each registered ore and emit sparkles when ready
	for grid_pos: Vector2i in _sparkle_timers.keys():
		_sparkle_timers[grid_pos] -= delta

		if _sparkle_timers[grid_pos] <= 0.0:
			# Time to emit a sparkle
			_emit_sparkle(grid_pos)

			# Reset timer with randomized interval based on rarity
			var ore_data: Dictionary = _registered_ores.get(grid_pos, {})
			var rarity: int = ore_data.get("rarity", 0)
			_sparkle_timers[grid_pos] = _get_random_interval(rarity)


func _emit_sparkle(grid_pos: Vector2i) -> void:
	## Emit a sparkle particle for the given ore position
	if not _registered_ores.has(grid_pos):
		return

	var ore_data: Dictionary = _registered_ores[grid_pos]
	var world_pos: Vector2 = ore_data.get("world_pos", Vector2.ZERO)
	var ore_color: Color = ore_data.get("color", Color.WHITE)
	var rarity: int = ore_data.get("rarity", 0)

	# Try to acquire a sparkle from the pool
	var index := _sparkle_pool.acquire()
	if index == -1:
		return  # Pool exhausted

	# Randomize position within the block
	var offset := Vector2(
		randf_range(-BLOCK_SIZE * 0.3, BLOCK_SIZE * 0.3),
		randf_range(-BLOCK_SIZE * 0.3, BLOCK_SIZE * 0.3)
	)
	var start_pos := world_pos + offset

	# Set initial position
	_sparkle_pool.set_position(index, start_pos)

	# Set color with brightness boost based on rarity
	var brightness_boost := 0.1 + (rarity * 0.1)
	var sparkle_color := ore_color.lightened(brightness_boost)
	_sparkle_pool.set_color(index, sparkle_color)

	# Initialize animation state
	_active_sparkles[index] = {
		"start_pos": start_pos,
		"time": 0.0,
		"color": sparkle_color,
		"grid_pos": grid_pos,
	}

	# Track which sparkles belong to this ore
	if not _ore_active_sparkles.has(grid_pos):
		_ore_active_sparkles[grid_pos] = []
	_ore_active_sparkles[grid_pos].append(index)


func _update_active_sparkles(delta: float) -> void:
	## Update animation for all active sparkles
	var to_release: Array[int] = []

	for index: int in _active_sparkles.keys():
		var data: Dictionary = _active_sparkles[index]
		data["time"] += delta

		var progress: float = data["time"] / SPARKLE_LIFETIME

		if progress >= 1.0:
			# Sparkle finished - mark for release
			to_release.append(index)
		else:
			# Animate: float upward and fade out
			var start_pos: Vector2 = data["start_pos"]
			var new_pos := start_pos + Vector2(0, -20.0 * progress)

			# Scale: grow then shrink
			var scale_curve: float
			if progress < 0.3:
				scale_curve = progress / 0.3  # Grow to full size
			else:
				scale_curve = 1.0 - ((progress - 0.3) / 0.7)  # Shrink

			# Alpha: full then fade
			var alpha: float
			if progress < 0.5:
				alpha = 1.0
			else:
				alpha = 1.0 - ((progress - 0.5) / 0.5)

			# Apply animation
			_sparkle_pool.set_position(index, new_pos)
			_sparkle_pool.set_scale_uniform(index, 0.5 + scale_curve * 0.5)

			var base_color: Color = data["color"]
			_sparkle_pool.set_color(index, Color(base_color.r, base_color.g, base_color.b, alpha))

	# Release finished sparkles
	for index in to_release:
		_release_sparkle(index)


func _release_sparkle(index: int) -> void:
	## Release a sparkle back to the pool and clean up tracking
	if not _active_sparkles.has(index):
		return

	var data: Dictionary = _active_sparkles[index]
	var grid_pos: Vector2i = data.get("grid_pos", Vector2i.ZERO)

	# Remove from ore's active sparkles list
	if _ore_active_sparkles.has(grid_pos):
		var ore_sparkles: Array = _ore_active_sparkles[grid_pos]
		var idx := ore_sparkles.find(index)
		if idx >= 0:
			ore_sparkles.remove_at(idx)

	# Clean up
	_active_sparkles.erase(index)
	_sparkle_pool.release(index)


func _get_random_interval(rarity: int) -> float:
	## Get random interval between sparkles based on ore rarity
	## Higher rarity = more frequent sparkles
	match rarity:
		0:  # Common
			return randf_range(3.0, 5.0)
		1:  # Uncommon
			return randf_range(2.0, 4.0)
		2:  # Rare
			return randf_range(1.5, 3.0)
		3:  # Epic
			return randf_range(1.0, 2.0)
		_:  # Legendary or higher
			return randf_range(0.5, 1.5)


# ============================================
# PUBLIC API
# ============================================

func register_sparkle(grid_pos: Vector2i, world_pos: Vector2, ore_color: Color, rarity: int, _symbol: String = "") -> void:
	## Register an ore block to receive sparkle effects.
	## Call this when an ore block becomes visible/active.
	if _registered_ores.has(grid_pos):
		return  # Already registered

	_registered_ores[grid_pos] = {
		"world_pos": world_pos,
		"color": ore_color,
		"rarity": rarity,
		"symbol": _symbol,  # Reserved for future colorblind support
	}

	# Initialize timer with random offset so not all sparkle at once
	_sparkle_timers[grid_pos] = randf() * _get_random_interval(rarity)


func unregister_sparkle(grid_pos: Vector2i) -> void:
	## Unregister an ore block from sparkle effects.
	## Call this when an ore block is destroyed or unloaded.
	if not _registered_ores.has(grid_pos):
		return

	# Release any active sparkles for this ore
	if _ore_active_sparkles.has(grid_pos):
		var sparkle_indices: Array = _ore_active_sparkles[grid_pos].duplicate()
		for index in sparkle_indices:
			_release_sparkle(index)
		_ore_active_sparkles.erase(grid_pos)

	# Clean up registration
	_registered_ores.erase(grid_pos)
	_sparkle_timers.erase(grid_pos)


func update_world_pos(grid_pos: Vector2i, world_pos: Vector2) -> void:
	## Update the world position for a registered ore block.
	## Call this if the block's position changes (shouldn't happen often).
	if _registered_ores.has(grid_pos):
		_registered_ores[grid_pos]["world_pos"] = world_pos


func get_registered_count() -> int:
	## Get number of registered ore blocks
	return _registered_ores.size()


func get_active_sparkle_count() -> int:
	## Get number of currently animating sparkles
	return _active_sparkles.size()


func clear_all() -> void:
	## Clear all registered ores and active sparkles
	_sparkle_pool.release_all()
	_registered_ores.clear()
	_sparkle_timers.clear()
	_active_sparkles.clear()
	_ore_active_sparkles.clear()
