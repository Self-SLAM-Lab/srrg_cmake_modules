#!/bin/bash

#ds check input parameters
if [ "$#" -ne 2 ]; then
  echo "ERROR: call as $0 PROJECT_ROOT_PATH PROJECT_NAME";
  exit 0;
fi

#ds parameters
PROJECT_ROOT_PATH="$1"
PROJECT_NAME="$2"
echo "--------------------------------------------------------------------------------"
echo "bash version: ${BASH_VERSION}"

#ds package build artifacts for upload
mkdir -p "${PROJECT_ROOT_PATH}/artifacts"
tar czf ${PROJECT_ROOT_PATH}/artifacts/build.tar.gz "build/${PROJECT_NAME}/gtest/googlemock/gtest/libgtest.so"
tar czf ${PROJECT_ROOT_PATH}/artifacts/devel.tar.gz "devel"
ls -al "${PROJECT_ROOT_PATH}/artifacts/"
echo "--------------------------------------------------------------------------------"
