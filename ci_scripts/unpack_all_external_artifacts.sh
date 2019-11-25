#!/bin/bash
#ds this script is intended to be sourced!

cd "/root/workspace/src/$PROJECT_NAME"

SRRG_LIBS=`catkin list --this --rdeps | awk '/build_depend/,/run_depend/{print $2}' | xargs -0 echo | awk '/srrg2/{print $0}' |  tac`

for LIB in $SRRG_LIBS;
  do source ${SRRG_SCRIPT_PATH}/unpack_external_artifacts.sh "$LIB" "$CI_BUILD_REF_NAME" "$CI_JOB_NAME" "$ARTIFACT_PRIVATE_TOKEN";
done
