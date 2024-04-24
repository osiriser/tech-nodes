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
echo " "
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
echo "ЗАРЕГЕСТРИРОВАЛИСЬ НА САЙТЕ?"
echo "https://dashboard.gaganode.com/register?referral_code=zujtwlxmvpbfaci"
echo "Да - y"
echo "Нет - n"
echo "Введите ответ:"
read item
case "$item" in
    y|Y) echo "ВЫ ВВЕЛИ «y», ПРОДОЛЖАЕМ..."
        ;;
    n|N) echo "ВЫ ВВЕЛИ «n», ПЕРЕЙДИТЕ НА САЙТ И ЗАРЕГЕСТРИРУЙТЕСЬ. ЗАТЕМ ЗАПУСТИТЕ УСТАНОВКУ ЗАНОВО..."
        exit 0
        ;;
    *) echo "ВЫ НИЧЕГО НЕ ВВЕЛИ. ВЫПОЛНЯЕМ ДЕЙСТВИЯ ПО УМОЛЧАНИЮ..."
        ;;
esac
echo " "
echo " "
read -p "ВВЕДИТЕ ТОКЕН (ВЗЯТЬ С ЛИЧНОГО КАБИНЕТА НА СТРАНИЦЕ https://dashboard.gaganode.com/install_run):" token
echo " "
echo " "
echo "УДАЛЕНИЕ СТАРОЙ ВЕРСИИ"
cd $HOME
cd app-linux-amd64
sudo ./app service remove
cd $HOME
sudo rm -rf app-linux-amd64
cd apphub-linux-amd64
sudo ./apphub service remove
cd $HOME
sudo rm -rf apphub-linux-amd64
echo " "
echo " "
echo "УСТАНОВКА НОДЫ GAGANODE"
echo " "
echo " "
cd $HOME
sudo apt-get update -y && sudo apt-get -y install curl tar ca-certificates
curl -o apphub-linux-amd64.tar.gz https://assets.coreservice.io/public/package/60/app-market-gaga-pro/1.0.4/app-market-gaga-pro-1_0_4.tar.gz && tar -zxf apphub-linux-amd64.tar.gz && rm -f apphub-linux-amd64.tar.gz && cd ./apphub-linux-amd64 && sudo ./apphub service install
sleep 10
echo ""
echo "ЗАПУСКАЕМ НОДУ"
sudo ./apphub service start
sleep 20
echo " "
sudo ./apps/gaganode/gaganode config set --token=$token
echo " "
echo "ПЕРЕЗАПУСКАЕМ НОДУ"
./apphub restart
sleep 30
echo " "
echo "СТАТУС НОДЫ"
#./app status
./apphub status
echo " "
echo "ЕСЛИ В КОНЦЕ НАПИСАНО [RUNNING], ТО ВСЕ УСТАНОВИЛОСЬ ПРАВИЛЬНО. ПРОВЕРЬТЕ ТАКЖЕ СТАТУС НОДЫ НА СТРАНИЦЕ https://dashboard.gaganode.com/user_node"
echo " "

