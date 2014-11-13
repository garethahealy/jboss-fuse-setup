#!/bin/sh
###
# Script to reset a Fuse Fabric enviroment, when fabric cannot resolve the local ip, due to it changing
###

FUSE_PATH="/opt/rh/jboss-fuse-6.1.0.redhat-379"

# Full path of your ssh, used by the aliases
SSH_PATH=$(which ssh)

# Configure logging to print line numbers
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# ulimits values needed by the processes inside the container
ulimit -u 4096
ulimit -n 4096

# Set debug mode
set -x

# Halt on errors
set -e

# Full paths to other tools to get local ip
IFCONFIG_PATH=$(which ifconfig)
GREP_PATH=$(which grep)
CUT_PATH=$(which cut)
AWK_PATH=$(which awk)

alias en0="$IFCONFIG_PATH en0 | $GREP_PATH 'inet' | $CUT_PATH -d: -f2 | $AWK_PATH '{ print \$2; }'"
localip=$(echo ${en0} | tr -d '\n')


#echo $localip
# Kill any processes matching the below
kill -kill $( ps aux | grep java | grep karaf | grep -v grep | awk '{ print $2; }' )

# Alias to connect to the ssh server exposed by JBoss Fuse. Uses sshpass to script the password authentication
alias ssh2fabric="sshpass -p admin $SSH_PATH -p 8101 -o ServerAliveCountMax=100 -o ConnectionAttempts=180 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o LogLevel=ERROR admin@localhost"

# Start fuse on root node (yes, that initial backslash is required to not use the declared alias)
"$FUSE_PATH/bin/start"

# Wait for ssh server to be up, avoids "Connection reset by peer" errors
while ! ssh2fabric "echo up" ; do sleep 1s; done;

# Wait for critical components to be available before progressing with other steps
ssh2fabric "wait-for-service -t 300000 io.fabric8.api.BootstrapComplete"

ssh2fabric "config:edit io.fabric8.zookeeper"
ssh2fabric "config:propset zookeeper.url $localip:2181"
ssh2fabric "config:update"