#!/usr/bin/env bash

#####
# STILL WORK IN PROGRESS
#####

echo "STILL WORK IN PROGRESS"
exit 1;

###
# #%L
# GarethHealy :: JBoss Fuse Setup :: Scaffolding Scripts
# %%
# Copyright (C) 2013 - 2015 Gareth Healy
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

VAR_ENV=$1

/opt/rh/scripts/envs/$VAR_ENV/environment.sh
/opt/rh/scripts/lib/helper_functions.sh

karaf_commands
start_fuse
exit 0
