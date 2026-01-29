class_name ArtifactData extends ItemData
## Resource class for artifact definitions.
## Artifacts are rare collectibles that can be found while mining.
## They don't stack and are displayed in the museum when collected.

## Unique display number for museum (1, 2, 3, etc.)
@export var museum_id: int = 0

## Era/period this artifact is from (for grouping in museum)
@export var era: String = "Unknown"

## Lore text about this artifact
@export var lore: String = ""

## Minimum depth where this artifact can spawn
@export var spawn_min_depth: int = 50

## Maximum depth where this artifact can spawn (0 = no max)
@export var spawn_max_depth: int = 0

## Spawn chance per block at valid depth (0.0001 = 1 in 10,000)
@export var spawn_chance: float = 0.0001


func _init() -> void:
	category = "artifact"
	max_stack = 1
	rarity = "legendary"
