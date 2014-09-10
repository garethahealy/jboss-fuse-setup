#!/bin/sh
###
# Script to create a Fuse Fabric enviroment, with containers
###

# Set the below paths accordingly
ROOT_POM_PATH="/home/gahealy/jboss-studio-workspace/jboss-fuse-setup"
FUSE_PATH="/opt/rh/jboss-fuse-6.1.0"

SH_PATH=$(which sh)
SUDO_PATH=$(which sudo)

$SH_PATH karaf-scripts/deploy-to-mvn.sh $ROOT_POM_PATH

$SUDO_PATH $SH_PATH deployment-scripts/clean_fuse_env.sh $FUSE_PATH
$SUDO_PATH $SH_PATH deployment-scripts/deploy-to-fuse.sh $FUSE_PATH
