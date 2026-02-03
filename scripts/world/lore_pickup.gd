extends Area2D
## LorePickup - Interactive lore item in caves/underground.
##
## Visual representation of a journal/lore item that player can collect.
## Shows subtle glow effect, plays celebration on pickup.

signal lore_picked_up(lore_id: String)

## Pickup state
var grid_pos: Vector2i = Vector2i.ZERO
var lore_id: String = ""
var lore_data = null
var is_picked_up: bool = false

## Visual nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var sparkle: CPUParticles2D = $Sparkle
@onready var glow: PointLight2D = $Glow

## Color based on rarity
const RARITY_COLORS := {
	"common": Color(0.6, 0.5, 0.4),      # Brown
	"uncommon": Color(0.4, 0.7, 0.5),    # Green
	"rare": Color(0.4, 0.6, 0.9),        # Blue
	"epic": Color(0.7, 0.4, 0.9),        # Purple
	"legendary": Color(1.0, 0.8, 0.3),   # Gold
}


func _ready() -> void:
	# Connect signals
	body_entered.connect(_on_body_entered)

	# Set collision layers
	collision_layer = 0
	collision_mask = 1  # Detect player (layer 1)

	# Start sparkle effect
	if sparkle:
		sparkle.emitting = true


## Configure the lore pickup with data from JournalManager
func configure(pos: Vector2i, lore_entry_id: String) -> void:
	grid_pos = pos
	lore_id = lore_entry_id

	# Get lore data from registry
	if DataRegistry:
		lore_data = DataRegistry.get_lore(lore_id)

	# Apply rarity-based visuals
	_apply_rarity_visuals()

	# Position in world
	position = Vector2(
		pos.x * GameManager.BLOCK_SIZE + GameManager.GRID_OFFSET_X + GameManager.BLOCK_SIZE / 2,
		pos.y * GameManager.BLOCK_SIZE + GameManager.BLOCK_SIZE / 2
	)


## Apply visual styling based on rarity
func _apply_rarity_visuals() -> void:
	var rarity := "uncommon"
	if lore_data != null and "rarity" in lore_data:
		rarity = lore_data.rarity

	var color: Color = RARITY_COLORS.get(rarity, RARITY_COLORS["uncommon"])

	# Tint sprite
	if sprite:
		sprite.modulate = color

	# Configure sparkle color
	if sparkle:
		sparkle.color = color.lightened(0.3)
		# Adjust particle amount based on rarity
		match rarity:
			"common": sparkle.amount = 3
			"uncommon": sparkle.amount = 4
			"rare": sparkle.amount = 6
			"epic": sparkle.amount = 8
			"legendary": sparkle.amount = 10

	# Configure glow
	if glow:
		glow.color = color
		match rarity:
			"common": glow.energy = 0.3
			"uncommon": glow.energy = 0.4
			"rare": glow.energy = 0.6
			"epic": glow.energy = 0.8
			"legendary": glow.energy = 1.0


## Called when player enters pickup area
func _on_body_entered(body: Node2D) -> void:
	if is_picked_up:
		return

	if body.is_in_group("player"):
		pickup_lore()


## Pick up the lore and notify systems
func pickup_lore() -> void:
	if is_picked_up:
		return

	is_picked_up = true

	# Tell JournalManager to collect this lore
	if JournalManager:
		JournalManager.collect_lore(lore_id)
		JournalManager.mark_lore_opened(grid_pos)

	# Play celebration effect
	_play_pickup_celebration()

	# Emit signal
	lore_picked_up.emit(lore_id)

	# Disable further interaction
	set_deferred("monitoring", false)


## Play lore pickup celebration
func _play_pickup_celebration() -> void:
	# Stop sparkle
	if sparkle:
		sparkle.emitting = false

	# Create burst effect
	_create_pickup_burst()

	# Play sound
	if SoundManager:
		SoundManager.play_milestone()  # Use milestone sound for now

	# Haptic feedback
	if HapticFeedback:
		HapticFeedback.on_milestone_reached()

	# Show pickup notification
	_show_pickup_notification()

	# Fade out glow
	if glow:
		var tween := create_tween()
		tween.tween_property(glow, "energy", 0.0, 0.5)

	# Remove after delay
	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(queue_free)


## Create pickup burst particle effect
func _create_pickup_burst() -> void:
	var rarity := "uncommon"
	if lore_data != null and "rarity" in lore_data:
		rarity = lore_data.rarity

	var color: Color = RARITY_COLORS.get(rarity, RARITY_COLORS["uncommon"])

	# Create a temporary particle burst
	var burst := CPUParticles2D.new()
	burst.emitting = true
	burst.one_shot = true
	burst.amount = 15
	burst.lifetime = 0.8
	burst.explosiveness = 1.0
	burst.direction = Vector2(0, -1)
	burst.spread = 180.0
	burst.gravity = Vector2(0, 100)
	burst.initial_velocity_min = 80.0
	burst.initial_velocity_max = 150.0
	burst.scale_amount_min = 2.0
	burst.scale_amount_max = 5.0
	burst.color = color.lightened(0.4)

	add_child(burst)

	# Auto-free burst after particles finish
	burst.finished.connect(burst.queue_free)


## Show floating pickup notification
func _show_pickup_notification() -> void:
	var display_name := "Journal Entry"
	if lore_data != null:
		display_name = lore_data.get_header()

	# Create floating label
	var label := Label.new()
	label.text = display_name + " found!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-60, -80)

	# Style the label
	var rarity := "uncommon"
	if lore_data != null and "rarity" in lore_data:
		rarity = lore_data.rarity
	var color: Color = RARITY_COLORS.get(rarity, Color.WHITE).lightened(0.3)
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 16)

	add_child(label)

	# Animate label floating up and fading
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 50, 1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5)
	tween.chain().tween_callback(label.queue_free)


## Check if pickup can be interacted with
func can_interact() -> bool:
	return not is_picked_up
