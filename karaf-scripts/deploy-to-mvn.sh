#!/bin/bash
###
# Script to build maven project and deploy
###

ROOT_POM_PATH=$1
EXAMPLES_POM_PATH=$2
MVN_PATH=$(which mvn)

# Build the jboss fuse setup and examples projects
$MVN_PATH clean install deploy -DremoteOBR -f$ROOT_POM_PATH
$MVN_PATH clean install deploy -DskipTests -DremoteOBR -f$EXAMPLES_POM_PATH

# Download the source and javadocs for both projects
$MVN_PATH dependency:sources -f$ROOT_POM_PATH
$MVN_PATH dependency:resolve -Dclassifier=javadoc -f$ROOT_POM_PATH

$MVN_PATH dependency:sources -f$EXAMPLES_POM_PATH
$MVN_PATH dependency:resolve -Dclassifier=javadoc -f$EXAMPLES_POM_PATH
