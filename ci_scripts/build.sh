#!/bin/bash

#ds check input parameters
if [ "$#" -ne 3 ]; then
  echo "ERROR: call as $0 BUILD_DIRECTORY PROJECT_NAME CMAKE_BUILD_TYPE"
  exit -1
fi

#ds parameters
BUILD_DIRECTORY="$1"
PROJECT_NAME="$2"
CMAKE_BUILD_TYPE="$3"
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;96mrunning build.sh|bash version: '${BASH_VERSION}'\e[0m"
cd "${BUILD_DIRECTORY}"

#ds set complete cmake build flags
CMAKE_BUILD_FLAGS="-j4 --no-status --summary -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"

#ds test build flags
CMAKE_BUILD_TESTS_FLAGS="-j4 --catkin-make-args tests"

#ds choose build system (currently only catkin)
BUILD_COMMAND="catkin build"

#ds build stack
echo "${BUILD_COMMAND} ${PROJECT_NAME} ${CMAKE_BUILD_FLAGS}"
${BUILD_COMMAND} ${PROJECT_NAME} ${CMAKE_BUILD_FLAGS}

#ds build tests
echo "${BUILD_COMMAND} ${PROJECT_NAME} ${CMAKE_BUILD_FLAGS} ${CMAKE_BUILD_TESTS_FLAGS}"
${BUILD_COMMAND} ${PROJECT_NAME} ${CMAKE_BUILD_FLAGS} ${CMAKE_BUILD_TESTS_FLAGS}

echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
