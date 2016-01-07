#!/usr/bin/env bash

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

## How to run:
## cd /opt/rh/scripts && assign-profiles.sh test

# Configure logging to print line numbers
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Set colours
GREEN="\e[32m"
RED="\e[41m\e[37m\e[1m"
YELLOW="\e[33m"
WHITE="\e[0m"

read -n1 -r -p "Press the any key..."

if [[ "$#" -lt 1 ]]; then
    echo -e $RED"Illegal number of parameters."$WHITE
    echo -e $RED"Usage: ./assign-profiles.sh (environment)"$WHITE
    echo -e $RED"Example: ./assign-profiles.sh test"$WHITE
    exit 1
fi

if [[ "$1" != "dev" ]] && [[ "$1" != "sandbox" ]] && [[ "$1" != "test" ]] && [[ "$1" != "preprod" ]] && [[ "$1" != "prod" ]]; then
    echo -e $RED"Environment $1 not supported. Expected; dev, sandbox, test, preprod or prod"$WHITE
    exit 1
fi

if [[ ! -d $HOST_RH_HOME ]]; then
    echo -e $RED"$HOST_RH_HOME does not exist!"$WHITE
    exit 1
fi

. ./lib/helper_functions.sh

export DEPLOYMENT_ENVIRONMENT="$1"
export RELEASE_VERSION="1.2"

# Set the environment variables for the selected environment 
. ./envs/$DEPLOYMENT_ENVIRONMENT/environment.sh

karaf_commands

echo -e $RED"Continuing with this process will change your enviorment!"$WHITE
read -n1 -r -p "If you continue, your current enviroment will be updated!"

## deploy profiles to containers
. ./envs/$DEPLOYMENT_ENVIRONMENT/assign-profiles.sh

exit 0
