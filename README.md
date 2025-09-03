# Cursor Hooks Example Project

This project demonstrates the use of Cursor Hooks to control and monitor shell command execution within the Cursor IDE. The hooks are located in the `.cursor/hooks/` directory and implement various security and auditing features.

## What are Cursor Hooks?

Cursor Hooks are scripts that can intercept and control shell commands before they are executed by the AI agent or user within Cursor. They implement the `beforeShellExecution` hook from the Cursor Hooks Specification, allowing you to:

- Block potentially dangerous commands
- Require user permission for sensitive operations
- Audit and log all command executions
- Redirect users to better alternatives

## Hooks in This Project

### 1. [`block-git.sh`](.cursor/hooks/block-git.sh) - Git Command Control Hook

This hook implements intelligent Git command management by:

**What it does:**

- **Blocks all `git` commands** and prevents their execution
- **Requires permission for `gh` (GitHub CLI) commands** before execution
- **Allows all other commands** to run normally

**Example behavior:**

- `git push` → Blocked with message suggesting `gh repo sync`
- `gh repo clone` → Asks for user permission
- `npm install` → Allowed without intervention

### 2. [`audit.sh`](.cursor/hooks/audit.sh) - Command Auditing Hook

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

### 3. [`redact-secrets.sh`](.cursor/hooks/redact-secrets.sh) - File Content Security Hook

This hook implements file content validation to prevent accidental exposure of sensitive credentials:

**What it does:**

- **Scans file content** for GitHub API key patterns before saving
- **Blocks files** containing GitHub personal access tokens (`ghp_`) or GitHub app tokens (`ghs_`)
- **Allows safe files** to be saved normally
- **Logs all decisions** to `/tmp/hooks.log` for debugging

**Security patterns detected:**

- GitHub personal access tokens: `ghp_[36 alphanumeric characters]`
- GitHub app tokens: `ghs_[36 alphanumeric characters]`

**Example behavior:**

- File with `ghp_1234567890abcdef1234567890abcdef12345678` → **Blocked**
- File with `ghs_abcdef1234567890abcdef1234567890abcdef` → **Blocked**
- File with regular code → **Allowed**

**Why it's useful:**

- Prevents accidental credential commits
- Protects against copy-paste errors
- Maintains security compliance
- Provides immediate feedback on potential leaks

## How Hooks Work

This project demonstrates two types of Cursor Hooks:

### Shell Command Hooks (`beforeShellExecution`)

Hooks like `block-git.sh` and `audit.sh` that intercept shell commands:

1. **Receives JSON input** from Cursor via stdin containing command details
2. **Processes the command** according to its logic
3. **Returns a JSON response** with one of three permissions:
   - `"allow"` - Execute the command
   - `"deny"` - Block the command
   - `"ask"` - Request user permission
4. **Can provide messages** to both user and agent explaining the decision

### File Content Validation Hooks

Hooks like `redact-secrets.sh` that validate file content before saving:

1. **Receives JSON input** containing file path and content
2. **Scans the content** for security patterns or violations
3. **Returns a JSON response** with permission:
   - `"allow"` - Save the file
   - `"deny"` - Block the file save
4. **Logs decisions** for audit and debugging purposes

## Hook Response Format

```json
{
  "continue": true,
  "permission": "allow|deny|ask",
  "userMessage": "Message shown to the user",
  "agentMessage": "Message shown to the AI agent"
}
```
