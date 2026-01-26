#!/bin/bash
# Install git pre-commit hook for basic validation
# This hook is installed automatically on Claude session start
#
# Note: Tests are NOT run in pre-commit - they run in CI after push.
# The post-push hook monitors CI and reports failures.

set -e

HOOK_PATH=".git/hooks/pre-commit"

# Only install if we're in a git repo
if [ ! -d ".git" ]; then
  exit 0
fi

# Skip if already installed (check for our marker)
if [ -f "$HOOK_PATH" ] && grep -q "GoDig pre-commit hook" "$HOOK_PATH" 2>/dev/null; then
  exit 0
fi

# Create the pre-commit hook (lightweight - no tests)
cat > "$HOOK_PATH" << 'EOF'
#!/bin/bash
# GoDig pre-commit hook - lightweight validation only
# Tests run in CI after push, monitored by post-push hook
# To skip: git commit --no-verify

# Just validate that staged files are syntactically valid GDScript
# This is fast and catches obvious errors

STAGED_GD=$(git diff --cached --name-only --diff-filter=ACM | grep '\.gd$' || true)

if [ -n "$STAGED_GD" ]; then
  # Basic syntax check - just ensure files aren't empty/corrupted
  for file in $STAGED_GD; do
    if [ ! -s "$file" ]; then
      echo "Warning: $file is empty"
    fi
  done
fi

exit 0
EOF

chmod +x "$HOOK_PATH"
echo "Pre-commit hook installed at $HOOK_PATH"

exit 0
