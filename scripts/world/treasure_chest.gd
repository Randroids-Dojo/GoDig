extends Area2D
## TreasureChest - Interactive treasure chest in caves.
##
## Visual representation of a chest that player can interact with.
## Shows sparkle effect, plays celebration on open.

signal chest_opened(loot: Array)

## Chest state
var grid_pos: Vector2i = Vector2i.ZERO
var tier: int = 0
var tier_name: String = "Chest"
var is_opened: bool = false

## Visual nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var sparkle: CPUParticles2D = $Sparkle
@onready var glow: PointLight2D = $Glow

## Tier colors for visual differentiation
const TIER_COLORS := {
	0: Color(0.6, 0.4, 0.2),   # Common - Brown
	1: Color(0.7, 0.7, 0.75),  # Uncommon - Silver
	2: Color(1.0, 0.84, 0.0),  # Rare - Gold
	3: Color(0.6, 0.2, 0.8),   # Epic - Purple
}

## Glow intensities per tier
const TIER_GLOW_ENERGY := {
	0: 0.3,
	1: 0.5,
	2: 0.8,
	3: 1.2,
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


## Configure the chest with data from TreasureChestManager
func configure(pos: Vector2i, chest_tier: int, chest_tier_name: String) -> void:
	grid_pos = pos
	tier = chest_tier
	tier_name = chest_tier_name

	# Apply tier-based visuals
	_apply_tier_visuals()

	# Position in world
	position = Vector2(
		pos.x * GameManager.BLOCK_SIZE + GameManager.GRID_OFFSET_X + GameManager.BLOCK_SIZE / 2,
		pos.y * GameManager.BLOCK_SIZE + GameManager.BLOCK_SIZE / 2
	)


## Apply visual styling based on tier
func _apply_tier_visuals() -> void:
	var color: Color = TIER_COLORS.get(tier, TIER_COLORS[0])

	# Tint sprite
	if sprite:
		sprite.modulate = color

	# Configure sparkle color
	if sparkle:
		sparkle.color = color.lightened(0.3)
		# Higher tier = more particles
		sparkle.amount = 3 + tier * 2

	# Configure glow
	if glow:
		glow.color = color
		glow.energy = TIER_GLOW_ENERGY.get(tier, 0.3)


## Called when player enters chest area
func _on_body_entered(body: Node2D) -> void:
	if is_opened:
		return

	if body.is_in_group("player"):
		open_chest()


## Open the chest and give loot to player
func open_chest() -> void:
	if is_opened:
		return

	is_opened = true

	# Get loot from manager
	var loot: Array = []
	if TreasureChestManager:
		loot = TreasureChestManager.open_chest(grid_pos)

	# Play celebration effect
	_play_open_celebration(loot)

	# Emit signal
	chest_opened.emit(loot)

	# Disable further interaction
	set_deferred("monitoring", false)


## Play chest opening celebration
func _play_open_celebration(loot: Array) -> void:
	# Stop sparkle
	if sparkle:
		sparkle.emitting = false

	# Create burst effect
	_create_loot_burst()

	# Play treasure discovery sound - use achievement for discoveries
	if SoundManager:
		SoundManager.play_achievement()  # Discovery-appropriate sound

	# Haptic feedback
	if HapticFeedback:
		HapticFeedback.on_milestone_reached()

	# Show loot notification
	_show_loot_notification(loot)

	# Change to opened sprite (darker/empty look)
	if sprite:
		sprite.modulate = sprite.modulate.darkened(0.5)

	# Fade out glow
	if glow:
		var tween := create_tween()
		tween.tween_property(glow, "energy", 0.0, 0.5)

	# Remove after delay
	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(queue_free)


## Create loot burst particle effect
func _create_loot_burst() -> void:
	# Create a temporary particle burst
	var burst := CPUParticles2D.new()
	burst.emitting = true
	burst.one_shot = true
	burst.amount = 20 + tier * 10
	burst.lifetime = 0.8
	burst.explosiveness = 1.0
	burst.direction = Vector2(0, -1)
	burst.spread = 180.0
	burst.gravity = Vector2(0, 200)
	burst.initial_velocity_min = 100.0
	burst.initial_velocity_max = 200.0
	burst.scale_amount_min = 3.0
	burst.scale_amount_max = 6.0
	burst.color = TIER_COLORS.get(tier, TIER_COLORS[0]).lightened(0.4)

	add_child(burst)

	# Auto-free burst after particles finish
	burst.finished.connect(burst.queue_free)


## Show floating loot notification
func _show_loot_notification(loot: Array) -> void:
	# Create floating text showing what was found
	var text := tier_name + " opened!"

	# Count coins and items
	var coin_total := 0
	var item_count := 0
	for item in loot:
		if item.get("type") == "coins":
			coin_total += item.get("amount", 0)
		else:
			item_count += item.get("amount", 1)

	# Build notification text
	var details := ""
	if coin_total > 0:
		details += "%d coins" % coin_total
	if item_count > 0:
		if details != "":
			details += ", "
		details += "%d items" % item_count

	# Create floating label
	var label := Label.new()
	label.text = text + "\n" + details
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-50, -80)

	# Style the label
	label.add_theme_color_override("font_color", TIER_COLORS.get(tier, Color.WHITE).lightened(0.3))
	label.add_theme_font_size_override("font_size", 18)

	add_child(label)

	# Animate label floating up and fading
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 50, 1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5)
	tween.chain().tween_callback(label.queue_free)


## Check if chest can be interacted with
func can_interact() -> bool:
	return not is_opened
