#!/bin/bash
# Install dots CLI tool for task management
# https://github.com/joelreymont/dots

set -e

INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "$INSTALL_DIR"

# Skip if already installed
if command -v dot &> /dev/null; then
  exit 0
fi

# Also check the install directory directly
if [ -x "$INSTALL_DIR/dot" ]; then
  # Ensure PATH is set for this session
  if [ -n "$CLAUDE_ENV_FILE" ]; then
    echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "$CLAUDE_ENV_FILE"
  fi
  exit 0
fi

# Determine platform
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map to release binary names
case "$OS-$ARCH" in
  linux-x86_64)
    BINARY="dot-linux-x86_64"
    ;;
  darwin-arm64)
    BINARY="dot-macos-arm64"
    ;;
  *)
    echo "Unsupported platform: $OS-$ARCH" >&2
    exit 0  # Don't fail the session, just skip
    ;;
esac

# Download from GitHub releases
DOWNLOAD_URL="https://github.com/joelreymont/dots/releases/latest/download/${BINARY}"

curl -sL "$DOWNLOAD_URL" -o "$INSTALL_DIR/dot"
chmod +x "$INSTALL_DIR/dot"

# Persist PATH for subsequent bash commands in this session
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

exit 0
