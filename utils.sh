#!/usr/bin/env bash

###
# Constants
###

declare -a original names descriptions colors
original=("good first issue" "help wanted" "invalid")
names+=("bug");descriptions+=("Something isn't working");colors+=("EE3F46")
names+=("security");descriptions+=("Potential breach");colors+=("EE3F46")
names+=("production");descriptions+=("In production");colors+=("F45D43")
names+=("chore");descriptions+=("Annoying to do but needed");colors+=("FEF2C0")
names+=("discussion");descriptions+=("Communication is key");colors+=("CC317C")
names+=("question");descriptions+=("Further information is requested");colors+=("CC317C")
names+=("enhancement");descriptions+=("Add functionality to an already existing feature");colors+=("5EBEFF")
names+=("optimizaiton");descriptions+=("Code optimization or refactoring");colors+=("5EBEFF")
names+=("feature");descriptions+=("New feature or request");colors+=("91CA55")
names+=("in progress");descriptions+=("Currently working on it");colors+=("FBCA04")
names+=("wontfix");descriptions+=("This will not be worked on");colors+=("D2DAE1")
names+=("duplicate");descriptions+=("This issue or pull request already exists");colors+=("D2DAE1")
names+=("on hold");descriptions+=("Not working on it at the moment");colors+=("D2DAE1")

###
# Script help
###
usage() {
    echo "Usage:"
    echo -e " $0 [ -d | --delete-original ] [ --help | -h ]\n"
    echo -e "\tDefault only creates or updates labels"
}

###
# Deletion function
###
delete_original() {
    for i in ${!original[@]}; do
        curl_output=$(curl -s -H "${token_header}" -H "${accept_header}" -X DELETE "${url}/${original[$i]// /%20}")
        curl_has_error=$(echo "${curl_output}" | jq -r '.errors')

        if [ ! -z "${curl_has_error}" ] && [ "${curl_has_error}" != null ]; then
            error=$(echo "${curl_output}")
            echo "Error: ${error}"
            echo -e "Output from curl: \n${curl_output}"
            echo "Exiting..."
            exit 1
        fi
        sleep 1
    done
    echo "Deleted originals."
}

###
# Creation/Updata function
###
create_or_update() {

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
}
