#!/bin/bash
#ds this script is intended to be sourced!

#ds check input parameters
if [ "$#" -ne 3 ]; then
  echo "ERROR: call as $0 URL TARGET_FOLDER TARGET_FILENAME"
  exit -1
fi
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;96mbash version: ${BASH_VERSION}\e[0m"
URL="$1"
TARGET_FOLDER="$2"
TARGET_FILENAME="$3"

#ds download and extract test dataset into current folder
cd "$TARGET_FOLDER"
wget --no-verbose "$URL" --output-document "$TARGET_FILENAME"
tar xzf "$TARGET_FILENAME"
rm "$TARGET_FILENAME"
ls -al
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
