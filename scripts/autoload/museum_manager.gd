extends Node
## Museum Manager - Tracks collected artifacts for the museum display.
##
## Artifacts are special collectibles found while mining. Once collected,
## they're added to the museum collection permanently. The museum displays
## all collected artifacts with their lore.

signal artifact_collected(artifact_id: String)
signal collection_updated

## Dictionary of collected artifact IDs -> first collection timestamp
var collected_artifacts: Dictionary = {}

## All available artifacts in the game (loaded from resources)
var _all_artifacts: Array = []


func _ready() -> void:
	# Load all artifact resources
	_load_artifacts()
	print("[MuseumManager] Ready - %d artifacts available" % _all_artifacts.size())


func _load_artifacts() -> void:
	## Load all artifact resources from the items folder
	_all_artifacts.clear()

	if DataRegistry == null:
		push_warning("[MuseumManager] DataRegistry not available")
		return

	# Get all items and filter for artifacts
	for item in DataRegistry.get_all_items():
		if item is ArtifactData:
			_all_artifacts.append(item)

	# Sort by museum_id
	_all_artifacts.sort_custom(func(a, b): return a.museum_id < b.museum_id)


## Check if an artifact has been collected
func is_collected(artifact_id: String) -> bool:
	return collected_artifacts.has(artifact_id)


## Mark an artifact as collected
func collect_artifact(artifact_id: String) -> void:
	if is_collected(artifact_id):
		return  # Already collected

	collected_artifacts[artifact_id] = Time.get_unix_time_from_system()
	artifact_collected.emit(artifact_id)
	collection_updated.emit()
	print("[MuseumManager] Artifact collected: %s" % artifact_id)


## Get the number of collected artifacts
func get_collected_count() -> int:
	return collected_artifacts.size()


## Get the total number of artifacts in the game
func get_total_count() -> int:
	return _all_artifacts.size()


## Get collection progress as a percentage (0.0 to 1.0)
func get_collection_progress() -> float:
	if _all_artifacts.size() == 0:
		return 0.0
	return float(collected_artifacts.size()) / float(_all_artifacts.size())


## Get all artifacts (for museum display)
func get_all_artifacts() -> Array:
	return _all_artifacts.duplicate()


## Get collected artifacts only
func get_collected_artifacts() -> Array:
	var result: Array = []
	for artifact in _all_artifacts:
		if is_collected(artifact.id):
			result.append(artifact)
	return result


## Get artifact data by ID
func get_artifact(artifact_id: String) -> ArtifactData:
	for artifact in _all_artifacts:
		if artifact.id == artifact_id:
			return artifact
	return null


## Check if an artifact can spawn at a given depth
func can_artifact_spawn_at_depth(artifact: ArtifactData, depth: int) -> bool:
	if artifact == null:
		return false
	if depth < artifact.spawn_min_depth:
		return false
	if artifact.spawn_max_depth > 0 and depth > artifact.spawn_max_depth:
		return false
	return true


## Roll for artifact spawn at a given position and depth
## Returns the artifact ID if one spawns, empty string otherwise
func roll_artifact_spawn(grid_pos: Vector2i, depth: int) -> String:
	# Use position as seed for deterministic randomness
	var seed_value := grid_pos.x * 10000 + grid_pos.y + depth * 100
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	for artifact in _all_artifacts:
		if not can_artifact_spawn_at_depth(artifact, depth):
			continue

		# Already collected artifacts are still spawnable (for selling)
		var roll := rng.randf()
		if roll < artifact.spawn_chance:
			return artifact.id

	return ""


## Save collection data to a dictionary (for SaveManager)
func save_data() -> Dictionary:
	return {
		"collected_artifacts": collected_artifacts.duplicate()
	}


## Load collection data from a dictionary (from SaveManager)
func load_data(data: Dictionary) -> void:
	if data.has("collected_artifacts"):
		collected_artifacts = data["collected_artifacts"].duplicate()
	else:
		collected_artifacts.clear()
	collection_updated.emit()
	print("[MuseumManager] Loaded %d collected artifacts" % collected_artifacts.size())


## Clear all collection data (for new game)
func clear_collection() -> void:
	collected_artifacts.clear()
	collection_updated.emit()
