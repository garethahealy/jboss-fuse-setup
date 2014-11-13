#!/bin/sh
###
# Script to reset a Fuse Fabric enviroment, when fabric cannot resolve the local ip, due to it changing
###

FUSE_PATH="/opt/rh/jboss-fuse-6.1.0.redhat-379"

# Full path of your ssh, used by the aliases
SSH_PATH=$(which ssh)

KARAF_PORT=8101

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

EN0_LOCALIP=`$IFCONFIG_PATH en0 | $GREP_PATH 'inet' | $CUT_PATH -d: -f2 | $AWK_PATH '{ print \$2; }' | tr -d '\n'`

# Kill any processes matching the below
kill -kill $( ps aux | grep java | grep karaf | grep -v grep | awk '{ print $2; }' )

# Alias to connect to the ssh server exposed by JBoss Fuse. Uses sshpass to script the password authentication
alias ssh2fabric="sshpass -p admin $SSH_PATH -o ServerAliveCountMax=100 -o ConnectionAttempts=180 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o LogLevel=ERROR admin@localhost"

array=( "$FUSE_PATH/bin" "$FUSE_PATH/instances/esb-uk/bin" "$FUSE_PATH/instances/amq-uk/bin" )
for i in "${array[@]}"
do
	# Start fuse on root node (yes, that initial backslash is required to not use the declared alias)
	"$i/start"

	# Wait for ssh server to be up, avoids "Connection reset by peer" errors
	while ! ssh2fabric "-p $KARAF_PORT" "echo up" ; do sleep 1s; done;

	# Set zookeeper to be the localip so fabric can come back up
	ssh2fabric "-p $KARAF_PORT" "config:propset -p io.fabric8.zookeeper zookeeper.url $EN0_LOCALIP:2181"

	port=$((port+1))
done