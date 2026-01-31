#!/bin/bash
# Setup Godot automation fork and PlayGodot for Claude Code Full environment
# This mirrors the CI setup for local development
#
# Security: Downloads from our pinned automation-latest release

set -e

# Save original directory (project root)
PROJECT_DIR="$(pwd)"

WORK_DIR="${HOME}/.local/share/godig"
GODOT_DIR="${WORK_DIR}/godot-automation"
PLAYGODOT_DIR="${WORK_DIR}/PlayGodot"
GODOT_BINARY="${GODOT_DIR}/godot.linuxbsd.editor.x86_64.mono"

# Only support Linux x86_64 for now (can expand later)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [ "$OS" != "linux" ] || [ "$ARCH" != "x86_64" ]; then
  echo "Godot automation setup: Skipping - only supports linux-x86_64" >&2
  exit 0
fi

# Create work directory
mkdir -p "$WORK_DIR"

# === Setup Godot Automation Binary ===
if [ -x "$GODOT_BINARY" ]; then
  echo "Godot automation binary already installed at $GODOT_BINARY"
else
  echo "=== Downloading Godot with Automation Support ==="
  mkdir -p "$GODOT_DIR"
  cd "$GODOT_DIR"

  # Download from our fork's automation-latest release
  GODOT_URL="https://github.com/Randroids-Dojo/godot/releases/download/automation-latest/godot-automation-linux-x86_64.zip"
  TEMP_ZIP=$(mktemp)
  trap "rm -f '$TEMP_ZIP'" EXIT

  curl -sL "$GODOT_URL" -o "$TEMP_ZIP"
  unzip -q -o "$TEMP_ZIP"
  chmod +x godot.linuxbsd.editor.x86_64.mono

  echo "Godot automation binary installed to $GODOT_BINARY"
fi

# === Setup PlayGodot ===
if [ -d "$PLAYGODOT_DIR" ]; then
  echo "PlayGodot already cloned at $PLAYGODOT_DIR"
else
  echo "=== Cloning PlayGodot ==="
  cd "$WORK_DIR"
  git clone --depth 1 https://github.com/Randroids-Dojo/PlayGodot.git
  echo "PlayGodot cloned to $PLAYGODOT_DIR"
fi

# === Install PlayGodot Python Package ===
# Check if already installed by trying to import
if python3 -c "import playgodot" 2>/dev/null; then
  echo "PlayGodot Python package already installed"
else
  echo "=== Installing PlayGodot Python Package ==="
  cd "$PLAYGODOT_DIR/python"
  pip install -q -e .
  echo "PlayGodot Python package installed"
fi

# === Install Test Dependencies ===
# Check if pytest is available
if python3 -c "import pytest, pytest_asyncio" 2>/dev/null; then
  echo "Test dependencies already installed"
else
  echo "=== Installing Test Dependencies ==="
  pip install -q pytest pytest-asyncio pytest-xdist
  echo "Test dependencies installed"
fi

# === Set Environment Variable ===
# Export GODOT_PATH for this session
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo "export GODOT_PATH=\"${GODOT_BINARY}\"" >> "$CLAUDE_ENV_FILE"
  echo "GODOT_PATH set to $GODOT_BINARY"
fi

# === Install .NET SDK if needed ===
# The mono build of Godot requires .NET SDK 8.0+ for --import to work
# Without it, the import command crashes with signal 11
if ! command -v dotnet >/dev/null 2>&1; then
  echo "=== Installing .NET SDK (required for Godot mono build) ==="
  # Install via Microsoft's script (works on most Linux distros)
  curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 8.0 --install-dir "$HOME/.dotnet" 2>/dev/null || true
  export PATH="$HOME/.dotnet:$PATH"
  export DOTNET_ROOT="$HOME/.dotnet"
  # Export for current session
  if [ -n "$CLAUDE_ENV_FILE" ]; then
    echo "export PATH=\"\$HOME/.dotnet:\$PATH\"" >> "$CLAUDE_ENV_FILE"
    echo "export DOTNET_ROOT=\"\$HOME/.dotnet\"" >> "$CLAUDE_ENV_FILE"
  fi
  if command -v dotnet >/dev/null 2>&1; then
    echo ".NET SDK installed successfully"
  else
    echo "WARNING: .NET SDK installation failed - tests may not work"
  fi
else
  echo ".NET SDK already available"
fi

# === Import Godot Project ===
# Run Godot import to ensure all resources are available for tests
# This is required before running tests - mirrors CI behavior
# CI runs import TWICE to ensure global classes are resolved
IMPORT_STAMP="${PROJECT_DIR}/.godot/.import_complete"
GLOBAL_CACHE="${PROJECT_DIR}/.godot/global_script_class_cache.cfg"

if [ -f "$IMPORT_STAMP" ] && [ -f "$GLOBAL_CACHE" ]; then
  echo "Godot project already imported"
else
  echo "=== Importing Godot Project ==="
  cd "$PROJECT_DIR"

  # Use xvfb-run if available (provides virtual display for Godot)
  XVFB_CMD=""
  if command -v xvfb-run >/dev/null 2>&1; then
    XVFB_CMD="xvfb-run --auto-servernum"
  fi

  # Run import twice to ensure all global classes are resolved (mirrors CI)
  echo "First import pass..."
  timeout 120 $XVFB_CMD "$GODOT_BINARY" --headless --path . --import 2>/dev/null || true

  echo "Second import pass..."
  timeout 120 $XVFB_CMD "$GODOT_BINARY" --headless --path . --import 2>/dev/null || true

  # Verify global class cache was created
  if [ -f "$GLOBAL_CACHE" ]; then
    echo "Global class cache created successfully"
    # Create stamp file to avoid re-importing every session
    touch "$IMPORT_STAMP" 2>/dev/null || true
  else
    echo "WARNING: Global class cache not found - import may have failed"
    echo "Tests may fail due to missing resource imports"
  fi

  echo "Godot project import complete"
fi

echo "=== Godot + PlayGodot Setup Complete ==="
echo "Godot binary: $GODOT_BINARY"
echo "PlayGodot: $PLAYGODOT_DIR"
echo "Run tests with: pytest tests/ -v"

exit 0
