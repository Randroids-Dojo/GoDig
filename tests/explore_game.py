#!/usr/bin/env python3
"""
GoDig Game Exploration Script

A PlayGodot instrumented script for live game control and ad-hoc testing.
Agents can use this to control the game, explore mechanics, and gather feedback.

Usage:
    python tests/explore_game.py                    # Run full exploration
    python tests/explore_game.py --interactive     # Interactive mode for manual commands

Or import and use programmatically:
    from tests.explore_game import GameExplorer
    async with GameExplorer.create() as explorer:
        await explorer.walk_around()

Connection Method:
    Uses PlayGodot's native RemoteDebugger protocol to communicate directly
    with the Godot automation fork. No addon required in the game.

Available Controls:
    - Movement: move_left(), move_right(), move_up(), move_down()
    - Digging: dig_left(), dig_right(), dig_up(), dig_down()
    - Mining: mine_shaft(depth), mine_tunnel(direction, length)
    - Jump: jump()
    - State: get_state(), get_hp(), get_depth(), get_player_position()

Feedback Collection:
    The GameplayFeedback class collects issues, observations, and metrics during
    exploration. Call full_exploration() for automated testing.

Headless Mode:
    - Uses test helper methods for mining (bypasses animation system)
    - Animation-based digging doesn't work in headless mode (no textures)
    - All core mechanics (movement, mining, state queries) work correctly

Known Limitations:
    - The Godot mono build pauses execution when resource loading errors occur
      during scene transitions (sends debug_enter message). The game scene has
      missing sprite resources in headless mode which triggers this.
    - For reliable testing, use the pytest tests which work with main menu scene.
"""
import asyncio
import argparse
import sys
import os
import socket
from pathlib import Path
from contextlib import asynccontextmanager
from dataclasses import dataclass, field
from typing import Optional, List, Dict, Any, Tuple
from datetime import datetime

# Project paths - resolved relative to this file
SCRIPT_DIR = Path(__file__).parent
GODOT_PROJECT = SCRIPT_DIR.parent

# Import PlayGodot native client
from playgodot import Godot

# Import helpers from the same directory
sys.path.insert(0, str(SCRIPT_DIR))
from helpers import PATHS, wait_for_condition, WAIT_TIMEOUT


def find_godot_path() -> str:
    """Find the Godot automation binary."""
    # Check GODOT_PATH environment variable first
    env_path = os.environ.get("GODOT_PATH")
    if env_path and Path(env_path).exists():
        return env_path

    # Check common locations
    common_paths = [
        Path.home() / ".local/share/godig/godot-automation/godot.linuxbsd.editor.x86_64.mono",
        Path.home() / ".local/share/godig/godot-automation/godot.linuxbsd.editor.x86_64",
        Path("/tmp/godot-automation/godot.linuxbsd.editor.x86_64.mono"),
    ]

    for path in common_paths:
        if path.exists():
            return str(path)

    raise RuntimeError("Could not find Godot automation binary. Set GODOT_PATH environment variable.")


def get_free_port() -> int:
    """Find an available port by binding to port 0."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(('127.0.0.1', 0))
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        return s.getsockname()[1]


GODOT_PATH = find_godot_path()


# =============================================================================
# CONSTANTS
# =============================================================================
BLOCK_SIZE = 128
SURFACE_ROW = 7
MOVE_DURATION = 0.15  # Time to move one block
DIG_DURATION = 0.2    # Time for dig animation


@dataclass
class GameState:
    """Snapshot of the current game state."""
    player_position: Tuple[float, float] = (0, 0)
    player_grid_pos: Tuple[int, int] = (0, 0)
    player_state: str = "IDLE"
    player_hp: float = 100.0
    player_max_hp: float = 100.0
    depth: int = 0
    coins: int = 0
    is_on_surface: bool = True
    blocks_mined: int = 0
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())

    def __str__(self):
        return (
            f"Position: {self.player_grid_pos} | "
            f"Depth: {self.depth}m | "
            f"HP: {self.player_hp}/{self.player_max_hp} | "
            f"Coins: {self.coins} | "
            f"State: {self.player_state}"
        )


@dataclass
class GameplayFeedback:
    """Collected feedback about gameplay experience."""
    issues: List[str] = field(default_factory=list)
    observations: List[str] = field(default_factory=list)
    metrics: Dict[str, Any] = field(default_factory=dict)

    def add_issue(self, severity: str, description: str):
        """Add an issue with severity (critical/major/minor)."""
        self.issues.append(f"[{severity.upper()}] {description}")

    def add_observation(self, observation: str):
        """Add a general observation."""
        self.observations.append(observation)

    def set_metric(self, name: str, value: Any):
        """Set a performance or gameplay metric."""
        self.metrics[name] = value

    def report(self) -> str:
        """Generate a formatted feedback report."""
        lines = [
            "=" * 70,
            "GAMEPLAY FEEDBACK REPORT",
            "=" * 70,
            "",
            "ISSUES FOUND:",
            "-" * 40,
        ]

        if self.issues:
            for issue in self.issues:
                lines.append(f"  {issue}")
        else:
            lines.append("  No issues found!")

        lines.extend([
            "",
            "OBSERVATIONS:",
            "-" * 40,
        ])

        if self.observations:
            for obs in self.observations:
                lines.append(f"  - {obs}")
        else:
            lines.append("  No observations recorded.")

        lines.extend([
            "",
            "METRICS:",
            "-" * 40,
        ])

        if self.metrics:
            for name, value in self.metrics.items():
                lines.append(f"  {name}: {value}")
        else:
            lines.append("  No metrics recorded.")

        lines.append("=" * 70)
        return "\n".join(lines)


class GameExplorer:
    """
    High-level game controller for exploration and testing.

    Provides intuitive methods for:
    - Movement (walk, jump, fall)
    - Actions (dig, mine, interact)
    - State queries (position, health, inventory)
    - Automated exploration sequences

    Usage:
        async with GameExplorer.create() as explorer:
            await explorer.explore_surface()
            feedback = await explorer.full_exploration()
    """

    def __init__(self, game: Godot):
        self.game = game
        self.feedback = GameplayFeedback()
        self._state_history: List[GameState] = []
        self._action_log: List[str] = []
        self._start_time = datetime.now()

    @classmethod
    @asynccontextmanager
    async def create(cls, headless: bool = True, resolution: Tuple[int, int] = (720, 1280)):
        """Create a new GameExplorer with a connected game instance.

        Must be used as an async context manager:
            async with GameExplorer.create() as explorer:
                ...
        """
        port = get_free_port()

        print(f"[Explorer] Launching Godot with native protocol on port {port}")

        print(f"[Explorer] Launching Godot with native protocol on port {port}")

        async with Godot.launch(
            str(GODOT_PROJECT),
            headless=headless,
            resolution=resolution,
            timeout=60.0,
            godot_path=GODOT_PATH,
            port=port,
        ) as g:
            # Wait for main menu to load
            print("[Explorer] Waiting for main menu...")
            await g.wait_for_node("/root/MainMenu", timeout=30.0)
            print("[Explorer] Main menu found")

            await asyncio.sleep(0.5)

            # Try to change to test level scene
            # Note: This may fail in headless mode due to resource loading errors
            # causing the Godot debugger to pause (debug_enter)
            print("[Explorer] Attempting to change to test level scene...")
            try:
                await g.change_scene("res://scenes/test_level.tscn")
                await asyncio.sleep(1.0)
            except Exception as e:
                print(f"[Explorer] Scene change error (expected in headless): {e}")

            # Wait for game scene to load - this may timeout if debugger pauses
            print("[Explorer] Waiting for game scene to load...")
            try:
                await g.wait_for_node("/root/Main", timeout=30.0)
                print("[Explorer] Game scene loaded")
            except Exception as e:
                print(f"[Explorer] Could not load game scene: {e}")
                print("[Explorer] Note: In headless mode, missing resources cause debugger to pause")
                raise RuntimeError(
                    "Game scene failed to load. This is a known limitation in headless mode "
                    "due to missing sprite resources causing the Godot debugger to pause. "
                    "Run with a display (xvfb-run or native) and ensure all resources exist."
                )

            await asyncio.sleep(0.5)

            explorer = cls(g)
            await explorer._log_action("Game launched and ready")

            yield explorer

        print("[Explorer] Godot process terminated")

    async def close(self):
        """Close is handled by context manager - no-op for backwards compatibility."""
        pass

    # =========================================================================
    # STATE QUERIES
    # =========================================================================

    def _parse_vector(self, value: Any) -> Tuple[float, float]:
        """Parse a vector value which may be dict or string like '(4, 6)'."""
        if isinstance(value, dict):
            return (value.get("x", 0), value.get("y", 0))
        elif isinstance(value, str):
            # Parse string format like "(4, 6)"
            import re
            match = re.match(r'\(([^,]+),\s*([^)]+)\)', value)
            if match:
                return (float(match.group(1)), float(match.group(2)))
        return (0, 0)

    async def get_state(self) -> GameState:
        """Get the current game state."""
        try:
            # Get player position
            pos_result = await self.game.get_property(PATHS["player"], "position")
            position = self._parse_vector(pos_result)

            # Get grid position (Vector2i serializes as string "(x, y)")
            grid_result = await self.game.get_property(PATHS["player"], "grid_position")
            grid_pos = self._parse_vector(grid_result)
            grid_pos = (int(grid_pos[0]), int(grid_pos[1]))

            # Get player state
            state_result = await self.game.get_property(PATHS["player"], "current_state")
            state_map = {0: "IDLE", 1: "MOVING", 2: "MINING", 3: "FALLING", 4: "WALL_SLIDING", 5: "WALL_JUMPING"}
            state = state_map.get(state_result, str(state_result))

            # Get HP
            hp_result = await self.game.get_property(PATHS["player"], "current_hp")
            max_hp_result = await self.game.get_property(PATHS["player"], "MAX_HP")

            # Get game manager data
            coins_result = await self.game.get_property(PATHS["game_manager"], "coins")

            # Calculate depth from grid position (more reliable than GameManager signal)
            calculated_depth = max(0, grid_pos[1] - SURFACE_ROW)

            state_obj = GameState(
                player_position=position,
                player_grid_pos=grid_pos,
                player_state=state,
                player_hp=float(hp_result) if hp_result else 100.0,
                player_max_hp=float(max_hp_result) if max_hp_result else 100.0,
                depth=calculated_depth,
                coins=int(coins_result) if coins_result else 0,
                is_on_surface=grid_pos[1] <= SURFACE_ROW,
            )

            self._state_history.append(state_obj)
            return state_obj

        except Exception as e:
            await self._log_action(f"Error getting state: {e}")
            return GameState()

    async def get_player_position(self) -> Tuple[int, int]:
        """Get the player's current grid position."""
        result = await self.game.get_property(PATHS["player"], "grid_position")
        pos = self._parse_vector(result)
        return (int(pos[0]), int(pos[1]))

    async def get_depth(self) -> int:
        """Get the current depth (0 = surface)."""
        result = await self.game.get_property(PATHS["game_manager"], "current_depth")
        return int(result) if result else 0

    async def get_hp(self) -> float:
        """Get the player's current HP."""
        result = await self.game.get_property(PATHS["player"], "current_hp")
        return float(result) if result else 100.0

    async def is_alive(self) -> bool:
        """Check if the player is alive."""
        hp = await self.get_hp()
        return hp > 0

    async def get_block_at(self, grid_x: int, grid_y: int) -> bool:
        """Check if a block exists at the given grid position."""
        result = await self.game.call(PATHS["dirt_grid"], "has_block_at", [grid_x, grid_y])
        return result is True

    async def get_grid_position(self) -> Tuple[int, int]:
        """Get player grid position using test helpers (more reliable in headless mode)."""
        x = await self.game.call(PATHS["player"], "test_get_grid_x", [])
        y = await self.game.call(PATHS["player"], "test_get_grid_y", [])
        return (int(x) if x is not None else 0, int(y) if y is not None else 0)

    # =========================================================================
    # MOVEMENT
    # =========================================================================

    async def _log_action(self, action: str):
        """Log an action for debugging."""
        timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]
        self._action_log.append(f"[{timestamp}] {action}")
        print(f"[{timestamp}] {action}")

    async def move_left(self, blocks: int = 1):
        """Move left by the specified number of blocks."""
        await self._log_action(f"Moving left {blocks} block(s)")
        for _ in range(blocks):
            await self.game.hold_action("move_left", MOVE_DURATION + 0.1)
            await asyncio.sleep(0.05)

    async def move_right(self, blocks: int = 1):
        """Move right by the specified number of blocks."""
        await self._log_action(f"Moving right {blocks} block(s)")
        for _ in range(blocks):
            await self.game.hold_action("move_right", MOVE_DURATION + 0.1)
            await asyncio.sleep(0.05)

    async def move_up(self, blocks: int = 1):
        """Move up by the specified number of blocks (if possible)."""
        await self._log_action(f"Moving up {blocks} block(s)")
        for _ in range(blocks):
            await self.game.hold_action("move_up", MOVE_DURATION + 0.1)
            await asyncio.sleep(0.05)

    async def move_down(self, blocks: int = 1):
        """Move down by the specified number of blocks."""
        await self._log_action(f"Moving down {blocks} block(s)")
        for _ in range(blocks):
            await self.game.hold_action("move_down", MOVE_DURATION + 0.1)
            await asyncio.sleep(0.05)

    async def jump(self):
        """Perform a jump."""
        await self._log_action("Jumping")
        await self.game.press_action("jump")
        await asyncio.sleep(0.3)

    async def wait_for_landing(self, timeout: float = 5.0):
        """Wait until the player stops falling."""
        await self._log_action("Waiting for landing...")

        async def check_not_falling():
            state = await self.game.get_property(PATHS["player"], "current_state")
            # State 3 = FALLING
            return state != 3

        landed = await wait_for_condition(self.game, check_not_falling, timeout)
        if landed:
            await self._log_action("Landed")
        else:
            await self._log_action("Landing timeout - may still be falling")
        return landed

    # =========================================================================
    # DIGGING (using test helpers for headless mode compatibility)
    # =========================================================================

    async def _mine_direction(self, dir_x: int, dir_y: int, max_hits: int = 5) -> bool:
        """Mine in a direction until block is destroyed or max hits reached.

        Uses test_mine_direction helper which bypasses animations.
        Returns True if block was destroyed and player moved.
        """
        for _ in range(max_hits):
            result = await self.game.call(
                PATHS["player"], "test_mine_direction", [dir_x, dir_y]
            )
            if result is True:
                # Block destroyed, wait for move to complete
                await asyncio.sleep(MOVE_DURATION + 0.1)
                return True
            elif result is False:
                # Block still there, continue hitting
                await asyncio.sleep(0.05)
            else:
                # No block in that direction
                return False
        return False

    async def dig_left(self) -> bool:
        """Dig one block to the left. Returns True if successful."""
        await self._log_action("Digging left")
        return await self._mine_direction(-1, 0)

    async def dig_right(self) -> bool:
        """Dig one block to the right. Returns True if successful."""
        await self._log_action("Digging right")
        return await self._mine_direction(1, 0)

    async def dig_down(self) -> bool:
        """Dig one block downward. Returns True if successful."""
        await self._log_action("Digging down")
        return await self._mine_direction(0, 1)

    async def dig_up(self) -> bool:
        """Dig one block upward. Returns True if successful."""
        await self._log_action("Digging up")
        return await self._mine_direction(0, -1)

    async def mine_shaft(self, depth: int = 5):
        """Dig a vertical shaft downward by the specified depth."""
        await self._log_action(f"Mining vertical shaft of {depth} blocks")
        for i in range(depth):
            before_hp = await self.get_hp()
            await self.dig_down()
            await asyncio.sleep(0.2)
            after_hp = await self.get_hp()

            if after_hp < before_hp:
                self.feedback.add_observation(
                    f"Took {before_hp - after_hp} damage while mining shaft at block {i+1}"
                )

        state = await self.get_state()
        await self._log_action(f"Shaft complete. Now at depth {state.depth}m")
        return state.depth

    async def mine_tunnel(self, direction: str = "right", length: int = 5):
        """Dig a horizontal tunnel in the specified direction."""
        await self._log_action(f"Mining tunnel {direction} for {length} blocks")

        dig_fn = self.dig_right if direction == "right" else self.dig_left

        for i in range(length):
            await dig_fn()
            await asyncio.sleep(0.1)

        state = await self.get_state()
        await self._log_action(f"Tunnel complete. Now at position {state.player_grid_pos}")

    # =========================================================================
    # EXPLORATION SEQUENCES
    # =========================================================================

    async def explore_surface(self) -> GameState:
        """Walk around on the surface to explore."""
        await self._log_action("=== EXPLORING SURFACE ===")

        initial_state = await self.get_state()
        self.feedback.add_observation(f"Starting on surface at position {initial_state.player_grid_pos}")

        # Walk right a bit
        await self._log_action("Walking right on surface...")
        for _ in range(5):
            await self.move_right()
            await asyncio.sleep(0.1)

        state_after_right = await self.get_state()

        # Walk left back and continue
        await self._log_action("Walking left on surface...")
        for _ in range(10):
            await self.move_left()
            await asyncio.sleep(0.1)

        state_after_left = await self.get_state()

        # Return to center
        await self._log_action("Returning to center...")
        for _ in range(5):
            await self.move_right()
            await asyncio.sleep(0.1)

        final_state = await self.get_state()

        # Check for issues
        if final_state.is_on_surface:
            self.feedback.add_observation("Surface walking works correctly - stayed on surface")
        else:
            self.feedback.add_issue("major", "Player fell through surface while walking!")

        return final_state

    async def test_digging(self) -> GameState:
        """Test basic digging mechanics."""
        await self._log_action("=== TESTING DIGGING ===")

        initial_state = await self.get_state()
        initial_depth = initial_state.depth

        # Dig down 3 blocks
        await self._log_action("Digging down 3 blocks...")
        for i in range(3):
            await self.dig_down()
            state = await self.get_state()
            await self._log_action(f"  After dig {i+1}: depth={state.depth}, pos={state.player_grid_pos}")
            await asyncio.sleep(0.15)

        state_after_dig = await self.get_state()

        # Check depth increased
        depth_change = state_after_dig.depth - initial_depth
        if depth_change >= 2:
            self.feedback.add_observation(f"Digging works - moved from depth {initial_depth} to {state_after_dig.depth}")
        else:
            self.feedback.add_issue("major", f"Digging may not be working - depth only changed by {depth_change}")

        # Try digging horizontally
        await self._log_action("Digging horizontal tunnel...")
        for _ in range(3):
            await self.dig_right()
            await asyncio.sleep(0.15)

        for _ in range(3):
            await self.dig_left()
            await asyncio.sleep(0.15)

        final_state = await self.get_state()
        self.feedback.add_observation(f"Horizontal tunneling complete at depth {final_state.depth}")

        return final_state

    async def test_falling(self) -> Tuple[GameState, float]:
        """Test falling mechanics and potential fall damage."""
        await self._log_action("=== TESTING FALLING ===")

        # First, dig a shaft to create a drop
        await self._log_action("Creating drop shaft...")
        for _ in range(5):
            await self.dig_down()
            await asyncio.sleep(0.2)

        # Move aside
        await self.dig_right()
        await asyncio.sleep(0.2)

        state_before_fall = await self.get_state()
        hp_before = state_before_fall.player_hp

        # Now dig back to the shaft to fall
        await self._log_action(f"HP before potential fall: {hp_before}")

        # Move up and over to fall down the shaft
        for _ in range(3):
            await self.dig_up()
            await asyncio.sleep(0.2)

        await self.dig_left()
        await asyncio.sleep(0.5)

        # Wait for falling to complete
        await self.wait_for_landing(timeout=3.0)
        await asyncio.sleep(0.3)

        state_after_fall = await self.get_state()
        hp_after = state_after_fall.player_hp
        damage_taken = hp_before - hp_after

        await self._log_action(f"HP after fall: {hp_after}, Damage: {damage_taken}")

        if damage_taken > 0:
            self.feedback.add_observation(f"Fall damage system working - took {damage_taken} damage from fall")
        else:
            self.feedback.add_observation("No fall damage taken (fall may have been < 3 blocks)")

        self.feedback.set_metric("fall_damage_test", damage_taken)

        return state_after_fall, damage_taken

    async def full_exploration(self) -> GameplayFeedback:
        """
        Run a comprehensive exploration of the game.

        This includes:
        1. Surface exploration
        2. Basic digging
        3. Fall testing
        4. Deep mining
        5. State verification
        """
        await self._log_action("=" * 70)
        await self._log_action("STARTING FULL GAME EXPLORATION")
        await self._log_action("=" * 70)

        start_time = datetime.now()

        # Record initial state
        initial_state = await self.get_state()
        self.feedback.set_metric("initial_hp", initial_state.player_hp)
        self.feedback.set_metric("initial_depth", initial_state.depth)
        self.feedback.set_metric("initial_coins", initial_state.coins)

        await self._log_action(f"Initial state: {initial_state}")

        # 1. Surface exploration
        await self.explore_surface()
        await asyncio.sleep(0.5)

        # 2. Basic digging test
        await self.test_digging()
        await asyncio.sleep(0.5)

        # 3. Fall testing
        await self.test_falling()
        await asyncio.sleep(0.5)

        # 4. Deep mining run
        await self._log_action("=== DEEP MINING RUN ===")

        # Mine down as far as possible
        for i in range(10):
            hp = await self.get_hp()
            if hp < 30:
                self.feedback.add_observation(f"Stopping deep mining at depth due to low HP ({hp})")
                break

            await self.dig_down()

            if i % 3 == 0:
                state = await self.get_state()
                await self._log_action(f"  Depth check: {state.depth}m, HP: {state.player_hp}")

        # 5. Final state
        final_state = await self.get_state()
        elapsed = (datetime.now() - start_time).total_seconds()

        self.feedback.set_metric("final_hp", final_state.player_hp)
        self.feedback.set_metric("final_depth", final_state.depth)
        self.feedback.set_metric("final_coins", final_state.coins)
        self.feedback.set_metric("exploration_time_seconds", round(elapsed, 2))
        self.feedback.set_metric("max_depth_reached", final_state.depth)

        await self._log_action(f"\nFinal state: {final_state}")
        await self._log_action(f"Exploration completed in {elapsed:.2f} seconds")

        # Generate summary observations
        hp_lost = initial_state.player_hp - final_state.player_hp
        if hp_lost > 0:
            self.feedback.add_observation(f"Lost {hp_lost} HP during exploration")

        if final_state.coins > initial_state.coins:
            self.feedback.add_observation(f"Collected {final_state.coins - initial_state.coins} coins")

        if final_state.depth > 5:
            self.feedback.add_observation(f"Successfully reached depth {final_state.depth}m")

        return self.feedback

    def get_action_log(self) -> List[str]:
        """Get the full action log."""
        return self._action_log.copy()

    def get_state_history(self) -> List[GameState]:
        """Get the history of recorded states."""
        return self._state_history.copy()


# =============================================================================
# MAIN EXECUTION
# =============================================================================

async def run_exploration():
    """Run a full game exploration and print the report."""
    print("\n" + "=" * 70)
    print("GoDig Game Exploration")
    print("=" * 70 + "\n")

    try:
        async with GameExplorer.create(headless=True) as explorer:
            feedback = await explorer.full_exploration()

            print("\n" + feedback.report())

            # Print action log summary
            print("\nACTION LOG (last 20 entries):")
            print("-" * 40)
            for entry in explorer.get_action_log()[-20:]:
                print(f"  {entry}")

            return feedback

    except Exception as e:
        print(f"\nError during exploration: {e}")
        import traceback
        traceback.print_exc()
        raise


async def interactive_mode():
    """Run an interactive exploration session."""
    print("\n" + "=" * 70)
    print("GoDig Interactive Exploration")
    print("Type 'help' for commands, 'quit' to exit")
    print("=" * 70 + "\n")

    commands = {
        "help": "Show this help",
        "state": "Show current game state",
        "left [n]": "Move left n blocks (default 1)",
        "right [n]": "Move right n blocks (default 1)",
        "up [n]": "Move up n blocks (default 1)",
        "down [n]": "Move down n blocks (default 1)",
        "dig-left": "Dig one block left",
        "dig-right": "Dig one block right",
        "dig-down": "Dig one block down",
        "dig-up": "Dig one block up",
        "shaft [n]": "Dig a vertical shaft n blocks deep",
        "tunnel [dir] [n]": "Dig a tunnel in direction for n blocks",
        "jump": "Jump",
        "explore": "Run full exploration",
        "feedback": "Show collected feedback",
        "log": "Show action log",
        "quit": "Exit interactive mode",
    }

    async with GameExplorer.create(headless=True) as explorer:
        while True:
            try:
                cmd = input("\n> ").strip().lower()
            except EOFError:
                break

            if not cmd:
                continue

            parts = cmd.split()
            action = parts[0]

            if action == "quit" or action == "exit":
                break
            elif action == "help":
                print("\nCommands:")
                for c, desc in commands.items():
                    print(f"  {c:20} - {desc}")
            elif action == "state":
                state = await explorer.get_state()
                print(f"\n{state}")
            elif action == "left":
                n = int(parts[1]) if len(parts) > 1 else 1
                await explorer.move_left(n)
            elif action == "right":
                n = int(parts[1]) if len(parts) > 1 else 1
                await explorer.move_right(n)
            elif action == "up":
                n = int(parts[1]) if len(parts) > 1 else 1
                await explorer.move_up(n)
            elif action == "down":
                n = int(parts[1]) if len(parts) > 1 else 1
                await explorer.move_down(n)
            elif action == "dig-left":
                await explorer.dig_left()
            elif action == "dig-right":
                await explorer.dig_right()
            elif action == "dig-down":
                await explorer.dig_down()
            elif action == "dig-up":
                await explorer.dig_up()
            elif action == "shaft":
                n = int(parts[1]) if len(parts) > 1 else 5
                await explorer.mine_shaft(n)
            elif action == "tunnel":
                direction = parts[1] if len(parts) > 1 else "right"
                n = int(parts[2]) if len(parts) > 2 else 5
                await explorer.mine_tunnel(direction, n)
            elif action == "jump":
                await explorer.jump()
            elif action == "explore":
                await explorer.full_exploration()
            elif action == "feedback":
                print(explorer.feedback.report())
            elif action == "log":
                for entry in explorer.get_action_log()[-20:]:
                    print(f"  {entry}")
            else:
                print(f"Unknown command: {action}. Type 'help' for commands.")

        print("\nExploration session ended.")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="GoDig Game Exploration Script")
    parser.add_argument(
        "--interactive", "-i",
        action="store_true",
        help="Run in interactive mode for manual commands"
    )
    args = parser.parse_args()

    if args.interactive:
        asyncio.run(interactive_mode())
    else:
        asyncio.run(run_exploration())


if __name__ == "__main__":
    main()
