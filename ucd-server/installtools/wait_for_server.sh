#!/usr/bin/env bash
set -e

if [ $# != 1 ]; then
    echo "Usage: $0 <ucd-server>
Wait for UCD server to be up and running on specified host with optional port."
    exit 1
fi

host=$1

# Check every 10 seconds for 120 seconds
for i in $(seq 1 12); do
    sleep 10
    if wget -q -O /dev/null --user admin --password admin "http://$host/cli/systemConfiguration"
    then
        exit 0
    fi
done
echo "$0: Server at $host failed to start"
exit 1
