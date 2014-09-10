#!/bin/bash

ROOT_POM_PATH=$1

mvn clean install deploy -DremoteOBR -f$ROOT_POM_PATH
