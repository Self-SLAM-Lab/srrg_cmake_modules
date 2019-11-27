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
LOCAL_DATASET_PATH="/datasets/" #ds TODO parametrize

#ds known datasets (public) in a map <name, google drive id> ADD YOUR DATASET_SEQUENCE HERE
#ds TODO move this list into a separate file
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
["icl_living_room_0"]="1HBEmz0qBxFUTrk1K4pJIUNPpJYhgMHYD"
["icl_living_room_1"]="1kojNwhrWbdK3nR08M2vIUv66wW-NZHo1"
["icl_living_room_2"]="1lJW4CcPiZmPOwJtMJR2kdfKc2sWtsJ_F"
["icl_living_room_3"]="17CaZbEGhBUMFwxTJSv71yl6VNtMF7i9k"
["icl_office_room_0"]="11_Ms0a9RVgjwEVQ88CzTzP_DOR7ZpbgR"
["icl_office_room_1"]="156ULtiSmisW42kccWE43kjr55qkj7gbt"
["icl_office_room_2"]="1Qnx4En3SnfaUCOfiiyu5DFpBywkoLdp7"
["icl_office_room_3"]="1ENF8aKAi9z92T8Res0vlY7O-icBLUU_F"
["tum_fr1_room"]="1qPavF3iHuoeG7P_cVUUQ_nyXKE0miR-z"
["tum_fr2_desk"]="1oE9VPUYcu5XLzFI15XnuyO-d6Ok_EttC"
["tum_fr2_large_with_loop"]="16T5ObpdfqTjVah7WE1aAtQiRLOwPOyMd"
["tum_fr3_long"]="16zdgsLWRiyLrDXokm9dp6w7I6ZE5Gqqv"
["euroc_mh_01"]="1g6_QudgZetukSTe6MwYxauaei_8n_lza"
["euroc_mh_02"]="1XzSHNZtEnt67D9Twb_kOwuA-cSlgB7LE"
["euroc_mh_03"]="1mG30GL0WvClVWpDxWkOtCwWvFgNcK3Bv"
["euroc_mh_04"]="1ylbX7EdKkOVRl7CURBbgLcyo3ou1rS1E"
)

#ds retrieve dataset (if available)
DATASET_SEQUENCE_NAME="${DATASET_NAME}_${SEQUENCE_NAME}"
DATASET_DRIVE_ID=${DATASET_SEQUENCES_AVAILABLE[$DATASET_SEQUENCE_NAME]}
echo "DATASET_DRIVE_ID: '${DATASET_DRIVE_ID}'"

#ds if dataset download ID could not be retrieved, escape with failure
#ds a file that is not available for download is also not available on disk
if [ -z "$DATASET_DRIVE_ID" ]; then
  echo "dataset sequence with name: '${DATASET_SEQUENCE_NAME}' is not registered"
  exit -1
fi

#ds create dataset folder
mkdir -p "$DATASET_SEQUENCE_NAME"

#ds check if the chosen sequence is provided locally
echo -e "\e[1;96mavailable local datasets in '$LOCAL_DATASET_PATH':\e[0m"
ls "$LOCAL_DATASET_PATH"

#ds loop over all dataset names and check if one matches the requested dataset name
LOCAL_DATASET_SEQUENCE_PATH=""
AVAILABLE_DATASETS=($(ls $LOCAL_DATASET_PATH))
for AVAILABLE_DATASET in "${AVAILABLE_DATASETS[@]}"
  do
    if [[ "$AVAILABLE_DATASET" == "$DATASET_NAME" ]]; then
      echo -e "\e[1;96mfound matching dataset: '$AVAILABLE_DATASET' containing sequences:\e[0m"
      ls "${LOCAL_DATASET_PATH}/${AVAILABLE_DATASET}"
      AVAILABLE_SEQUENCES=($(ls ${LOCAL_DATASET_PATH}/${AVAILABLE_DATASET}))
      for AVAILABLE_SEQUENCE in "${AVAILABLE_SEQUENCES[@]}"
        do
          if [[ "$AVAILABLE_SEQUENCE" == "$SEQUENCE_NAME" ]]; then
            echo -e "\e[1;96mfound matching sequence: '$AVAILABLE_SEQUENCE' containing files:\e[0m"
            LOCAL_DATASET_SEQUENCE_PATH="${LOCAL_DATASET_PATH}/${AVAILABLE_DATASET}/${AVAILABLE_SEQUENCE}"
            ls "$LOCAL_DATASET_SEQUENCE_PATH"
          fi
      done
    fi
done

#ds if we could not locate the dataset sequence on disk
if [ -z "$LOCAL_DATASET_SEQUENCE_PATH" ]; then
  echo -e "\e[1;96munable to locate matching dataset sequence - download required\e[0m"

  #ds download dataset into a temporary folder that corresponds to the drive ID
  source ${SRRG_SCRIPT_PATH}/drive_download_and_extract_file.sh "$DATASET_DRIVE_ID" "$DATASET_SEQUENCE_NAME"

  #ds move into the extracted folder (exported variable by download script)
  EXTRACTED_FOLDER=($(ls ${DATASET_SEQUENCE_NAME}))
  echo "EXTRACTED_FOLDER: '${EXTRACTED_FOLDER[0]}'"
  cd "${DATASET_SEQUENCE_NAME}/${EXTRACTED_FOLDER[0]}"
else
  echo -e "\e[1;96mfound dataset sequence '${LOCAL_DATASET_SEQUENCE_PATH}' - no download necessary!\e[0m"

  #ds establish symlinks in target folder
  echo -e "\e[1;96msetting up symlinks:\e[0m"
  cd "${DATASET_SEQUENCE_NAME}"
  ln -s "${LOCAL_DATASET_SEQUENCE_PATH}/binary/"
  ln -s "${LOCAL_DATASET_SEQUENCE_PATH}/messages.json"
  ln -s "${LOCAL_DATASET_SEQUENCE_PATH}/gt.txt"

  #ds specific symlinks
  if [[ $DATASET_NAME == "kitti" ]]; then
    ln -s "${LOCAL_DATASET_SEQUENCE_PATH}/times.txt"
    ln -s "${LOCAL_DATASET_SEQUENCE_PATH}/calib.txt"
  fi

  #ds list created links
  ls -al
fi

#ds run benchmark binary (absolute path must be provided)
$($BENCHMARK_BINARY_ABSOLUTE_PATH)

#ds run visualization tools (if applicable) TODO map as well reduce this boilerplate code
if [[ $DATASET_NAME == "kitti" ]]; then
  echo "running KITTI evaluation tools"
  ${RESULT_TOOL_ABSOLUTE_PATH} -gt "gt.txt" -odom "trajectory.txt" -seq "${SEQUENCE_NAME}.txt"
  cp "results/plot_path/${SEQUENCE_NAME}.png" "${RESULT_PATH}/kitti/${SEQUENCE_NAME}/"
  cp "results/plot_error/${SEQUENCE_NAME}_tl.png" "${RESULT_PATH}/kitti/${SEQUENCE_NAME}/"
  cp "results/plot_error/${SEQUENCE_NAME}_rl.png" "${RESULT_PATH}/kitti/${SEQUENCE_NAME}/"
fi
if [[ $DATASET_NAME == "icl" ]]; then
  echo "running ICL evaluation tools"
  ${RESULT_TOOL_ABSOLUTE_PATH} "gt.txt" "trajectory.txt" --plot "trajectory_error.png"
  cp "trajectory_error.png" "${RESULT_PATH}/icl/${SEQUENCE_NAME}/"
fi
if [[ $DATASET_NAME == "tum" ]]; then
  echo "running TUM evaluation tools"
  ${RESULT_TOOL_ABSOLUTE_PATH} "gt.txt" "trajectory.txt" --plot "trajectory_error.png"
  cp "trajectory_error.png" "${RESULT_PATH}/tum/${SEQUENCE_NAME}/"
fi
if [[ $DATASET_NAME == "euroc" ]]; then
  echo "running EuRoC evaluation tools"
  ${RESULT_TOOL_ABSOLUTE_PATH} "gt.txt" "trajectory.txt" --plot "trajectory_error.png"
  cp "trajectory_error.png" "${RESULT_PATH}/euroc/${SEQUENCE_NAME}/"
fi

#ds cleanup benchmark files
ls -al
cd "../.."
rm -rf "$DATASET_SEQUENCE_NAME"
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
