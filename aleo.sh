#!/bin/bash







sudo ufw allow 3032 
sudo iptables -t filter -A INPUT -p tcp --dport 3032 -j ACCEPT
sudo ufw allow 4132
sudo iptables -t filter -A INPUT -p tcp --dport 4132 -j ACCEPT









echo "УСТАНОВКА ЗАВИСИМОСТЕЙ:" && sleep 1
apt update
apt install make clang pkg-config libssl-dev build-essential gcc xz-utils git curl vim tmux ntp jq llvm ufw -y < "/dev/null"
echo "=================================================="
echo -e 'КЛОНИРОВАНИЕ SNARKOS...\n' && sleep 1
rm -rf $HOME/snarkOS $(which snarkos) $(which snarkos) $HOME/.aleo $HOME/aleo
cd $HOME
git clone https://github.com/AleoHQ/snarkOS.git --depth 1
cd snarkOS
echo "=================================================="
echo 'УСТАНОВКА snarkos ...\n' && sleep 1
bash ./build_ubuntu.sh
source $HOME/.bashrc
source $HOME/.cargo/env
echo 'ГЕНЕРАЦИЯ Aleo account address ...\n' && sleep 1
mkdir $HOME/aleo
echo "==================================================
                  Your Aleo account:
==================================================
" > $HOME/aleo/account_new.txt
date >> $HOME/aleo/account_new.txt
snarkos account new >>$HOME/aleo/account_new.txt
sleep 2
cat $HOME/aleo/account_new.txt
echo -e "\033[41m\033[30mPLEASE REMEMBER TO SAVE THE ACCOUNT PRIVATE KEY AND VIEW KEY.\033[0m\n"
sleep 3
mkdir -p /var/aleo/
cat $HOME/aleo/account_new.txt >>/var/aleo/account_backup.txt
echo 'export PROVER_PRIVATE_KEY'=$(grep "Private Key" $HOME/aleo/account_new.txt | awk '{print $3}') >> $HOME/.bash_profile
source $HOME/.bash_profile
echo -e 'Creating a service for Aleo Client Node...\n' && sleep 1
echo "[Unit]
Description=Aleo Client Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which snarkos) start --nodisplay --client ${PROVER_PRIVATE_KEY}
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleo-client.service
 mv $HOME/aleo-client.service /etc/systemd/system
 tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
systemctl restart systemd-journald
echo -e 'Creating a service for Aleo Prover Node...\n' && sleep 1
echo "[Unit]
Description=Aleo Prover Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which snarkos) start --nodisplay --prover ${PROVER_PRIVATE_KEY}
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleo-prover.service
 mv $HOME/aleo-prover.service /etc/systemd/system

echo -e "Installing Aleo Updater\n"
cd $HOME
wget -q -O $HOME/aleo_updater_WIP.sh https://api.nodes.guru/aleo3_updater_WIP.sh && chmod +x $HOME/aleo_updater_WIP.sh
echo "[Unit]
Description=Aleo Updater
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/snarkOS
ExecStart=/bin/bash $HOME/aleo_updater_WIP.sh
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleo-updater.service
mv $HOME/aleo-updater.service /etc/systemd/system
systemctl daemon-reload
echo -e 'Enabling Aleo Updater services\n' && sleep 1
systemctl enable aleo-updater
systemctl restart aleo-updater
echo -e '\n\e[42mRuning Aleo Prover Node\e[0m\n' && sleep 1
systemctl enable aleo-prover
systemctl restart aleo-prover

if [[ `service aleo-prover status | grep active` =~ "running" ]]; then
  echo -e "Your Aleo Prover Node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7msystemctl status aleo-prover\e[0m"
  echo -e "You can check Aleo Prover Node logs by the command \e[7mjournalctl -u aleo-prover -f -o cat\e[0m"
  echo -e "Press \e[7mctrl+c\e[0m for exit from logs"
else
  echo -e "Your Aleo Prover Node \e[31mwas not installed correctly\e[39m, please reinstall."
