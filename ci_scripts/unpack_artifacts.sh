#!/bin/bash

#ds check input parameters
if [ "$#" -ne 1 ]; then
  echo "ERROR: call as $0 PROJECT_ROOT_PATH";
  exit 0;
fi

#ds parameters
PROJECT_ROOT_PATH="$1"
echo "--------------------------------------------------------------------------------"
echo "bash version: ${BASH_VERSION}"

#ds restore build artifacts from previous corresponding stage of this project
pwd
tar xzf "${PROJECT_ROOT_PATH}/artifacts/build.tar.gz"
tar xzf "${PROJECT_ROOT_PATH}/artifacts/devel.tar.gz"
ls -al

#ds update library path environment variable
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/workspace/devel/lib/
export LD_LIBRARY_PATH
echo "--------------------------------------------------------------------------------"

