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
## cd /opt/rh/scripts
##       && ./install-fuse-and-deploy.sh -e local -u fuse

DEBUG_MODE=false
INTERACTIVE_MODE=true

ARGS_COUNTER=0
while getopts ":e:u:i:x:" opt; do
  ARGS_COUNTER=$[$ARGS_COUNTER +1]

  case $opt in
    e) DEPLOYMENT_ENVIRONMENT=$OPTARG
    ;;
    u) SSH_USER=$OPTARG
    ;;
    i) INTERACTIVE_MODE=$OPTARG
    ;;
    x) DEBUG_MODE=$OPTARG
    ;;
    \?)
    echo -e $RED"Illegal parameters: -$OPTARG expected: 4"$WHITE
    echo -e $RED"Usage: ./install-fuse-and-deploy.sh -e (environment) -u (sshuser) -i (interactive mode - default: true) -x (debug - default: false)"$WHITE
    echo -e $RED"Example: ./install-fuse-and-deploy.sh -e local -u fuse -i true -x true"$WHITE
    exit 1
    ;;
  esac
done

./install-fuse.sh -e $DEPLOYMENT_ENVIRONMENT -i $INTERACTIVE_MODE -x $DEBUG_MODE
[ $? -eq 0 ] || exit $?;

./deploy.sh -e $DEPLOYMENT_ENVIRONMENT -u $SSH_USER -i $INTERACTIVE_MODE -x $DEBUG_MODE
[ $? -eq 0 ] || exit $?;

exit 0
