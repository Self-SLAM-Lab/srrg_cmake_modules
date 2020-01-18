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
function pull_repo() {
    cd "/root/workspace/src/"
    if $(git clone "git@gitlab.com:srrg-software/$1.git");then
        create_tree $1
        create_tree $1_ros
    fi
}

declare -A deps_tree;
layer=0
function create_tree() {
    echo $1
    cd "$(catkin_find_pkg $1)"
    pwd
    echo "getting deps"
    locale SRRG_DEPS="$(catkin list --this --deps | awk '/build_depend/,/run_depend/{print $2}' | xargs -0 echo | aw\
k '/srrg2/{print $0}' |  tac)"
    echo "${SRRG_DEPS[@]}"

    for dep in $SRRG_DEPS; do
        echo $dep
        deps_tree[$dep]=$layer;
        pull_repo "$dep"
    done
}
deps_tree[$PROJECT_NAME]=0
create_tree $PROJECT_NAME

for a in "${!deps_tree[@]}"; do
  echo $a ${deps_tree[$a]}
done

cd "$(catkin_find_pkg ${PROJECT_NAME})"

SRRG_DEPS="$(catkin list --this --rdeps | awk '/build_de\
pend/,/run_depend/{print $2}' | xargs -0 echo | awk '/sr\
rg2/{print $0}' |  tac)"
echo "${SRRG_DEPS[@]}"

for LIB in $SRRG_DEPS; do
    echo "\e[1;96mDownloading $LIB artifacts\e[0m";
    source ${SRRG_SCRIPT_PATH}/unpack_external_artifacts\
.sh "$LIB" "$BRANCH_NAME" "$JOB_NAME" "$TOKEN"
done
