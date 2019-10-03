#!/bin/bash
#ds this script is intended to be sourced!
#ds it performs dataset download and executes the specified benchmark
#ds it is an disk space friendly alternative to the run_benchmarks.sh version since downloaded datasets are removed after processing

#ds check input parameters
if [ "$#" -ne 5 ]; then
  echo "ERROR: call as $0 BENCHMARK_BINARY_ABSOLUTE_PATH DATASET_NAME SEQUENCE_NAME RESULT_TOOL_ABSOLUTE_PATH RESULT_PATH"
  exit -1
fi

#ds check if required external variables are not set
if [ -z "$SRRG_SCRIPT_PATH" ]; then
  echo "environment variable SRRG_SCRIPT_PATH not set"
  exit -1
fi

#ds set parameters
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;96mbash version: '${BASH_VERSION}'\e[0m"
BENCHMARK_BINARY_ABSOLUTE_PATH="$1"
DATASET_NAME="$2"
SEQUENCE_NAME="$3"
RESULT_TOOL_ABSOLUTE_PATH="$4"
RESULT_PATH="$5"

#ds known datasets (public) in a map <name, google drive id> ADD YOUR DATASET_SEQUENCE HERE
declare -A DATASET_SEQUENCES_AVAILABLE=(
["kitti_00"]="1u_d4qp5p7eyWQk4zZhI8x13uEB_Ut7pC"
["kitti_01"]="1oPoczbCpXJyB_1lz7AsNqHu4NiWcqpkM"
["kitti_02"]="1LXwdo0mGaSKBQ_Pi_1fOK-VMQx0ciAwq"
["kitti_03"]="1jtZpf_u5nb_0sa3etXsLV79J5ywG14pc"
["kitti_04"]="1YZFLycQp4ilSaLTrovLxSY80UK2Q2wF1"
["kitti_05"]="1i5xCzLTNa0uW3RvroLQpkoLA7qPD103m"
["kitti_06"]="1F6UR8ycHKGosg9YcriZvBiX2nUNvV2EL"
["kitti_07"]="1gMRUpX4IOR70lB87_gzevVpq-VAsu26G"
["kitti_08"]="15lg3x3KNuPYMxowE38hWBZk8ch5SdfOI"
["kitti_09"]="1DtGrqxS50stlUMpeOP-gUHdWFuPp4gZg"
["kitti_10"]="1-fQCLyr2IT7H-l_EXfQtJ8H9nRhr1lZD"
)

#ds retrieve dataset (if available)
DATASET_SEQUENCE_NAME="${DATASET_NAME}_${SEQUENCE_NAME}"
DATASET_DRIVE_ID=${DATASET_SEQUENCES_AVAILABLE[$DATASET_SEQUENCE_NAME]}
echo "DATASET_DRIVE_ID: '${DATASET_DRIVE_ID}'"

#ds if dataset download ID could not be retrieved, escape with failure
if [ -z "$DATASET_DRIVE_ID" ]; then
  echo "dataset sequence with name: '${DATASET_SEQUENCE_NAME}' is not registered"
  exit -1
fi

#ds download dataset into a temporary folder that corresponds to the drive ID
source ${SRRG_SCRIPT_PATH}/drive_download_and_extract_file.sh "$DATASET_DRIVE_ID" "$DATASET_DRIVE_ID"

#ds move into the extracted folder (exported variable by download script)
EXTRACTED_FOLDER=($(ls ${DATASET_DRIVE_ID}))
echo "EXTRACTED_FOLDER: '${EXTRACTED_FOLDER[0]}'"
cd "${DATASET_DRIVE_ID}/${EXTRACTED_FOLDER[0]}"

#ds run benchmark binary (absolute path must be provided)
$($BENCHMARK_BINARY_ABSOLUTE_PATH)

#ds run visualization tools (if applicable) TODO map as well to support other result tools
if [[ $DATASET_NAME == *"kitti"* ]]; then
  ${RESULT_TOOL_ABSOLUTE_PATH} -gt "gt.txt" -odom "trajectory.txt" -seq "${SEQUENCE_NAME}.txt"
  cp "results/plot_path/${SEQUENCE_NAME}.png" "${RESULT_PATH}/kitti/${SEQUENCE_NAME}/"
  cp "results/plot_error/${SEQUENCE_NAME}_tl.png" "${RESULT_PATH}/kitti/${SEQUENCE_NAME}/"
  cp "results/plot_error/${SEQUENCE_NAME}_rl.png" "${RESULT_PATH}/kitti/${SEQUENCE_NAME}/"
fi

#ds cleanup benchmark files
ls -al
cd "../.."
rm -rf "$DATASET_DRIVE_ID"
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
