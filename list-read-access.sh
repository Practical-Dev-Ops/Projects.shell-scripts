#!/bin/bash

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token (make sure to set these environment variables)
USERNAME=${username}
TOKEN=${token}

# User and Repository information from arguments
REPO_OWNER=$1
REPO_NAME=$2

# Check if USERNAME and TOKEN are set
if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
    echo "Error: Please set the GitHub username and personal access token."
    exit 1
fi

# Check if REPO_OWNER and REPO_NAME are provided
if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
    echo "Usage: $0 <repo_owner> <repo_name>"
    exit 1
fi

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch the list of collaborators on the repository
    collaborators=$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true and .permissions.push == false and .permissions.admin == false) | .login')

    # Display the list of collaborators with read access
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# Main script
echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
