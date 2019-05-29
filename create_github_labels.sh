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
declare -a names descriptions colors

names+=("bug"); descriptions+=("Something isn't right"); colors+=("EE3F46")
names+=("security"); descriptions+=("Potential Breach"); colors+=("EE3F46")
names+=("production"); descriptions+=("In production"); colors+=("F45D43")
names+=("chore"); descriptions+=("Annoying but useful"); colors+=("FEF2C0")
names+=("discussion"); descriptions+=("Let's talk about it"); colors+=("CC317C")
names+=("question"); descriptions+=(""); colors+=("CC317C")
names+=("enhancement"); descriptions+=("Add functionality to an already existing feature"); colors+=("5EBEFF")
names+=("optimizaiton"); descriptions+=("Optimize code"); colors+=("5EBEFF")
names+=("feature"); descriptions+=("New feature"); colors+=("91CA55")
names+=("in progress"); descriptions+=("Currently working on it"); colors+=("FBCA04")
names+=("wontfix"); descriptions+=("Not important"); colors+=("D2DAE1")
names+=("duplicate"); descriptions+=("Issue already exists"); colors+=("D2DAE1")
names+=("on hold"); descriptions+=("Not working on it at the moment"); colors+=("D2DAE1")

###
# Get a token from Github
###

token=$(cat .token)
read -p "Who owns the repo you want labels on?: " owner
read -p "What repo do you want labels on?: " repo

url="https://api.github.com/repos/${owner}/${repo}/labels"
header="Authorization: token ${token}"

for i in ${!names[@]}; do
    data="{\"name\":\"${names[$i]}\", \"color\":\"${colors[$i]}\", \"description\":\"${descriptions[$i]}\"}"

    curl_output=$(curl -s -H "${header}" -X POST "$url" -d "${data}")
    curl_has_error=$(echo "${curl_output}" | jq -r '.errors')

    if [ ! -z "${curl_has_error}" ] && [ "${curl_has_error}" != null ]; then
        error=$(echo "${curl_output}" | jq -r '.errors[0].code')

        if [ "${error}" == "already_exists" ]; then
            echo "'${names[$i]}' already exists. Updating..."
            curl_output=$(curl -s -H "${header}" -X PATCH "${url}/${names[$i]/ /%20}" -d "${data}")
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
