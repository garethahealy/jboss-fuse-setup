#!/bin/bash

sh karaf-scripts/deploy-to-mvn.sh

sudo sh deployment-scripts/clean_fuse_env.sh
sudo sh deployment-scripts/deploy-to-fuse.sh
