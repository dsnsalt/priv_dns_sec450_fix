#! /bin/bash

# DNS fix for private networks that do not allow DNS requests to external servers
# Course Version >= SEC450_2_G01_01

function check_valid_ip() {
	ipRegex='^[0-9]{1,3}(\.[0-9]{1,3}){3}$'
    if [[ $1 =~ $ipRegex ]]
    then
		bIFS=$IFS
		IFS='.'
		read -ra ipArr <<< "$1"
		for octet in "${ipArr[@]}"
		do
			if ! [ $(("$octet" >= 0)) == $(("$octet" <= 255)) ]
			then
				return 0
			fi
		done
		IFS=$bIFS
	else
		return 0
	fi
	return 1
}

labs=("2.1" "5.3")
if [ -z $1 ]
then
    echo "Select action to perform:
        1) Apply lab DNS fix
        2) Undo lab DNS fix"
    read -p "[1/2]:" selection

    case $selection in
        1) fix=true;;
        2) fix=false;;
        *) echo "Invalid selection"; exit 2;;
    esac
else
    fix=true
    usrIP="$1"
fi

for lab in ${labs[@]}
do
    cd /labs/$lab

    if $fix
    then
        if ! [ -f docker-compose.yaml.bk ]
        then
            cp docker-compose.yaml docker-compose.yaml.bk
        fi

        while [ -z "${usrIP}" ] || check_valid_ip "${usrIP}" || 
            [ $(dig @"${usrIP}" sec450.com A +time=1 +tries=1 | grep "connection timed out" -c) -gt 0 ]
        do
            read -p "Specify a valid DNS IP address: " usrIP
        done

        if [ $(grep -c "#Restricted DNS Fix" docker-compose.yaml) -gt 0 ]
        then
            sed -i '/#Restricted DNS Fix/d' docker-compose.yaml
        fi

        sed -i "/dns:/a \      - ${usrIP} #Restricted DNS Fix" docker-compose.yaml
        sed -i "/WEBPASSWORD/i \      DNS1: '${usrIP}' #Restricted DNS Fix \n      DNS2: 'no' #Restricted DNS Fix \n      PIHOLE_DNS_1: '${usrIP}' #Restricted DNS Fix \n      PIHOLE_DNS_2: 'no' #Restricted DNS Fix" docker-compose.yaml
    else
        if [ -f docker-compose.yaml.bk ]
        then
            mv docker-compose.yaml.bk docker-compose.yaml
        fi

        if [ $(grep -c "#Restricted DNS Fix" docker-compose.yaml) -gt 0 ]
        then
            sed -i '/#Restricted DNS Fix/d' docker-compose.yaml
        fi
    fi
done
