#!/bin/bash
echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;96mbash version: ${BASH_VERSION}\e[0m"

#ds check if required external variables are not set
if [ -z "$SSH_PRIVATE_KEY_FULL" ]; then
  echo "environment variable SSH_PRIVATE_KEY_FULL not set"
  exit -1
fi

#ds set up ssh with key that is required for private repository cloning
eval $(ssh-agent -s)
echo "$SSH_PRIVATE_KEY_FULL" | tr -d '\r' | ssh-add - > /dev/null
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
chmod 644 ~/.ssh/known_hosts

echo -e "\e[1;96m--------------------------------------------------------------------------------\e[0m"
