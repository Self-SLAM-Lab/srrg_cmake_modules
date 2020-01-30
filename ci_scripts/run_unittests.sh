#!/bin/bash

#ds check input parameters
if [ "$#" -lt 2 ]; then
  echo "ERROR: call as $0 REPOSITORY_PATH PROJECT_NAME [WORKSPACE_PATH]"
  exit -1
fi

#ds set parameters
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;96mbash version: ${BASH_VERSION}\e[0m"
REPOSITORY_PATH="$1"
PROJECT_NAME="$2"
WORKSPACE_PATH="$3"
if [[ -z ${WORKSPACE_PATH} ]]; then
  WORKSPACE_PATH=${WS}
fi

if [[ -z ${SRRG_SCRIPT_PATH} ]]; then
  echo -e "\e[1;91mSRRG_SCRIPT_PATH not set\e[0m"
  exit -1
fi

#ds compose test path and check if existing - with fallback for non-nested repositories
TEST_BINARIES_PATH="${REPOSITORY_PATH}/${PROJECT_NAME}/tests"
if [ ! -d "$TEST_BINARIES_PATH" ]; then
  echo -e "\e[1;93mtest directory: $TEST_BINARIES_PATH is not existing - fallback to ${REPOSITORY_PATH}/tests\e[0m"
  TEST_BINARIES_PATH="${REPOSITORY_PATH}/tests"
fi

#ds check if binary path is valid now
if [ -d "$TEST_BINARIES_PATH" ]; then
  #ds parse test binaries from test path
  TEST_BINARIES=($(ls ${TEST_BINARIES_PATH}))
  echo -e "\e[1;96mfound test files in '${TEST_BINARIES_PATH}' (unfiltered): \e[0m"
  echo "${TEST_BINARIES[@]}"

  #ds call each binary (skipping all files that do not end in cpp nor start with test)
  for TEST_BINARY in "${TEST_BINARIES[@]}"
  do
    #ds binary must start with test keyword and end in .cpp
    TEST_BINARY_PREFIX=${TEST_BINARY:0:4}
    TEST_BINARY_FILE_TYPE=${TEST_BINARY:${#TEST_BINARY}-4:4}
    if [ ${TEST_BINARY_PREFIX} == "test" ] && [ ${TEST_BINARY_FILE_TYPE} == ".cpp" ]; then
      source ${SRRG_SCRIPT_PATH}/run_executable.sh ${PROJECT_NAME} ${TEST_BINARY:0:${#TEST_BINARY}-4} ${WORKSPACE_PATH}
      # echo ""
      # TEXT_EXE="${WORKSPACE_PATH}/devel/${PROJECT_NAME}/lib/${PROJECT_NAME}/${TEST_BINARY:0:${#TEST_BINARY}-4}"
      # echo -e "\e[1;96m${TEXT_EXE}\e[0m"
      # ${TEXT_EXE}
  	fi
  done
else
  echo -e "\e[1;93mtest directory: $TEST_BINARIES_PATH is not existing - skipping tests (confirm if running this stage is necessary!)\e[0m"
fi
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
