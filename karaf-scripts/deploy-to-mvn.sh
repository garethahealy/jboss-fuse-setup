#!/bin/bash

###
# The below location should be to the root pom
###

mvn clean install deploy -DremoteOBR -f/home/gahealy/jboss-studio-workspace/jboss-fuse-setup
