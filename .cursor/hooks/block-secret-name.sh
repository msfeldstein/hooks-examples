#!/bin/bash

# Hook to block prompts containing 'secret-name'
# This hook implements the beforeSubmitPrompt hook from the Cursor Hooks Spec

# Initialize debug logging
echo "Hook execution started - block-secret-name" >> /tmp/hooks.log

# Read JSON input from stdin
input=$(cat)
echo "Received input: $input" >> /tmp/hooks.log

# Parse the prompt text from the JSON input
# The prompt text could be in different fields depending on the structure
prompt_text=$(echo "$input" | jq -r '.text // .prompt // .content // empty')
echo "Parsed prompt text: '$prompt_text'" >> /tmp/hooks.log

# Check if the prompt contains 'secret-name' (case-insensitive)
if [[ "$prompt_text" =~ [Ss][Ee][Cc][Rr][Ee][Tt]-[Nn][Aa][Mm][Ee] ]]; then
    echo "Secret-name detected in prompt - blocking" >> /tmp/hooks.log
    # Block the prompt submission
    cat << EOF
{
  "continue": false
}
EOF
else
    echo "No secret-name detected - allowing prompt" >> /tmp/hooks.log
    # Allow the prompt submission
    cat << EOF
{
  "continue": true
}
EOF
fi





