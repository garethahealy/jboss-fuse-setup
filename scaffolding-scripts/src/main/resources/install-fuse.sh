#!/usr/bin/env bash

###
# #%L
# GarethHealy :: JBoss Fuse Setup :: Scaffolding Scripts
# %%
# Copyright (C) 2013 - 2018 Gareth Healy
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
## cd /tmp &&
##      wget https://repo1.maven.org/maven2/com/garethahealy/scaffolding-scripts/${project.version}/scaffolding-scripts-${project.version}-all.zip &&
##      unzip scaffolding-scripts-*-all.zip &&
##      cd scripts &&
##      chmod -R 755 install-fuse.sh &&
##      ./install-fuse.sh -e local

# Configure logging to print line numbers
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Set colours
GREEN="\e[32m"
RED="\e[41m\e[37m\e[1m"
YELLOW="\e[33m"
WHITE="\e[0m"

export DEBUG_MODE=false
export INTERACTIVE_MODE=true

EXPECTED_ARGS_COUNT=3
ARGS_COUNTER=0
while getopts ":e:i:x:" opt; do
  ARGS_COUNTER=$[$ARGS_COUNTER +1]

  case $opt in
    e) export DEPLOYMENT_ENVIRONMENT=$OPTARG
    ;;
    i) export INTERACTIVE_MODE=$OPTARG
    ;;
    x) export DEBUG_MODE=$OPTARG
    ;;
    \?)
    echo -e $RED"Illegal parameters: -$OPTARG expected: $EXPECTED_ARGS_COUNT"$WHITE
    echo -e $RED"Usage: ./install-fuse.sh -e (environment) -i (interactive mode - default: true) -x (debug - default: false)"$WHITE
    echo -e $RED"Example: ./install-fuse.sh -e local -i true -x true"$WHITE
    exit 1
    ;;
  esac
done

if [[ $ARGS_COUNTER -gt $EXPECTED_ARGS_COUNT ]]; then
    echo -e $RED"Illegal number of parameters: $ARGS_COUNTER"$WHITE
    echo -e $RED"Usage: ./install-fuse.sh -e (environment) -x (debug - optional)"$WHITE
    echo -e $RED"Example: ./install-fuse.sh -e local -x true"$WHITE
    exit 1
fi

SUPPORTED_ENVS_ARRAY=($(ls -lrt $(pwd)/envs | grep -v grep | awk '{ print $9; }'))
if [[ " ${SUPPORTED_ENVS_ARRAY[@]} " =~ " ${DEPLOYMENT_ENVIRONMENT} " ]]; then
    echo -e $GREEN"Environment: $DEPLOYMENT_ENVIRONMENT"$WHITE
else
    echo -e $RED"Environment \"$DEPLOYMENT_ENVIRONMENT\" not supported. Expected: ${SUPPORTED_ENVS_ARRAY[@]}"$WHITE
    exit 1
fi

if [[ "$INTERACTIVE_MODE" == "true" ]]; then
    echo -e $GREEN"Interactive mode"$WHITE
    read -n1 -r -p "Press the any key..."
fi

if [[ "$DEBUG_MODE" == "true" ]]; then
    echo -e $GREEN"Debug mode"$WHITE
    set -x
fi

echo ""

# Set the environment variables for the selected environment
. ./envs/base-environment.sh
. ./envs/$DEPLOYMENT_ENVIRONMENT/environment.sh
. ./lib/helper_functions.sh

if [[ ! -d $HOST_RH_HOME ]]; then
    echo -e $RED"$HOST_RH_HOME does not exist!"$WHITE
    exit 1
fi

if [[ -d $HOST_FUSE_HOME ]]; then
    echo -e $RED"$HOST_FUSE_HOME already exists!"$WHITE
    if [[ "$INTERACTIVE_MODE" == "true" ]]; then
        read -n1 -r -p "If you continue, your current enviroment will be deleted!"
    fi

    kill_karaf_instances

    echo -e $YELLOW"Removing old: $HOST_FUSE_HOME"$WHITE
    rm -rf $HOST_FUSE_HOME

    if [[ -d $HOST_FUSE_HOME ]]; then
        echo -e $RED"Couldnt delete: $HOST_FUSE_HOME :: rm -rf $HOST_FUSE_HOME"$WHITE
        exit 1
    fi
fi

if [[ $DOWNLOAD_FUSE_ZIP == "true" ]]; then
    if [[ -a $HOST_RH_HOME/$FUSE_ZIP ]]; then
        echo -e $YELLOW"Removing old: $HOST_RH_HOME/$FUSE_ZIP"$WHITE
        rm -rf $HOST_RH_HOME/$FUSE_ZIP
    fi
fi

if [[ -a $SCAFFOLDING_ZIP ]]; then
    echo -e $YELLOW"Removing old: $SCAFFOLDING_ZIP"$WHITE
    rm -f $SCAFFOLDING_ZIP
fi

if [[ -d $SCRIPTS_FOLDER ]]; then
    echo -e $YELLOW"Removing old: $SCRIPTS_FOLDER"$WHITE
    rm -rf $SCRIPTS_FOLDER
fi

echo -e $YELLOW"Removing any fabric8* or jboss-fuse* files/folders from /tmp"$WHITE
rm -rf /tmp/fabric8* /tmp/jboss-fuse*

echo -e $GREEN"Starting JBoss Fuse install..."$WHITE

if [[ $KARAF_PASSWORD == "readline" ]]; then
    echo -e $GREEN"Enter password for 'admin' user"$WHITE

    if [[ "$INTERACTIVE_MODE" == "false" ]]; then
        echo -e $GREEN"Interactive Mode is false, but Karaf password is readline. How can i get the password without my human?!?"$WHITE
        exit 1
    fi

    read -p "Password for 'admin' user: " adminpass
    KARAF_PASSWORD=$adminpass;

    sed -i 's/KARAF_PASSWORD=readline/KARAF_PASSWORD=$KARAF_PASSWORD/' /tmp/scripts/envs/$DEPLOYMENT_ENVIRONMENT/environment.sh
fi

if [[ $DOWNLOAD_FUSE_ZIP == "true" ]]; then
    echo -e $GREEN"Downloading JBoss Fuse.zip..."$WHITE

    cd $HOST_RH_HOME &&
        wget $FUSE_ZIP_DOWNLOAD &&
        unzip -q -o $FUSE_ZIP
else
    echo -e $GREEN"Unzipping JBoss Fuse.zip..."$WHITE

    cd $HOST_RH_HOME &&
        unzip -q -o $FUSE_ZIP
fi

if [[ ! -d $HOST_FUSE_HOME ]]; then
    echo -e $RED"$HOST_FUSE_HOME doesnt exist"$WHITE
    exit 1
fi

echo -e $GREEN"Applying base config..."$WHITE
sed -i 's/encryption.enabled = false/encryption.enabled = true/' $HOST_FUSE_HOME/etc/org.apache.karaf.jaas.cfg
sed -i "s/karaf.name = root/karaf.name = $ROOT_NODE_NAME/" $HOST_FUSE_HOME/etc/system.properties
sed -i 's/JAVA_MIN_MEM=512M/JAVA_MIN_MEM=1024M/' $HOST_FUSE_HOME/bin/setenv
sed -i 's/JAVA_MAX_MEM=512M/JAVA_MAX_MEM=1024M/' $HOST_FUSE_HOME/bin/setenv

cd /tmp &&
    cp -R scripts $SCRIPTS_FOLDER &&
    cd $SCRIPTS_FOLDER &&
    chmod -R 755 *.sh commands/*.sh envs/$DEPLOYMENT_ENVIRONMENT/*.sh

cat >> $HOST_FUSE_HOME/etc/users.properties <<EOT

$KARAF_USER=$KARAF_PASSWORD,admin,manager,viewer,Monitor, Operator, Maintainer, Deployer, Auditor, Administrator, SuperUser
EOT

echo -e $GREEN"Install fuse $DEPLOYMENT_ENVIRONMENT Done"$WHITE
exit 0
