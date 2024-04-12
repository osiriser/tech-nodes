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
echo " "
echo " "
echo "УДАЛЕНИЕ СТАРОЙ ВЕРСИИ НОДЫ MUON"
cd $HOME/muon-node
sudo docker-compose down
cd $HOME
sudo rm -rf muon-node
sudo docker stop muon-node redis mongo 
sudo docker rm muon-node redis mongo
sudo docker image prune 
sudo rm muon-node-js -rf
echo " "
echo " "
echo "НАЧИНАЕМ УСТАНОВКУ НОДЫ MUON"
sudo apt update && sudo apt upgrade -y
sudo apt install wget pip git systemctl cargo  -y
echo " "
echo " "

#Uninstall old versions Docker
#sudo apt-get remove docker docker-engine docker.io containerd runc


#Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudo apt-get install ca-certificates && curl &&  gnupg -y
#Add Docker’s official GPG key:
sudo mkdir -m 0755 -p /etc/apt/keyrings 
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#Set up the repository:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list 

sudo apt-get update -y
sudo apt-get install docker-compose -y
#Install Docker Engine, containerd, and Docker Compose
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

#inslall need packets for docker
sudo snap install docker -y
sudo apt  install podman-docker -y
sudo apt  install docker.io -y
sudo service docker start
sudo apt-get update -y

#firewall rules
sudo ufw allow ssh
sudo ufw allow 8000
sudo ufw allow 4000
sudo iptables -t filter -A INPUT -p tcp --dport 8000 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 4000 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT

cd $HOME
mkdir muon-node
cd $HOME/muon-node
sudo curl -o docker-compose.yml 'https://raw.githubusercontent.com/muon-protocol/muon-node-js/testnet/docker-compose-pull.yml'
sudo docker-compose up -d
sleep 60
sudo docker start muon-node redis mongo
sleep 60
# Get name of interface frome default route
interface=$(ip route show default | awk '/default/ {print $5}')

# Get IP-address of interface
ip_address=$(ip addr show dev $interface | awk '/inet / {print $2}' | cut -d '/' -f 1)

echo "НЕОБХОДИМЫЕ ДАННЫЕ (IP-address, Node_address и Peer_ID) ДЛЯ ПОДКЛЮЧЕНИЯ НОДЫ НА САЙТЕ alice.muon.net:"
echo " "
echo "ВАШ IP-АДРЕС ИНТЕРФЕЙСА $interface: $ip_address"
echo " "
echo " "

response=$(curl -s "http://$ip_address:8000/status")

address=$(echo $response | sed -n 's/."address":"\([^"]*\)".*/\1/p' | head -1)
peerId=$(echo $response | sed -n 's/.*"peerId":"\([^"]*\)".*/\1/p' | head -1)

echo "ВАШ Node_Address: $address"
echo "ВАШ Peer_Id: $peerId"
echo " "
echo " "
echo "ДАННЫЕ и СТАТУС НОДЫ:"
sudo curl "http://$ip_address:8000/status"
echo " "
echo " "
echo "ДАЛЛЕЕ НЕОБХОДИМО ПЕРЕЙТИ НА САЙТ https://alice.muon.net/"
echo " "
echo " "
  
FILE=/root/backup.json
now=$(date)
echo "$now"
if [[ -f "$FILE" ]]; then
  sudo docker exec -it muon-node ./node_modules/.bin/ts-node ./src/cmd keys backup > "backup $now.json" # Если бэкап существует создаем новый бэкап с датой создания
  echo "СОЗДАЕМ НОВЫЙ БЭКАП"
else 
 sudo docker exec -it muon-node ./node_modules/.bin/ts-node ./src/cmd keys backup > backup.json  # Создаем первичный бэкап
 echo "СОЗДАЕМ ПЕРВИЧНЫЙ БЭКАП"
fi
