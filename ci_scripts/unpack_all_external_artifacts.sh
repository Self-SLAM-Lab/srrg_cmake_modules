#!/bin/bash
#ds this script is intended to be sourced!

#ds check input parameters
if [ "$#" -ne 4 ]; then
  echo "ERROR: call as $0 PROJECT_NAME BRANCH_NAME JOB_NAME ACCESS_TOKEN"
  exit -1
fi

#ds start
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;96mbash version: ${BASH_VERSION}\e[0m"
PROJECT_NAME="$1"
BRANCH_NAME="$2"
JOB_NAME="$3"
TOKEN="$4"

cd /root/workspace/
cd "$(catkin_find_pkg ${CI_PROJECT_NAME})" && pwd

mkdir -p devel
mkdir -p build

SRRG_DEPS="$(catkin list --this --deps | awk '/build_depend/,/run_depend/{print $2}' | xargs -0 echo | awk '/srrg2/{print $0}' |  tac)"
SRRG_RDEPS="$(catkin list --this --rdeps | awk '/build_depend/,/run_depend/{print $2}' | xargs -0 echo | awk '/srrg2/{print $0}' |  tac)"
echo "${SRRG_DEPS[@]}"
echo "${SRRG_RDEPS[@]}"

SRRG_LIBS=($(for v in "${SRRG_LIBS[@]}"; do echo "$v";done|uniq| xargs))
echo "${SRRG_LIBS[@]}"

for LIB in $SRRG_LIBS; do
  echo "\e[1;96mDownloading $LIB artifacts\e[0m";
  source ${SRRG_SCRIPT_PATH}/unpack_external_artifacts.sh "$LIB" "$BRANCH_NAME" "$JOB_NAME" "$TOKEN"
done
