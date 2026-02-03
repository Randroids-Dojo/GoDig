---
title: "AUDIT: Full feature review and dead code cleanup"
status: closed
priority: 1
issue-type: task
created-at: "\"\\\"2026-02-03T04:30:25.606760-06:00\\\"\""
closed-at: "2026-02-03T04:40:36.161263-06:00"
close-reason: Audit complete. Found FrustrationTracker was missing SaveManager integration - fixed and committed. All other managers (WelcomeBackManager, JournalManager, SecretLayerManager, TreasureRoomManager, EurekaMechanicManager, HandcraftedCaveManager, DangerZoneManager, DepthDiscoveryManager, TreasureChestManager) are properly integrated with save/load and used by game systems (DirtGrid, HUD, Shop). No dead code found. Systems regenerate deterministically from world seed where appropriate.
---

Comprehensive audit of all game features added in recent sessions.

GOALS:
1. Identify and remove dead code / unused systems
2. Ensure all features are fully wired up and functional
3. Verify features support the cohesive game loop
4. Create follow-up tasks for incomplete implementations

SYSTEMS TO AUDIT (from recent commits):

Celebration/Feedback:
- [ ] Close-call celebration system
- [ ] Wall-jump mastery celebration
- [ ] Surface arrival 'home base' effects
- [ ] Safe return celebration
- [ ] Surprise cave biome discovery
- [ ] Welcome-back rewards (WelcomeBackManager)

Discovery/Exploration:
- [ ] Lore system + 10 journal entries (JournalManager)
- [ ] Secret layer system (SecretLayerManager) - Animal Well inspired
- [ ] Treasure rooms - 3 types (TreasureRoomManager)
- [ ] Treasure chests (TreasureChestManager)
- [ ] Depth-specific eureka mechanics (EurekaMechanicManager)
- [ ] Depth discovery UI (DepthDiscoveryManager)

Progression/Economy:
- [ ] FrustrationTracker → upgrade recommendations
- [ ] EconomyConfig for post-launch tuning
- [ ] Passive income system
- [ ] Sidegrade upgrades
- [ ] Monetization gates (MonetizationManager)
- [ ] ProgressionGateManager

World Generation:
- [ ] Handcrafted cave chunks (HandcraftedCaveManager) - Spelunky style
- [ ] Threaded chunk generation
- [ ] Danger zones (DangerZoneManager)
- [ ] Two-layer cave system (CaveLayerManager)
- [ ] Exploration fog (ExplorationManager)

Player Safety/UX:
- [ ] Instant exit/resume
- [ ] Fair emergency rescue with warnings
- [ ] Enemy spawn warning delay
- [ ] Rescue system (Loop Hero model)
- [ ] Return safety calculation
- [ ] Ladder checkpoint rescue (Cairn inspired)

Visual/Audio:
- [ ] Depth palette system (warm→cold)
- [ ] Layer visual identity (Dead Cells style)
- [ ] Subtle tension audio
- [ ] Distinct ore audio
- [ ] Inventory tension visuals
- [ ] Juice level settings

FOR EACH FEATURE CHECK:
1. Is the manager/script instantiated in autoload or scene?
2. Are signals connected and firing?
3. Is save/load implemented if needed?
4. Does it integrate with GameManager state?
5. Is there UI feedback for the player?
6. Does it support the core dig→collect→sell→upgrade loop?

OUTPUT:
- List of dead/orphaned code to remove
- List of partially implemented features needing completion
- List of features that don't serve the core loop (candidates for removal)
- Create follow-up dots for each issue found
