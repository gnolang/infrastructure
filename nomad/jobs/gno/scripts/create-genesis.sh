#!/usr/bin/env sh


echo "NOMAD ALLOC: ${NOMAD_ALLOC_INDEX}"

# if [ "z$NOMAD_ALLOC_INDEX" != "z1" ]; then
#     exit
# fi

COUNT=${COUNT:-3}
CHAIN_ID=${CHAIN_ID:-"gnoland-devnet-1"}

NOMAD_ADDR=${NOMAD_ADDR:-"http://localhost:4646"}
NOMAD_TOKEN=${NOMAD_TOKEN:-""}
NOMAD_NAMESPACE=${NOMAD_NAMESPACE:-"default"}

NOMAD_VAR_PREFIX="nomad/jobs/gno-devnet-1/nodes/gnoland"

export NOMAD_ADDR=${NOMAD_ADDR}
export NOMAD_TOKEN=${NOMAD_TOKEN}
export NOMAD_NAMESPACE=${NOMAD_NAMESPACE}

# GNO_INSTALL_URL="https://github.com/gnolang/gno/releases/download/v0.1.0-nightly.20240523/gno_0.1.0-nightly.20240523_linux_amd64.tar.gz"
# if ! command -v gnoland &> /dev/null
# then
#     wget ${GNO_INSTALL_URL} -O - | tar -xzvf - -C /usr/bin/
# fi

rm -rvf  genesis.json node-* ${CHAIN_ID}
mkdir -p ${CHAIN_ID}

# gnoland genesis generate --chain-id "${CHAIN_ID}"
gnoland start --lazy --chainid "${CHAIN_ID}" --data-dir ${CHAIN_ID}/node-0 --genesis "${CHAIN_ID}/genesis.json"

gnoland genesis validator remove --genesis-path "./${CHAIN_ID}/genesis.json" --address "$(cat ${CHAIN_ID}/genesis.json | jq -r ".validators[0].address")"

for i in $(seq 1 $COUNT); do
    gnoland config  init --config-path ${CHAIN_ID}/node-$i/config/config.toml
    gnoland secrets init --data-dir ${CHAIN_ID}/node-$i/secrets

    NODE_ID=$(gnoland secrets get --data-dir ${CHAIN_ID}/node-$i/secrets NodeKey | grep -o 'g1.*')
    WALLET_ADDR=$(gnoland secrets get --data-dir ${CHAIN_ID}/node-$i/secrets ValidatorPrivateKey | grep -o 'g1.*')
    VAL_PUBKEY=$(gnoland secrets get --data-dir ${CHAIN_ID}/node-$i/secrets ValidatorPrivateKey | grep -o 'gpub1.*')

    echo "NODE_ID: ${NODE_ID}"
    echo "WALLET_ADDR: ${WALLET_ADDR}"
    echo "VAL_PUBKEY: ${VAL_PUBKEY}"

    nomad var put --force "${NOMAD_VAR_PREFIX}/${i}" \
        "NODE_ID=${NODE_ID}" \
        "WALLET_ADDR=${WALLET_ADDR}" \
        "VAL_PUBKEY=${VAL_PUBKEY}" \
        "node_key=$(cat ${CHAIN_ID}/node-$i/secrets/node_key.json)" \
        "priv_validator_key=$(cat ${CHAIN_ID}/node-$i/secrets/priv_validator_key.json)"

    gnoland genesis validator add --genesis-path "${CHAIN_ID}/genesis.json" --name gnode-devnet-$i --address ${WALLET_ADDR} --pub-key ${VAL_PUBKEY}
done

gnoland genesis balances add --genesis-path "${CHAIN_ID}/genesis.json" --balance-sheet $GOPATH/src/github.com/gnolang/gno/gno.land/genesis/genesis_balances.txt
gnoland genesis txs add      --genesis-path "${CHAIN_ID}/genesis.json" $GOPATH/src/github.com/gnolang/gno/gno.land/genesis/genesis_txs.jsonl

gnoland genesis verify --genesis-path "${CHAIN_ID}/genesis.json"

## TO BIG, it's failing need to store in s3
# nomad var put --force "${NOMAD_VAR_PREFIX}" "genesis=$(cat ./genesis.json)"
mc cp --attr x-amz-acl=public-read  ./${CHAIN_ID}/genesis.json aib-do/gno/gnoland-devnet-1/genesis.json
