#!/bin/bash

#ds check input parameters
if [ "$#" -ne 3 ]; then
  echo "ERROR: call as $0 REPOSITORY_PATH WORKSPACE_PATH PROJECT_NAME";
  exit 0;
fi

#ds set parameters
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;96mbash version: ${BASH_VERSION}\e[0m"
REPOSITORY_PATH="$1"
WORKSPACE_PATH="$2"
PROJECT_NAME="$3"

#ds compose test path and check if existing
EXECUTABLES_PATH="${REPOSITORY_PATH}/${PROJECT_NAME}/benchmarks"
if [ -d "$EXECUTABLES_PATH" ]; then
  #ds parse test binaries from test path
  EXECUTABLES=($(ls ${EXECUTABLES_PATH}))
  echo -e "\e[1;96mfound test files in '${EXECUTABLES_PATH}' (unfiltered): \e[0m"
  echo "${EXECUTABLES[@]}"

  #ds call each binary (skipping all files that do not end in cpp nor start with test)
  for EXECUTABLE in "${EXECUTABLES[@]}"
  do
    #ds binary must start with test keyword and end in .cpp
    EXECUTABLE_PREFIX=${EXECUTABLE:0:4}
    EXECUTABLE_FILE_TYPE=${EXECUTABLE:${#EXECUTABLE}-4:4}
    if [ ${EXECUTABLE_PREFIX} == "benchmark" ] && [ ${EXECUTABLE_FILE_TYPE} == ".cpp" ]; then
      echo ""
      echo -e "\e[1;96m${WORKSPACE_PATH}/${PROJECT_NAME}/${EXECUTABLE:0:${#EXECUTABLE}-4}\e[0m"
  	  ${WORKSPACE_PATH}/${PROJECT_NAME}/${EXECUTABLE:0:${#EXECUTABLE}-4}
  	fi
  done
else 
  echo -e "\e[1;93mbenchmark directory: $EXECUTABLES_PATH is not existing - skipping benchmarks (confirm if running this stage is necessary!)\e[0m"
fi
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
