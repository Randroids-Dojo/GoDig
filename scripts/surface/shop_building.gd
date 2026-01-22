extends Node2D
## Physical shop building on the surface
##
## Represents the shop where the player can sell resources and buy upgrades.
## When the player is near the building, they can interact with it to open
## the shop UI.

signal player_entered
signal player_exited

@onready var interaction_area: Area2D = $InteractionArea
@onready var label: Label = $Label

var player_nearby: bool = false

func _ready() -> void:
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_nearby = true
		player_entered.emit()
		if label:
			label.modulate = Color(1, 1, 0.5)  # Highlight when player is near

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_nearby = false
		player_exited.emit()
		if label:
			label.modulate = Color.WHITE

func is_player_nearby() -> bool:
	return player_nearby
