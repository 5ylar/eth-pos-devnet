docker rm -f $(docker ps -a -q) || echo 'no running docker containers'
rm -Rf ./consensus/beacondata
rm -Rf ./consensus/validatordata
rm -Rf ./consensus/genesis.ssz
rm -Rf ./execution/geth

rm -Rf ./n*_consensus
rm -Rf ./n*_execution

