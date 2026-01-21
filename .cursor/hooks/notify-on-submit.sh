#!/bin/bash

# Notification blooms
# When thoughts are sent to AI
# A gentle reminder

# notify-on-submit.sh - Hook script that shows an OS notification when a prompt is submitted
# This script implements a beforeSubmitPrompt hook from the Cursor Hooks Spec

# Read JSON input from stdin
input=$(cat)

# Parse the prompt from the JSON input
prompt=$(echo "$input" | jq -r '.prompt // "Unknown prompt"')

# Get the first 50 characters of the prompt for the notification
prompt_preview=$(echo "$prompt" | head -c 50)
if [ ${#prompt} -gt 50 ]; then
    prompt_preview="${prompt_preview}..."
fi

# Show macOS notification
osascript -e "display notification \"$prompt_preview\" with title \"Prompt Submitted\" subtitle \"Processing your request...\""

# Always allow the prompt to continue
cat << EOF
{
  "permission": "allow"
}
EOF




























































