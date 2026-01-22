extends Control
## UILayout - Base layout system for portrait mode UI.
##
## Provides safe area handling, anchor utilities, and standard layout zones
## for 720x1280 portrait orientation with proper mobile device support.

## Standard UI element sizes (in pixels at 720w base resolution)
const BUTTON_SIZE_SMALL: int = 88    # 48dp minimum touch target
const BUTTON_SIZE_MEDIUM: int = 118  # 64dp recommended
const BUTTON_SIZE_LARGE: int = 148   # 80dp for primary actions

const TEXT_SIZE_BODY: int = 29       # 16sp
const TEXT_SIZE_HEADER: int = 37     # 20sp
const TEXT_SIZE_HUD: int = 44        # 24sp

const MARGIN_STANDARD: int = 16
const MARGIN_LARGE: int = 24
const MARGIN_SMALL: int = 8
const BUTTON_SPACING: int = 12

## Layout zone heights
const STATUS_BAR_HEIGHT: int = 60
const TOP_HUD_HEIGHT: int = 120
const BOTTOM_CONTROLS_HEIGHT: int = 220

## Anchor presets for common UI positions
enum Anchor {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	CENTER_LEFT,
	CENTER,
	CENTER_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT,
	TOP_FULL,
	BOTTOM_FULL,
	LEFT_FULL,
	RIGHT_FULL,
	FULL
}

## References to layout containers
@onready var safe_area_container: MarginContainer = $SafeAreaContainer
@onready var top_hud: Control = $SafeAreaContainer/TopHUD
@onready var bottom_controls: Control = $SafeAreaContainer/BottomControls
@onready var fullscreen_overlays: Control = $FullscreenOverlays


func _ready() -> void:
	# Apply safe area margins on startup
	_apply_safe_area_margins()

	# React to window size changes (device rotation, split-screen, etc)
	get_tree().root.size_changed.connect(_apply_safe_area_margins)


## Get the safe area insets for the current device
func get_safe_area_insets() -> Dictionary:
	var safe_area := DisplayServer.get_display_safe_area()
	var screen_size := DisplayServer.screen_get_size()

	return {
		"top": safe_area.position.y,
		"bottom": screen_size.y - safe_area.end.y,
		"left": safe_area.position.x,
		"right": screen_size.x - safe_area.end.x
	}


## Apply safe area margins to the container
func _apply_safe_area_margins() -> void:
	if not safe_area_container:
		return

	var insets := get_safe_area_insets()

	# Ensure minimum safe area for standard devices
	var top_margin := maxi(STATUS_BAR_HEIGHT, int(insets["top"]))
	var bottom_margin := maxi(40, int(insets["bottom"]))
	var left_margin := maxi(0, int(insets["left"]))
	var right_margin := maxi(0, int(insets["right"]))

	safe_area_container.add_theme_constant_override("margin_top", top_margin)
	safe_area_container.add_theme_constant_override("margin_bottom", bottom_margin)
	safe_area_container.add_theme_constant_override("margin_left", left_margin)
	safe_area_container.add_theme_constant_override("margin_right", right_margin)


## Apply standard anchor preset to a control node
static func apply_anchor(control: Control, anchor: Anchor) -> void:
	if not control:
		return

	match anchor:
		Anchor.TOP_LEFT:
			control.anchor_left = 0.0
			control.anchor_right = 0.0
			control.anchor_top = 0.0
			control.anchor_bottom = 0.0
			control.grow_horizontal = Control.GROW_DIRECTION_END
			control.grow_vertical = Control.GROW_DIRECTION_END

		Anchor.TOP_CENTER:
			control.anchor_left = 0.5
			control.anchor_right = 0.5
			control.anchor_top = 0.0
			control.anchor_bottom = 0.0
			control.grow_horizontal = Control.GROW_DIRECTION_BOTH
			control.grow_vertical = Control.GROW_DIRECTION_END

		Anchor.TOP_RIGHT:
			control.anchor_left = 1.0
			control.anchor_right = 1.0
			control.anchor_top = 0.0
			control.anchor_bottom = 0.0
			control.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			control.grow_vertical = Control.GROW_DIRECTION_END

		Anchor.CENTER_LEFT:
			control.anchor_left = 0.0
			control.anchor_right = 0.0
			control.anchor_top = 0.5
			control.anchor_bottom = 0.5
			control.grow_horizontal = Control.GROW_DIRECTION_END
			control.grow_vertical = Control.GROW_DIRECTION_BOTH

		Anchor.CENTER:
			control.anchor_left = 0.5
			control.anchor_right = 0.5
			control.anchor_top = 0.5
			control.anchor_bottom = 0.5
			control.grow_horizontal = Control.GROW_DIRECTION_BOTH
			control.grow_vertical = Control.GROW_DIRECTION_BOTH

		Anchor.CENTER_RIGHT:
			control.anchor_left = 1.0
			control.anchor_right = 1.0
			control.anchor_top = 0.5
			control.anchor_bottom = 0.5
			control.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			control.grow_vertical = Control.GROW_DIRECTION_BOTH

		Anchor.BOTTOM_LEFT:
			control.anchor_left = 0.0
			control.anchor_right = 0.0
			control.anchor_top = 1.0
			control.anchor_bottom = 1.0
			control.grow_horizontal = Control.GROW_DIRECTION_END
			control.grow_vertical = Control.GROW_DIRECTION_BEGIN

		Anchor.BOTTOM_CENTER:
			control.anchor_left = 0.5
			control.anchor_right = 0.5
			control.anchor_top = 1.0
			control.anchor_bottom = 1.0
			control.grow_horizontal = Control.GROW_DIRECTION_BOTH
			control.grow_vertical = Control.GROW_DIRECTION_BEGIN

		Anchor.BOTTOM_RIGHT:
			control.anchor_left = 1.0
			control.anchor_right = 1.0
			control.anchor_top = 1.0
			control.anchor_bottom = 1.0
			control.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			control.grow_vertical = Control.GROW_DIRECTION_BEGIN

		Anchor.TOP_FULL:
			control.anchor_left = 0.0
			control.anchor_right = 1.0
			control.anchor_top = 0.0
			control.anchor_bottom = 0.0
			control.grow_horizontal = Control.GROW_DIRECTION_BOTH
			control.grow_vertical = Control.GROW_DIRECTION_END

		Anchor.BOTTOM_FULL:
			control.anchor_left = 0.0
			control.anchor_right = 1.0
			control.anchor_top = 1.0
			control.anchor_bottom = 1.0
			control.grow_horizontal = Control.GROW_DIRECTION_BOTH
			control.grow_vertical = Control.GROW_DIRECTION_BEGIN

		Anchor.LEFT_FULL:
			control.anchor_left = 0.0
			control.anchor_right = 0.0
			control.anchor_top = 0.0
			control.anchor_bottom = 1.0
			control.grow_horizontal = Control.GROW_DIRECTION_END
			control.grow_vertical = Control.GROW_DIRECTION_BOTH

		Anchor.RIGHT_FULL:
			control.anchor_left = 1.0
			control.anchor_right = 1.0
			control.anchor_top = 0.0
			control.anchor_bottom = 1.0
			control.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			control.grow_vertical = Control.GROW_DIRECTION_BOTH

		Anchor.FULL:
			control.anchor_left = 0.0
			control.anchor_right = 1.0
			control.anchor_top = 0.0
			control.anchor_bottom = 1.0
			control.grow_horizontal = Control.GROW_DIRECTION_BOTH
			control.grow_vertical = Control.GROW_DIRECTION_BOTH


## Get the top HUD container for adding UI elements
func get_top_hud() -> Control:
	return top_hud


## Get the bottom controls container for adding touch controls
func get_bottom_controls() -> Control:
	return bottom_controls


## Get the fullscreen overlays container for popups and modals
func get_fullscreen_overlays() -> Control:
	return fullscreen_overlays


## Check if a point is within the game view area (not obstructed by UI)
func is_in_game_view_area(point: Vector2) -> bool:
	var viewport_size := get_viewport_rect().size
	var insets := get_safe_area_insets()

	var top_boundary := insets["top"] + TOP_HUD_HEIGHT
	var bottom_boundary := viewport_size.y - BOTTOM_CONTROLS_HEIGHT - insets["bottom"]

	return point.y >= top_boundary and point.y <= bottom_boundary
