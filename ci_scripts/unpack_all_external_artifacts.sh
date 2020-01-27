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
function clone_repo() {
    cd "/root/workspace/src/"
    if [[ ! -d $1 && $(git clone -q git@gitlab.com:srrg-software/$1.git) ]];then
        create_tree $1
        create_tree $1_ros
    fi
}

function create_tree() {
    echo $1
    cd "$(catkin_find_pkg $1)"
    #echo "getting deps"
    SRRG_DEPS="$(catkin list --this --deps | awk '/build_depend/,/run_depend/{print $2}' | xargs -0 echo | awk '/srrg2/{print $0}' |  tac)"
    #echo "${SRRG_DEPS[@]}"

    for dep in $SRRG_DEPS; do
        echo $dep
        clone_repo "$dep"
    done
}
create_tree $PROJECT_NAME

cd "$(catkin_find_pkg ${PROJECT_NAME})"

SRRG_RDEPS="$(catkin list --this --rdeps | awk '/build_depend/,/run_depend/{print $2}' | xargs -0 echo | awk '/srrg2/{print $0}' |  tac)"
echo "${SRRG_RDEPS[@]}"

for LIB in $SRRG_RDEPS; do
    echo "\e[1;96mDownloading $LIB artifacts\e[0m";
    source ${SRRG_SCRIPT_PATH}/unpack_external_artifacts.sh "$LIB" "$BRANCH_NAME" "$JOB_NAME" "$TOKEN"
done
