#!/bin/bash
#ds this script is intended to be sourced!

#ds check input parameters
if [ "$#" -ne 2 ]; then
  echo "ERROR: call as $0 PROJECT_NAME COMMIT_MESSAGE"
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
PROJECT_NAME="$1"
COMMIT_MESSAGE="$2"

#ds update reference commit - currently locked in executor TODO change
cd "/root/workspace/srrg2_executor"
git pull --rebase #ds someone might push while we're benching
sed -i "s|${PROJECT_NAME}/commit/.*|${PROJECT_NAME}/commit/${CI_COMMIT_SHA}|g" "readme.md"
git config --global user.email "benchamin@srrg.com"
git config --global user.name "benchamin"
git add "results"

#ds if the content has changed (does not have to be the case)
if [[ $(git status) != *"nothing to commit, working tree clean"* ]]; then
  #ds push to remote without triggering it's ci
  git commit -am "${COMMIT_MESSAGE} [skip ci]"
  git push origin master
else
  #ds ignore push
  echo -e "\e[1;96mbenchmark results have not changed - ignoring commit and push\e[0m"
fi
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
