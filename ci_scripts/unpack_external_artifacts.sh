#!/bin/bash

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
echo "--------------------------------------------------------------------------------"
echo "bash version: ${BASH_VERSION}"
pwd
PROJECT_NAME="$1"
BRANCH_NAME="$2"
JOB_NAME="$3"
TOKEN="$4"

#ds clone project to catkin source folder (requires SSH key to be properly set up)
cd "/root/workspace/src/"
git clone "git@gitlab.com:srrg-software/${PROJECT_NAME}.git"

#ds assemble project artifact URL
ARTIFACT_DOWNLOAD_URL="https://gitlab.com/api/v4/projects/srrg-software%2F${PROJECT_NAME}/jobs/artifacts/${BRANCH_NAME}/download?job=${JOB_NAME}"

#ds download artifacts into the catkin workspace folder using the gitlab api
cd "/root/workspace/"
wget --header "PRIVATE-TOKEN: $TOKEN" "$ARTIFACT_DOWNLOAD_URL" --output-document "artifacts.zip"

#ds unzip artifacts into corresponding folders and remove file containers
unzip artifacts.zip
rm artifacts.zip
tar xzf artifacts/build.tar.gz
tar xzf artifacts/devel.tar.gz
rm -rf artifacts
echo "--------------------------------------------------------------------------------"

#ds blacklist the loaded project in catkin to disable rebuilding in any circumstances
#ds we have to extend the previous blacklist since the command is not appending
if [ -z "$CATKIN_BLACKLIST" ]; then
  CATKIN_BLACKLIST="$PROJECT_NAME"
else
  CATKIN_BLACKLIST="${CATKIN_BLACKLIST} $PROJECT_NAME"
fi
catkin config --blacklist $CATKIN_BLACKLIST
export CATKIN_BLACKLIST
