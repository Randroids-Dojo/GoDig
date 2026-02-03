class_name MultiMeshPool
extends Node2D
## Reusable MultiMesh pooling system for efficiently rendering many similar sprites.
##
## Reduces draw calls by batching identical sprites into a single MultiMeshInstance2D.
## Supports per-instance transform, color, and custom data via shaders.
##
## Usage:
##   var pool := MultiMeshPool.new()
##   pool.texture = my_texture
##   pool.pool_size = 500
##   pool.sprite_size = Vector2(16, 16)
##   add_child(pool)
##
##   var index := pool.acquire()
##   pool.set_position(index, Vector2(100, 200))
##   pool.release(index)  # When done

## Emitted when an instance is activated
signal instance_activated(index: int)

## Emitted when an instance is deactivated
signal instance_deactivated(index: int)

## Maximum number of instances in the pool
@export var pool_size: int = 200

## Texture to use for all instances
@export var texture: Texture2D

## Size of each sprite (quad mesh size)
@export var sprite_size: Vector2 = Vector2(16, 16)

## Optional shader material for custom effects
@export var shader_material: ShaderMaterial

var _multimesh: MultiMesh
var _instance_node: MultiMeshInstance2D
var _active_indices: Array[int] = []
var _available_indices: Array[int] = []

## Position used to "hide" inactive instances (moved off-screen)
const OFF_SCREEN := Vector2(-100000, -100000)


func _ready() -> void:
	_initialize_pool()


func _initialize_pool() -> void:
	## Create and configure the MultiMesh and instance node

	# Create quad mesh for 2D sprites
	var mesh := QuadMesh.new()
	mesh.size = sprite_size

	# Create MultiMesh resource
	_multimesh = MultiMesh.new()
	_multimesh.mesh = mesh
	_multimesh.transform_format = MultiMesh.TRANSFORM_2D
	_multimesh.use_custom_data = true  # For per-instance color/data
	_multimesh.instance_count = pool_size

	# Create the visual instance node
	_instance_node = MultiMeshInstance2D.new()
	_instance_node.multimesh = _multimesh
	_instance_node.texture = texture

	# Apply optional shader material to the node (NOT the mesh)
	if shader_material != null:
		_instance_node.material = shader_material

	add_child(_instance_node)

	# Initialize all instances as hidden (off-screen) and available
	for i in pool_size:
		_available_indices.append(i)
		_multimesh.set_instance_transform_2d(i, Transform2D(0.0, OFF_SCREEN))
		_multimesh.set_instance_custom_data(i, Color(1, 1, 1, 0))  # Fully transparent


func acquire() -> int:
	## Acquire an instance from the pool.
	## Returns the instance index, or -1 if pool is exhausted.
	if _available_indices.is_empty():
		push_warning("MultiMeshPool exhausted! Pool size: %d" % pool_size)
		return -1

	var index := _available_indices.pop_back()
	_active_indices.append(index)
	instance_activated.emit(index)
	return index


func release(index: int) -> void:
	## Release an instance back to the pool
	if index < 0 or index >= pool_size:
		return

	var active_pos := _active_indices.find(index)
	if active_pos == -1:
		return  # Already released

	_active_indices.remove_at(active_pos)
	_available_indices.append(index)

	# Hide the instance by moving off-screen and making transparent
	_multimesh.set_instance_transform_2d(index, Transform2D(0.0, OFF_SCREEN))
	_multimesh.set_instance_custom_data(index, Color(1, 1, 1, 0))

	instance_deactivated.emit(index)


func set_transform(index: int, transform: Transform2D) -> void:
	## Set full transform for an instance
	_multimesh.set_instance_transform_2d(index, transform)


func get_transform(index: int) -> Transform2D:
	## Get current transform for an instance
	return _multimesh.get_instance_transform_2d(index)


func set_position(index: int, pos: Vector2) -> void:
	## Set position while preserving rotation/scale
	var current := _multimesh.get_instance_transform_2d(index)
	current.origin = pos
	_multimesh.set_instance_transform_2d(index, current)


func get_position(index: int) -> Vector2:
	## Get position of an instance
	return _multimesh.get_instance_transform_2d(index).origin


func set_scale_uniform(index: int, scale: float) -> void:
	## Set uniform scale for an instance
	var current := _multimesh.get_instance_transform_2d(index)
	current = Transform2D(current.get_rotation(), current.origin)
	current = current.scaled(Vector2(scale, scale))
	_multimesh.set_instance_transform_2d(index, current)


func set_custom_data(index: int, data: Color) -> void:
	## Set custom data (accessible as INSTANCE_CUSTOM in shaders)
	## Commonly used for color, UV offset, or animation frame
	_multimesh.set_instance_custom_data(index, data)


func get_custom_data(index: int) -> Color:
	## Get custom data for an instance
	return _multimesh.get_instance_custom_data(index)


func set_color(index: int, color: Color) -> void:
	## Convenience method to set instance color via custom data
	_multimesh.set_instance_custom_data(index, color)


func get_active_count() -> int:
	## Get number of currently active instances
	return _active_indices.size()


func get_available_count() -> int:
	## Get number of available instances in pool
	return _available_indices.size()


func is_active(index: int) -> bool:
	## Check if an instance is currently active
	return index in _active_indices


func for_each_active(callback: Callable) -> void:
	## Execute a callback for each active instance
	## Callback receives: func(index: int) -> void
	for index in _active_indices:
		callback.call(index)


func get_active_indices() -> Array[int]:
	## Get a copy of active indices array (for iteration without modification issues)
	return _active_indices.duplicate()


func release_all() -> void:
	## Release all active instances back to the pool
	var to_release := _active_indices.duplicate()
	for index in to_release:
		release(index)
