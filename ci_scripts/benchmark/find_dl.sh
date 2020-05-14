#!/bin/bash

cd ${WS}/src/
git clone git@gitlab.com:srrg-software/srrg2_executor.git
cd ${WS}
catkin build srrg2_executor --no-deps
${WS}/devel/srrg2_executor/lib/srrg2_executor/auto_dl_finder
export DLC=${WS}/dl.conf
