extends Control
## JournalScreen - UI for reading collected journal entries.
##
## Shows a list of collected lore entries with their content.
## Uncollected entries appear as "???" until found.
## Can be accessed from the museum or pause menu.

signal closed

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/VBox/Header/TitleLabel
@onready var progress_label: Label = $Panel/VBox/Header/ProgressLabel
@onready var close_button: Button = $Panel/VBox/Header/CloseButton
@onready var scroll_container: ScrollContainer = $Panel/VBox/ScrollContainer
@onready var entry_list: VBoxContainer = $Panel/VBox/ScrollContainer/EntryList
@onready var content_panel: PanelContainer = $Panel/VBox/ContentPanel
@onready var content_header: Label = $Panel/VBox/ContentPanel/VBox/ContentHeader
@onready var content_text: Label = $Panel/VBox/ContentPanel/VBox/ContentText
@onready var content_author: Label = $Panel/VBox/ContentPanel/VBox/ContentAuthor

var selected_entry_id: String = ""


func _ready() -> void:
	# Connect signals
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

	# Connect to JournalManager updates
	if JournalManager:
		JournalManager.journal_updated.connect(_refresh_display)

	_refresh_display()
	_hide_content_panel()


func _refresh_display() -> void:
	## Update the list of journal entries
	if entry_list == null:
		return

	# Clear existing entries
	for child in entry_list.get_children():
		child.queue_free()

	if JournalManager == null:
		return

	# Update progress label
	if progress_label:
		var collected := JournalManager.get_collected_count()
		var total := JournalManager.get_total_count()
		progress_label.text = "%d/%d collected" % [collected, total]

	# Get all lore entries
	var all_lore = JournalManager.get_all_lore()
	if all_lore.is_empty():
		# Fallback to DataRegistry if JournalManager not initialized
		if DataRegistry:
			all_lore = DataRegistry.get_all_lore()

	# Create entry buttons
	for lore in all_lore:
		var is_collected := JournalManager.is_collected(lore.id)
		var entry_button := _create_entry_button(lore, is_collected)
		entry_list.add_child(entry_button)


func _create_entry_button(lore, is_collected: bool) -> Button:
	## Create a button for a journal entry
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 50)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	if is_collected:
		# Show entry title
		button.text = lore.get_header()
		button.add_theme_color_override("font_color", _get_rarity_color(lore.rarity))
		button.pressed.connect(func(): _on_entry_selected(lore.id))
	else:
		# Show locked entry
		button.text = "??? - Not Found"
		button.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		button.disabled = true

	return button


func _on_entry_selected(lore_id: String) -> void:
	## Handle tapping a journal entry to read it
	selected_entry_id = lore_id

	var lore = null
	if JournalManager:
		lore = JournalManager.get_lore(lore_id)
	if lore == null and DataRegistry:
		lore = DataRegistry.get_lore(lore_id)

	if lore == null:
		_hide_content_panel()
		return

	_show_content_panel(lore)


func _show_content_panel(lore) -> void:
	## Display the lore content
	if content_panel == null:
		return

	content_panel.visible = true

	# Set header
	if content_header:
		content_header.text = lore.get_header()
		content_header.add_theme_color_override("font_color", _get_rarity_color(lore.rarity))

	# Set main content
	if content_text:
		content_text.text = lore.content
		content_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Set author
	if content_author:
		content_author.text = "- %s, %s" % [lore.author, lore.era]
		content_author.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))


func _hide_content_panel() -> void:
	## Hide the content panel
	if content_panel:
		content_panel.visible = false


func _on_close_pressed() -> void:
	## Handle close button
	close()


func open() -> void:
	## Show the journal screen
	visible = true
	_refresh_display()
	_hide_content_panel()


func close() -> void:
	## Hide the journal screen
	visible = false
	selected_entry_id = ""
	closed.emit()


func _get_rarity_color(rarity: String) -> Color:
	## Get display color based on rarity
	match rarity:
		"common":
			return Color(0.8, 0.8, 0.8)
		"uncommon":
			return Color(0.4, 0.8, 0.5)
		"rare":
			return Color(0.4, 0.6, 1.0)
		"epic":
			return Color(0.8, 0.4, 1.0)
		"legendary":
			return Color(1.0, 0.8, 0.3)
		_:
			return Color.WHITE
