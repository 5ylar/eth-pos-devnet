#/bin/bash
#

bash ./clean.sh

docker compose -f docker-compose.all.yml up -d create-beacon-chain-genesis geth-genesis
sleep 5
docker compose -f docker-compose.all.yml up -d beacon-chain geth validator

until false
do
    BLOCK_NUMBER=$(docker exec geth geth attach --exec 'eth.blockNumber' /execution/geth.ipc | tr -d '\n');

    if [[ "$BLOCK_NUMBER" -ge "1" ]]
    then
        echo '> geth is ready'
        break
    fi
done

mkdir n1_execution
cp execution/genesis.json n1_execution/
cp execution/geth_password.txt n1_execution/
cp execution/jwtsecret n1_execution/

docker compose -f docker-compose.all.yml up -d n1-geth-genesis
sleep 5
GETH_ENODE_HASH=$(docker exec geth geth attach --exec 'admin.nodeInfo.enode' /execution/geth.ipc | sed -e 's/^"enode:\/\///' | sed -e 's/@127.0.0.1.*//' | tr -d '\n')
echo "GETH_ENODE_HASH: $GETH_ENODE_HASH"
GETH_ENODE_HASH=$GETH_ENODE_HASH docker compose -f docker-compose.all.yml up -d n1-geth

mkdir n1_consensus
cp consensus/config.yml n1_consensus/

docker compose -f docker-compose.all.yml up -d n1-beacon-chain-genesis
sleep 5

# ex. 192.168.128.1
HOST_IP=$(docker exec -ti geth ip -4 route show default | cut -d" " -f3 | tr -d '\n')
# ex. 16Uiu2HAmGU23BYZhKe4YWPiYsDi6TpXe1M8vjNf1AGwn9yW2QSHD
PEER_ID=$(docker logs beacon-chain 2>&1 | head -n 50 | grep 'Running node with peer id' | xargs python3 -c "import sys;print(sys.argv[3].replace('msg=Running node with peer id of ', '').strip())" | tr -d '\n')
PEER="/ip4/$HOST_IP/tcp/13000/p2p/$PEER_ID"

echo "PEER: $PEER"

docker compose -f docker-compose.all.yml up -d n1-beacon-chain

# docker compose -f docker-compose.all.yml up -d beacon-chain geth validator
# sleep 60
# docker exec -it geth geth attach --exec eth.blockNumber /execution/geth.ipc

# ---- N1 ----

# mkdir n1_execution
# cp execution/genesis.json n1_execution/
# cp execution/geth_password.txt n1_execution/
# cp execution/jwtsecret n1_execution/
#
# mkdir n1_consensus
# cp consensus/config.yml n1_consensus/
#
# docker compose -f docker-compose.all.yml up -d n1-geth-genesis
# sleep 3
# docker compose -f docker-compose.all.yml up -d n1-geth
