#!/usr/bin/env bash

###
# Import
###
source utils.sh

###
# Setup
###
token=$(cat .github_api_token)
read -p "What is the name of the repository?: " repo
read -p "Who is the owner of the repository?: " owner

url="https://api.github.com/repos/${owner}/${repo}/labels"
token_header="Authorization: token ${token}"
accept_header="Accept: application/vnd.github.symmetra-preview+json"

###
# Main
###
optspec="dh"
while getopts "$optspec" opt; do
    case $opt in
    h)
        usage
        exit 0
        ;;
    d) delete_original ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 127
        ;;
    esac
done

create_or_update
exit 0
