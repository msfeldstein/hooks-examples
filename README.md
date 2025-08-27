# Cursor Hooks Example Project

This project demonstrates the use of Cursor Hooks to control and monitor shell command execution within the Cursor IDE. The hooks are located in the `.cursor/hooks/` directory and implement various security and auditing features.

## What are Cursor Hooks?

Cursor Hooks are scripts that can intercept and control shell commands before they are executed by the AI agent or user within Cursor. They implement the `beforeShellExecution` hook from the Cursor Hooks Specification, allowing you to:

- Block potentially dangerous commands
- Require user permission for sensitive operations
- Audit and log all command executions
- Redirect users to better alternatives

## Hooks in This Project

### 1. `block-git.sh` - Git Command Control Hook

This hook implements intelligent Git command management by:

**What it does:**
- **Blocks all `git` commands** and prevents their execution
- **Requires permission for `gh` (GitHub CLI) commands** before execution
- **Allows all other commands** to run normally

**Example behavior:**
- `git push` → Blocked with message suggesting `gh repo sync`
- `gh repo clone` → Asks for user permission
- `npm install` → Allowed without intervention

### 2. `audit.sh` - Command Auditing Hook

This hook provides comprehensive logging and auditing capabilities:

**What it does:**
- **Logs all shell commands** and their metadata to `/tmp/agent-audit.log`
- **Timestamps each entry** for chronological tracking
- **Captures the full JSON context** provided by Cursor

**Why it's useful:**
- Security auditing and compliance
- Debugging command execution issues
- Tracking AI agent behavior
- Monitoring user command patterns

**Log format:**
```
[2024-01-15 14:30:25] {"command": "npm install", "workingDirectory": "/path/to/project", ...}
```

## How Hooks Work

Each hook script:

1. **Receives JSON input** from Cursor via stdin containing command details
2. **Processes the command** according to its logic
3. **Returns a JSON response** with one of three permissions:
   - `"allow"` - Execute the command
   - `"deny"` - Block the command
   - `"ask"` - Request user permission

4. **Can provide messages** to both user and agent explaining the decision

## Hook Response Format

```json
{
  "continue": true,
  "permission": "allow|deny|ask",
  "userMessage": "Message shown to the user",
  "agentMessage": "Message shown to the AI agent"
}
```