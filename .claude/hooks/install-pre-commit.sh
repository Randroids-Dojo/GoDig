#!/bin/bash
# Install git pre-commit hook to run tests before commits
# This hook is installed automatically on Claude session start
#
# The pre-commit hook runs PlayGodot integration tests to catch issues
# before they reach CI.

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

# Create the pre-commit hook
cat > "$HOOK_PATH" << 'EOF'
#!/bin/bash
# GoDig pre-commit hook - runs integration tests before commit
# To skip: git commit --no-verify

echo "=== Running pre-commit tests ==="

# Run pytest with minimal output for faster feedback
# Use -n 0 to run sequentially (more reliable in hook context)
if python3 -m pytest tests/ -v --tb=short -q 2>/dev/null; then
  echo "=== Tests PASSED ==="
  exit 0
else
  echo ""
  echo "=== Tests FAILED ==="
  echo "Fix the failing tests before committing."
  echo "To skip this check: git commit --no-verify"
  exit 1
fi
EOF

chmod +x "$HOOK_PATH"
echo "Pre-commit hook installed at $HOOK_PATH"

exit 0
