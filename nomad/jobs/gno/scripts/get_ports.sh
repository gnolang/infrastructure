#!/usr/bin/env sh

P2P_PEERS=""

for rpc in $(cat /tmp/services.txt | grep -o '100.*') ; do
    echo "-> ${rpc}"
    curl -s ${rpc}/status | jq -r ".result.node_info.net_address"
done
