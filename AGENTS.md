# GoDig Agent Instructions

## CI/CD Requirements

**ALWAYS troubleshoot CI issues when pushing.**

After any `git push`, you must:
1. Check the CI workflow status using `gh run list --limit 1`
2. If the run fails, investigate with `gh run view <run-id> --log-failed`
3. Fix any failing tests or build issues before considering the task complete
4. Re-push and verify CI passes

Do not consider a push successful until CI is green.
