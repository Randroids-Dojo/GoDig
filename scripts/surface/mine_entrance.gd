extends Node2D
## Mine entrance visual indicator
##
## Shows where the underground mine begins. This is a visual indicator
## showing the player where they can enter the mine to start digging.

@onready var entrance_rect: ColorRect = $EntranceRect
@onready var label: Label = $Label

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	# Optional: Add subtle animation or glow effect
	pass
