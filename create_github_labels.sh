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
# $ chmod +x create_labels.sh
# $ ./create_labels.sh

###
# Label definitions
###
declare -A LABELS

# Problems
LABELS["bug"]="EE3F46"
LABELS["security"]="EE3F46"
LABELS["production"]="F45D43"

# Mindless
LABELS["chore"]="FEF2C0"

# Feedback
LABELS["discussion"]="CC317C"
LABELS["rfc"]="CC317C"
LABELS["question"]="CC317C"

# Improvements
LABELS["enhancement"]="5EBEFF"
LABELS["optimizaiton"]="5EBEFF"

# Additions
LABELS["feature"]="91CA55"

# Pending
LABELS["in_progress"]="FBCA04"

# Inactive
LABELS["invalid"]="D2DAE1"
LABELS["wontfix"]="D2DAE1"
LABELS["duplicate"]="D2DAE1"
LABELS["on_hold"]="D2DAE1"

###
# Get a token from Github
###

token=$(cat .token)
read -p "Who owns the repo you want labels on?: " owner
read -p "What repo do you want labels on?: " repo

url="https://api.github.com/repos/${owner}/${repo}/labels"
header="Authorization: token ${token}"

for name in ${!LABELS[@]}; do
    data="{\"name\":\"${name}\", \"color\":\"${LABELS[$name]}\"}"

    curl_output=$(curl -s -H "${header}" -X POST "$url" -d "${data}")
    curl_has_error=$(echo "${curl_output}" | jq -r '.errors')

    if [ ! -z "${curl_has_error}" ] && [ "${curl_has_error}" != null ]; then
        error=$(echo "${curl_output}" | jq -r '.errors[0].code')

        if [ "${error}" == "already_exists" ]; then
            echo "'${name}' already exists. Updating..."
            curl_output=$(curl -s -H "${header}" -X PATCH "${url}/${name/ /%20}" -d "${data}")
            echo "Updated '${name}'."
        else
            echo "Unknown error: ${error}"
            echo -e "Output from curl: \n${curl_output}"
            echo "Exiting..."
            exit 1
        fi
    else
        echo "Created '${name}'."
    fi
done
exit 0
