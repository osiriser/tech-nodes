26656/TCP for CometBFT P2P, should be public
26657/TCP for CometBFT RPC, should be private
26660/TCP for CometBFT metrics, should be private
26658/TCP for Penumbra ABCI, should be private
9000/TCP for Penumbra metrics, should be private
8080/TCP for Penumbra gRPC, should be private
443/TCP for Penumbra HTTPS, optional, should be public if enabled




sudo ufw allow 26658 
sudo ufw allow 26657
sudo ufw allow 8080
sudo ufw allow 26656
sudo ufw allow 26660
sudo ufw allow 9000
sudo ufw allow 443
sudo iptables -t filter -A INPUT -p tcp --dport 26658 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 26657 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 8080 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 26656 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 26660 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 9000 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT





IP_ADDRESS=$(curl -s ifconfig.me)

echo "Enter the name of your node:"
read MY_NODE_NAME

UBUNTU_VERSION=$(lsb_release -sr)
if (( $(echo "$UBUNTU_VERSION < 22" | bc -l) )); then
    echo "This script requires Ubuntu version 22 or higher. Your version is $UBUNTU_VERSION."
    exit 1
fi

# Remove previous versions of Penumbra and related modules
echo "Removing old versions of Penumbra and related modules..."
sudo rm -rf /root/penumbra /root/cometbft /root/.local/share/pcli/

# Rename existing Penumbra directory (for updates)
if [ -d "/root/penumbra" ]; then
    mv /root/penumbra /root/penumbra_old
fi

# Update package list and install dependencies
sudo apt-get update
sudo apt-get install -y build-essential pkg-config libssl-dev clang git-lfs tmux libclang-dev curl
sudo apt-get install tmux

curl -sSfL -O https://github.com/penumbra-zone/penumbra/releases/download/v0.69.0/pd-x86_64-unknown-linux-gnu.tar.xz
unxz pd-x86_64-unknown-linux-gnu.tar.xz
tar -xf pd-x86_64-unknown-linux-gnu.tar
sudo mv pd-x86_64-unknown-linux-gnu/pd /usr/local/bin/


# confirm the pd binary is installed by running:
pd --version







cd /root/penumbra
./target/release/pd testnet unsafe-reset-all
./target/release/pd testnet join --external-address $IP_ADDRESS:26656 --moniker $MY_NODE_NAME




cd deployments/compose/
docker-compose pull
docker-compose up --abort-on-container-exit

