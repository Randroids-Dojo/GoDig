"""
Shared test helper functions for PlayGodot tests.

This module contains utilities used across multiple test files to avoid duplication.
"""
import asyncio


# Timeout for waiting operations (seconds)
WAIT_TIMEOUT = 5.0


# =============================================================================
# NODE PATHS
# =============================================================================

# Main Menu paths (when on main menu scene)
MAIN_MENU_PATHS = {
    "main_menu": "/root/MainMenu",
    "main_menu_new_game": "/root/MainMenu/CenterContainer/VBox/ButtonContainer/NewGameButton",
    "main_menu_continue": "/root/MainMenu/CenterContainer/VBox/ButtonContainer/ContinueButton",
    "main_menu_settings": "/root/MainMenu/CenterContainer/VBox/ButtonContainer/SettingsButton",
    "main_menu_version": "/root/MainMenu/VersionLabel",
    "main_menu_title": "/root/MainMenu/CenterContainer/VBox/TitleContainer/TitleLabel",
    "main_menu_subtitle": "/root/MainMenu/CenterContainer/VBox/TitleContainer/SubtitleLabel",
}

# Game scene paths (after navigating from main menu)
PATHS = {
    "main": "/root/Main",
    "player": "/root/Main/Player",
    "dirt_grid": "/root/Main/DirtGrid",
    "camera": "/root/Main/Player/Camera2D",
    "shop_button": "/root/Main/UI/ShopButton",
    "shop": "/root/Main/UI/Shop",
    "game_manager": "/root/GameManager",
    "data_registry": "/root/DataRegistry",
    "inventory_manager": "/root/InventoryManager",
    "save_manager": "/root/SaveManager",
    "player_data": "/root/PlayerData",
    "settings_manager": "/root/SettingsManager",
    "platform_detector": "/root/PlatformDetector",
    "touch_controls": "/root/Main/UI/TouchControls",
    "virtual_joystick": "/root/Main/UI/TouchControls/VirtualJoystick",
    "action_buttons": "/root/Main/UI/TouchControls/ActionButtons",
    "jump_button": "/root/Main/UI/TouchControls/ActionButtons/JumpButton",
    "inventory_button": "/root/Main/UI/TouchControls/ActionButtons/InventoryButton",
    "player_sprite": "/root/Main/Player/AnimatedSprite2D",
    "player_collision": "/root/Main/Player/CollisionShape2D",
    "pause_menu": "/root/Main/PauseMenu",
    "pause_menu_resume": "/root/Main/PauseMenu/Panel/VBox/ResumeButton",
    "pause_menu_settings": "/root/Main/PauseMenu/Panel/VBox/SettingsButton",
    "pause_menu_rescue": "/root/Main/PauseMenu/Panel/VBox/RescueButton",
    "pause_menu_reload": "/root/Main/PauseMenu/Panel/VBox/ReloadButton",
    "pause_menu_quit": "/root/Main/PauseMenu/Panel/VBox/QuitButton",
    "pause_menu_confirm_dialog": "/root/Main/PauseMenu/ConfirmDialog",
    "hud": "/root/Main/UI/HUD",
    "health_bar": "/root/Main/UI/HUD/HealthBar",
    "health_label": "/root/Main/UI/HUD/HealthBar/HealthLabel",
    "low_health_vignette": "/root/Main/UI/HUD/LowHealthVignette",
    "hud_coins_label": "/root/Main/UI/HUD/CoinsLabel",
    "hud_depth_label": "/root/Main/UI/HUD/DepthLabel",
    "hud_pause_button": "/root/Main/UI/HUD/PauseButton",
    # Aliases for backward compatibility
    "coins_label": "/root/Main/UI/HUD/CoinsLabel",
    "depth_label": "/root/Main/UI/HUD/DepthLabel",
    "pause_button": "/root/Main/UI/HUD/PauseButton",
    "floating_text_layer": "/root/Main/FloatingTextLayer",
    "surface": "/root/Main/Surface",
    "surface_sky": "/root/Main/Surface/Sky",
    "surface_ground": "/root/Main/Surface/Ground",
    "surface_spawn_point": "/root/Main/Surface/SpawnPoint",
    "surface_shop_building": "/root/Main/Surface/ShopBuilding",
    "surface_mine_entrance": "/root/Main/Surface/MineEntrance",
    "death_screen": "/root/Main/DeathScreen",
    "milestone_notification": "/root/Main/UI/HUD/MilestoneNotification",
    "player_stats": "/root/PlayerStats",
    "haptic_feedback": "/root/HapticFeedback",
    "hud": "/root/Main/UI/HUD",
    "upgrade_goal_container": "/root/Main/UI/HUD/UpgradeGoalContainer",
    "save_indicator_label": "/root/Main/UI/HUD/SaveIndicatorLabel",
    "ladder_quickslot": "/root/Main/UI/HUD/LadderQuickSlot",
    "surface_parallax": "/root/Main/Surface/ParallaxBackground",
    "lighting_manager": "/root/LightingManager",
    "ambient_modulate": "/root/Main/AmbientModulate",
    "mining_progress_container": "/root/Main/UI/HUD/MiningProgressContainer",
    "mining_progress_bar": "/root/Main/UI/HUD/MiningProgressContainer/MiningProgressBar",
    "depth_record_label": "/root/Main/UI/HUD/DepthRecordLabel",
    "inventory_value_label": "/root/Main/UI/HUD/InventoryValueLabel",
    "sound_manager": "/root/SoundManager",
    "localization_manager": "/root/LocalizationManager",
    "analytics_manager": "/root/AnalyticsManager",
    "tutorial_overlay": "/root/Main/TutorialOverlay",
    "daily_rewards_manager": "/root/DailyRewardsManager",
    "day_night_manager": "/root/DayNightManager",
    "prestige_manager": "/root/PrestigeManager",
    "enemy_manager": "/root/EnemyManager",
    "biome_manager": "/root/BiomeManager",
    "cave_layer_manager": "/root/CaveLayerManager",
    "economy_config": "/root/EconomyConfig",
    "danger_zone_manager": "/root/DangerZoneManager",
    "performance_monitor": "/root/PerformanceMonitor",
    "frustration_tracker": "/root/FrustrationTracker",
    "mining_bonus_manager": "/root/MiningBonusManager",
    "exploration_manager": "/root/ExplorationManager",
    "journal_manager": "/root/JournalManager",
    "treasure_room_manager": "/root/TreasureRoomManager",
    "monetization_manager": "/root/MonetizationManager",
    "welcome_back_manager": "/root/WelcomeBackManager",
}


# =============================================================================
# WAIT HELPERS
# =============================================================================
async def wait_for_condition(game, check_fn, timeout=WAIT_TIMEOUT):
    """Wait for a condition function to return True with timeout.

    Args:
        game: The PlayGodot game instance
        check_fn: Async function that returns True when condition is met
        timeout: Maximum wait time in seconds

    Returns:
        True if condition was met, False if timeout
    """
    elapsed = 0
    while elapsed < timeout:
        if await check_fn():
            return True
        await asyncio.sleep(0.1)
        elapsed += 0.1
    return False


async def wait_for_node(game, path, timeout=WAIT_TIMEOUT):
    """Wait for a node to exist.

    Args:
        game: The PlayGodot game instance
        path: Node path to wait for
        timeout: Maximum wait time in seconds

    Returns:
        True if node exists, False if timeout
    """
    async def node_exists():
        result = await game.node_exists(path)
        return result.get("exists", False)

    return await wait_for_condition(game, node_exists, timeout)
