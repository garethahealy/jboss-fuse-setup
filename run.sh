#!/bin/bash

ROOT_POM_PATH="/home/gahealy/jboss-studio-workspace/jboss-fuse-setup"
FUSE_PATH="/opt/rh/jboss-fuse-6.1.0"

sh karaf-scripts/deploy-to-mvn.sh $ROOT_POM_PATH

sudo sh deployment-scripts/clean_fuse_env.sh $FUSE_PATH
sudo sh deployment-scripts/deploy-to-fuse.sh $FUSE_PATH
