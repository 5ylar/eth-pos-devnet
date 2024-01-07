#/bin/bash

mkdir n1_execution
cp execution/genesis.json n1_execution/
cp execution/geth_password.txt n1_execution/
cp execution/jwtsecret n1_execution/

mkdir n1_consensus
cp consensus/config.yml n1_consensus/

docker compose -f docker-compose.n1-genesis.yml up -d
sleep 3
docker compose -f docker-compose.n1.yml up -d
# sleep 60
# docker exec -it eth-pos-devnet-n1-geth-1 geth attach --exec eth.blockNumber /execution/geth.ipc
