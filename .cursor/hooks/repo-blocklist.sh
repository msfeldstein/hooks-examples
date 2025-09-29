#!/bin/bash

# Hook to block file reads from repositories in a static blocklist
# This hook implements the beforeFileRead hook from the Cursor Hooks Spec

# Initialize debug logging
echo "Repo blocklist hook execution started" >> /tmp/hooks.log

# Read JSON input from stdin
input=$(cat)
echo "Received input: $input" >> /tmp/hooks.log

# Parse the file path from the JSON input
file_path=$(echo "$input" | jq -r '.filePath // empty')
echo "Parsed file path: '$file_path'" >> /tmp/hooks.log

# Static blocklist of repository names/URLs (add your blocked repos here)
BLOCKED_REPOS=(
    "sensitive-project"
    "confidential-repo" 
    "private-company-code"
    "github.com/company/secret-project"
    "gitlab.com/org/classified"
    "example-blocked-repo"
)

# Function to get git repository info
get_git_repo_info() {
    local file_dir
    file_dir=$(dirname "$file_path")
    
    # Find the git repository root by looking for .git directory
    local current_dir="$file_dir"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/.git" ]]; then
            echo "Found git repository at: $current_dir" >> /tmp/hooks.log
            
            # Get repository name from directory name
            local repo_name=$(basename "$current_dir")
            echo "Repository name: $repo_name" >> /tmp/hooks.log
            
            # Try to get remote URL if available
            local remote_url=""
            if [[ -f "$current_dir/.git/config" ]]; then
                remote_url=$(grep -E "url\s*=" "$current_dir/.git/config" | head -1 | sed 's/.*url\s*=\s*//' | tr -d ' ')
                echo "Repository remote URL: $remote_url" >> /tmp/hooks.log
            fi
            
            echo "$repo_name|$remote_url"
            return 0
        fi
        current_dir=$(dirname "$current_dir")
    done
    
    echo "No git repository found for file: $file_path" >> /tmp/hooks.log
    echo "|"
    return 1
}

# Check if file is empty or doesn't exist
if [[ -z "$file_path" ]]; then
    echo "No file path provided - allowing" >> /tmp/hooks.log
    cat << EOF
{
  "permission": "allow"
}
EOF
    exit 0
fi

# Get repository information
repo_info=$(get_git_repo_info)
repo_name=$(echo "$repo_info" | cut -d'|' -f1)
remote_url=$(echo "$repo_info" | cut -d'|' -f2)

# Check if repository name or URL matches any in the blocklist
blocked=false
matched_entry=""

for blocked_repo in "${BLOCKED_REPOS[@]}"; do
    # Check repository name match
    if [[ "$repo_name" == "$blocked_repo" ]]; then
        blocked=true
        matched_entry="$blocked_repo (repository name)"
        break
    fi
    
    # Check remote URL match (if available)
    if [[ -n "$remote_url" && "$remote_url" == *"$blocked_repo"* ]]; then
        blocked=true
        matched_entry="$blocked_repo (remote URL)"
        break
    fi
done

if [[ "$blocked" == true ]]; then
    echo "Repository blocked - matched: $matched_entry" >> /tmp/hooks.log
    # Block file read from repositories in the blocklist
    cat << EOF
{
  "permission": "deny",
  "userMessage": "File read blocked: Repository '$repo_name' is in the blocklist.",
  "agentMessage": "Access to files in the repository '$repo_name' has been blocked by a project policy. This repository is included in the static blocklist and file reads are not permitted. Matched entry: $matched_entry"
}
EOF
else
    echo "Repository not in blocklist - allowing file read" >> /tmp/hooks.log
    # Allow file read for repositories not in the blocklist
    cat << EOF
{
  "permission": "allow"
}
EOF
fi


