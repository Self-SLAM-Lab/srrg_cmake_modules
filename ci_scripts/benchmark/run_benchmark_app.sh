#!/bin/bash

if [[ $# -ne 5 ]]; then
  echo "usage: $0 <dataset> <config> <gt_topic> <dl_source> <plot_mode {xy,xz,xyz}>"
  exit -1;
  return;
fi

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
RESET=$(tput sgr0)
BOLD=$(tput bold)

DATASET_NAME="$1"
CONFIG_NAME="$2"
GT_TOPIC="$3"
DL_SOURCE="$4"
PLOT_MODE="$5"
GT_FILE="gt.txt"
TRAJ_FORMAT="tum"

#find config in workspace
CONFIG="$(find $CI_PROJECT_DIR -type f -name ${CONFIG_NAME})"
if [[ ! -f ${CONFIG}  ]]; then
  echo "Config "$CYAN $CONFIG_NAME" $RED$BOLD NOT FOUND $RESET in "$YELLOW $(pwd)
  echo $RESET
  return;
  exit -1;
fi
CONFIG=$(realpath "${CONFIG}")

#find dataset in standard dataset directory
if [[ -z "${DATASET_PATH}" ]]; then
  echo "$YELLOW DATASET_PATH $RESET variable $RED$BOLD NOT SET $RESET "
  echo "Please set it before calling this script"
  echo $RESET
  return;
  exit -1;
fi
DATASET="$(find $DATASET_PATH -type f -name ${DATASET_NAME})"
if [[ ! -f ${DATASET}  ]]; then
  echo "Dataset "$CYAN $DATASET_NAME" $RED$BOLD NOT FOUND $RESET in "$YELLOW $(pwd)
  echo $RESET
  return;
  exit -1;
fi
DATASET=$(realpath "${DATASET}")

echo "dataset: $CYAN${DATASET}$RESET"
echo "config: $CYAN${CONFIG}$RESET"
echo "gt_topic: $CYAN${GT_TOPIC}$RESET"

roscore&
ROSCORE_PID=$!
sleep 2

DEVEL_PATH="${WS}/srrg2/devel/"
if [ ${DATASET: -4} == ".bag" ]; then
  EXEC_PATH="${DEVEL_PATH}srrg2_core_ros/lib/srrg2_core_ros/"
  ${EXEC_PATH}extract_gt_from_ros -f ${TRAJ_FORMAT} -i "${DATASET}" -t "${GT_TOPIC}" -o "${GT_FILE}"
else
  EXEC_PATH="${DEVEL_PATH}srrg2_core/lib/srrg2_core/"
  ${EXEC_PATH}extract_gt_from_srrg -f ${TRAJ_FORMAT} -i "${DATASET}" -t "${GT_TOPIC}" -o "${GT_FILE}"
fi
EXEC_PATH="${DEVEL_PATH}srrg2_slam_interfaces/lib/srrg2_slam_interfaces/"
${EXEC_PATH}app_benchmark -dlc ${DL_SOURCE} -c ${CONFIG} -d "${DATASET}" -f ${TRAJ_FORMAT}

kill -9 $ROSCORE_PID

if [[ ! $(pip3 list --format=columns | grep evo)  ]]; then
  echo "evo not installed"
  echo "run: pip3 install evo --upgrade --no-binary evo"
  exit -1
  return;
fi

RESULTS_APE="results_ape"
PLOT_APE="plot_ape"
evo_ape ${TRAJ_FORMAT} ${GT_FILE} out_${TRAJ_FORMAT}.txt -va --plot_mode ${PLOT_MODE} --save_results ${RESULTS_APE}.zip --no_warnings --save_plot ${PLOT_APE}.pdf

unzip -p ${RESULTS_APE}.zip stats.json > ${RESULTS_APE}.json
pdftoppm ${PLOT_APE}.pdf ${PLOT_APE} -png -f 2 -singlefile

rm ${RESULTS_APE}.zip ${PLOT_APE}.pdf

RESULTS_RPE="results_rpe"
PLOT_RPE="plot_rpe"
evo_rpe ${TRAJ_FORMAT} ${GT_FILE} out_${TRAJ_FORMAT}.txt -va --plot_mode ${PLOT_MODE} --save_results ${RESULTS_RPE}.zip --no_warnings --save_plot ${PLOT_RPE}.pdf

unzip -p ${RESULTS_RPE}.zip stats.json > ${RESULTS_RPE}.json
pdftoppm ${PLOT_RPE}.pdf ${PLOT_RPE} -png -f 2 -singlefile

rm ${RESULTS_RPE}.zip ${PLOT_RPE}.pdf

export RESULTS_APE=$(realpath ${RESULTS_APE}.json)
export RESULTS_RPE=$(realpath ${RESULTS_RPE}.json)
