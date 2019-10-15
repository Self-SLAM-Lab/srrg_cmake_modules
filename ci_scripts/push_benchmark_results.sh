#!/bin/bash
#ds this script is intended to be sourced!

#ds check input parameters
if [ "$#" -ne 4 ]; then
  echo "ERROR: call as $0 RESULT_REPOSITORY_PATH PROJECT_NAME DATASET_NAME COMMIT_MESSAGE"
  exit -1
fi

#ds commit hash needs to be set
if [ -z "$CI_COMMIT_SHA" ]; then
  echo "ERROR: CI commit SHA not set"
  exit -1
fi

#ds start
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;96mbash version: ${BASH_VERSION}\e[0m"
RESULT_REPOSITORY_PATH="$1"
PROJECT_NAME="$2"
DATASET_NAME="$3"
COMMIT_MESSAGE="$4"

#ds update reference commit in the provided result repository
cd "$RESULT_REPOSITORY_PATH"
sed -i "s|\[${DATASET_NAME}\]\: https://gitlab.com/srrg-software/${PROJECT_NAME}/commit/.*|\[${DATASET_NAME}\]\: https://gitlab.com/srrg-software/${PROJECT_NAME}/commit/${CI_COMMIT_SHA}|g" "readme.md"
git config --global user.email "benchamin@srrg.com"
git config --global user.name "benchamin"
git add "results"
ls -al

#ds if the content has changed (does not have to be the case)
if [[ $(git status) != *"nothing to commit, working tree clean"* ]]; then
  #ds push to remote without triggering it's ci
  echo -e "\e[1;96mgit commit -am ${COMMIT_MESSAGE} [skip ci]\e[0m"
  git commit -am "${COMMIT_MESSAGE} [skip ci]"
  echo -e "\e[1;96mgit pull --rebase\e[0m"
  git pull --rebase
  echo -e "\e[1;96mgit push origin master\e[0m"
  #ds push - can be ignored if there were no changes after pulling
  git push origin master
else
  #ds ignore push
  echo -e "\e[1;96mbenchmark results have not changed - ignoring commit and push\e[0m"
fi
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
