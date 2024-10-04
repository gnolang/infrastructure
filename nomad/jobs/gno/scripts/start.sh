#!/usr/bin/env sh

apk add jq

MONIKER=${MONIKER:-"gnode-${NOMAD_ALLOC_INDEX}" }

P2P_LADDR="tcp://0.0.0.0:26656"
RPC_LADDR="tcp://0.0.0.0:26657"

SEED_MODE=true

EXTERNAL_ADDR=${EXTERNAL_ADDR:-""}

CHAIN_ID={{ env "CHAIN_ID" }}

SEEDS=${SEEDS:-""}
PERSISTENT_PEERS=${PERSISTENT_PEERS:-""}

TELEMETRY_EXPORTER_ENDPOINT=${TELEMETRY_EXPORTER_ENDPOINT:-""}

CONSENSUS_TIMEOUT_COMMIT=${CONSENSUS_TIMEOUT_COMMIT:-"5s"}

# Get nomad vars
NODE_1_ID=$(wget -O- http://${NOMAD_IP_rpc}:4646/v1/var/nomad/jobs/gno-devnet-1/nodes/gnoland/1\?namespace\=gno | jq -r '.Items.NODE_ID')
# NODE_1_IP=$(cat /local/services.txt | grep -o '100.*' | sed "s/^/${NODE_1_ID}/")
NODE_1_p2p=$(cat /local/services.txt| grep -o '100.*' | sed "s/^/${NODE_1_ID}@/" | tr '\n' ',' | sed 's/,$//')

SEEDS="${NODE_1_p2p}"
PERSISTENT_PEERS="${NODE_1_p2p}"

gnoland config init
gnoland secrets init

cp -v /local/node_key.json           gnoland-data/secrets/node_key.json
cp -v /local/priv_validator_key.json gnoland-data/secrets/priv_validator_key.json

# Set the config values
gnoland config set moniker       "${MONIKER}"
gnoland config set rpc.laddr     "${RPC_LADDR}"
gnoland config set p2p.laddr     "${P2P_LADDR}"
gnoland config set p2p.seed_mode "${SEED_MODE}"
gnoland config set p2p.seeds     "${SEEDS}"
gnoland config set p2p.persistent_peers "${PERSISTENT_PEERS}"
gnoland config set p2p.external_address "${EXTERNAL_ADDR}"
gnoland config set consensus.timeout_commit "${CONSENSUS_TIMEOUT_COMMIT}"

if [ -n "${TELEMETRY_EXPORTER_ENDPOINT}" ]; then
    gnoland config set telemetry.enabled true
    gnoland config set telemetry.exporter_endpoint ${TELEMETRY_EXPORTER_ENDPOINT}
fi


# --skip-failing-genesis-txs \

exec gnoland start \
    --genesis="/local/genesis.json" \
    --log-level=info
