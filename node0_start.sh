#/bin/bash

docker compose -f docker-compose.genesis.yml up -d
sleep 3
docker compose -f docker-compose.yml up -d
sleep 60
docker exec -it eth-pos-devnet-geth-1 geth attach --exec eth.blockNumber /execution/geth.ipc
