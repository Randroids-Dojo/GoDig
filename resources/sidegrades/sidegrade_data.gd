class_name SidegradeData extends Resource
## Resource class for sidegrade definitions.
## Sidegrades are lateral upgrades that provide new OPTIONS/ABILITIES
## rather than pure stat increases. They expand player playstyles
## without trivializing early content.
##
## Design philosophy (from roguelite research):
## - Pure stat progression leads to "inverse difficulty curve"
## - Sidegrades let experienced players explore new strategies
## - Each sidegrade should enable a distinct playstyle

## Categories of sidegrades
enum Category {
	MINING_STYLE,      ## Different approaches to mining
	MOVEMENT,          ## New traversal abilities
	RESOURCE_HANDLING, ## Inventory/loot management changes
	EXPLORATION,       ## Discovery and navigation aids
	SURVIVAL,          ## Risk/reward trade-offs
}

## Unique identifier for this sidegrade
@export var id: String = ""

## Display name shown to the player
@export var display_name: String = ""

## Short description of what it does
@export var description: String = ""

## Detailed explanation of trade-offs and usage
@export_multiline var detailed_description: String = ""

## Category for shop organization
@export var category: Category = Category.MINING_STYLE

## Cost in coins to purchase
@export var cost: int = 5000

## Minimum max_depth required to unlock in shop
@export var unlock_depth: int = 200

## Icon for UI display
@export var icon: Texture2D

## Whether this sidegrade is mutually exclusive with others
## Empty array = can be combined with anything
## Non-empty = cannot be used with these sidegrade IDs simultaneously
@export var exclusive_with: Array[String] = []

## Whether this sidegrade has trade-offs (true sidegrades have downsides)
@export var has_trade_off: bool = true

## Color tint for UI (helps players identify category at a glance)
@export var ui_color: Color = Color.WHITE


# ============================================
# MINING STYLE PROPERTIES
# ============================================

@export_group("Mining Style")

## Mining damage multiplier (1.0 = normal)
## Sidegrades may reduce this in exchange for other benefits
@export var damage_multiplier: float = 1.0

## Mining speed multiplier (1.0 = normal)
@export var speed_multiplier: float = 1.0

## Chance to get double resources from ores (0.0 - 1.0)
@export_range(0.0, 1.0) var double_drop_chance: float = 0.0

## Chance to mine adjacent blocks (chain mining)
@export_range(0.0, 1.0) var chain_mining_chance: float = 0.0

## Blocks mined don't drop resources but mine much faster
@export var speed_mining_mode: bool = false


# ============================================
# MOVEMENT PROPERTIES
# ============================================

@export_group("Movement")

## Allow wall jumping (cling to walls briefly)
@export var wall_jump_enabled: bool = false

## Allow wall sliding (slow descent on walls)
@export var wall_slide_enabled: bool = false

## Allow quick dropping through ladders
@export var ladder_slide_enabled: bool = false

## Extra air jumps available (0 = none)
@export var extra_jumps: int = 0

## Movement speed multiplier (1.0 = normal)
@export var move_speed_multiplier: float = 1.0

## Fall damage multiplier (1.0 = normal, 0.0 = immune)
@export var fall_damage_multiplier: float = 1.0


# ============================================
# RESOURCE HANDLING PROPERTIES
# ============================================

@export_group("Resource Handling")

## Auto-sell low-value items when inventory full
@export var auto_sell_junk: bool = false

## Threshold value for auto-sell (items below this sell automatically)
@export var auto_sell_threshold: int = 10

## Auto-stack resources from ground (magnet effect)
@export var auto_pickup_enabled: bool = false

## Range for auto-pickup (in blocks)
@export var auto_pickup_range: float = 0.0

## Sell value multiplier (may be < 1.0 as trade-off)
@export var sell_value_multiplier: float = 1.0


# ============================================
# EXPLORATION PROPERTIES
# ============================================

@export_group("Exploration")

## Extended ore detection range
@export var ore_detection_enabled: bool = false

## Ore detection range (in blocks)
@export var ore_detection_range: float = 0.0

## Show path hints back to surface
@export var path_hint_enabled: bool = false

## Remember previously explored areas
@export var auto_map_enabled: bool = false

## Light radius multiplier
@export var light_radius_multiplier: float = 1.0


# ============================================
# SURVIVAL PROPERTIES
# ============================================

@export_group("Survival")

## Emergency teleport charges per dive (0 = disabled)
@export var emergency_teleport_charges: int = 0

## Second chance - survive one fatal hit per dive
@export var second_chance_enabled: bool = false

## Health regen while standing still (HP per second)
@export var idle_regen_rate: float = 0.0

## Max HP multiplier (may be < 1.0 for glass cannon builds)
@export var max_hp_multiplier: float = 1.0


# ============================================
# HELPER METHODS
# ============================================

## Get formatted trade-off text for UI
func get_trade_off_text() -> String:
	var drawbacks: Array[String] = []

	if damage_multiplier < 1.0:
		drawbacks.append("-%d%% mining damage" % int((1.0 - damage_multiplier) * 100))
	if speed_multiplier < 1.0:
		drawbacks.append("-%d%% mining speed" % int((1.0 - speed_multiplier) * 100))
	if sell_value_multiplier < 1.0:
		drawbacks.append("-%d%% sell value" % int((1.0 - sell_value_multiplier) * 100))
	if max_hp_multiplier < 1.0:
		drawbacks.append("-%d%% max HP" % int((1.0 - max_hp_multiplier) * 100))
	if fall_damage_multiplier > 1.0:
		drawbacks.append("+%d%% fall damage" % int((fall_damage_multiplier - 1.0) * 100))
	if move_speed_multiplier < 1.0:
		drawbacks.append("-%d%% move speed" % int((1.0 - move_speed_multiplier) * 100))

	if drawbacks.is_empty():
		return ""
	return "Trade-off: " + ", ".join(drawbacks)


## Get formatted benefits text for UI
func get_benefits_text() -> String:
	var benefits: Array[String] = []

	# Mining benefits
	if damage_multiplier > 1.0:
		benefits.append("+%d%% mining damage" % int((damage_multiplier - 1.0) * 100))
	if speed_multiplier > 1.0:
		benefits.append("+%d%% mining speed" % int((speed_multiplier - 1.0) * 100))
	if double_drop_chance > 0.0:
		benefits.append("%d%% double drops" % int(double_drop_chance * 100))
	if chain_mining_chance > 0.0:
		benefits.append("%d%% chain mining" % int(chain_mining_chance * 100))
	if speed_mining_mode:
		benefits.append("Speed mining mode")

	# Movement benefits
	if wall_jump_enabled:
		benefits.append("Wall jump")
	if wall_slide_enabled:
		benefits.append("Wall slide")
	if ladder_slide_enabled:
		benefits.append("Ladder slide")
	if extra_jumps > 0:
		benefits.append("+%d air jump%s" % [extra_jumps, "s" if extra_jumps > 1 else ""])
	if move_speed_multiplier > 1.0:
		benefits.append("+%d%% move speed" % int((move_speed_multiplier - 1.0) * 100))
	if fall_damage_multiplier < 1.0:
		benefits.append("-%d%% fall damage" % int((1.0 - fall_damage_multiplier) * 100))

	# Resource handling benefits
	if auto_sell_junk:
		benefits.append("Auto-sell junk")
	if auto_pickup_enabled:
		benefits.append("Resource magnet")
	if sell_value_multiplier > 1.0:
		benefits.append("+%d%% sell value" % int((sell_value_multiplier - 1.0) * 100))

	# Exploration benefits
	if ore_detection_enabled:
		benefits.append("Ore detection (%dm)" % int(ore_detection_range))
	if path_hint_enabled:
		benefits.append("Return path hints")
	if auto_map_enabled:
		benefits.append("Auto-mapping")
	if light_radius_multiplier > 1.0:
		benefits.append("+%d%% light radius" % int((light_radius_multiplier - 1.0) * 100))

	# Survival benefits
	if emergency_teleport_charges > 0:
		benefits.append("%d emergency teleport%s" % [emergency_teleport_charges, "s" if emergency_teleport_charges > 1 else ""])
	if second_chance_enabled:
		benefits.append("Second chance")
	if idle_regen_rate > 0.0:
		benefits.append("Idle HP regen")
	if max_hp_multiplier > 1.0:
		benefits.append("+%d%% max HP" % int((max_hp_multiplier - 1.0) * 100))

	return ", ".join(benefits) if not benefits.is_empty() else description


## Check if this sidegrade conflicts with another
func conflicts_with(other_id: String) -> bool:
	return other_id in exclusive_with


## Get category display name
func get_category_name() -> String:
	match category:
		Category.MINING_STYLE:
			return "Mining Style"
		Category.MOVEMENT:
			return "Movement"
		Category.RESOURCE_HANDLING:
			return "Resources"
		Category.EXPLORATION:
			return "Exploration"
		Category.SURVIVAL:
			return "Survival"
	return "Unknown"
