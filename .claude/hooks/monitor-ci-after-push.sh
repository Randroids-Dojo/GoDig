#!/bin/bash
# Post-push hook: Monitor CI status and report failures
# This hook runs after git push and waits for CI to complete
#
# Features:
# - Exponential backoff when PR doesn't exist yet
# - Monitors GitHub Actions workflow runs
# - Reports failures with actionable details

set -e

# Configuration
MAX_PR_WAIT_ATTEMPTS=5       # Max attempts to find PR
MAX_CI_WAIT_ATTEMPTS=30      # Max attempts to wait for CI (5 min with 10s intervals)
CI_POLL_INTERVAL=10          # Seconds between CI status checks

# Get current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [ -z "$BRANCH" ] || [ "$BRANCH" = "HEAD" ]; then
  echo "Could not determine current branch"
  exit 0
fi

# Skip for main/master branches (no PR expected)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "On $BRANCH branch - checking latest workflow run directly"

  # Wait a moment for the push to trigger CI
  sleep 3

  # Get the latest run
  RUN_INFO=$(gh run list --branch "$BRANCH" --limit 1 --json databaseId,status,conclusion,name 2>/dev/null || echo "")
  if [ -z "$RUN_INFO" ] || [ "$RUN_INFO" = "[]" ]; then
    echo "No workflow runs found yet"
    exit 0
  fi

  RUN_ID=$(echo "$RUN_INFO" | jq -r '.[0].databaseId')
  echo "Monitoring workflow run $RUN_ID..."
else
  # For feature branches, look for associated PR
  echo "Looking for PR associated with branch: $BRANCH"

  PR_NUMBER=""
  WAIT_TIME=2  # Initial wait time for exponential backoff

  for attempt in $(seq 1 $MAX_PR_WAIT_ATTEMPTS); do
    PR_NUMBER=$(gh pr view "$BRANCH" --json number --jq '.number' 2>/dev/null || echo "")

    if [ -n "$PR_NUMBER" ]; then
      echo "Found PR #$PR_NUMBER"
      break
    fi

    if [ $attempt -lt $MAX_PR_WAIT_ATTEMPTS ]; then
      echo "PR not found yet (attempt $attempt/$MAX_PR_WAIT_ATTEMPTS), waiting ${WAIT_TIME}s..."
      sleep $WAIT_TIME
      WAIT_TIME=$((WAIT_TIME * 2))  # Exponential backoff: 2, 4, 8, 16, 32
    fi
  done

  if [ -z "$PR_NUMBER" ]; then
    echo "No PR found for branch $BRANCH after $MAX_PR_WAIT_ATTEMPTS attempts"
    echo "CI monitoring skipped - create a PR to enable CI monitoring"
    exit 0
  fi

  # Get the latest run for this PR
  sleep 3  # Brief wait for push to trigger CI
  RUN_INFO=$(gh run list --branch "$BRANCH" --limit 1 --json databaseId,status,conclusion,name 2>/dev/null || echo "")
  if [ -z "$RUN_INFO" ] || [ "$RUN_INFO" = "[]" ]; then
    echo "No workflow runs found for PR #$PR_NUMBER yet"
    exit 0
  fi

  RUN_ID=$(echo "$RUN_INFO" | jq -r '.[0].databaseId')
  echo "Monitoring workflow run $RUN_ID for PR #$PR_NUMBER..."
fi

# Wait for CI to complete
for attempt in $(seq 1 $MAX_CI_WAIT_ATTEMPTS); do
  STATUS_INFO=$(gh run view "$RUN_ID" --json status,conclusion,name 2>/dev/null || echo "")

  if [ -z "$STATUS_INFO" ]; then
    echo "Could not fetch run status"
    exit 0
  fi

  STATUS=$(echo "$STATUS_INFO" | jq -r '.status')
  CONCLUSION=$(echo "$STATUS_INFO" | jq -r '.conclusion')
  NAME=$(echo "$STATUS_INFO" | jq -r '.name')

  if [ "$STATUS" = "completed" ]; then
    if [ "$CONCLUSION" = "success" ]; then
      echo "=== CI PASSED ==="
      echo "Workflow '$NAME' completed successfully"
      exit 0
    else
      echo "=== CI FAILED ==="
      echo "Workflow '$NAME' failed with conclusion: $CONCLUSION"
      echo ""
      echo "Fetching failure details..."
      echo ""
      gh run view "$RUN_ID" --log-failed 2>/dev/null | tail -100 || echo "Could not fetch logs"
      echo ""
      echo "Run 'gh run view $RUN_ID --log-failed' for full details"
      exit 1
    fi
  fi

  echo "CI status: $STATUS (attempt $attempt/$MAX_CI_WAIT_ATTEMPTS)..."
  sleep $CI_POLL_INTERVAL
done

echo "CI still running after $((MAX_CI_WAIT_ATTEMPTS * CI_POLL_INTERVAL))s"
echo "Check status manually: gh run view $RUN_ID"
exit 0
