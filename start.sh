#!/bin/bash
# By Dimokus (https://t.me/Dimokus)
source $HOME/.bashrc
TZ=Europe/Kiev
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
apt-get update
apt-get install -y wget tar nginx unzip xz-utils make gcc jq pwgen
sleep 5
source $HOME/.bashrc
###################### SSH #########################
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config ;
SSHPASS=$(pwgen -s 15 1)
(echo $PASS; echo $PASS) | passwd root
service ssh start
####################################################
LATEST=$(curl -s https://api.github.com/repos/SoftEtherVPN/SoftEtherVPN_Stable/releases/latest | jq -r '.assets[] | select(.name|match("linux-x64-64bit.tar.gz$")) | select(.name|match("vpnserver")) | .browser_download_url')
wget $LATEST
tar xvzf softether-vpnserver*
rm softether-vpnserver*
cd vpnserver
make
sleep 10
./vpnserver start
sleep 10
./vpnserver stop
sleep 20
ls
sleep 10
CONFIG=/vpnserver/vpn_server.config
line=$(grep -A 19 -n DDnsClient $CONFIG | grep -m1 -B19 "}" | grep "bool Disabled" | awk -F "-" '{print $1}')
sed -i $line's/false/true/' $CONFIG
line=$(grep -n DisableJsonRpcWebApi $CONFIG |awk -F ":" '{print $1}')
sed -i $line's/false/true/' $CONFIG
ADMINPASS=$(pwgen -s 15 1)
HUBPASS=$(pwgen -s 15 1)
PSKPASS=$(pwgen -s 15 1)
sleep 10
./vpnserver start
sleep 10
  ./vpncmd /SERVER 127.0.0.1 /CMD SstpEnable no
  ./vpncmd /SERVER 127.0.0.1 /CMD SyslogDisable
  ./vpncmd /SERVER 127.0.0.1 /CMD ServerCipherSet ECDHE-RSA-AES128-GCM-SHA256
  
  ./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD SecureNatEnable
  ./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD LogDisable packet
  
  ./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD UserCreate $USER /GROUP:none /REALNAME:$USER /NOTE:none
  { echo $USERPASS; echo $USERPASS; } | ./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD UserPasswordSet $USER
  
  # To enable Anonymous mode (any user password will work):
  #./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD UserAnonymousSet $USER
  
  # specify the default hub so you don't need to specify "user@<hub name>"
  ./vpncmd /SERVER 127.0.0.1 /CMD IPsecEnable /L2TP:yes /L2TPRAW:no /ETHERIP:no /PSK:$PSKPASS /DEFAULTHUB:DEFAULT

  { echo $ADMINPASS; echo $ADMINPASS; } | ./vpncmd /SERVER 127.0.0.1 /ADMINHUB:DEFAULT /CMD ServerPasswordSet
  { echo $HUBPASS; echo $HUBPASS; } | ./vpncmd /SERVER 127.0.0.1 /HUB:DEFAULT /CMD SetHubPassword

  # OpenVPN config
  ./vpncmd /SERVER /PASSWORD:$ADMINPASS localhost /CMD OpenVpnMakeConfig openvpn

 unzip openvpn.zip '*_openvpn_remote_access_l3.ovpn'
 
cat *_openvpn_remote_access_l3.ovpn | grep -Ev '^\#|^;' | strings | sed 's/^remote .*/remote <SET YOUR AKASH INGRESS URI HERE> <SET YOUR AKASH PORT MAPPED TO 443>/g' | sed 's/^proto udp/proto tcp/g' | sed 's/^cipher .*/cipher AES-256-CBC/g' > /var/www/html/VPN_on_Akash_Network.ovpn

 rm /var/www/html/index.nginx-debian.html
 cat > /var/www/html/index.html <<EOF 
 <!DOCTYPE html>
 <meta charset="utf-8">
<html>
<head>
<title>Welcome to VPN on Akash!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to VPN on Akash!</h1>
<p>VPN server successfully installed!</p>

<p>Download the OpenVPN connection
<a href="VPN_on_Akash_Network.ovpn">certificate</a>.<br/>
<p><em>This page will be removed in 1 hour.</em></p>
<p><em>Thank you for using Akash Network!</em></p>
<br/>
<br/>

<h1>Добро пожаловать в VPN на Akash!</h1>
<p>VPN сервер успешно установлен!</p>

<p>Скачайте
<a href="VPN_on_Akash_Network.ovpn">сертификат</a> подключения по OpenVPN.<br/>
<p><em>Страница удалится через 1 час.</em></p>
<p><em>Спасибо что выбрали Akash Network!</em></p>

</body>
</html>
EOF
service nginx start
echo ===========================================
echo === Развертывание сервера VPN завершено ===
echo ===== VPN Server Deployment Completed =====
echo ===========================================
echo ============= USER VPN: $USER =============
echo ========= PASSWORD USER VPN: $USERPASS ====
echo ==== Admin server password: $ADMINPASS ====
echo ========= Hub password: $HUBPASS ==========
echo ========= PSK password: $PSKPASS ==========
echo ===========================================
echo ===========================================
echo ============ SSH user:"root" ==============
echo ============ SSH password: $SSHPASS =======
sleep 3600
rm /var/www/html/index.html /var/www/html/VPN_on_Akash_Network.ovpn
service nginx stop
