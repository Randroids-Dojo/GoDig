class_name UIColors
extends RefCounted
## Unified UI color palette for GoDig.
##
## This class provides a consistent color language across all HUD and UI elements.
## Use these constants instead of hardcoded colors to ensure visual consistency.
##
## Color categories:
## - Primary: Gold, Green, Blue - The core 3-color palette
## - Status: Health states, warnings, danger indicators
## - Panel: Backgrounds and button colors
## - Text: Font colors and outlines

# =============================================================================
# PRIMARY COLORS - The core 3-color palette
# =============================================================================

## Gold/Amber - For coins, upgrades, positive highlights, achievements
const GOLD := Color(1.0, 0.85, 0.2)
const GOLD_BRIGHT := Color(1.0, 0.9, 0.3)
const GOLD_DIM := Color(0.8, 0.7, 0.15)

## Green - For health, inventory, confirmations, success states
const GREEN := Color(0.3, 0.9, 0.3)
const GREEN_BRIGHT := Color(0.4, 1.0, 0.4)
const GREEN_DIM := Color(0.3, 0.7, 0.3)
const GREEN_HEALTH := Color(0.3, 0.8, 0.3)

## Blue - For depth, information, neutral indicators
const BLUE := Color(0.4, 0.7, 1.0)
const BLUE_LIGHT := Color(0.7, 0.8, 1.0)
const BLUE_DIM := Color(0.3, 0.5, 0.8)

# =============================================================================
# STATUS COLORS - Health and warning states
# =============================================================================

## Health bar states
const HEALTH_FULL := Color(0.3, 0.8, 0.3)       # Green - healthy
const HEALTH_MEDIUM := Color(1.0, 0.6, 0.2)    # Orange - caution
const HEALTH_LOW := Color(1.0, 0.2, 0.2)       # Red - danger

## Warning levels
const WARNING_YELLOW := Color(1.0, 0.8, 0.2)   # Yellow warning
const WARNING_ORANGE := Color(1.0, 0.5, 0.2)   # Orange warning
const WARNING_RED := Color(1.0, 0.3, 0.2)      # Red urgent

## Warning backgrounds
const WARNING_BG_YELLOW := Color(0.5, 0.35, 0.1, 0.9)
const WARNING_BG_RED := Color(0.6, 0.15, 0.1, 0.95)

## Record/Achievement - Magenta/Pink for special moments
const RECORD := Color(1.0, 0.5, 0.9)

# =============================================================================
# PANEL COLORS - Backgrounds and containers
# =============================================================================

## Panel backgrounds
const PANEL_DARK := Color(0.1, 0.1, 0.15, 0.85)
const PANEL_MEDIUM := Color(0.15, 0.15, 0.2, 0.9)
const PANEL_LIGHT := Color(0.2, 0.2, 0.25, 0.7)

## Toast/notification backgrounds
const TOAST_BG_SUCCESS := Color(0.15, 0.35, 0.15, 0.95)
const TOAST_BG_INFO := Color(0.1, 0.1, 0.1, 0.85)

## Mining progress background
const MINING_BG := Color(0.1, 0.1, 0.1, 0.85)

## Streak indicator background
const STREAK_BG := Color(0.2, 0.2, 0.25, 0.7)

# =============================================================================
# TEXT COLORS - Font colors and outlines
# =============================================================================

## Standard text
const TEXT_WHITE := Color(1.0, 1.0, 1.0)
const TEXT_LIGHT := Color(0.9, 0.9, 0.9)
const TEXT_MEDIUM := Color(0.7, 0.7, 0.7)
const TEXT_DIM := Color(0.5, 0.5, 0.5)
const TEXT_DISABLED := Color(0.6, 0.6, 0.6)

## Text outline for readability
const OUTLINE := Color(0.0, 0.0, 0.0, 0.9)
const OUTLINE_SIZE := 3

## Streak text colors
const STREAK_NORMAL := Color(0.8, 0.9, 1.0)    # Subtle blue-white
const STREAK_HOT := Color(1.0, 0.9, 0.5)       # Gold for "in the zone"

# =============================================================================
# ITEM/SLOT COLORS - Quickslot and inventory states
# =============================================================================

## Quickslot states
const SLOT_EMPTY_TEXT := Color(0.6, 0.6, 0.6)
const SLOT_EMPTY_MODULATE := Color(0.7, 0.7, 0.7, 1.0)
const SLOT_ALERT := Color(1.0, 0.4, 0.4)

## Ladder color (tan/brown)
const LADDER := Color(0.9, 0.7, 0.4)

# =============================================================================
# PROGRESS BAR COLORS - Mining and upgrade progress
# =============================================================================

## Mining progress states
const MINING_LOW := Color(0.8, 0.8, 0.8)       # Gray - just started
const MINING_MID := Color(0.9, 0.9, 0.5)       # Yellow - making progress
const MINING_HIGH := Color(0.5, 1.0, 0.5)      # Green - almost done

## Tool durability
const DURABILITY_GOOD := Color(0.4, 0.8, 0.4)
const DURABILITY_TEXT := Color(0.7, 0.7, 0.7)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

## Apply standard dark outline to a label for readability
static func apply_outline(label: Label, size: int = OUTLINE_SIZE, color: Color = OUTLINE) -> void:
	label.add_theme_constant_override("outline_size", size)
	label.add_theme_color_override("font_outline_color", color)


## Set label font color
static func set_font_color(label: Label, color: Color) -> void:
	label.add_theme_color_override("font_color", color)
