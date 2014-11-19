#!/bin/sh
###
# Script to create a Fuse Fabric enviroment, with containers
###

# Fuse user
FUSE_USER=jbossfuse
LOCAL_USER=gahealy

# Set the below paths accordingly
WORKING_DIRECTORY="/Users/garethah/Documents/github/garethahealy"
ROOT_POM_PATH="$WORKING_DIRECTORY/jboss-fuse-setup"
EXAMPLES_POM_PATH="$WORKING_DIRECTORY/jboss-fuse-examples"
FUSE_PATH="/opt/rh/jboss-fuse-6.1.0.redhat-379"

SH_PATH=$(which sh)
 
$ROOT_POM_PATH/karaf-scripts/deploy-to-mvn.sh $ROOT_POM_PATH $EXAMPLES_POM_PATH

#$SH_PATH $ROOT_POM_PATH/deployment-scripts/clean_fuse_env.sh $FUSE_PATH
#$SH_PATH $ROOT_POM_PATH/deployment-scripts/deploy-to-fuse.sh $FUSE_PATH
