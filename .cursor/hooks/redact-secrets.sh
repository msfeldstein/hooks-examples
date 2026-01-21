#!/bin/bash
# Shebang line: tells the system to use bash to execute this script

# Secrets hide in code
# Like shadows in the moonlight
# This hook finds them all

# redact-secrets.sh - Hook script that checks for GitHub API keys in file content
# This script implements a file content validation hook from the Cursor Hooks Spec
# Purpose: Prevent accidental commits of GitHub API keys and tokens

# Initialize debug logging
# All hook execution events are logged to /tmp/hooks.log for debugging
echo "Redact-secrets hook execution started" >> /tmp/hooks.log

# Read JSON input from stdin
# Cursor sends hook data as JSON via stdin containing filePath and content
input=$(cat)
echo "Received input: $input" >> /tmp/hooks.log

# Parse the file path and content from the JSON input
# Using jq (JSON processor) to extract values from the JSON structure
# -r flag outputs raw strings without JSON quotes
# // empty provides a default empty string if the key doesn't exist
file_path=$(echo "$input" | jq -r '.filePath // empty')
content=$(echo "$input" | jq -r '.content // empty')
echo "Parsed file path: '$file_path'" >> /tmp/hooks.log
echo "Content length: ${#content} characters" >> /tmp/hooks.log

# Check if the content contains a GitHub API key pattern
# Pattern explanation: 
#   - 'gh[ps]_[A-Za-z0-9]{36}' matches:
#     * 'ghp_' prefix (GitHub personal access tokens) OR 'ghs_' prefix (GitHub app tokens)
#     * Followed by exactly 36 alphanumeric characters
#   - '|' is the OR operator
#   - 'gh_api_[A-Za-z0-9]+' matches:
#     * 'gh_api_' prefix (GitHub test/API keys)
#     * Followed by one or more alphanumeric characters
# grep flags:
#   -q: quiet mode (suppress output, only return exit code)
#   -E: extended regex mode (enables the pattern syntax used)
if echo "$content" | grep -qE 'gh[ps]_[A-Za-z0-9]{36}|gh_api_[A-Za-z0-9]+'; then
    # Pattern matched - GitHub API key detected in the file content
    echo "GitHub API key detected in file: '$file_path'" >> /tmp/hooks.log
    # Deny permission if GitHub API key is detected
    # Output must be valid JSON according to Cursor Hooks Spec
    cat << EOF
{
  "permission": "deny"
}
EOF
    # Exit code 3 indicates the hook denied the operation
    exit 3
else
    # Pattern did not match - no GitHub API keys found
    echo "No GitHub API key detected in file: '$file_path' - allowing" >> /tmp/hooks.log
    # Allow permission if no GitHub API key is detected
    # Output must be valid JSON according to Cursor Hooks Spec
    cat << EOF
{
  "permission": "allow"
}
EOF
fi

