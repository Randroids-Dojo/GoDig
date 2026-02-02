extends CanvasLayer
## Screen flash effect for jackpot discoveries.
##
## Creates a brief white/gold flash over the entire screen
## when player discovers rare ores. Flash intensity and
## duration scales with rarity tier.

## Rarity tier definitions
enum Tier { RARE, EPIC, LEGENDARY }

## Flash colors per rarity tier
const TIER_COLORS := {
	Tier.RARE: Color(0.3, 0.6, 1.0, 0.3),       # Subtle blue tint
	Tier.EPIC: Color(0.85, 0.4, 1.0, 0.4),      # Purple tint
	Tier.LEGENDARY: Color(1.0, 0.95, 0.7, 0.5)  # Gold/white flash
}

## Flash durations per tier (seconds)
const TIER_DURATIONS := {
	Tier.RARE: 0.15,
	Tier.EPIC: 0.25,
	Tier.LEGENDARY: 0.35
}

@onready var flash_rect: ColorRect

var _in_pool: bool = true


func _ready() -> void:
	# Set layer to render above game but below UI
	layer = 50

	# Create the flash rectangle
	flash_rect = ColorRect.new()
	flash_rect.name = "FlashRect"
	flash_rect.color = Color(1.0, 1.0, 1.0, 0.0)  # Start invisible
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block input
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(flash_rect)


## Flash the screen for the given rarity tier
## tier: 0=rare, 1=epic, 2=legendary
func flash(tier: int = 0, ore_color: Color = Color.WHITE) -> void:
	if flash_rect == null:
		return

	# Skip if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		return

	visible = true
	_in_pool = false

	# Clamp tier to valid range
	tier = clampi(tier, 0, 2)

	# Get tier settings
	var tier_color: Color = TIER_COLORS.get(tier, TIER_COLORS[Tier.RARE])
	var duration: float = TIER_DURATIONS.get(tier, TIER_DURATIONS[Tier.RARE])

	# Blend tier color with ore color for unique flash
	var flash_color: Color = tier_color.lerp(ore_color, 0.2)

	# Animate flash: quick fade in, slower fade out
	flash_rect.color = flash_color

	var tween := create_tween()
	# Quick flash to peak intensity (30% of duration)
	tween.tween_property(flash_rect, "color:a", flash_color.a, duration * 0.3)
	# Fade out (70% of duration)
	tween.tween_property(flash_rect, "color:a", 0.0, duration * 0.7)

	tween.tween_callback(_return_to_pool)


## Quick flash with custom color and duration
func flash_custom(flash_color: Color, duration: float = 0.2) -> void:
	if flash_rect == null:
		return

	# Skip if reduced motion is enabled
	if SettingsManager and SettingsManager.reduced_motion:
		return

	visible = true
	_in_pool = false

	flash_rect.color = flash_color

	var tween := create_tween()
	tween.tween_property(flash_rect, "color:a", flash_color.a, duration * 0.3)
	tween.tween_property(flash_rect, "color:a", 0.0, duration * 0.7)

	tween.tween_callback(_return_to_pool)


func _return_to_pool() -> void:
	visible = false
	if flash_rect:
		flash_rect.color.a = 0.0
	_in_pool = true


## Check if this instance is available in the pool
func is_available() -> bool:
	return _in_pool
