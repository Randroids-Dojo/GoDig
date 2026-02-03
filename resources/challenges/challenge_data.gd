class_name ChallengeData extends Resource
## Resource class for defining challenge run modifiers.
##
## Challenges are optional difficulty modifiers that experienced players
## can enable for challenge runs, inspired by Hades' Pact of Punishment.

## Unique identifier for this challenge
@export var id: String = ""

## Display name shown in UI
@export var display_name: String = ""

## Description of what the modifier does
@export var description: String = ""

## Challenge tier (1-3, affects reward type)
## Tier 1: Cosmetic rewards (recolors)
## Tier 2: Special pickaxe skins
## Tier 3: Rare badges/titles
@export_range(1, 3) var tier: int = 1

## Icon for the challenge (optional)
@export var icon: Texture2D = null

## Whether this challenge can be combined with others
@export var stackable: bool = true

## List of challenge IDs that cannot be used with this one
@export var incompatible_with: Array[String] = []

## Reward ID unlocked when completing this challenge
@export var reward_id: String = ""

## Reward description for display
@export var reward_description: String = ""

## Challenge-specific parameters
## Used by ChallengeManager to configure the modifier
@export var parameters: Dictionary = {}


## Get the tier color for UI display
func get_tier_color() -> Color:
	match tier:
		1:
			return Color(0.6, 0.8, 0.6)  # Green - common
		2:
			return Color(0.6, 0.6, 1.0)  # Blue - rare
		3:
			return Color(1.0, 0.8, 0.4)  # Gold - legendary
		_:
			return Color.WHITE


## Get the tier name for display
func get_tier_name() -> String:
	match tier:
		1:
			return "Common"
		2:
			return "Rare"
		3:
			return "Legendary"
		_:
			return "Unknown"


## Check if this challenge is compatible with another
func is_compatible_with(other_id: String) -> bool:
	return other_id not in incompatible_with


## Create a simple challenge programmatically
static func create(
	p_id: String,
	p_display_name: String,
	p_description: String,
	p_tier: int = 1,
	p_parameters: Dictionary = {}
) -> Resource:
	var script = load("res://resources/challenges/challenge_data.gd")
	var challenge = script.new()
	challenge.id = p_id
	challenge.display_name = p_display_name
	challenge.description = p_description
	challenge.tier = p_tier
	challenge.parameters = p_parameters
	challenge.reward_id = "reward_%s" % p_id
	return challenge
