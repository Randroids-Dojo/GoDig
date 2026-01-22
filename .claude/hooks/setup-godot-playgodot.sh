#!/bin/bash
# Setup Godot automation fork and PlayGodot for Claude Code Full environment
# This mirrors the CI setup for local development
#
# Security: Downloads from our pinned automation-latest release

set -e

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

echo "=== Godot + PlayGodot Setup Complete ==="
echo "Godot binary: $GODOT_BINARY"
echo "PlayGodot: $PLAYGODOT_DIR"
echo "Run tests with: pytest tests/ -v"

exit 0
