#!/bin/bash

if [[ $# -ne 5 ]]; then
  echo "usage: $0 <dataset> <config> <gt_topic> <dl_source> <plot_mode {xy,xz}>"
  exit -1;
  return;
fi

DATASET="$1"
CONFIG="$2"
GT_TOPIC="$3"
DL_SOURCE="$4"
PLOT_MODE="$5"
GT_FILE="gt.txt"
TRAJ_FORMAT="tum"

source ~/workspaces/srrg2/devel/setup.bash

echo "dataset: ${DATASET} config: ${CONFIG} gt_topic: ${GT_TOPIC}"

roscore&
sleep 2

if [ ${DATASET: -4} == ".bag" ]; then
  rosrun srrg2_core_ros extract_gt_from_ros -f ${TRAJ_FORMAT} -i "${DATASET}" -t "${GT_TOPIC}" -o "${GT_FILE}"
else
  rosrun srrg2_core extract_gt_from_srrg -f ${TRAJ_FORMAT} -i "${DATASET}" -t "${GT_TOPIC}" -o "${GT_FILE}"
fi

rosrun srrg2_slam_interfaces app_benchmark -dlc ${DL_SOURCE} -c ${CONFIG} -d "${DATASET}" -f ${TRAJ_FORMAT}

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

./pass_bench.py --threshold 0.1 ${RESULTS_APE}.json
./pass_bench.py --threshold 0.01 ${RESULTS_RPE}.json
