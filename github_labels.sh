#!/usr/bin/env bash

# This is a clone of
#   https://gist.github.com/Chompas/fb158eb01204d03f783d
# Colours and convention picked from
#   https://robinpowered.com/blog/best-practice-system-for-organizing-and-tagging-github-issues/

## Instructions
# Bash 4+ is needed because of associative arrays
# jq (https://stedolan.github.io/jq/)
# Create access Token from Github https://help.github.com/articles/creating-an-access-token-for-command-line-use/
#   and save it under ".token" file

# To run the script from command line:
# $ chmod +x create_github_labels.sh
# $ ./create_github_labels.sh

###
# Script usage
###
usage() {
    echo "Usage:"
    echo -e " $0 [ -d | --delete-original ] [ -D | --delete-all ]\n $0 [ --help | -h ]\n"
    echo -e "\tDefault only creates/updates labels"
}

###
# Deletion functions
###
delete_original() {
    echo "Not yet implemented"
    exit 0
}

delete_all() {
    echo "Not yet implemented"
    exit 0
}

###
# Script flags consideration
###
optspec="dDh"
while getopts "$optspec" opt; do
    if [ $opt == "h"]; then
        usage
        exit 0
    fi
done

while getopts "$optspec" opt; do
    case $opt in
    d) delete_original ;;
    D) delete_all ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 127
        ;;
    esac
done

###
# Label definitions
###
declare -a names descriptions colors

names+=("bug"); descriptions+=("Something isn't working"); colors+=("EE3F46")
names+=("security"); descriptions+=("Potential breach"); colors+=("EE3F46")
names+=("production"); descriptions+=("In production"); colors+=("F45D43")
names+=("chore"); descriptions+=("Annoying to do but needed"); colors+=("FEF2C0")
names+=("discussion"); descriptions+=("Communication is key"); colors+=("CC317C")
names+=("question"); descriptions+=("Further information is requested"); colors+=("CC317C")
names+=("enhancement"); descriptions+=("Add functionality to an already existing feature"); colors+=("5EBEFF")
names+=("optimizaiton"); descriptions+=("Code optimization or refactoring"); colors+=("5EBEFF")
names+=("feature"); descriptions+=("New feature or request"); colors+=("91CA55")
names+=("in progress"); descriptions+=("Currently working on it"); colors+=("FBCA04")
names+=("wontfix"); descriptions+=("This will not be worked on"); colors+=("D2DAE1")
names+=("duplicate"); descriptions+=("This issue or pull request already exists"); colors+=("D2DAE1")
names+=("on hold"); descriptions+=("Not working on it at the moment"); colors+=("D2DAE1")

###
# Get and set necessary information
###

token=$(cat .github_api_token)
read -p "Who owns the repo you want labels on?: " owner
read -p "What repo do you want labels on?: " repo

url="https://api.github.com/repos/${owner}/${repo}/labels"
token_header="Authorization: token ${token}"
accept_header="Accept: application/vnd.github.symmetra-preview+json"

###
# Create or Update labels
###

for i in ${!names[@]}; do
    data="{\"name\":\"${names[$i]}\", \"color\":\"${colors[$i]}\", \"description\":\"${descriptions[$i]}\"}"

    curl_output=$(curl -s -H "${token_header}" -H "${accept_header}" -X POST "${url}" -d "${data}")
    curl_has_error=$(echo "${curl_output}" | jq -r '.errors')

    if [ ! -z "${curl_has_error}" ] && [ "${curl_has_error}" != null ]; then
        error=$(echo "${curl_output}" | jq -r '.errors[0].code')

        if [ "${error}" == "already_exists" ]; then
            echo "'${names[$i]}' already exists. Updating..."
            curl_output=$(curl -s -H "${token_header}" -H "${accept_header}" -X PATCH "${url}/${names[$i]/ /%20}" -d "${data}")
            echo "Updated '${names[$i]}'."
        else
            echo "Unknown error: ${error}"
            echo -e "Output from curl: \n${curl_output}"
            echo "Exiting..."
            exit 1
        fi
    else
        echo "Created '${names[$i]}'."
    fi
done
exit 0
