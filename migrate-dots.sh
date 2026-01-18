#!/bin/bash
# Migration script: beads -> dots
# Migrates from beads task management system to dots

set -e

echo "=========================================="
echo "Migrating from beads to dots"
echo "=========================================="
echo ""

# Check if .beads exists
if [ ! -d ".beads" ]; then
    echo "✗ No .beads directory found. Migration may have already been completed."
    exit 0
fi

# Check if .dots exists
if [ ! -d ".dots" ]; then
    echo "✗ No .dots directory found. Please set up dots first."
    exit 1
fi

echo "Checking beads tasks..."
if [ -f ".beads/issues.jsonl" ] && [ -s ".beads/issues.jsonl" ]; then
    echo "⚠ Warning: .beads/issues.jsonl contains data!"
    echo "Please manually review and migrate any important tasks before running this script."
    echo "Current beads tasks:"
    cat ".beads/issues.jsonl"
    echo ""
    read -p "Continue with migration anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Migration cancelled."
        exit 0
    fi
else
    echo "✓ No beads tasks found (issues.jsonl is empty)"
fi

echo ""
echo "Migration steps:"
echo "1. Remove .beads directory"
echo ""

# Remove .beads directory
echo "Removing .beads directory..."
rm -rf .beads
echo "✓ .beads directory removed"

echo ""
echo "=========================================="
echo "Migration complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  • Removed .beads directory"
echo "  • dots is now the task management system"
echo ""
echo "Next steps:"
echo "  • Commit the changes: git add -A && git commit -m 'Migrate from beads to dots'"
echo "  • Use 'dot' command for task management"
echo ""
