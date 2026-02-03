class_name LoreData extends ItemData
## Resource class for discoverable lore entries (journals, artifacts).
## Lore items are collectible text snippets that tell stories of the underground.
## Collected lore is viewable in the Journal screen from the museum.

## Unique lore entry number (Journal Entry #1, #2, etc.)
@export var entry_number: int = 1

## Lore type: "journal", "artifact_note", "message"
@export var lore_type: String = "journal"

## The main lore text content (the story/message)
@export var content: String = ""

## Author/attribution (e.g., "Unknown Miner", "Ancient Scrawl")
@export var author: String = "Unknown"

## Era/time period this lore is from (for grouping/sorting)
@export var era: String = "Unknown Era"

## Minimum depth where this lore can spawn
@export var spawn_min_depth: int = 20

## Maximum depth where this lore can spawn (0 = no max)
@export var spawn_max_depth: int = 0

## Spawn chance per chunk at valid depth (0.001 = 0.1% per chunk)
@export var spawn_chance: float = 0.001


func _init() -> void:
	category = "lore"
	max_stack = 1
	rarity = "uncommon"


## Check if this lore can spawn at a given depth
func can_spawn_at_depth(depth: int) -> bool:
	if depth < spawn_min_depth:
		return false
	if spawn_max_depth > 0 and depth > spawn_max_depth:
		return false
	return true


## Get a display string for the entry header
func get_header() -> String:
	if lore_type == "journal":
		return "Journal Entry #%d" % entry_number
	elif lore_type == "artifact_note":
		return "Artifact Note #%d" % entry_number
	else:
		return "Message #%d" % entry_number


## Get a short preview of the content for lists
func get_preview(max_length: int = 50) -> String:
	if content.length() <= max_length:
		return content
	return content.substr(0, max_length - 3) + "..."
