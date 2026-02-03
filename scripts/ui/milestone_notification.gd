extends Control
## MilestoneNotification - Enhanced celebration for depth milestone achievements.
##
## Shows a prominent center-screen notification when the player reaches
## significant depth milestones (10m, 25m, 50m, 100m, etc.).
## Enhanced features:
## - Custom milestone messages with content unlock hints
## - Coin bonuses for first-time reach
## - Screen flash and camera shake
## - Achievement tracking integration

@onready var label: Label = $Panel/VBox/Label
@onready var panel: PanelContainer = $Panel
@onready var _subtitle_label: Label = $Panel/VBox/SubtitleLabel
@onready var _bonus_label: Label = $Panel/VBox/BonusLabel

## Animation state
var _tween: Tween = null

## Milestone configuration with custom messages and rewards
## Format: {depth: {title, message, bonus, color}}
const MILESTONE_DATA := {
	10: {
		"title": "First Steps!",
		"message": "Keep digging - the riches await below!",
		"bonus": 10,
		"color": Color(0.7, 0.85, 1.0)  # Light blue
	},
	25: {
		"title": "Getting Deeper!",
		"message": "New ore types appear at greater depths.",
		"bonus": 25,
		"color": Color(0.5, 0.8, 0.5)  # Green
	},
	50: {
		"title": "Stone Layer Reached!",
		"message": "Iron ore now available. Upgrade your pickaxe!",
		"bonus": 50,
		"color": Color(0.8, 0.8, 0.8)  # Silver
	},
	100: {
		"title": "Deep Explorer!",
		"message": "The Equipment Shop is now open on the surface!",
		"bonus": 100,
		"color": Color(0.3, 0.7, 1.0)  # Blue
	},
	150: {
		"title": "Cavern Depths!",
		"message": "Rare gems begin to appear in the stone.",
		"bonus": 150,
		"color": Color(0.6, 0.3, 0.8)  # Purple
	},
	200: {
		"title": "Into the Abyss!",
		"message": "The Gem Appraiser awaits your discoveries!",
		"bonus": 200,
		"color": Color(0.8, 0.4, 1.0)  # Violet
	},
	300: {
		"title": "Treasure Hunter!",
		"message": "Gadget Shop now open. New tools await!",
		"bonus": 300,
		"color": Color(1.0, 0.5, 0.2)  # Orange
	},
	500: {
		"title": "Deep Dive Master!",
		"message": "The Elevator is now available for fast travel!",
		"bonus": 500,
		"color": Color(1.0, 0.85, 0.0)  # Gold
	},
	750: {
		"title": "Subterranean Legend!",
		"message": "The deepest secrets lie just below...",
		"bonus": 750,
		"color": Color(1.0, 0.6, 0.8)  # Pink
	},
	1000: {
		"title": "MILE MARKER!",
		"message": "A true mining champion! 1km deep!",
		"bonus": 1000,
		"color": Color(1.0, 1.0, 0.6)  # Pale gold
	}
}

func _ready() -> void:
	# Start hidden
	modulate.a = 0.0
	visible = false


## Display enhanced milestone notification with celebration
func show_milestone(depth: int) -> void:
	if label == null or panel == null:
		return

	# Get milestone data
	var data: Dictionary = _get_milestone_data(depth)

	# Format the milestone text
	label.text = data.get("title", "DEPTH MILESTONE: %dm!" % depth)

	# Set subtitle if available
	if _subtitle_label:
		var message: String = data.get("message", "")
		_subtitle_label.text = message
		_subtitle_label.visible = not message.is_empty()

	# Set bonus display
	var bonus: int = data.get("bonus", 0)
	if _bonus_label and bonus > 0:
		_bonus_label.text = "+$%d" % bonus
		_bonus_label.visible = true
		# Award the bonus coins
		_award_bonus(bonus)
	elif _bonus_label:
		_bonus_label.visible = false

	# Apply color tint
	var color: Color = data.get("color", Color.GOLD)
	label.add_theme_color_override("font_color", color)

	# Reset state
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)

	# Cancel any existing animation
	if _tween and _tween.is_valid():
		_tween.kill()

	# Trigger camera shake for celebration
	_trigger_camera_shake(_get_shake_intensity(depth))

	# Trigger screen flash
	_trigger_screen_flash(color)

	# Skip fancy animations if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		modulate.a = 1.0
		scale = Vector2(1.0, 1.0)
		_tween = create_tween()
		_tween.tween_interval(3.0)  # Longer display for reading
		_tween.tween_property(self, "modulate:a", 0.0, 0.3)
		_tween.tween_callback(_hide)
		return

	# Enhanced animated sequence
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.15) \
		.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1) \
		.set_ease(Tween.EASE_IN_OUT)

	# Pulse effect for emphasis
	_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.15)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

	# Hold longer for reading
	_tween.tween_interval(2.5)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5) \
		.set_ease(Tween.EASE_IN)
	_tween.tween_callback(_hide)


func _get_milestone_data(depth: int) -> Dictionary:
	## Get configuration for a specific milestone depth
	if MILESTONE_DATA.has(depth):
		return MILESTONE_DATA[depth]

	# Generic milestone for unlisted depths
	return {
		"title": "DEPTH MILESTONE: %dm!" % depth,
		"message": "",
		"bonus": int(depth * 0.5),  # Scale bonus with depth
		"color": Color.GOLD
	}


func _get_shake_intensity(depth: int) -> float:
	## Calculate camera shake intensity based on milestone significance
	if depth >= 1000:
		return 8.0
	elif depth >= 500:
		return 6.0
	elif depth >= 200:
		return 5.0
	elif depth >= 100:
		return 4.0
	else:
		return 3.0


func _award_bonus(amount: int) -> void:
	## Award bonus coins for reaching milestone
	if GameManager:
		GameManager.add_coins(amount)
		print("[MilestoneNotification] Awarded $%d milestone bonus" % amount)


func _trigger_camera_shake(intensity: float) -> void:
	## Find the game camera and trigger shake
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_node("GameCamera"):
		var camera = player.get_node("GameCamera")
		if camera.has_method("shake"):
			camera.shake(intensity)


func _trigger_screen_flash(color: Color) -> void:
	## Create a brief screen flash effect
	# Skip if reduced motion
	if SettingsManager and SettingsManager.reduced_motion:
		return

	# Create a temporary flash overlay
	var flash := ColorRect.new()
	flash.name = "MilestoneFlash"
	flash.color = Color(color.r, color.g, color.b, 0.3)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.z_index = -1  # Behind the notification panel
	add_child(flash)

	# Animate flash
	var flash_tween := create_tween()
	flash_tween.tween_property(flash, "color:a", 0.0, 0.4).set_ease(Tween.EASE_OUT)
	flash_tween.tween_callback(flash.queue_free)


## Display layer entry notification
func show_layer_entered(layer_name: String) -> void:
	if label == null or panel == null:
		return

	# Format the layer text
	label.text = "ENTERING: %s" % layer_name
	label.add_theme_color_override("font_color", Color.CYAN)

	# Hide subtitle and bonus for layer notifications
	if _subtitle_label:
		_subtitle_label.visible = false
	if _bonus_label:
		_bonus_label.visible = false

	# Reset state
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)

	# Cancel any existing animation
	if _tween and _tween.is_valid():
		_tween.kill()

	# Small camera shake
	_trigger_camera_shake(2.0)

	# Skip fancy animations if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		modulate.a = 1.0
		scale = Vector2(1.0, 1.0)
		_tween = create_tween()
		_tween.tween_interval(2.0)
		_tween.tween_property(self, "modulate:a", 0.0, 0.3)
		_tween.tween_callback(_hide)
		return

	# Animated sequence
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.15) \
		.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1) \
		.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(1.5)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5) \
		.set_ease(Tween.EASE_IN)
	_tween.tween_callback(_hide)


## Display building unlock notification
func show_building_unlocked(building_name: String) -> void:
	if label == null or panel == null:
		return

	# Format the building unlock text
	label.text = "UNLOCKED: %s!" % building_name
	label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))  # Green

	# Hide subtitle, show hint in bonus label
	if _subtitle_label:
		_subtitle_label.text = "Visit the surface to explore!"
		_subtitle_label.visible = true
	if _bonus_label:
		_bonus_label.visible = false

	# Reset state
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)

	# Cancel any existing animation
	if _tween and _tween.is_valid():
		_tween.kill()

	# Medium camera shake for unlock
	_trigger_camera_shake(4.0)

	# Screen flash for unlock celebration
	_trigger_screen_flash(Color(0.3, 1.0, 0.3))

	# Skip fancy animations if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		modulate.a = 1.0
		scale = Vector2(1.0, 1.0)
		_tween = create_tween()
		_tween.tween_interval(2.5)
		_tween.tween_property(self, "modulate:a", 0.0, 0.3)
		_tween.tween_callback(_hide)
		return

	# Animated sequence with extra pop for unlock events
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.15) \
		.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15) \
		.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(2.5)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5) \
		.set_ease(Tween.EASE_IN)
	_tween.tween_callback(_hide)


## Display depth record notification
func show_depth_record(depth: int) -> void:
	if label == null or panel == null:
		return

	label.text = "NEW DEPTH RECORD!"
	label.add_theme_color_override("font_color", Color.GOLD)

	if _subtitle_label:
		_subtitle_label.text = "%dm - Your deepest dive yet!" % depth
		_subtitle_label.visible = true

	if _bonus_label:
		_bonus_label.visible = false

	# Reset state
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)

	if _tween and _tween.is_valid():
		_tween.kill()

	# Celebration effects
	_trigger_camera_shake(3.0)
	_trigger_screen_flash(Color.GOLD)

	if SettingsManager and SettingsManager.reduced_motion:
		modulate.a = 1.0
		scale = Vector2(1.0, 1.0)
		_tween = create_tween()
		_tween.tween_interval(2.0)
		_tween.tween_property(self, "modulate:a", 0.0, 0.3)
		_tween.tween_callback(_hide)
		return

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.15) \
		.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1) \
		.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(2.0)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5) \
		.set_ease(Tween.EASE_IN)
	_tween.tween_callback(_hide)


func _hide() -> void:
	visible = false


## Display discovery notification (depth-based surprises)
func show_discovery(discovery_type: String, discovery_name: String) -> void:
	if label == null or panel == null:
		return

	# Format discovery text based on type
	var title_text := "DISCOVERY!"
	var color := Color.GOLD

	match discovery_type:
		"MYSTERIOUS_CAVE":
			title_text = "CAVE DISCOVERED!"
			color = Color(0.4, 0.8, 1.0)  # Cyan
		"ABANDONED_EQUIPMENT":
			title_text = "ABANDONED EQUIPMENT!"
			color = Color(0.8, 0.6, 0.4)  # Brown/copper
		"RARE_VEIN":
			title_text = "RARE VEIN FOUND!"
			color = Color(1.0, 0.85, 0.0)  # Gold
		"ANCIENT_RELIC":
			title_text = "ANCIENT RELIC!"
			color = Color(0.8, 0.4, 1.0)  # Purple
		"UNUSUAL_FORMATION":
			title_text = "STRANGE DISCOVERY!"
			color = Color(0.6, 1.0, 0.6)  # Light green

	label.text = title_text
	label.add_theme_color_override("font_color", color)

	if _subtitle_label:
		_subtitle_label.text = discovery_name
		_subtitle_label.visible = true

	if _bonus_label:
		_bonus_label.visible = false

	# Reset state
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.7, 0.7)

	if _tween and _tween.is_valid():
		_tween.kill()

	# Celebration effects
	_trigger_camera_shake(5.0)
	_trigger_screen_flash(color)

	if SettingsManager and SettingsManager.reduced_motion:
		modulate.a = 1.0
		scale = Vector2(1.0, 1.0)
		_tween = create_tween()
		_tween.tween_interval(2.5)
		_tween.tween_property(self, "modulate:a", 0.0, 0.3)
		_tween.tween_callback(_hide)
		return

	# Enhanced pop animation for discoveries
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.1) \
		.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15) \
		.set_ease(Tween.EASE_IN_OUT)

	# Extra pulse for excitement
	_tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.1)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	_tween.tween_interval(2.0)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5) \
		.set_ease(Tween.EASE_IN)
	_tween.tween_callback(_hide)


## Display discovery hint notification
func show_discovery_hint(direction: String, distance: int) -> void:
	if label == null or panel == null:
		return

	label.text = "Something nearby..."
	label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))

	if _subtitle_label:
		_subtitle_label.text = "Check %s (~%d blocks)" % [direction, distance]
		_subtitle_label.visible = true

	if _bonus_label:
		_bonus_label.visible = false

	# Reset state
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.9, 0.9)

	if _tween and _tween.is_valid():
		_tween.kill()

	# Subtle hint - no camera shake
	if SettingsManager and SettingsManager.reduced_motion:
		modulate.a = 1.0
		scale = Vector2(1.0, 1.0)
		_tween = create_tween()
		_tween.tween_interval(1.5)
		_tween.tween_property(self, "modulate:a", 0.0, 0.3)
		_tween.tween_callback(_hide)
		return

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.7, 0.2) \
		.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
	_tween.tween_interval(1.5)
	_tween.tween_property(self, "modulate:a", 0.0, 0.4) \
		.set_ease(Tween.EASE_IN)
	_tween.tween_callback(_hide)
