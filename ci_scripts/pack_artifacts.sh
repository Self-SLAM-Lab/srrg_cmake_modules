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
cd "/root/workspace/"
ls -al

#ds determine gtest library location in the build folder
GTEST_LIBRARY_PATH=$(find "build/${PROJECT_NAME}" -name "libgtest.so")
echo "GTEST_LIBRARY_PATH='$GTEST_LIBRARY_PATH'"

#ds package build artifacts for upload
mkdir -p "${PROJECT_ROOT_PATH}/artifacts"
if [ ! -z "$GTEST_LIBRARY_PATH" ]; then
  tar czf ${PROJECT_ROOT_PATH}/artifacts/build.tar.gz "$GTEST_LIBRARY_PATH"
else
  echo "no tests found for project: '${PROJECT_NAME}' - creating empty build archive"
  tar czf ${PROJECT_ROOT_PATH}/artifacts/build.tar.gz --files-from /dev/null
fi
tar czf ${PROJECT_ROOT_PATH}/artifacts/devel.tar.gz "devel"
ls -al "${PROJECT_ROOT_PATH}/artifacts/"
echo "--------------------------------------------------------------------------------"
