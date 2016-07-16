#!/usr/bin/env bash

#####
# STILL WORK IN PROGRESS
#####

echo "STILL WORK IN PROGRESS"
exit 1;

###
# #%L
# GarethHealy :: JBoss Fuse Setup :: Scaffolding Scripts
# %%
# Copyright (C) 2013 - 2015 Gareth Healy
# %%
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# #L%
###
set +x

## How to run:
## cd /opt/rh/scripts
##      && ./post-deploy-import-profiles.sh -e local

# Configure logging to print line numbers
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Set colours
GREEN="\e[32m"
RED="\e[41m\e[37m\e[1m"
YELLOW="\e[33m"
WHITE="\e[0m"

read -n1 -r -p "Press the any key..."

ARGS_COUNTER=0
while getopts ":e:x:" opt; do
  ARGS_COUNTER=$[$ARGS_COUNTER +1]

  case $opt in
    e) export DEPLOYMENT_ENVIRONMENT=$OPTARG
    ;;
    x) export DEBUG_MODE=$OPTARG
    ;;
    \?)
    echo -e $RED"Illegal parameters: -$OPTARG"$WHITE
    echo -e $RED"Usage: ./post-deploy-import-profiles.sh -e (environment) -x (debug - optional)"$WHITE
    echo -e $RED"Example: ./post-deploy-import-profiles.sh -e local -x true"$WHITE
    exit 1
    ;;
  esac
done

if [[ $ARGS_COUNTER -gt 2 ]]; then
    echo -e $RED"Illegal number of parameters: $ARGS_COUNTER"$WHITE
    echo -e $RED"Usage: ./post-deploy-import-profiles.sh -e (environment) -x (debug - optional)"$WHITE
    echo -e $RED"Example: ./post-deploy-import-profiles.sh -e local -x true"$WHITE
    exit 1
fi

SUPPORTED_ENVS_ARRAY=($(ls -lrt $(pwd)/envs | grep -v grep | awk '{ print $9; }'))
if [[ " ${SUPPORTED_ENVS_ARRAY[@]} " =~ " ${DEPLOYMENT_ENVIRONMENT} " ]]; then
    echo -e $GREEN"Environment: $DEPLOYMENT_ENVIRONMENT"$WHITE
else
    echo -e $RED"Environment \"$DEPLOYMENT_ENVIRONMENT\" not supported. Expected: ${SUPPORTED_ENVS_ARRAY[@]}"$WHITE
    exit 1
fi

if [[ "$DEBUG_MODE" == "true" ]]; then
    echo -e $GREEN"Debug mode"$WHITE
    set -x
fi

echo ""

# Set the environment variables for the selected environment
. ./envs/$DEPLOYMENT_ENVIRONMENT/environment.sh
. ./lib/helper_functions.sh

karaf_commands

if [[ ! -d $HOST_RH_HOME ]]; then
    echo -e $RED"$HOST_RH_HOME does not exist!"$WHITE
    exit 1
fi

echo -e $RED"Continuing with this process will change your enviorment!"$WHITE
read -n1 -r -p "If you continue, your current enviroment will be changed!"

#karaf_client fabric:profile-import mvn:com.garethahealy.jboss-fuse-examples/garethahealy-gateway-http/1.0.0-SNAPSHOT/zip/profile
#karaf_client fabric:profile-import mvn:com.garethahealy.jboss-fuse-examples/garethahealy-gateway-mq/1.0.0-SNAPSHOT/zip/profile
karaf_client fabric:profile-import mvn:com.garethahealy.jboss-fuse-examples/esb-uk-profile/1.0.0-SNAPSHOT/zip/profile
karaf_client fabric:profile-import mvn:com.garethahealy.jboss-fuse-examples/amq-uk-profile/1.0.0-SNAPSHOT/zip/profile

if [[ $DOWNLOAD_ALL_FOR_ROOT == "true" ]]; then
    echo -e $YELLOW"Downloading artifacts for profile garethahealy-gateway-http / garethahealy-gateway-mq / garethahealy-esb / garethahealy-amq to $HOME/.m2/repository/ for root"$WHITE
    karaf_client fabric:profile-download-artifacts --threads 4 --verbose --profile garethahealy-gateway-http $HOME/.m2/repository/
    karaf_client fabric:profile-download-artifacts --threads 4 --verbose --profile garethahealy-gateway-mq $HOME/.m2/repository/
    karaf_client fabric:profile-download-artifacts --threads 4 --verbose --profile com-garethahealy-esb-uk $HOME/.m2/repository/
    karaf_client fabric:profile-download-artifacts --threads 4 --verbose --profile com-garethahealy-amq-uk $HOME/.m2/repository/
fi

if [[ $DOWNLOAD_ALL_FOR_SSH == "true" ]]; then
    echo -e $YELLOW"Downloading artifacts for profile garethahealy-gateway-http / garethahealy-gateway-mq / garethahealy-esb / garethahealy-amq to $HOME/.m2/repository/ for containers"$WHITE
    karaf_client fabric:container-connect gwy-001 \"fabric:profile-download-artifacts --threads 4 --verbose --profile garethahealy-gateway-http $HOME/.m2/repository/\"
    karaf_client fabric:container-connect gwy-001 \"fabric:profile-download-artifacts --threads 4 --verbose --profile garethahealy-gateway-mq $HOME/.m2/repository/\"
    karaf_client fabric:container-connect esb-001 \"fabric:profile-download-artifacts --threads 4 --verbose --profile com-garethahealy-esb-uk $HOME/.m2/repository/\"
    karaf_client fabric:container-connect amq-001 \"fabric:profile-download-artifacts --threads 4 --verbose --profile com-garethahealy-amq-uk $HOME/.m2/repository/\"
fi

##todo: set features as empty for esb profile

echo -e $GREEN"Post deploy import profiles for $DEPLOYMENT_ENVIRONMENT Done"$WHITE
exit 0
