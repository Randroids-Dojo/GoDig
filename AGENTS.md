# GoDig Agent Instructions

## Integration Testing Requirements

**ALWAYS write or update PlayGodot integration tests when making changes.**

When implementing new features or modifying existing functionality:
1. Add tests to `tests/test_hello_world.py` (or create new test files in `tests/`)
2. Update `tests/helpers.py` with any new node paths
3. Run tests locally with `python3 -m pytest tests/ -v` before pushing
4. Ensure all tests pass before considering the task complete

### PlayGodot Test Patterns

```python
# tests/helpers.py - Define node paths
PATHS = {
    "main": "/root/Main",
    "player": "/root/Main/Player",
    "game_manager": "/root/GameManager",
}

# Test file - Use async tests with the game fixture
@pytest.mark.asyncio
async def test_node_exists(game):
    exists = await game.node_exists(PATHS["player"])
    assert exists, "Player node should exist"

@pytest.mark.asyncio
async def test_property_value(game):
    value = await game.get_property(PATHS["game_manager"], "is_running")
    assert value is True, "Game should be running"
```

### What to Test
- Scene structure (nodes exist at expected paths)
- Initial state (properties have correct default values)
- Game manager state
- UI elements display correct text
- New gameplay mechanics work as expected

## CI/CD Requirements

**ALWAYS troubleshoot CI issues when pushing.**

After any `git push`, you must:
1. Check the CI workflow status using `gh run list --limit 1`
2. If the run fails, investigate with `gh run view <run-id> --log-failed`
3. Fix any failing tests or build issues before considering the task complete
4. Re-push and verify CI passes

Do not consider a push successful until CI is green.

## Task Management with Dots

**Use `dot` for tracking work items during sessions.**

Dots is a lightweight task tracker for managing work. Use it to track discrete tasks, bugs, and features.

### Quick Reference

```bash
# Creating dots
dot "Fix the bug"                        # Quick add
dot add "Design API" -p 1 -d "Details"   # With priority and description
dot add "Subtask" -P dots-1              # As child of dots-1
dot add "After X" -a dots-2              # Depends on dots-2

# Working on dots
dot ls                    # List all open dots
dot ready                 # Show unblocked dots (ready to work)
dot on dots-3             # Start working on a dot
dot off dots-3            # Complete a dot
dot off dots-3 -r "Done"  # Complete with reason

# Viewing dots
dot show dots-1           # Show dot details
dot tree                  # Show hierarchy
dot find "query"          # Search dots
```

### Priority Levels

Use `-p` flag when creating dots:
- `0` = Critical (do now)
- `1` = High
- `2` = Medium (default)
- `3` = Low
- `4` = Backlog

### Workflow

1. **Starting a session**: Run `dot ready` to see available work
2. **Claiming work**: Run `dot on <id>` before starting
3. **Completing work**: Run `dot off <id>` when done
4. **Creating subtasks**: Use `-P parent-id` for hierarchical organization

### When to Use Dots vs TodoWrite

- **Dots**: Multi-step work, tasks that may span sessions, work with dependencies
- **TodoWrite**: Simple single-session execution tracking visible to user

## Ralph Loop Protection

**NEVER remove or cancel a Ralph loop without explicit user instruction.**

The Ralph loop file at `.claude/ralph-loop.local.md` controls iterative improvement tasks. When a Ralph loop is active:
1. Continue iterating until `max_iterations` is reached
2. Always keep the primer version as the quality baseline
3. Only update primer when improvements are validated
4. Do NOT delete the ralph-loop.local.md file
5. Do NOT run `/ralph-wiggum:cancel-ralph` unless the user explicitly requests it

The Ralph loop is designed to run autonomously. Completion of work within an iteration does not mean the loop should stop.
