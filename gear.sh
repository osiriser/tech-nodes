#!/bin/bash
tput reset 
tput civis 
echo -e "\033[32m████─████─██─██─████─███─████─███─██─██─█──█─████──███─████─████─███─███\e[0m"
echo -e "\033[32m█──█─█──█──███──█──█──█──█──█─█────███──██─█─█──██──█──█──█─█──█──█──█──\e[0m"
echo -e "\033[32m█────████───█───████──█──█──█─███───█───█─██─█──██──█──█────████──█──███\e[0m"
echo -e "\033[32m█──█─█─█────█───█─────█──█──█───█───█───█──█─█──██──█──█──█─█──█──█──█──\e[0m"
echo -e "\033[32m████─█─█────█───█─────█──████─███───█───█──█─████──███─████─█──█──█──███\e[0m"
echo " "
echo -e "\033[93m╔╗─╔╗╔══╗╔══╗─╔═══╗───╔══╗╔╗─╔╗╔══╗╔════╗╔══╗╔╗──╔╗──╔═══╗╔═══╗\e[0m"
echo -e "\033[93m║╚═╝║║╔╗║║╔╗╚╗║╔══╝───╚╗╔╝║╚═╝║║╔═╝╚═╗╔═╝║╔╗║║║──║║──║╔══╝║╔═╗║\e[0m"
echo -e "\033[93m║╔╗─║║║║║║║╚╗║║╚══╗────║║─║╔╗─║║╚═╗──║║──║╚╝║║║──║║──║╚══╗║╚═╝║\e[0m"
echo -e "\033[93m║║╚╗║║║║║║║─║║║╔══╝────║║─║║╚╗║╚═╗║──║║──║╔╗║║║──║║──║╔══╝║╔╗╔╝\e[0m"
echo -e "\033[93m║║─║║║╚╝║║╚═╝║║╚══╗───╔╝╚╗║║─║║╔═╝║──║║──║║║║║╚═╗║╚═╗║╚══╗║║║║─\e[0m"
echo -e "\033[93m╚╝─╚╝╚══╝╚═══╝╚═══╝───╚══╝╚╝─╚╝╚══╝──╚╝──╚╝╚╝╚══╝╚══╝╚═══╝╚╝╚╝─\e[0m"


echo "ВВЕДИТЕ КЛЮЧ ДОСТУПА К НОДЕ:"
read key

response=$(curl -s -o /dev/null -w "%{http_code}" "https://cryptosyndicate.vc/api/user/nodes/activation-code/$key")

if [ $response -eq 200 ]; then
  echo "ДОСТУП РАЗРЕШЕН"
else
  echo "ДОСТУП ЗАПРЕЩЕН"
  exit 1
fi

echo " "
echo " "
echo "НАЧИНАЕМ УСТАНОВКУ НОДЫ GEAR"
echo " "
echo " "

sudo apt-get update && sudo apt-get upgrade -y

sudo apt install htop mc curl tar wget git make ncdu jq chrony net-tools iotop nload -y

wget --no-check-certificate https://get.gear.rs/gear-nightly-linux-x86_64.tar.xz && \
tar xvfJ gear-nightly-linux-x86_64.tar.xz && \
rm gear-nightly-linux-x86_64.tar.xz
sudo chmod +x gear && sudo mv gear /usr/bin

read -p "ПРИДУМАЙТЕ НАЗВАНИЕ ДЛЯ ВАШЕЙ НОДЫ GEAR: " node_name

# Check if string is empty using -z. For more 'help test'    
if [[ -z "$node_name" ]]; then
    printf '%s\n' "ВЫ НЕ УСТАНОВИЛИ НАЗВАНИЕ ВАШЕЙ НОДЫ"
    exit 1
else
    # If userInput is not empty show what the user typed in and run ls -l
    printf "НАЗВАНИЕ ВАШЕЙ НОДЫ GEAR %s " "$node_name"

echo " "
echo " "
echo "СОЗДАНИЕ СЕРВИС ФАЙЛА"
echo " "
echo " "

sudo tee /etc/systemd/system/gear-node.service > /dev/null <<EOF
[Unit]
Description=Gear-node
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/gear --telemetry-url "ws://telemetry-backend-shard.gear-tech.io:32001/submit 0" --name "$node_name"
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
fi

sudo systemctl daemon-reload && \
sudo systemctl enable gear-node && \
sudo systemctl restart gear-node

echo " "
echo " "
echo "ДЕЛАЕМ БЭКАП"
echo " "
echo " "
sudo mkdir -p $HOME/backup/gear
sudo cp $HOME/.local/share/gear/chains/gear_staging_testnet_*/network/secret_* $HOME/backup/gear/
echo " "
echo " "

