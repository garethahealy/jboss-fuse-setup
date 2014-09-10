#!/bin/bash
###
# Script to kill any running karaf processes (ESB, AMQ, Fabric8 etc)
###

FUSE_PATH=$1

# Enable debugging
set -x

# Kill any processes matching the below
kill -kill $( ps aux | grep java | grep karaf | grep -v grep | awk '{ print $2; }' )

# Remove the data (Fabric8 directory) and instances directories (Any containers)
rm -rf "$FUSE_PATH/data" "$FUSE_PATH/instances"
