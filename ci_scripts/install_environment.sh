#!/bin/bash

#ds check input parameters
if [ "$#" -ne 2 ]; then
  echo "ERROR: call as $0 PROJECT_DIRECTORY PROJECT_NAME"
  exit -1
fi

#ds set parameters
PROJECT_DIRECTORY="$1"
PROJECT_NAME="$2"
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;96mbash version: ${BASH_VERSION}\e[0m"

#ds check if required external variables are not set
if [ -z "$SRRG_SCRIPT_PATH" ]; then
  echo "environment variable SRRG_SCRIPT_PATH not set"
  exit -1
fi

#srrg avoid ros updating
apt-mark hold ros-* > /dev/null

#ds generic build dependencies (valid for ubuntu 16.04 and 18.04)
apt update -qq
#mc disabling this temporally
# apt dist-upgrade -y
apt install -y -qq sudo ssh openssh-client git \
    python-catkin-tools build-essential libeigen3-dev \
    libsuitesparse-dev libgtest-dev

#ds set up catkin workspace
source ${SRRG_SCRIPT_PATH}/install_catkin_workspace.sh ${PROJECT_DIRECTORY} ${PROJECT_NAME}

#ds set up ssh with key that is required for private repository cloning TODO move
source ${SRRG_SCRIPT_PATH}/install_ssh.sh
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
