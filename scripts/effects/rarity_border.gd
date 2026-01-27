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

	# In HIGH_CONTRAST mode, use high-contrast black/white for borders
	if SettingsManager and SettingsManager.colorblind_mode == SettingsManager.ColorblindMode.HIGH_CONTRAST:
		draw_color = Color.WHITE if _is_dark_background() else Color.BLACK
		draw_color.a = alpha

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

	# Draw colorblind symbols if enabled
	if SettingsManager and SettingsManager.colorblind_mode != SettingsManager.ColorblindMode.OFF:
		_draw_rarity_symbol(draw_color)


func _draw_rarity_symbol(draw_color: Color) -> void:
	## Draw a shape symbol indicating rarity for colorblind mode
	## Uses different geometric shapes for each rarity level
	var center := Vector2(BLOCK_SIZE / 2, BLOCK_SIZE / 2)
	var symbol_size := 16.0
	var symbol_color := Color.WHITE if border_color.get_luminance() < 0.5 else Color.BLACK

	match rarity:
		0:  # Common - single dot
			draw_circle(center, 4.0, symbol_color)
		1:  # Uncommon - two dots
			draw_circle(center + Vector2(-8, 0), 3.0, symbol_color)
			draw_circle(center + Vector2(8, 0), 3.0, symbol_color)
		2:  # Rare - triangle
			var points := PackedVector2Array([
				center + Vector2(0, -symbol_size / 2),
				center + Vector2(-symbol_size / 2, symbol_size / 2),
				center + Vector2(symbol_size / 2, symbol_size / 2),
			])
			draw_colored_polygon(points, symbol_color)
		3:  # Epic - diamond
			var points := PackedVector2Array([
				center + Vector2(0, -symbol_size / 2),
				center + Vector2(-symbol_size / 2, 0),
				center + Vector2(0, symbol_size / 2),
				center + Vector2(symbol_size / 2, 0),
			])
			draw_colored_polygon(points, symbol_color)
		_:  # Legendary - star
			_draw_star(center, symbol_size / 2, 5, symbol_color)


func _draw_star(center: Vector2, radius: float, points: int, col: Color) -> void:
	## Draw a simple star shape
	var inner_radius := radius * 0.4
	var angle_step := TAU / points
	var half_step := angle_step / 2

	var star_points := PackedVector2Array()
	for i in range(points):
		var angle := -PI / 2 + i * angle_step
		star_points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		var inner_angle := angle + half_step
		star_points.append(center + Vector2(cos(inner_angle), sin(inner_angle)) * inner_radius)

	draw_colored_polygon(star_points, col)


func _is_dark_background() -> bool:
	## Simple heuristic to determine if background is dark
	return border_color.get_luminance() < 0.5


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
