#!/bin/bash
git clone https://github.com/conduitxyz/node.git
echo " "
echo " "
cd node
echo " "
echo " "
./download-config.py zora-mainnet-0
echo " "
echo " "
export CONDUIT_NETWORK=zora-mainnet-0
echo " "
echo " "
cp .env.example .env
echo " "
echo " "
read -p "ВВЕДИТЕ HTTPS КЛЮЧ ИЗ ALCHEMY: " link_https
echo " "
echo " "
echo "OP_NODE_L1_ETH_RPC=${link_https}" > .env
echo "OP_NODE_L1_BEACON=http://$(hostname -I | awk '{print $1}'):3500" >> .env



echo "" > docker-compose.yml

cat << EOF > docker-compose.yml
services:
  op-geth: # this is Optimism's geth client
    pull_policy: always
    build:
      context: .
      dockerfile: op-geth.Dockerfile
    ports:
      - 8845:8545       # RPC
      - 8646:8546       # websocket
      - 31303:30303     # P2P TCP (currently unused)
      - 31303:30303/udp # P2P UDP (currently unused)
      - 7401:6060       # metrics
    env_file:
      - .env.default
      - networks/${CONDUIT_NETWORK:?set network}/.env
      - .env
    volumes:
      #- ./geth-data/:/data # enable to have persistency between restarts
      - ./networks/${CONDUIT_NETWORK:?set network}/genesis.json:/genesis.json
  op-node:
    pull_policy: always
    build:
      context: .
      dockerfile: op-node.Dockerfile
    depends_on:
      - op-geth
    ports:
      - 7645:8545     # RPC
      - 9322:9222     # P2P TCP
      - 9322:9222/udp # P2P UDP
      - 7400:7300     # metrics
      - 6160:6060     # pprof
    env_file:
      - .env.default
      - networks/${CONDUIT_NETWORK:?set network}/.env
      - .env
    volumes:
      - ./networks/${CONDUIT_NETWORK:?set network}/rollup.json:/rollup.json
      - ./networks/${CONDUIT_NETWORK:?set network}/genesis.json:/genesis.json
EOF
echo " "
echo " "
echo "Введите эти команды"
echo "screen –S zora"
echo "docker compose up --build"
