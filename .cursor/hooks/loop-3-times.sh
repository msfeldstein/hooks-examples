#!/bin/bash

# Read the input JSON from stdin
input=$(cat)

# Extract loop_count from the input JSON
loop_count=$(echo "$input" | jq -r '.loopCount // 0')

# Check if loop_count is less than 3
if [ "$loop_count" -lt 13 ]; then
    # Return with followupMessage to continue the loop
    cat << EOF
{
  "continue": true,
  "followup_message": "Just say hello"
}
EOF
fi
