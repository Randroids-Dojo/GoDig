extends Button
## InventorySlot - A single slot in the inventory grid.
##
## Displays an item icon, quantity, and rarity border.
## Emits slot_pressed when tapped for selection.

signal slot_pressed(slot_index: int)

@export var slot_index: int = 0

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel
@onready var border: Panel = $Border

var current_item = null  # ItemData


func _ready() -> void:
	pressed.connect(_on_pressed)
	display_empty()


func display_item(item, quantity: int) -> void:
	## Show an item in this slot
	current_item = item

	# Show icon if available
	if icon:
		if item.icon != null:
			icon.texture = item.icon
			icon.visible = true
		else:
			# Fallback: create a colored rect as placeholder
			icon.visible = false

	# Show quantity if > 1
	if quantity_label:
		if quantity > 1:
			quantity_label.text = str(quantity)
			quantity_label.visible = true
		else:
			quantity_label.visible = false

	# Set border color based on rarity
	if border:
		var rarity_color := _get_rarity_color(item.rarity if "rarity" in item else 0)
		border.modulate = rarity_color


func display_empty() -> void:
	## Clear the slot display
	current_item = null

	if icon:
		icon.visible = false

	if quantity_label:
		quantity_label.visible = false

	if border:
		border.modulate = Color(0.3, 0.3, 0.3, 0.5)  # Dim gray


func set_selected(selected: bool) -> void:
	## Visual feedback for selection state
	if selected:
		modulate = Color(1.2, 1.2, 1.2)  # Slight brighten
	else:
		modulate = Color.WHITE


func _get_rarity_color(rarity: int) -> Color:
	## Get border color based on item rarity
	match rarity:
		0: return Color.GRAY       # Common
		1: return Color.GREEN      # Uncommon
		2: return Color.BLUE       # Rare
		3: return Color.PURPLE     # Epic
		4: return Color.ORANGE     # Legendary
		_: return Color.WHITE


func _on_pressed() -> void:
	slot_pressed.emit(slot_index)
