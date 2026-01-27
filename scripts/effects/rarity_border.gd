extends Node2D
## Rarity border visual effect for ore blocks.
##
## Draws a colored border around ore blocks to indicate their rarity level.
## Uses a subtle pulsing glow animation for better visual feedback.

const BLOCK_SIZE := 128

## Border thickness in pixels
const BORDER_WIDTH := 3.0

## Pulse animation settings
const PULSE_SPEED := 2.0  # Cycles per second
const PULSE_MIN_ALPHA := 0.5
const PULSE_MAX_ALPHA := 1.0

## The rarity color for this border
var border_color: Color = Color.GRAY

## Rarity level (0-4)
var rarity: int = 0

## Internal pulse timer
var _pulse_time: float = 0.0


func _ready() -> void:
	# Randomize initial pulse phase so borders don't all pulse together
	_pulse_time = randf() * TAU


func _process(delta: float) -> void:
	# Only animate if reduced motion is disabled
	if SettingsManager and SettingsManager.reduced_motion:
		queue_redraw()
		return

	# Update pulse animation
	_pulse_time += delta * PULSE_SPEED * TAU
	if _pulse_time > TAU:
		_pulse_time -= TAU

	queue_redraw()


func _draw() -> void:
	var alpha := PULSE_MAX_ALPHA

	# Apply pulse animation unless reduced motion is enabled
	if not (SettingsManager and SettingsManager.reduced_motion):
		# Smooth pulse using sine wave
		var pulse := (sin(_pulse_time) + 1.0) / 2.0  # 0 to 1
		alpha = lerp(PULSE_MIN_ALPHA, PULSE_MAX_ALPHA, pulse)

	var draw_color := Color(border_color.r, border_color.g, border_color.b, alpha)

	# Draw border as four rectangles (top, bottom, left, right)
	var outer := Rect2(0, 0, BLOCK_SIZE, BLOCK_SIZE)

	# Top border
	draw_rect(Rect2(0, 0, BLOCK_SIZE, BORDER_WIDTH), draw_color)
	# Bottom border
	draw_rect(Rect2(0, BLOCK_SIZE - BORDER_WIDTH, BLOCK_SIZE, BORDER_WIDTH), draw_color)
	# Left border
	draw_rect(Rect2(0, BORDER_WIDTH, BORDER_WIDTH, BLOCK_SIZE - BORDER_WIDTH * 2), draw_color)
	# Right border
	draw_rect(Rect2(BLOCK_SIZE - BORDER_WIDTH, BORDER_WIDTH, BORDER_WIDTH, BLOCK_SIZE - BORDER_WIDTH * 2), draw_color)


func configure(p_rarity: int) -> void:
	## Configure the border for a specific rarity level
	rarity = p_rarity
	border_color = _get_rarity_color(p_rarity)
	queue_redraw()


func _get_rarity_color(p_rarity: int) -> Color:
	## Get border color based on rarity level (matches inventory_slot.gd)
	match p_rarity:
		0: return Color.GRAY       # Common
		1: return Color.GREEN      # Uncommon
		2: return Color.BLUE       # Rare
		3: return Color.PURPLE     # Epic
		_: return Color.ORANGE     # Legendary (4+)
