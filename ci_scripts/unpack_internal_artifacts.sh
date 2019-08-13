#!/bin/bash

#ds gitlab artifact resources:
#https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html
#https://docs.gitlab.com/ee/api/jobs.html
#https://networkinferno.net/token-access-to-files-from-private-repo-in-gitlab

#ds check input parameters
if [ "$#" -ne 1 ]; then
  echo "ERROR: call as $0 PROJECT_ROOT_PATH";
  exit 0;
fi

#ds start
echo -en "\e[1;96m--------------------------------------------------------------------------------\e[0m"
echo -en "\e[1;96mbash version: ${BASH_VERSION}\e[0m"
cd "/root/workspace/"
PROJECT_ROOT_PATH="$1"

#ds restore build artifacts from previous corresponding stage of this project
tar xzf "${PROJECT_ROOT_PATH}/artifacts/build.tar.gz"
tar xzf "${PROJECT_ROOT_PATH}/artifacts/devel.tar.gz"
ls -al
echo -en "\e[1;96m--------------------------------------------------------------------------------\e[0m"
