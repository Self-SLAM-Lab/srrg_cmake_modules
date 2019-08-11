#!/bin/bash

#ds check input parameters
if [ "$#" -ne 2 ]; then
  echo "ERROR: call as $0 PROJECT_DIRECTORY PROJECT_NAME";
  exit 0;
fi

#ds set parameters
PROJECT_DIRECTORY="$1"
PROJECT_NAME="$2"
echo "--------------------------------------------------------------------------------"
echo "bash version: $BASH_VERSION"

#ds generic build dependencies (valid for ubuntu 16.04 and 18.04)
apt install python-catkin-tools -y
apt install build-essential -y
apt install libeigen3-dev -y
apt install libsuitesparse-dev -y
apt install libgtest-dev -y

#ds create catkin workspace and link this repository for build with catkin
mkdir -p /root/workspace/src
ln -s "$PROJECT_DIRECTORY" "/root/workspace/src/${PROJECT_NAME}"

#ds setup test data path (routed through source directory for local compatibility)
mkdir -p /root/source/srrg && mkdir -p /root/source/srrg2
ln -s "$PROJECT_DIRECTORY" "/root/source/srrg2/${PROJECT_NAME}"
echo "--------------------------------------------------------------------------------"
