#!/bin/bash

# redact-secrets.sh - Hook script that checks for GitHub API keys in file content
# This script implements a file content validation hook from the Cursor Hooks Spec

# Initialize debug logging
echo "Redact-secrets hook execution started" >> /tmp/hooks.log

# Read JSON input from stdin
input=$(cat)
echo "Received input: $input" >> /tmp/hooks.log

# Parse the file path and content from the JSON input
file_path=$(echo "$input" | jq -r '.filePath // empty')
content=$(echo "$input" | jq -r '.content // empty')
echo "Parsed file path: '$file_path'" >> /tmp/hooks.log
echo "Content length: ${#content} characters" >> /tmp/hooks.log

# Check if the content contains a GitHub API key pattern: gh_api_<24 characters>
# Pattern explanation: gh_api_ followed by exactly 24 alphanumeric characters
if echo "$content" | grep -qE 'gh_api_[A-Za-z0-9]{24}'; then
    echo "GitHub API key detected in file: '$file_path'" >> /tmp/hooks.log
    # Deny permission if GitHub API key is detected
    cat << EOF
{
  "permission": "deny"
}
EOF
else
    echo "No GitHub API key detected in file: '$file_path' - allowing" >> /tmp/hooks.log
    # Allow permission if no GitHub API key is detected
    cat << EOF
{
  "permission": "allow"
}
EOF
fi

