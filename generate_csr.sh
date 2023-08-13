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

#Select Action
echo "${green} 1. Generate CSR ${reset}"
echo "${green} 2. Create PFX Certificate ${reset}"
echo -n "Select Action: ${yellow}${bold}"
read -r action

while [ -z $action ]; do
        echo -n "${red}[Mandatory]${reset}Select Action: ${yellow}"
	read -r action
done

while [[ "$action" != "1" && "$action" != "2" ]]; do
	echo -n "${red}[Input not valid]${reset} Please input action (1 or 2): ${yellow}"
	read -r action
done

#Generate CSR
if [ "$action" = "1" ] 
then
	#Required
 	ssl_directory="/tmp/openssl"
 	recent_directory=$(ls -td -- $ssl_directory/*/ 2>/dev/null | head -n 1 | sed 's#/##')
	recent_directory_name=$(basename "$recent_directory")

	echo -n "${red}[Mandatory]${reset}Domain Name [${yellow}$recent_directory_name${reset}]: ${yellow}"
	read -r domain
	echo "${reset}"
	# If the input is empty, use the most recent directory name if available
	if [ -z "$domain" ]; then
		if [ -n "$recent_directory_name" ]; then
			domain="$recent_directory_name"
		else

			while [ -z "$domain" ]; do
				echo -n "${red}[Mandatory]${reset}Domain Name: ${yellow}"
				read -r domain
				echo "${reset}"
			done
		fi
	fi

	echo "${reset}Enter hostname of your server/apps (e.g: ${cyan}webmail${reset})"
	echo -n "Hostname: ${yellow}"
	read -r hostname
	while [ -z $hostname ]; do
		echo -n "${red}[Mandatory]${reset}Hostname: ${yellow}"
		read -r hostname
	done

	echo "${reset}[Optional] Enter IP Address of your server/apps. Separate multiple IP by comma (e.g: ${cyan}192.168.1.1,192.168.1.2${reset})"
	echo -n "${reset}IP Address: ${yellow}"
	read -r listip
 	ip=$(echo "$listip" | sed 's/\([0-9.]\+\)/IP:\1/g')

	echo "${reset}[Optional] Enter your extra dns (SAN) separated by comma ${cyan}mail.$domain,webmail.$domain,smtp.$domain${reset}"
	echo -n "Extra DNS (SAN): ${yellow}"
	read -r dns
	dns1=$(echo "$dns" | sed 's/,/,DNS:/g')
	dns1=$(echo "$dns1" | sed 's/^/DNS:/g')
	echo "${reset}"
	fqdn=$hostname.$domain
	cn=$fqdn
	if [ -z "$ip" ] && [ -z "$dns" ]
	then
		SAN="DNS:$fqdn,DNS:$hostname"
	elif [ -z "$ip" ]
	then
		SAN="DNS:$fqdn,DNS:$hostname,$dns1"
	elif [ -z "$dns" ]
	then
		SAN="DNS:$fqdn,DNS:$hostname,$ip"
	else
		SAN="DNS:$fqdn,DNS:$hostname,$dns1,$ip"
	fi
	echo "FQDN = "$fqdn
	echo "SAN = "$SAN

	#Change to your company details
	country=ID
	state=Jakarta
	locality=DKI
	organization="IT Security"
	organizationalunit=AnyWhere
	email=admin@$domain

	# SSL Home Directory
	mkdir -p $ssl_directory/$domain
	conf=$ssl_directory/.conf
	if [ ! -f $conf ]
	then
		wget https://raw.githubusercontent.com/heronqsilalahi/csr/main/csr.conf -O $conf
	fi
	#Generate Key & CSR
	echo "${reset}"
	printf "${yellow}Generating Private Key & CSR for $fqdn\n${reset}"
	echo "${cyan}"
	set -x
	openssl req -newkey rsa:2048 -nodes -keyout $ssl_directory/$domain/$hostname.key -out $ssl_directory/$domain/$hostname.csr -new -sha256 \
		-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=""$cn""/emailAddress=$email" \
		-reqexts SAN -config <(cat $ssl_directory/.conf <(printf "[SAN]\nsubjectAltName=""$SAN"))
	#openssl req -out sslcert.csr -newkey rsa:2048 -nodes -keyout private.key -config san.cnf
	openssl req -in $ssl_directory/$domain/$hostname.csr -noout -text
	chmod 400 $ssl_directory/$domain/$hostname.key

	set +x
	echo "${cyan}Your Private Key :$ssl_directory/$domain/$hostname.key ${reset}${green}"
	cat $ssl_directory/$domain/$hostname.key
	echo "${reset}"
	echo "${cyan}Your CSR  :$ssl_directory/$domain/$hostname.csr ${reset}${green}"
	cat $ssl_directory/$domain/$hostname.csr
	echo "${reset}"
	cd $ssl_directory/$domain

#Create PFX Ceertificate
elif [ "$action" = "2" ] 
then
	echo "${reset}${cyan}You will create PKCS12 (PFX) certificate from existing private key & public certificate.${reset})"
	
	echo -n "${reset}Certificate file name (e.g: ${cyan}mail.cer or /home/user/folder/mail.cer${reset}) : ${yellow}"
	read -r public
	while [ -z $public ]; do
		echo -n "${red}[Mandatory]${reset}Certificate file name: ${yellow}"
		read -r public
	done
	while [[ ! -f $public ]]; do
		echo -n "${red}[File not found.]${reset}Certificate file name (or full path): ${yellow}"
		read -r public
	done
        host="${public##*/}"
        host="${host%.*}"

	echo -n "${reset}Private key file name (e.g: ${cyan}mail.key or /home/user/folder/mail.key${reset}): ${yellow}"
	read -r private
	while [ -z $private ]; do
		echo -n "${red}[File not found.]${reset}Private key file name: ${yellow}"
		read -r private
	done
	while [[ ! -f $private ]]; do
		echo -n "${red}[File not found.]${reset}Private key file name (or full path): ${yellow}"
		read -r private
	done
	
	echo -n "${reset}Output file name [${green}$host.pfx ${reset}]: ${yellow}"
	read -r output
	while [ -z $output ]; do
		output=$host."pfx"
	done	
	

	unset secret
	echo -n "${reset}New password for PFX certificate (e.g: ${cyan}Secr3T${reset}) : ${yellow}"
	while IFS= read -p "$prompt" -r -s -n 1 char ; do
		# Enter - accept password
		if [[ $char == $'\0' ]] ; then
			break
		fi
		# Backspace
		if [[ $char == $'\177' ]] ; then
			prompt=$'\b \b'
			secret="${password%?}"
		else
			prompt='*'
			secret+="$char"
		fi
	done
	echo "${reset}"
	while [ -z $secret ]; do
		unset secret
		echo -n "${red}[Mandatory]${reset}Input password: ${yellow}"
        	while IFS= read -p "$prompt" -r -s -n 1 char ; do
                        # Enter - accept password
                        if [[ $char == $'\0' ]] ; then
                                break
                        fi
                        # Backspace
                        if [[ $char == $'\177' ]] ; then
                                prompt=$'\b \b'
                                secret="${password%?}"
                        else
                                prompt='*'
                                secret+="$char"
                        fi
        	done
		echo "${reset}"
	done
	
	#Gererate file
	set -x
	openssl pkcs12 -inkey $private -in $public -passout pass:$secret -name $host -export -out $output
	set +x

# Invalid	
else
	echo "${reset}${red}${bold}Good Bye!{reset})"
fi

echo "${reset}"
printf "╔═╗╔╗╔╔╦╗ \n"
printf "║╣ ║║║ ║║ \n"
printf "╚═╝╝╚╝═╩╝ \n"
