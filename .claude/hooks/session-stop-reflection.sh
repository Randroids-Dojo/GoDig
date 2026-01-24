#!/bin/bash
# Session stop hook - prompts agent to reflect on AGENTS.md improvements

cat << 'EOF'
SESSION REFLECTION PROMPT:

Before ending, consider: Would any AGENTS.md changes help the next agent avoid issues you encountered in this session?

If yes, propose updates to AGENTS.md covering:
- Tools or commands that were hard to find
- Workflows that weren't obvious
- Gotchas or platform-specific limitations
- File locations that required exploration
- Best practices you discovered

If the session was smooth with no issues, no changes needed.
EOF
