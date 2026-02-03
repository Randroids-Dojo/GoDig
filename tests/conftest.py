"""
PlayGodot test configuration for GoDig.

This project uses PlayGodot (NOT GdUnit4) for E2E game testing.
PlayGodot requires a custom Godot fork with automation support.

See TESTING.md for setup instructions.
"""
import os
import platform
import socket
from typing import Optional
import pytest_asyncio
from pathlib import Path
from playgodot import Godot

GODOT_PROJECT = Path(__file__).parent.parent


def find_godot_path() -> Optional[str]:
    """
    Auto-discover the Godot automation fork binary.

    Search order:
    1. GODOT_PATH environment variable (explicit override)
    2. .godot-path file in project root (local config, gitignored)
    3. Sibling directory: ../godot/bin/godot.*
    4. Common well-known locations
    """
    # Platform-specific binary names
    system = platform.system().lower()
    machine = platform.machine().lower()

    if system == "darwin":  # macOS
        arch = "arm64" if machine == "arm64" else "x86_64"
        binary_names = [
            f"godot.macos.editor.{arch}",
            "godot.macos.editor.universal",
        ]
    elif system == "linux":
        binary_names = [
            "godot.linuxbsd.editor.x86_64",
            "godot.linuxbsd.editor.x86_64.mono",
        ]
    else:  # Windows
        binary_names = [
            "godot.windows.editor.x86_64.exe",
            "godot.windows.editor.x86_64.mono.exe",
        ]

    # 1. Environment variable (highest priority)
    env_path = os.environ.get("GODOT_PATH")
    if env_path and Path(env_path).exists():
        return env_path

    # 2. Local config file (.godot-path)
    config_file = GODOT_PROJECT / ".godot-path"
    if config_file.exists():
        path = config_file.read_text().strip()
        if Path(path).exists():
            return path

    # 3. Sibling godot directory (works in worktrees too)
    project_parent = GODOT_PROJECT.parent
    sibling_godot = project_parent / "godot" / "bin"
    if sibling_godot.exists():
        for name in binary_names:
            candidate = sibling_godot / name
            if candidate.exists():
                return str(candidate)

    # 4. Well-known locations
    well_known = []
    if system == "darwin":
        well_known = [
            Path.home() / "Documents/Dev/Godot/godot/bin",
            Path.home() / "godot-automation/bin",
        ]
    elif system == "linux":
        well_known = [
            Path.home() / "godot-automation/bin",
            Path("/tmp/godot-automation"),
        ]

    for location in well_known:
        if location.exists():
            for name in binary_names:
                candidate = location / name
                if candidate.exists():
                    return str(candidate)

    return None


def validate_godot_path(path: Optional[str]) -> str:
    """Validate the Godot path and provide helpful error messages."""
    if path is None:
        raise RuntimeError(
            "\n"
            "=" * 70 + "\n"
            "  GODOT AUTOMATION FORK NOT FOUND\n"
            "=" * 70 + "\n\n"
            "PlayGodot tests require a custom Godot build with automation support.\n\n"
            "Quick fix options:\n\n"
            "1. Create .godot-path file (recommended):\n"
            "   echo '/path/to/godot/bin/godot.macos.editor.arm64' > .godot-path\n\n"
            "2. Set GODOT_PATH environment variable:\n"
            "   export GODOT_PATH=/path/to/godot/bin/godot.macos.editor.arm64\n\n"
            "3. Place the fork at ../godot/ (sibling to this project)\n\n"
            "To build the fork from source:\n"
            "   git clone https://github.com/Randroids-Dojo/godot.git ../godot\n"
            "   cd ../godot && git checkout automation\n"
            "   scons platform=macos arch=arm64 target=editor -j8\n\n"
            "See TESTING.md for detailed instructions.\n"
            "=" * 70
        )

    if not Path(path).exists():
        raise RuntimeError(
            f"\nGODOT_PATH does not exist: {path}\n\n"
            f"Please verify the path and ensure the binary was built."
        )

    if not os.access(path, os.X_OK):
        raise RuntimeError(
            f"\nGODOT_PATH is not executable: {path}\n\n"
            f"Fix with: chmod +x {path}"
        )

    return path


# Auto-discover and validate GODOT_PATH on import
_discovered_path = find_godot_path()
GODOT_PATH = validate_godot_path(_discovered_path)


def get_free_port() -> int:
    """Find an available port by binding to port 0."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(('127.0.0.1', 0))
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        return s.getsockname()[1]


def get_playgodot_port() -> int:
    """
    Determine port for PlayGodot connection.

    Priority:
    1. PLAYGODOT_PORT env var (explicit override)
    2. pytest-xdist worker ID (6007 + worker_num)
    3. Dynamic free port (cross-session safety)
    """
    # Priority 1: Explicit environment variable
    env_port = os.environ.get("PLAYGODOT_PORT")
    if env_port:
        return int(env_port)

    # Priority 2: pytest-xdist worker ID
    worker_id = os.environ.get("PYTEST_XDIST_WORKER")
    if worker_id and worker_id != "master":
        worker_num = int(worker_id.replace("gw", ""))
        return 6007 + worker_num + 1

    # Priority 3: Dynamic port allocation
    return get_free_port()


@pytest_asyncio.fixture
async def main_menu():
    """Launch the game on the main menu and yield the Godot connection.

    This fixture has extended timeouts to handle parallel execution
    scenarios where multiple Godot instances may be running.
    """
    import asyncio
    port = get_playgodot_port()

    # Extended timeouts for parallel execution scenarios
    LAUNCH_TIMEOUT = 60.0
    MENU_TIMEOUT = 45.0
    MAX_RETRIES = 2

    last_error = None

    for attempt in range(MAX_RETRIES + 1):
        try:
            async with Godot.launch(
                str(GODOT_PROJECT),
                headless=True,
                resolution=(720, 1280),
                timeout=LAUNCH_TIMEOUT,
                godot_path=GODOT_PATH,
                port=port,
            ) as g:
                # Wait for main menu to load
                await g.wait_for_node("/root/MainMenu", timeout=MENU_TIMEOUT)
                yield g
                return  # Success - exit the retry loop
        except Exception as e:
            last_error = e
            if attempt < MAX_RETRIES:
                # Wait before retry to let system resources free up
                await asyncio.sleep(2.0)
                # Get a new port in case of port conflicts
                port = get_free_port()
            else:
                raise last_error


@pytest_asyncio.fixture
async def game():
    """Launch the game and navigate to the test level scene.

    This fixture has extended timeouts and retry logic to handle
    parallel execution scenarios where multiple Godot instances
    may be competing for system resources.
    """
    import asyncio
    port = get_playgodot_port()

    # Extended timeouts for parallel execution scenarios
    LAUNCH_TIMEOUT = 90.0
    MENU_TIMEOUT = 60.0
    SCENE_TIMEOUT = 90.0
    MAX_RETRIES = 2

    last_error = None

    for attempt in range(MAX_RETRIES + 1):
        try:
            async with Godot.launch(
                str(GODOT_PROJECT),
                headless=True,
                resolution=(720, 1280),
                timeout=LAUNCH_TIMEOUT,
                godot_path=GODOT_PATH,
                port=port,
            ) as g:
                # Wait for main menu to load first
                await g.wait_for_node("/root/MainMenu", timeout=MENU_TIMEOUT)
                await asyncio.sleep(0.5)

                # Change to game scene
                await g.change_scene("res://scenes/test_level.tscn")

                # Wait for game scene to load with extended timeout
                await g.wait_for_node("/root/Main", timeout=SCENE_TIMEOUT)
                yield g
                return  # Success - exit the retry loop
        except Exception as e:
            last_error = e
            if attempt < MAX_RETRIES:
                # Wait before retry to let system resources free up
                await asyncio.sleep(2.0)
                # Get a new port in case of port conflicts
                port = get_free_port()
            else:
                raise last_error
