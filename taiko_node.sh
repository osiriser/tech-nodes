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
echo " "
echo "ВЫ УСТАНАВЛИВАЕТЕ НОДУ TAIKO"
echo " "
echo " "

# Запрашиваем ключ у пользователя
echo "ВВЕДИТЕ КЛЮЧ ДОСТУПА К НОДЕ:"
read key

# Выполняем запрос GET на сайт cryptosyndicate.vc с использованием ключа
response=$(curl -s -o /dev/null -w "%{http_code}" "https://cryptosyndicate.vc/api/user/nodes/activation-code/$key")

if [ $response -eq 200 ]; then
  echo "ДОСТУП РАЗРЕШЕН"
else
  echo "ДОСТУП ЗАПРЕЩЕН"
exit 1
fi

#all links
link_key_wallet="https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-export-an-account-s-private-key"
link_testnets="https://chainlist.org/"
link_alchemy="https://alchemy.com/?r=6aff3a94e7bae9bd"
link_sepolia="https://sepoliafaucet.com/"
link_etherscan="https://sepolia.etherscan.io/"
link_explorer="https://explorer.test.taiko.xyz/"
echo " "
echo " "
echo "УДАЛЕНИЕ СТАРОЙ ВЕРСИИ НОДЫ"
#remove a node
cd ~/simple-taiko-node
docker compose down -v
rm -f .env

echo " "
echo " "
cd $HOME/
echo "ДОБАВЛЕНИЕ НЕОБХОДИМЫХ ПРАВИЛ В ФАЕРВОЛЫ"
sudo ufw allow 22
sudo ufw allow 8545
sudo ufw allow 8546
sudo ufw allow 6060
sudo ufw allow 30303
sudo ufw allow 9000
sudo ufw allow 9090
sudo ufw allow 3000
sudo iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 8545 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 8546 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 6060 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 30303 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 9000 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 9090 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 3000 -j ACCEPT
echo " "

cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install curl wget -y



# Install git
echo "НАЧИНАЕМ УСТАНОВКУ GIT"
sudo apt update && apt upgrade -y
sudo apt install pkg-config curl git-all build-essential libssl-dev libclang-dev ufw
git version
# Install docker
echo "НАЧИНАЕМ УСТАНОВКУ DOCKER"
sudo apt-get install ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo apt install docker-compose

#inslall need packets for docker
sudo snap install docker -y
sudo apt  install podman-docker -y
sudo apt  install docker.io -y
sudo service docker start
sudo apt-get update -y
echo ""
echo ""
sudo docker run hello-world
echo ""
echo ""
echo "НАЧИНАЕМ УСТАНОВКУ НОДЫ TAIKO"
# Install node
cd $HOME
git clone https://github.com/taikoxyz/simple-taiko-node.git
echo ""
echo ""

cd simple-taiko-node

# Copy .env.sample to .env file
cp .env.sample .env




# Request user input for key wallet
read -p "ВВЕДИТЕ СВОЙ ПРИВАТНЫЙ КЛЮЧ ИЗ КОШЕЛЬКА METAMASK(КАК НАЙТИ: ГАЙД ПО ССЫЛКЕ $link): " key_wallet

# Request user input for wallet address
read -p "ВВЕДИТЕ СВОЙ METAMASK АДРЕС: " address_wallet
echo ""
echo "ПЕРЕХОДИМ НА ALCHEMY($link_alchemy) И ПРОХОДИМ РЕГИСТРАЦИЮ"
echo ""
echo ""
echo "НА САЙТЕ В СТРОКЕ NETWORK УКАЗЫВАЕМ WEB3 API И ПРИДУМЫВАЕМ НАЗВАНИЕ ПРОЕКТА"
echo ""
echo ""
echo "В ПРАВОМ ВЕРХНЕМ УГЛУ КЛИКАЕМ API KEYS И НАЖИМАЕМ НА НАЗВАНИЕ НАШЕЙ ОРГАНИЗАЦИИ"
echo ""
echo ""
echo "ДАЛЕЕ МЕНЯЕМ СЕТЬ MAINNET НА SEPOLIA, КОПИРУЕМ HTTPS КЛЮЧ, КОТОРЫЙ ВЫСВЕТИТСЯ В СТРОКЕ И МЕНЯЕМ HTTPS НА WEBSOCKET, СКОПИРОВАВ ПРИ ЭТОМ НАШ ВТОРОЙ КЛЮЧ"
echo ""
echo ""
# Request user input for HTTP link
read -p "ВВЕДИТЕ ССЫЛКУ HHTPS: " link_http

# Request user input for WS link
read -p "ВВЕДИТЕ ССЫЛКУ WEBSOCKETS: " link_ws


#sed -i 's/^L2_SUGGESTED_FEE_RECIPIENT.*$/L2_SUGGESTED_FEE_RECIPIENT='$address_wallet'/' .env

sed -i 's/^DISABLE_P2P_SYNC.*$/DISABLE_P2P_SYNC=true/' .env

# Replace ENABLE_PROPOSER value from "false" to "true"
sed -i 's/^ENABLE_PROVER.*$/ENABLE_PROVER=true/' .env

sed -i 's/^ENABLE_PROPOSER.*$/ENABLE_PROPOSER=true/' .env

# Replace PRIVATE_KEY value with key_wallet
sed -i.bak "s|^L1_PROVER_PRIVATE_KEY=.*|L1_PROVER_PRIVATE_KEY=$key_wallet|" .env

# Replace FEE_RECIPIENT value with address
sed -i.bak "s|^L2_SUGGESTED_FEE_RECIPIENT=.*|L2_SUGGESTED_FEE_RECIPIENT=$address_wallet|" .env

# Replace L1_ENDPOINT_HTTP value with key_wallet
sed -i.bak "s|^L1_ENDPOINT_HTTP=.*|L1_ENDPOINT_HTTP=$link_http|" .env

# Replace L1_ENDPOINT_WS value with link_ws
sed -i.bak "s|^L1_ENDPOINT_WS=.*|L1_ENDPOINT_WS=$link_ws|" .env

sed -i.bak "s|^L1_PROPOSER_PRIVATE_KEY=.*|L1_PROPOSER_PRIVATE_KEY=$key_wallet|" .env

echo ""
echo ""
#Запуск ноды
echo "ЗАПУСК НОДЫ"
echo ""
echo ""
cd ~/simple-taiko-node
docker compose up -d
echo ""
echo "ПОСМОТРЕТЬ РАБОТАЕТ ЛИ НОДА МОЖНО ПО ССЫЛКЕ: $link_etherscan ИЛИ $link_explorer"

