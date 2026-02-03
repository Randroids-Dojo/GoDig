extends CanvasLayer
## WelcomeBackPopup - Guilt-free returning player celebration.
##
## Shows the player's achievements, progress reminder, and free ladder gift.
## Designed to feel like a warm welcome, not punishment for absence.
##
## Key UX principles (from Session 26 research):
## - Celebrate what player achieved before leaving
## - Free gift without conditions (no streak requirement)
## - Positive framing ("Welcome back!" not "You missed X days")

signal welcome_accepted  ## Player clicked to continue
signal welcome_dismissed  ## Player dismissed without claiming

## UI Elements (created programmatically)
var background: ColorRect = null
var panel: PanelContainer = null
var title_label: Label = null
var time_away_label: Label = null
var progress_container: VBoxContainer = null
var depth_label: Label = null
var stats_label: Label = null
var gift_container: HBoxContainer = null
var gift_label: Label = null
var continue_btn: Button = null

## Animation
var _fade_tween: Tween = null

## Cached welcome data
var _welcome_data: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_ui()
	visible = false

	# Connect to WelcomeBackManager
	if WelcomeBackManager:
		WelcomeBackManager.welcome_back_ready.connect(_on_welcome_back_ready)

	print("[WelcomeBackPopup] Ready")


func _create_ui() -> void:
	## Create all UI elements programmatically

	# Background overlay (semi-transparent)
	background = ColorRect.new()
	background.name = "Background"
	background.color = Color(0.0, 0.0, 0.0, 0.8)
	background.anchors_preset = Control.PRESET_FULL_RECT
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	# CRITICAL: Disable input when hidden (for web builds)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	# Main panel
	panel = PanelContainer.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(320, 0)  # Min width, auto-height
	add_child(panel)

	# Panel styling - warm, welcoming colors
	var style := StyleBoxFlat.new()
	style.bg_color = UIColors.PANEL_DARK
	style.set_corner_radius_all(12)
	style.set_border_width_all(3)
	style.border_color = UIColors.GOLD  # Gold border for celebration
	panel.add_theme_stylebox_override("panel", style)

	# Content margin
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	# Main vertical layout
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	# Title - warm welcome message
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "WELCOME BACK!"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", UIColors.GOLD_BRIGHT)
	UIColors.apply_outline(title_label)
	vbox.add_child(title_label)

	# Time away (friendly, not punishing)
	time_away_label = Label.new()
	time_away_label.name = "TimeAwayLabel"
	time_away_label.text = "We missed you!"
	time_away_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_away_label.add_theme_font_size_override("font_size", 14)
	time_away_label.add_theme_color_override("font_color", UIColors.TEXT_MEDIUM)
	vbox.add_child(time_away_label)

	# Separator
	var sep1 := HSeparator.new()
	vbox.add_child(sep1)

	# Progress reminder section
	progress_container = VBoxContainer.new()
	progress_container.name = "ProgressContainer"
	progress_container.add_theme_constant_override("separation", 6)
	vbox.add_child(progress_container)

	# Depth record
	depth_label = Label.new()
	depth_label.name = "DepthLabel"
	depth_label.text = "Your depth record: 42m"
	depth_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	depth_label.add_theme_font_size_override("font_size", 18)
	depth_label.add_theme_color_override("font_color", UIColors.BLUE)
	UIColors.apply_outline(depth_label, 2)
	progress_container.add_child(depth_label)

	# Stats summary
	stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.text = "Blocks mined: 1,234\nOres collected: 56\nPlaytime: 2:30"
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 13)
	stats_label.add_theme_color_override("font_color", UIColors.TEXT_LIGHT)
	progress_container.add_child(stats_label)

	# Separator
	var sep2 := HSeparator.new()
	vbox.add_child(sep2)

	# Gift section (the free ladders)
	gift_container = HBoxContainer.new()
	gift_container.name = "GiftContainer"
	gift_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(gift_container)

	# Gift background for emphasis
	var gift_bg := ColorRect.new()
	gift_bg.color = Color(0.2, 0.4, 0.2, 0.5)  # Green tint
	gift_bg.custom_minimum_size = Vector2(280, 50)
	gift_container.add_child(gift_bg)

	# Gift content overlay
	var gift_vbox := VBoxContainer.new()
	gift_vbox.set_anchors_preset(Control.PRESET_CENTER)
	gift_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	gift_bg.add_child(gift_vbox)

	# "Free gift!" header
	var gift_header := Label.new()
	gift_header.text = "FREE GIFT!"
	gift_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gift_header.add_theme_font_size_override("font_size", 14)
	gift_header.add_theme_color_override("font_color", UIColors.GREEN_BRIGHT)
	gift_vbox.add_child(gift_header)

	# Gift details
	gift_label = Label.new()
	gift_label.name = "GiftLabel"
	gift_label.text = "+5 Ladders"
	gift_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gift_label.add_theme_font_size_override("font_size", 20)
	gift_label.add_theme_color_override("font_color", UIColors.LADDER)
	UIColors.apply_outline(gift_label, 2)
	gift_vbox.add_child(gift_label)

	# Continue button
	continue_btn = Button.new()
	continue_btn.name = "ContinueButton"
	continue_btn.text = "Let's Dig!"
	continue_btn.custom_minimum_size = Vector2(200, 50)
	continue_btn.add_theme_font_size_override("font_size", 18)
	continue_btn.pressed.connect(_on_continue_pressed)
	vbox.add_child(continue_btn)

	# Center-align the button
	var btn_container := CenterContainer.new()
	vbox.remove_child(continue_btn)
	btn_container.add_child(continue_btn)
	vbox.add_child(btn_container)


func _on_welcome_back_ready(data: Dictionary) -> void:
	## Called when WelcomeBackManager has pending welcome data
	_welcome_data = data
	show_popup(data)


func show_popup(data: Dictionary) -> void:
	## Show the welcome back popup with player progress and gift
	_welcome_data = data

	# Update time away (friendly phrasing)
	var time_text: String = data.get("time_away_text", "a while")
	time_away_label.text = "It's been %s - we missed you!" % time_text

	# Update depth record
	var max_depth: int = data.get("max_depth", 0)
	if max_depth > 0:
		depth_label.text = "Your depth record: %dm" % max_depth
		depth_label.visible = true
	else:
		depth_label.visible = false

	# Update stats summary
	var blocks: int = data.get("blocks_mined", 0)
	var ores: int = data.get("ores_collected", 0)
	var playtime: String = data.get("playtime_text", "0:00")
	stats_label.text = "Blocks mined: %s\nOres collected: %d\nPlaytime: %s" % [
		_format_number(blocks), ores, playtime
	]

	# Update gift display
	var ladder_gift: int = data.get("ladder_gift", 0)
	if ladder_gift > 0:
		gift_label.text = "+%d Ladders" % ladder_gift
		gift_container.visible = true
	else:
		gift_container.visible = false

	# Enable background input
	background.mouse_filter = Control.MOUSE_FILTER_STOP

	# Show with animation
	visible = true
	background.modulate.a = 0.0
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)

	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	_fade_tween.tween_property(background, "modulate:a", 1.0, 0.2)
	_fade_tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	_fade_tween.tween_property(panel, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Position panel after frame so size is calculated
	await get_tree().process_frame
	_center_panel()

	print("[WelcomeBackPopup] Showing welcome back popup")


func hide_popup() -> void:
	## Hide the popup
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	# Disable background input before hiding
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	visible = false
	print("[WelcomeBackPopup] Hidden")


func _center_panel() -> void:
	## Center the panel on screen
	var viewport_size := get_viewport().get_visible_rect().size
	var panel_size := panel.size
	panel.position = Vector2(
		(viewport_size.x - panel_size.x) / 2.0,
		(viewport_size.y - panel_size.y) / 2.0
	)


func _on_continue_pressed() -> void:
	## Player accepted the welcome - claim the gift
	if WelcomeBackManager:
		WelcomeBackManager.claim_welcome_back()

	welcome_accepted.emit()
	hide_popup()


func _format_number(n: int) -> String:
	## Format large numbers with commas
	var s := str(n)
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result
