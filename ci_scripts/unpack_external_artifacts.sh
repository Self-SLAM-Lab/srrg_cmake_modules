#!/bin/bash
#ds this script is intended to be sourced!

#ds gitlab artifact resources:
#https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html
#https://docs.gitlab.com/ee/api/jobs.html
#https://networkinferno.net/token-access-to-files-from-private-repo-in-gitlab

#ds check input parameters
if [ "$#" -ne 4 ]; then
  echo "ERROR: call as $0 PROJECT_NAME BRANCH_NAME JOB_NAME ACCESS_TOKEN";
  exit 0;
fi

#ds start
echo -en "\e[1;96m--------------------------------------------------------------------------------\e[0m"
echo -en "\e[1;96mbash version: ${BASH_VERSION}\e[0m"
PROJECT_NAME="$1"
BRANCH_NAME="$2"
JOB_NAME="$3"
TOKEN="$4"

#ds clone project to catkin source folder (requires SSH key to be properly set up)
cd "/root/workspace/src/"
git clone --single-branch --branch "$BRANCH_NAME" "git@gitlab.com:srrg-software/${PROJECT_NAME}.git"

#ds check if the commit hash of the available artifacts corresponds to the last push
#ds if not, we won't be fetching the artifacts and instead perform a rebuild (otherwise we risk build inconsistencies)
echo -en "\e[1;96mchecking status of latest commit for: ${PROJECT_NAME}/${BRANCH_NAME}\e[0m"
LATEST_COMMIT_URL="https://gitlab.com/api/v4/projects/srrg-software%2F${PROJECT_NAME}/repository/commits/${BRANCH_NAME}"
COMMIT_STATUS=$(curl --header "PRIVATE-TOKEN: $TOKEN" "$LATEST_COMMIT_URL")
if [[ $COMMIT_STATUS != *"\"status\":\"success\""* ]]; then
  echo -e "\e[1;93mcommit not successful - skipping artifact import\e[0m"
  return #ds statement has no effect if script is not sourced
  exit #ds escape in any case (skipped when sourcing, otherwise fatal)
fi
echo -en "\e[1;96mstatus:success - importing artifacts\e[0m"

#ds assemble project artifact URL
ARTIFACT_DOWNLOAD_URL="https://gitlab.com/api/v4/projects/srrg-software%2F${PROJECT_NAME}/jobs/artifacts/${BRANCH_NAME}/download?job=${JOB_NAME}"

#ds download artifacts into the catkin workspace folder using the gitlab api
cd "/root/workspace/"
wget --no-verbose --header "PRIVATE-TOKEN: $TOKEN" "$ARTIFACT_DOWNLOAD_URL" --output-document "artifacts.zip"

#ds unzip artifacts into corresponding folders and remove file containers
unzip artifacts.zip
rm artifacts.zip
tar xzf artifacts/build.tar.gz
tar xzf artifacts/devel.tar.gz
rm -rf artifacts
echo -en "\e[1;96m--------------------------------------------------------------------------------\e[0m"

#ds blacklist the loaded project in catkin to disable rebuilding in any circumstances
#ds we have to extend the previous blacklist since the command is not appending
if [ -z "$CATKIN_BLACKLIST" ]; then
  CATKIN_BLACKLIST="$PROJECT_NAME ${PROJECT_NAME}_ros"
else
  CATKIN_BLACKLIST="${CATKIN_BLACKLIST} $PROJECT_NAME ${PROJECT_NAME}_ros"
fi
catkin config --blacklist $CATKIN_BLACKLIST
export CATKIN_BLACKLIST
