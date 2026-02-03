extends Node
## MonetizationManager autoload singleton for gating and managing monetization.
##
## Follows research showing top idle games wait until Day 3+ before showing ads.
## Front-loading monetization is a key mistake - players must feel invested first.
##
## Design Principles:
## - No monetization until player is invested (first upgrade purchased, 3+ runs, or 15min playtime)
## - Rewarded videos only - helpful, not intrusive
## - 'Ads that bail players out, not slow them down' achieve 42% engagement vs 25-30% average
## - Player can always decline with no penalty

signal monetization_unlocked  ## Emitted when player becomes eligible for monetization
signal rewarded_ad_available(offer_type: String)  ## Emitted when a reward offer can be shown
signal rewarded_ad_completed(reward_type: String, amount: int)  ## Emitted when player receives reward
signal rewarded_ad_declined(offer_type: String)  ## Emitted when player declines offer (no penalty)

## Monetization readiness gates - ALL conditions must be met (but any ONE path works)
## Path 1: First upgrade purchased (most engaged players)
## Path 2: 3+ successful mining runs (exploration-focused players)
## Path 3: 15+ minutes total playtime (time-invested players)
const GATE_MIN_SUCCESSFUL_RUNS := 3
const GATE_MIN_PLAYTIME_SECONDS := 15.0 * 60.0  # 15 minutes

## Reward types and amounts
const REWARD_STUCK_LADDERS := 3  # Free ladders when player is stuck deep underground
const REWARD_COIN_BOOST_PCT := 0.25  # 25% bonus on next sale
const REWARD_REVIVE_HP_PCT := 0.5  # Revive with 50% HP after death

## State tracking
var _monetization_unlocked: bool = false
var _successful_runs: int = 0  # Runs where player returned with loot
var _total_playtime_seconds: float = 0.0

## Pending reward offers (only one active at a time)
var _pending_offer_type: String = ""
var _pending_offer_shown: bool = false

## Ad tracking for analytics
var _ads_offered: int = 0
var _ads_watched: int = 0
var _ads_declined: int = 0


func _ready() -> void:
	# Connect to relevant signals for tracking
	if SaveManager:
		SaveManager.load_completed.connect(_on_load_completed)

	if GameManager:
		if GameManager.has_signal("successful_run_completed"):
			GameManager.successful_run_completed.connect(_on_successful_run)

	print("[MonetizationManager] Ready - monetization initially locked")


func _process(delta: float) -> void:
	# Track playtime (only when actively playing)
	if SaveManager and SaveManager.is_game_loaded():
		_total_playtime_seconds += delta

		# Check if we've crossed the time threshold
		if not _monetization_unlocked and _total_playtime_seconds >= GATE_MIN_PLAYTIME_SECONDS:
			_check_unlock_eligibility()


## Check if monetization features should be unlocked
func _check_unlock_eligibility() -> void:
	if _monetization_unlocked:
		return  # Already unlocked

	var eligible := false
	var reason := ""

	# Path 1: First upgrade purchased (shows engagement with core loop)
	if SaveManager and SaveManager.has_first_upgrade_purchased():
		eligible = true
		reason = "first upgrade purchased"

	# Path 2: Multiple successful runs (shows retention)
	elif _successful_runs >= GATE_MIN_SUCCESSFUL_RUNS:
		eligible = true
		reason = "%d successful runs completed" % _successful_runs

	# Path 3: Time invested (shows interest even without completion)
	elif _total_playtime_seconds >= GATE_MIN_PLAYTIME_SECONDS:
		eligible = true
		reason = "%.0f minutes played" % (_total_playtime_seconds / 60.0)

	if eligible:
		_monetization_unlocked = true
		print("[MonetizationManager] Monetization unlocked: %s" % reason)
		monetization_unlocked.emit()


## Check if monetization is currently available
func is_monetization_unlocked() -> bool:
	if not _monetization_unlocked:
		_check_unlock_eligibility()  # Recheck in case state changed
	return _monetization_unlocked


## Track a successful run (returned to surface with loot)
func track_successful_run() -> void:
	_successful_runs += 1
	print("[MonetizationManager] Successful run #%d completed" % _successful_runs)
	_check_unlock_eligibility()


## Track when the player gets stuck (low health, no ladders, deep underground)
## Returns true if an ad offer is available
func check_stuck_offer(depth: int, ladder_count: int, hp_percent: float) -> bool:
	if not is_monetization_unlocked():
		return false

	if _pending_offer_shown:
		return false  # Don't spam offers

	# Conditions for being "stuck": deep, low resources, low health
	var is_deep := depth >= 50  # Deep enough that climbing back is tedious
	var low_ladders := ladder_count <= 1
	var low_health := hp_percent <= 0.3

	if is_deep and (low_ladders or low_health):
		_pending_offer_type = "stuck_ladders"
		rewarded_ad_available.emit(_pending_offer_type)
		_ads_offered += 1
		return true

	return false


## Show the stuck recovery ad offer (called by UI)
func show_stuck_recovery_offer() -> void:
	if not is_monetization_unlocked():
		push_warning("[MonetizationManager] Cannot show offer - monetization locked")
		return

	_pending_offer_type = "stuck_ladders"
	_pending_offer_shown = true
	rewarded_ad_available.emit(_pending_offer_type)
	_ads_offered += 1


## Player watched the ad and gets reward
func on_rewarded_ad_completed() -> void:
	_ads_watched += 1
	_pending_offer_shown = false

	match _pending_offer_type:
		"stuck_ladders":
			_grant_stuck_ladders_reward()
		"coin_boost":
			_grant_coin_boost_reward()
		"revive":
			_grant_revive_reward()
		_:
			push_warning("[MonetizationManager] Unknown reward type: %s" % _pending_offer_type)

	_pending_offer_type = ""


## Player declined the ad (no penalty, just track for analytics)
func on_rewarded_ad_declined() -> void:
	_ads_declined += 1
	_pending_offer_shown = false

	rewarded_ad_declined.emit(_pending_offer_type)
	print("[MonetizationManager] Player declined %s offer (no penalty)" % _pending_offer_type)

	_pending_offer_type = ""


## Grant the stuck ladders reward
func _grant_stuck_ladders_reward() -> void:
	if InventoryManager and DataRegistry:
		var ladder_item = DataRegistry.get_item("ladder")
		if ladder_item:
			InventoryManager.add_item(ladder_item, REWARD_STUCK_LADDERS)
			print("[MonetizationManager] Granted %d ladders from ad reward" % REWARD_STUCK_LADDERS)
			rewarded_ad_completed.emit("stuck_ladders", REWARD_STUCK_LADDERS)


## Grant the coin boost reward
func _grant_coin_boost_reward() -> void:
	# Set a flag for the shop to apply bonus on next sale
	# This would need to be tracked and applied in shop.gd
	print("[MonetizationManager] Coin boost reward activated (+%d%%)" % int(REWARD_COIN_BOOST_PCT * 100))
	rewarded_ad_completed.emit("coin_boost", int(REWARD_COIN_BOOST_PCT * 100))


## Grant the revive reward
func _grant_revive_reward() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("heal"):
		var max_hp: int = player.MAX_HP if "MAX_HP" in player else 100
		var heal_amount := int(max_hp * REWARD_REVIVE_HP_PCT)
		player.heal(heal_amount)
		print("[MonetizationManager] Revived player with %d HP" % heal_amount)
		rewarded_ad_completed.emit("revive", heal_amount)


# ============================================
# ANALYTICS HELPERS
# ============================================

## Get conversion rate (ads watched / ads offered)
func get_ad_conversion_rate() -> float:
	if _ads_offered == 0:
		return 0.0
	return float(_ads_watched) / float(_ads_offered)


## Get analytics data for tracking
func get_analytics_data() -> Dictionary:
	return {
		"monetization_unlocked": _monetization_unlocked,
		"successful_runs": _successful_runs,
		"total_playtime_minutes": _total_playtime_seconds / 60.0,
		"ads_offered": _ads_offered,
		"ads_watched": _ads_watched,
		"ads_declined": _ads_declined,
		"conversion_rate": get_ad_conversion_rate(),
	}


# ============================================
# SAVE/LOAD
# ============================================

func get_save_data() -> Dictionary:
	return {
		"monetization_unlocked": _monetization_unlocked,
		"successful_runs": _successful_runs,
		"total_playtime_seconds": _total_playtime_seconds,
		"ads_offered": _ads_offered,
		"ads_watched": _ads_watched,
		"ads_declined": _ads_declined,
	}


func load_save_data(data: Dictionary) -> void:
	_monetization_unlocked = data.get("monetization_unlocked", false)
	_successful_runs = data.get("successful_runs", 0)
	_total_playtime_seconds = data.get("total_playtime_seconds", 0.0)
	_ads_offered = data.get("ads_offered", 0)
	_ads_watched = data.get("ads_watched", 0)
	_ads_declined = data.get("ads_declined", 0)

	print("[MonetizationManager] Loaded - monetization %s, %d runs, %.1f min playtime" % [
		"unlocked" if _monetization_unlocked else "locked",
		_successful_runs,
		_total_playtime_seconds / 60.0
	])


func reset() -> void:
	_monetization_unlocked = false
	_successful_runs = 0
	_total_playtime_seconds = 0.0
	_pending_offer_type = ""
	_pending_offer_shown = false
	_ads_offered = 0
	_ads_watched = 0
	_ads_declined = 0
	print("[MonetizationManager] Reset to defaults - monetization locked")


# ============================================
# SIGNAL HANDLERS
# ============================================

func _on_load_completed(_success: bool) -> void:
	# After load, recheck eligibility in case stats qualify
	_check_unlock_eligibility()


func _on_successful_run() -> void:
	track_successful_run()
