#!/bin/bash

#ds gitlab artifact resources:
#https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html
#https://docs.gitlab.com/ee/api/jobs.html
#https://networkinferno.net/token-access-to-files-from-private-repo-in-gitlab

#ds check input parameters
if [ "$#" -ne 1 ] && [ "$#" -ne 4 ]; then
  echo "ERROR: call as $0 PROJECT_ROOT_PATH | PROJECT_NAME BRANCH_NAME JOB_NAME CI_TOKEN";
  exit 0;
fi
echo "--------------------------------------------------------------------------------"
echo "bash version: ${BASH_VERSION}"
pwd

#ds for one parameter we have in-project unpacking (download handled by gitlab)
if [ "$#" -eq 1 ]; then
PROJECT_ROOT_PATH="$1"

#ds restore build artifacts from previous corresponding stage of this project
tar xzf "${PROJECT_ROOT_PATH}/artifacts/build.tar.gz"
tar xzf "${PROJECT_ROOT_PATH}/artifacts/devel.tar.gz"
ls -al

else
PROJECT_NAME="$1"
BRANCH_NAME="$2"
JOB_NAME="$3"
TOKEN="$4"

#ds assemble project artifact URL
ARTIFACT_DOWNLOAD_URL="https://gitlab.com/api/v4/projects/srrg-software%2F${PROJECT_NAME}/jobs/artifacts/${BRANCH_NAME}/download?job=${JOB_NAME}"

#ds download artifacts into current folder using the gitlab api
wget --header "PRIVATE-TOKEN: $TOKEN" "$ARTIFACT_DOWNLOAD_URL" --output-document "artifacts.zip"

#ds unzip artifacts into corresponding folders and remove file containers
unzip artifacts.zip
rm artifacts.zip
tar xzf artifacts/build.tar.gz
tar xzf artifacts/devel.tar.gz
rm -rf artifacts

#ds blacklist the loaded project in catkin to disable rebuilding in any circumstances
catkin config --blacklist "$PROJECT_NAME"

fi

#ds update library path environment variable to include unpacked artifacts
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/workspace/devel/lib/
export LD_LIBRARY_PATH
echo "--------------------------------------------------------------------------------"
