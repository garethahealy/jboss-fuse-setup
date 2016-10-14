#!/usr/bin/env bash

###
# #%L
# GarethHealy :: JBoss Fuse Setup :: Scaffolding Scripts
# %%
# Copyright (C) 2013 - 2016 Gareth Healy
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

# Version
export FUSE_VERSION=6.3.0.redhat-187

# Host OS paths
export HOST_RH_HOME=/opt/rh
export HOST_FUSE_HOME=${HOST_RH_HOME}/jboss-fuse-${FUSE_VERSION}

# Zip for install
export FUSE_ZIP=jboss-fuse-karaf-${FUSE_VERSION}.zip
export FUSE_ZIP_DOWNLOAD=http://$NEXUS_IP:8081/nexus/content/repositories/releases/org/jboss/fuse/jboss-fuse-karaf/${FUSE_VERSION}/${FUSE_ZIP}
export SCAFFOLDING_ZIP=$HOST_RH_HOME/scaffolding-scripts-${project.version}-all.zip
export SCRIPTS_FOLDER=$HOST_RH_HOME/scripts
