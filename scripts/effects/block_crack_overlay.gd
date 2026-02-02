extends Node2D
## Block crack overlay visual effect.
##
## Draws crack lines on dirt blocks to show mining progress.
## Cracks accumulate through 4 stages as the block takes damage.
## Provides satisfying visual feedback that builds anticipation.

const BLOCK_SIZE := 128

## Number of crack stages (0 = no cracks, 4 = heavily cracked)
const MAX_CRACK_STAGE := 4

## Damage thresholds for each crack stage (0-1 range)
const CRACK_THRESHOLDS := [0.0, 0.25, 0.50, 0.75]

## Current crack stage (0-4)
var crack_stage: int = 0

## Crack line color (slightly darker than block)
var crack_color: Color = Color(0.0, 0.0, 0.0, 0.6)

## Line width for cracks
const CRACK_WIDTH := 2.5

## Cached crack patterns for each stage (generated once per stage)
var _crack_patterns: Array = []


func _ready() -> void:
	# Pre-generate crack patterns for deterministic appearance
	_generate_crack_patterns()


func _draw() -> void:
	if crack_stage <= 0:
		return  # No cracks to draw

	# Draw all crack patterns up to current stage
	for stage in range(1, mini(crack_stage + 1, MAX_CRACK_STAGE + 1)):
		if stage <= _crack_patterns.size():
			_draw_crack_pattern(_crack_patterns[stage - 1])


func _generate_crack_patterns() -> void:
	## Generate crack line patterns for each stage.
	## Each stage adds new cracks, building on previous ones.
	## Uses deterministic "random" values based on position.

	# Stage 1: Single crack from top-right corner
	_crack_patterns.append([
		[Vector2(BLOCK_SIZE * 0.8, 0), Vector2(BLOCK_SIZE * 0.6, BLOCK_SIZE * 0.3)],
		[Vector2(BLOCK_SIZE * 0.6, BLOCK_SIZE * 0.3), Vector2(BLOCK_SIZE * 0.5, BLOCK_SIZE * 0.4)],
	])

	# Stage 2: Add crack from bottom-left
	_crack_patterns.append([
		[Vector2(0, BLOCK_SIZE * 0.7), Vector2(BLOCK_SIZE * 0.25, BLOCK_SIZE * 0.55)],
		[Vector2(BLOCK_SIZE * 0.25, BLOCK_SIZE * 0.55), Vector2(BLOCK_SIZE * 0.35, BLOCK_SIZE * 0.6)],
	])

	# Stage 3: Center crack network
	_crack_patterns.append([
		[Vector2(BLOCK_SIZE * 0.5, BLOCK_SIZE * 0.4), Vector2(BLOCK_SIZE * 0.45, BLOCK_SIZE * 0.6)],
		[Vector2(BLOCK_SIZE * 0.45, BLOCK_SIZE * 0.6), Vector2(BLOCK_SIZE * 0.35, BLOCK_SIZE * 0.6)],
		[Vector2(BLOCK_SIZE * 0.45, BLOCK_SIZE * 0.6), Vector2(BLOCK_SIZE * 0.55, BLOCK_SIZE * 0.75)],
		[Vector2(BLOCK_SIZE * 0.5, BLOCK_SIZE * 0.4), Vector2(BLOCK_SIZE * 0.65, BLOCK_SIZE * 0.5)],
	])

	# Stage 4: Heavy cracking - block about to shatter
	_crack_patterns.append([
		[Vector2(BLOCK_SIZE * 0.2, 0), Vector2(BLOCK_SIZE * 0.3, BLOCK_SIZE * 0.25)],
		[Vector2(BLOCK_SIZE * 0.3, BLOCK_SIZE * 0.25), Vector2(BLOCK_SIZE * 0.25, BLOCK_SIZE * 0.4)],
		[Vector2(BLOCK_SIZE, BLOCK_SIZE * 0.5), Vector2(BLOCK_SIZE * 0.75, BLOCK_SIZE * 0.55)],
		[Vector2(BLOCK_SIZE * 0.75, BLOCK_SIZE * 0.55), Vector2(BLOCK_SIZE * 0.65, BLOCK_SIZE * 0.5)],
		[Vector2(BLOCK_SIZE * 0.55, BLOCK_SIZE * 0.75), Vector2(BLOCK_SIZE * 0.5, BLOCK_SIZE)],
		[Vector2(0, BLOCK_SIZE * 0.3), Vector2(BLOCK_SIZE * 0.15, BLOCK_SIZE * 0.35)],
	])


func _draw_crack_pattern(pattern: Array) -> void:
	## Draw a set of crack lines
	for line in pattern:
		if line.size() >= 2:
			draw_line(line[0], line[1], crack_color, CRACK_WIDTH, true)


func update_damage(damage_ratio: float) -> void:
	## Update crack stage based on damage ratio (0.0 to 1.0).
	## Higher damage = more cracks visible.
	var new_stage := 0

	for i in range(CRACK_THRESHOLDS.size()):
		if damage_ratio >= CRACK_THRESHOLDS[i]:
			new_stage = i + 1

	# Cap at max stage
	new_stage = mini(new_stage, MAX_CRACK_STAGE)

	if new_stage != crack_stage:
		crack_stage = new_stage
		queue_redraw()


func set_crack_color(base_block_color: Color) -> void:
	## Set crack color based on block color (cracks are darker version)
	crack_color = base_block_color.darkened(0.5)
	crack_color.a = 0.7
	queue_redraw()


func reset() -> void:
	## Reset to no cracks (for block recycling)
	crack_stage = 0
	queue_redraw()
