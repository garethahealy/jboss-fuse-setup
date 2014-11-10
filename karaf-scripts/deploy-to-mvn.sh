#!/bin/bash
###
# Script to build maven project and deploy
###

ROOT_POM_PATH=$1
EXAMPLES_POM_PATH=$2
MVN_PATH=$(which mvn)

$MVN_PATH clean install deploy -DremoteOBR -f$ROOT_POM_PATH
$MVN_PATH clean install deploy -DskipTests -DremoteOBR -f$EXAMPLES_POM_PATH
