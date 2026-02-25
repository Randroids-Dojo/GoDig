extends Button
## InventorySlot - A single slot in the inventory grid.
##
## Displays an item icon, quantity, and rarity border.
## Emits slot_pressed when tapped for selection.

signal slot_pressed(slot_index: int)

const _TERRAIN_ATLAS := preload("res://resources/tileset/terrain_atlas.png")

## Preloaded item icons for web export compatibility.
## Runtime load() can fail in WASM builds; preload() ensures textures are packed.
const _ITEM_ICONS := {
	"ladder": preload("res://resources/icons/items/ladder.png"),
	"rope": preload("res://resources/icons/items/rope.png"),
	"teleport_scroll": preload("res://resources/icons/items/teleport_scroll.png"),
	"fossil_common": preload("res://resources/icons/items/fossil_common.png"),
	"fossil_rare": preload("res://resources/icons/items/fossil_rare.png"),
	"fossil_legendary": preload("res://resources/icons/items/fossil_legendary.png"),
	"fossil_amber": preload("res://resources/icons/items/fossil_amber.png"),
	"artifact_ancient_coin": preload("res://resources/icons/items/artifact_ancient_coin.png"),
	"artifact_crystal_skull": preload("res://resources/icons/items/artifact_crystal_skull.png"),
	"artifact_fossilized_crown": preload("res://resources/icons/items/artifact_fossilized_crown.png"),
	"artifact_obsidian_tablet": preload("res://resources/icons/items/artifact_obsidian_tablet.png"),
}

@export var slot_index: int = 0

@onready var item_icon: TextureRect = $Icon
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
	if item_icon:
		var tex = _resolve_item_icon(item)
		if tex:
			item_icon.texture = tex
			item_icon.visible = true
		else:
			item_icon.visible = false

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

	if item_icon:
		item_icon.visible = false

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


func _get_rarity_color(rarity) -> Color:
	## Get border color based on item rarity (supports string or int)
	if rarity is String:
		match rarity:
			"common": return Color.GRAY
			"uncommon": return Color.GREEN
			"rare": return Color.BLUE
			"epic": return Color.PURPLE
			"legendary": return Color.ORANGE
			_: return Color.WHITE
	else:
		# Legacy int support
		match rarity:
			0: return Color.GRAY       # Common
			1: return Color.GREEN      # Uncommon
			2: return Color.BLUE       # Rare
			3: return Color.PURPLE     # Epic
			4: return Color.ORANGE     # Legendary
			_: return Color.WHITE


func _resolve_item_icon(item) -> Texture2D:
	## Return the best available icon for an item.
	## Priority: explicit icon → preloaded icon dict → atlas tile (ores) → null

	if item.icon != null:
		return item.icon

	# Preloaded icon lookup (web-safe: avoids runtime load() in WASM)
	var item_id: String = item.id
	if _ITEM_ICONS.has(item_id):
		return _ITEM_ICONS[item_id]

	# Ores and other tiles with atlas coordinates
	var coords = item.get("tile_atlas_coords")
	if coords != null:
		var atlas_tex := AtlasTexture.new()
		atlas_tex.atlas = _TERRAIN_ATLAS
		atlas_tex.region = Rect2(coords.x * 128, coords.y * 128, 128, 128)
		return atlas_tex

	return null


func _on_pressed() -> void:
	slot_pressed.emit(slot_index)
