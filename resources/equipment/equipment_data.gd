class_name EquipmentData extends Resource
## Resource class for equipment definitions (boots, helmets, etc.).
## Each piece of equipment provides passive bonuses.

enum EquipmentSlot { BOOTS, HELMET, ACCESSORY }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

## Unique identifier for this equipment
@export var id: String = ""

## Display name shown to the player
@export var display_name: String = ""

## Equipment slot type
@export var slot: EquipmentSlot = EquipmentSlot.BOOTS

## Rarity tier (affects color and value)
@export var rarity: Rarity = Rarity.COMMON

## Icon texture for UI/inventory display
@export var icon: Texture2D

## Description text for tooltips
@export var description: String = ""

## Cost to purchase
@export var cost: int = 100

## Depth requirement to unlock
@export var unlock_depth: int = 0

## Tier for sorting/progression (higher = better)
@export var tier: int = 0

# ============================================
# BOOTS-SPECIFIC PROPERTIES
# ============================================

## Fall damage reduction percentage (0.0-1.0)
## 0.0 = no reduction, 1.0 = 100% immunity
@export var fall_damage_reduction: float = 0.0

## Extra fall blocks before damage starts (added to base threshold)
@export var fall_threshold_bonus: int = 0

# ============================================
# HELMET-SPECIFIC PROPERTIES
# ============================================

## Light radius bonus (added to base light radius)
@export var light_radius_bonus: float = 0.0

## Light intensity multiplier
@export var light_intensity_bonus: float = 0.0

# ============================================
# ACCESSORY-SPECIFIC PROPERTIES
# ============================================

## Mining speed bonus multiplier (1.0 = no bonus)
@export var mining_speed_bonus: float = 1.0

## Ore find chance bonus (0.0-1.0 added to base chance)
@export var ore_find_bonus: float = 0.0


## Get effective fall damage after applying reduction
func apply_fall_damage_reduction(damage: float) -> float:
	return damage * (1.0 - fall_damage_reduction)


## Get rarity color for UI display
func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color.WHITE
		Rarity.UNCOMMON: return Color(0.3, 0.9, 0.3)  # Green
		Rarity.RARE: return Color(0.3, 0.5, 0.9)  # Blue
		Rarity.EPIC: return Color(0.7, 0.3, 0.9)  # Purple
		Rarity.LEGENDARY: return Color(1.0, 0.7, 0.2)  # Orange/Gold
	return Color.WHITE


## Get human-readable rarity name
func get_rarity_name() -> String:
	match rarity:
		Rarity.COMMON: return "Common"
		Rarity.UNCOMMON: return "Uncommon"
		Rarity.RARE: return "Rare"
		Rarity.EPIC: return "Epic"
		Rarity.LEGENDARY: return "Legendary"
	return "Unknown"
