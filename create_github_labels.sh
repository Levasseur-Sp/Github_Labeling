#!/usr/bin/env bash
# This is a modification from https://gist.github.com/omegahm/28d87a4e1411c030aa89
# Colours and convention picked from https://robinpowered.com/blog/best-practice-system-for-organizing-and-tagging-github-issues/


## Instructions
# Bash 4+ is needed because of associative arrays
# jq (https://stedolan.github.io/jq/)
# Create access Token from Github (https://help.github.com/articles/creating-an-access-token-for-command-line-use/) and save it under ".token" file
# Comment / Uncomment / Add, all the labels you want
# To run the script from command line:
# $ chmod +x create_labels.sh
# $ ./create_labels.sh

###
# Label definitions
###
declare -A LABELS

# Platform
# LABELS["ruby"]="BFD4F2"
# LABELS["rails"]="BFD4F2"

# Problems
LABELS["bug"]="EE3F46"
LABELS["security"]="EE3F46"
LABELS["production"]="F45D43"

# Mindless
LABELS["chore"]="FEF2C0"
# LABELS["legal"]="FFF2C1"

# Experience
LABELS["copy"]="FFC274"
LABELS["design"]="FFC274"
LABELS["ux"]="FFC274"

# Environment
# LABELS["staging"]="FAD8C7"
# LABELS["test"]="FAD8C7"

# Feedback
LABELS["discussion"]="CC317C"
# LABELS["rfc"]="CC317C"
# LABELS["question"]="CC317C"

# Improvements
LABELS["enhancement"]="5EBEFF"
#LABELS["optimizaiton"]="5EBEFF"

# Additions
LABELS["feature"]="91CA55"

# Pending
LABELS["in progress"]="FBCA04"
# LABELS["watchlist"]="FBCA04"

# Inactive
LABELS["invalid"]="D2DAE1"
LABELS["wontfix"]="D2DAE1"
LABELS["duplicate"]="D2DAE1"
#LABELS["on hold"]="D2DAE1"

###
# Get a token from Github
###

TOKEN=$(cat .token)

read -p "Who owns the repo you want labels on?: " owner
read -p "What repo do you want labels on?: " repo

for K in "${!LABELS[@]}"; do
  CURL_OUTPUT=$(curl -s -H "Authorization: token $TOKEN" -X POST "https://api.github.com/repos/$owner/$repo/labels" -d "{\"name\":\"$K\", \"color\":\"${LABELS[$K]}\"}")
  HAS_ERROR=$(echo "$CURL_OUTPUT" | jq -r '.errors')

  if [ ! -z "$HAS_ERROR" ] && [ "$HAS_ERROR" != null ]; then
    ERROR=$(echo "$CURL_OUTPUT" | jq -r '.errors[0].code')

    if [ "$ERROR" == "already_exists" ]; then
      # We update
      echo "'$K' already exists. Updating..."
      CURL_OUTPUT=$(curl -s -H "Authorization: token $TOKEN" -X PATCH "https://api.github.com/repos/$owner/$repo/labels/${K/ /%20}" -d "{\"name\":\"$K\", \"color\":\"${LABELS[$K]}\"}")
    else
      echo "Unknown error: $ERROR"
      echo "Output from curl: "
      echo "$CURL_OUTPUT"
      echo "Exiting..."
      exit 1;
    fi
  else
    echo "Created '$K'."
  fi
done
exit 0