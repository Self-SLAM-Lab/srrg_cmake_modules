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

#srrg avoid ros updating
apt-mark hold ros-*

#ds generic build dependencies (valid for ubuntu 16.04 and 18.04)
apt update 
apt upgrade -y
apt install -y sudo ssh openssh-client git \
    python-catkin-tools build-essential libeigen3-dev \
    libsuitesparse-dev libgtest-dev

#ds create catkin workspace and link this repository for build with catkin
mkdir -p /root/workspace/src
ln -s "$PROJECT_DIRECTORY" "/root/workspace/src/${PROJECT_NAME}"

#ds setup test data path (routed through source directory for local compatibility)
mkdir -p /root/source/srrg && mkdir -p /root/source/srrg2
ln -s "$PROJECT_DIRECTORY" "/root/source/srrg2/${PROJECT_NAME}"
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
