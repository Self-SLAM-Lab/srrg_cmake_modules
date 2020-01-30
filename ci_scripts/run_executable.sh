#!/bin/bash

#ds check input parameters
if [ "$#" -lt 2 ]; then
  echo "ERROR: call as $0 PROJECT_NAME TEST_NAME [WORKSPACE_PATH]"
  exit -1
fi

#ds set parameters
PROJECT_NAME="$1"
TEST_NAME="$2"
WORKSPACE_PATH="$3"
if [[ -z ${WORKSPACE_PATH} ]]; then
  WORKSPACE_PATH=${WS}
fi

echo ""
EXE="${WORKSPACE_PATH}/devel/${PROJECT_NAME}/lib/${PROJECT_NAME}/${TEST_BINARY:0:${#TEST_BINARY}-4}"
echo -e "\e[1;96m${EXE}\e[0m"
${EXE}
