#!/bin/bash

# Define the path to the CSV file
csv_path="./tasks.csv"

# Check if CSV file exists
if [ ! -f "$csv_path" ]; then
    echo "Error: CSV file does not exist at $csv_path"
    exit 1
fi

# Get the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Find the row in the CSV file for the current branch and read the needed fields
# Use the corrected header names and improve parsing with space and case handling
IFS=, read -r bug_id description branch developer priority github_url < <(awk -v branch="$current_branch" 'BEGIN{FS=OFS=","} {gsub(/^ *| *$/, "", $3); if(tolower($3) == tolower(branch)) print $1, $2, $3, $4, $5, $6}' $csv_path)

# Add debugging statements to help trace values
echo "Current branch is: $current_branch"
echo "Parsed CSV values: BugId: $bug_id, Description: $description, Branch: $branch, Developer: $developer, Priority: $priority, GitHub URL: $github_url"

# Exit if no entry is found for the current branch
if [ -z "$bug_id" ]; then
    echo "No tasks found for branch $current_branch in $csv_path"
    exit 1
fi

# Get current date and time
current_date_time=$(date +"%Y-%m-%d %H:%M:%S")

# Construct the commit message
commit_message="BugID:$bug_id:$current_date_time:Branch $branch:DevName $developer:Priority $priority:$description"

# Append additional developer description if provided
if [ ! -z "$1" ]; then
    commit_message+=":Dev Description $1"
fi

# Stage all changes
git add .

# Commit changes
git commit -m "$commit_message"
echo "Committed changes with message: $commit_message"
# Push to the remote repository
git push origin $current_branch
if [ $? -ne 0 ]; then
    echo "Error: Failed to push to GitHub."
    exit 1
fi
