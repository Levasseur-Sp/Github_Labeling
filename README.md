# Github Labeling

This is the result of wanting a less annoying labeling system for when I create a repo.

Could've created a gist but decided on making a repo as it gives an opportunity to test it in the repo and have a readme.

## Requirements
- Bash 4+ is needed because of associative arrays
- [Jq](https://stedolan.github.io/jq/)
- A [personal github access token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/)

## Setup && Usage
- Clone this project `git clone https://github.com/Levasseur-Sp/Github_Labeling`
- Make a `.github_api_token` file
- Copy the personal github access token and put it inside the `.github_api_token` file
- Add script execution permission `chmod +x github_labels.sh`
- Use the script `./create_github_labels.sh`
  - It will prompt you for the repo owner and repo name

## Sources
- Original from Mads Ohm Larsen, (***omegahm***), [here](https://gist.github.com/omegahm/28d87a4e1411c030aa89)
- Colours and convention picked from [here](https://robinpowered.com/blog/best-practice-system-for-organizing-and-tagging-github-issues/)
