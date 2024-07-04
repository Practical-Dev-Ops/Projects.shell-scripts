#!/bin/bash

##########################################################################################################################################
# About: List read access script
# Author: SDolaide
# Owner: Practical-Dev-Ops
# Date: 4th July 2024
# This script would list users with only read access to a GitHub repository. A user need to provide username, token,  repo owner and repo.
# Input: Username, Access Token, Owner, and Repo.
##########################################################################################################################################

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token from arguments
USERNAME=$1
TOKEN=$2

# User and Repository information
REPO_OWNER=$3
REPO_NAME=$4

# Check if USERNAME and TOKEN are provided
if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
    echo "Error: Please provide the GitHub username and personal access token as the first two arguments."
    echo "Usage: $0 <username> <token> <repo_owner> <repo_name>"
    exit 1
fi

# Check if REPO_OWNER and REPO_NAME are provided
if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
    echo "Error: Please provide the repository owner and repository name as the third and fourth arguments."
    echo "Usage: $0 <username> <token> <repo_owner> <repo_name>"
    exit 1
fi

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to check if the provided credentials are correct
function check_credentials {
    local endpoint="user"

    # Fetch the authenticated user's information
    response=$(github_api_get "$endpoint")

    # Check if the response contains a "login" field
    if echo "$response" | jq -e '.login' > /dev/null 2>&1; then
        echo "Authenticated successfully as $(echo "$response" | jq -r '.login')."
    else
        echo "Error: Authentication failed. Please check your username and token."
        exit 1
    fi
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
check_credentials
echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
