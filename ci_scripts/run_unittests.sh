#!/bin/bash

#ds check input parameters
if [ "$#" -ne 3 ]; then
  echo "ERROR: call as $0 REPOSITORY_PATH WORKSPACE_PATH PROJECT_NAME";
  exit 0;
fi

#ds set parameters
echo "--------------------------------------------------------------------------------"
echo "bash version: ${BASH_VERSION}"
REPOSITORY_PATH="$1"
WORKSPACE_PATH="$2"
PROJECT_NAME="$3"

#ds compose test path and check if existing
TEST_BINARIES_PATH="${REPOSITORY_PATH}/${PROJECT_NAME}/tests"
if [ -d "$TEST_BINARIES_PATH" ]; then
  #ds parse test binaries from test path
  TEST_BINARIES=($(ls ${TEST_BINARIES_PATH}))
  echo "found test files in '${TEST_BINARIES_PATH}': "
  echo "${TEST_BINARIES[@]} (unfiltered)"
  
  #ds call each binary (skipping all files that do not end in cpp nor start with test)
  for TEST_BINARY in "${TEST_BINARIES[@]}"
  do
    #ds binary must start with test keyword and end in .cpp
    TEST_BINARY_PREFIX=${TEST_BINARY:0:4}
    TEST_BINARY_FILE_TYPE=${TEST_BINARY:${#TEST_BINARY}-4:4}
    if [ ${TEST_BINARY_PREFIX} == "test" ] && [ ${TEST_BINARY_FILE_TYPE} == ".cpp" ]; then
  	  ${WORKSPACE_PATH}/${PROJECT_NAME}/${TEST_BINARY:0:${#TEST_BINARY}-4}
  	fi
  done
else 
  echo "test directory: $TEST_BINARIES_PATH is not existing - skipping tests"
fi
echo "--------------------------------------------------------------------------------"
