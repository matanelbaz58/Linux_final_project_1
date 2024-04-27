#!/bin/bash

# Script name: commit.sh
# Description: Automates git commit process by including details from a CSV file and current time.

# Constants
CSV_FILE="tasks.csv"

# Check if CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file does not exist in the current directory."
    exit 1
fi

# Get current branch name
current_branch=$(git branch --show-current)
echo "Current branch: $current_branch"


# Check if additional description is provided
additional_description=""
if [ ! -z "$1" ]; then
    additional_description=":$1"
fi

# Extract relevant data from CSV
while IFS=, read -r bug_id description branch dev_name priority github_url
echo "Bug ID: $bug_id Description: $description Branch: $branch Developer Name: $dev_name Priority: $priority GitHub URL: $github_url"
do
    if [ "$branch" == "$current_branch" ]; then
        # Prepare commit message
        current_time=$(date "+%Y-%m-%d %H:%M:%S")
        commit_message="${bug_id}:${current_time}:${branch}:${dev_name}:${priority}:${description}${additional_description}"
        echo "Commit message: \n\n\n\n\n\n"
        echo $github_url
        echo "\n\n\n\n"
        
        # Git operations
        git add .
        git commit -m "$commit_message"
        git push $github_url --all
        if [ $? -eq 0 ]; then
            echo "Successfully pushed to GitHub."
        else
            echo "Error: Failed to push to GitHub."
            exit 1
        fi
        exit 0
    fi
done < <(tail -n +2 "$CSV_FILE")

echo "Error: No matching branch found in CSV."
exit 1