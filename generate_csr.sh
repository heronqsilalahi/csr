#!/bin/bash
#COLOR
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
purple=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
reset=`tput sgr0`
bgred=`(tput setab 1)`
bggreen=`(tput setab 2)`
bgyellow=`(tput setab 3)`
bgblue=`(tput setab 4)`
bgpurple=`(tput setab 5)`
bgcyan=`(tput setab 6)`
bgwhite=`(tput setab 7)`
bold=`tput bold`
bell=`tput bel`

printf "╔═╗╔╦╗╔═╗╦═╗╔╦╗ \n"
printf "╚═╗ ║ ╠═╣╠╦╝ ║  \n"
printf "╚═╝ ╩ ╩ ╩╩╚═ ╩  \n"

#Required
echo "${reset}Enter your domain name (e.g: ${cyan}vistakom.local${reset})"
echo -n "Domain Name: ${yellow}"
read -r domain
while [ -z $domain ]; do
        echo -n "${red}[Mandatory]${reset}Domain Name: ${yellow}"
        read -r domain
done
echo "${reset}Enter hostname of your server/apps (e.g: ${cyan}webmail${reset})"
echo -n "Hostname: ${yellow}"
read -r hostname
while [ -z $hostname ]; do
        echo -n "${red}[Mandatory]${reset}Hostname: ${yellow}"
        read -r hostname
done

echo "${reset}[Optional] Enter IP Address of your server/apps (e.g: ${cyan}192.168.1.1${reset})"
echo -n "${reset}IP Address: ${yellow}"
read -r ip

echo "${reset}[Optional] Enter your extra dns with format ${cyan}DNS:mail.vistakom.local,DNS:webmail.vistakom.local,DNS:smtp.vistakom.local${reset}"
echo -n "Extra DNS: ${yellow}"
read -r dns
echo "${reset}"
fqdn=$hostname.$domain
cn=$fqdn
if [ -z "$ip" ] && [ -z "$dns" ]
then
        SAN="DNS:$fqdn,DNS:$hostname"
elif [ -z "$ip" ]
then
        SAN="DNS:$fqdn,DNS:$hostname,$dns"
elif [ -z "$dns" ]
then
        SAN="DNS:$fqdn,DNS:$hostname,IP:$ip"
else
        SAN="DNS:$fqdn,DNS:$hostname,$dns,IP:$ip"
fi
echo "FQDN = "$fqdn
echo "SAN = "$SAN

#Change to your company details
country=ID
state=Jakarta
locality=DKI
organization=MylabCert
organizationalunit=Virtual
email=admin@$domain

# SSL Home Directory
ssl_directory="/var/openssl"
mkdir -p $ssl_directory/$domain
conf=$ssl_directory/.conf
if [ ! -f $conf ]
then
    wget https://raw.githubusercontent.com/heronqsilalahi/csr/main/csr.conf -O $conf
fi
#Generate Key & CSR
echo "${reset}"
printf "\n====Generating Private Key & CSR for $fqdn====\n"
echo "${cyan}"
set -x
openssl req -newkey rsa:2048 -nodes -keyout $ssl_directory/$domain/$fqdn.key -out $ssl_directory/$domain/$fqdn.csr -new -sha256 \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=""$cn""/emailAddress=$email" \
    -reqexts SAN -config <(cat $ssl_directory/.conf <(printf "[SAN]\nsubjectAltName=""$SAN"))
#openssl req -out sslcert.csr -newkey rsa:2048 -nodes -keyout private.key -config san.cnf
openssl req -in $ssl_directory/$domain/$fqdn.csr -noout -text
chmod 400 $ssl_directory/$domain/$fqdn.key

set +x
echo "${cyan}Your Private Key :$ssl_directory/$domain/$fqdn.key ${reset}${green}"
cat $ssl_directory/$domain/$fqdn.key
echo "${reset}"
echo "${cyan}Your CSR  :$ssl_directory/$domain/$fqdn.csr ${reset}${green}"
cat $ssl_directory/$domain/$fqdn.csr
echo "${reset}"
cd $ssl_directory/$domain
printf "╔═╗╔╗╔╔╦╗ \n"
printf "║╣ ║║║ ║║ \n"
printf "╚═╝╝╚╝═╩╝ \n"
