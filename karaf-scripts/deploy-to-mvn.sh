#!/bin/bash
###
# Script to build maven project and deploy
###

ROOT_POM_PATH=$1
MVN_PATH=$(which mvn)

$MVN_PATH clean install deploy -DremoteOBR -f$ROOT_POM_PATH
