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
