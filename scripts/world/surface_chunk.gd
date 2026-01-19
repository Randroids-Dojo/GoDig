class_name SurfaceChunk
extends RefCounted

## Data for a single surface chunk
## Surface chunks represent horizontal segments of the ground level
## where buildings can be placed and players can walk

var chunk_x: int = 0
var tiles: Dictionary = {}  # Vector2i (local) -> tile_type
var building_slot: int = -1  # Building slot index if chunk has one
var has_building: bool = false
