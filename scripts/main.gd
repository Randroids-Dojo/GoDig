extends Control
## Main scene script for GoDig
##
## Hello world placeholder scene.

@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	print("[Main] Scene ready")
	_update_status("Game initialized!")


func _update_status(text: String) -> void:
	if status_label:
		status_label.text = text


func get_title() -> String:
	return "GoDig"


func get_status() -> String:
	if status_label:
		return status_label.text
	return ""
