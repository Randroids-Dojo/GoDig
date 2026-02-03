extends Node
## GoDig UI Theme Manager
##
## Provides centralized access to the game's custom theme and
## defines mobile-friendly UI constants for touch targets and spacing.
## All UI scenes should use this theme for consistent styling.

# ============================================
# UI CONSTANTS - Mobile Touch Requirements
# ============================================

## Minimum touch target size in pixels (Apple/Google guidelines: 44-48px)
const TOUCH_TARGET_MIN := 48

## Recommended button size for primary actions
const BUTTON_PRIMARY_SIZE := Vector2(200, 56)

## Recommended button size for secondary actions
const BUTTON_SECONDARY_SIZE := Vector2(140, 48)

## Touch button size for action buttons (jump, dig, etc.)
const TOUCH_BUTTON_SIZE := Vector2(100, 100)

## Inventory slot size (larger for touch-friendly interactions)
const SLOT_SIZE := Vector2(80, 80)

## Minimum spacing between touch targets
const TOUCH_SPACING := 8

## Panel padding
const PANEL_PADDING := 16

## Panel margin from screen edges
const PANEL_MARGIN := 20

# ============================================
# THEME COLORS - Mining Game Palette
# ============================================

## Primary earth tone colors
const COLOR_EARTH_DARK := Color(0.12, 0.1, 0.09)
const COLOR_EARTH_MID := Color(0.25, 0.22, 0.2)
const COLOR_EARTH_LIGHT := Color(0.45, 0.38, 0.3)

## Border/accent colors
const COLOR_BORDER := Color(0.55, 0.45, 0.35)
const COLOR_BORDER_HIGHLIGHT := Color(0.8, 0.65, 0.4)

## Text colors
const COLOR_TEXT := Color(0.9, 0.85, 0.75)
const COLOR_TEXT_HIGHLIGHT := Color(1.0, 0.95, 0.85)
const COLOR_TEXT_DISABLED := Color(0.5, 0.45, 0.4, 0.6)

## Health bar color
const COLOR_HEALTH := Color(0.7, 0.25, 0.2)
const COLOR_HEALTH_LOW := Color(0.85, 0.2, 0.15)

## Currency/gold color
const COLOR_GOLD := Color(0.95, 0.8, 0.3)

## Rarity colors for items
const COLOR_COMMON := Color(0.7, 0.7, 0.7)
const COLOR_UNCOMMON := Color(0.3, 0.8, 0.3)
const COLOR_RARE := Color(0.3, 0.5, 0.9)
const COLOR_EPIC := Color(0.7, 0.3, 0.9)
const COLOR_LEGENDARY := Color(0.95, 0.7, 0.2)

# ============================================
# THEME RESOURCE
# ============================================

var game_theme: Theme = null

# ============================================
# LIFECYCLE
# ============================================

func _ready() -> void:
	_load_theme()
	print("[UITheme] Ready - mobile-friendly theme loaded")


func _load_theme() -> void:
	game_theme = load("res://resources/themes/game_theme.tres") as Theme
	if game_theme == null:
		push_warning("[UITheme] Failed to load game theme, using default")
		game_theme = Theme.new()


# ============================================
# PUBLIC API
# ============================================

## Apply the game theme to a Control node and all its children
func apply_theme(control: Control) -> void:
	if control and game_theme:
		control.theme = game_theme


## Get the game theme for manual assignment
func get_theme() -> Theme:
	return game_theme


## Get appropriate button size based on button type
func get_button_size(is_primary: bool = true) -> Vector2:
	var base_size := BUTTON_PRIMARY_SIZE if is_primary else BUTTON_SECONDARY_SIZE
	# Scale based on user's button size preference
	var scale := SettingsManager.button_size_scale
	return Vector2(base_size.x * scale, base_size.y * scale)


## Get scaled touch button size for action buttons
func get_touch_button_size() -> Vector2:
	var scale := SettingsManager.button_size_scale
	return TOUCH_BUTTON_SIZE * scale


## Get scaled inventory slot size
func get_slot_size() -> Vector2:
	var scale := SettingsManager.button_size_scale
	return SLOT_SIZE * scale


## Ensure a control meets minimum touch target requirements
func ensure_touch_friendly(control: Control) -> void:
	if control.custom_minimum_size.x < TOUCH_TARGET_MIN:
		control.custom_minimum_size.x = TOUCH_TARGET_MIN
	if control.custom_minimum_size.y < TOUCH_TARGET_MIN:
		control.custom_minimum_size.y = TOUCH_TARGET_MIN


## Get rarity color for an item
func get_rarity_color(rarity: String) -> Color:
	match rarity.to_lower():
		"common":
			return COLOR_COMMON
		"uncommon":
			return COLOR_UNCOMMON
		"rare":
			return COLOR_RARE
		"epic":
			return COLOR_EPIC
		"legendary":
			return COLOR_LEGENDARY
		_:
			return COLOR_COMMON


## Create a styled button programmatically
func create_styled_button(text: String, is_primary: bool = true) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = get_button_size(is_primary)
	if game_theme:
		button.theme = game_theme
	return button


## Create a panel with consistent styling
func create_styled_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	if game_theme:
		panel.theme = game_theme
	return panel
