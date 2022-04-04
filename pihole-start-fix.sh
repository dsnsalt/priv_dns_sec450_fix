#!/bin/bash

# DNS fix for private networks that do not allow DNS requests to external servers
# Course Version: SEC450_2_G01_01

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

function helper() {
    echo -e "Add an alternative DNS server to your pi-hole configuration.\n"
    case $1 in
        override)
            echo -e "Usage: pihole-start-fix.sh OPTION [IP-ADDRESS]\n"
            echo "override [IP-ADDRESS]     Override the default use of the VM's default DNS server and specify the DNS server IPv4 address to use.";;
        *)
            echo "Usage: pihole-start-fix.sh OPTION [IP-ADDRESS]"
            echo -e "Options:\n"
            echo "apply                     Apply the fix using the VM's default DNS server. Default option."
            echo "reset                     Remove the defined DNS servers and use the default configuration."
            echo "override [IP-ADDRESS]     Override the default use of the VM's default DNS server and specify the DNS server IPv4 address to use.";;
    esac
}

# Check if option has been defined. If not, assume the apply action
if [ ! -z $1 ]
then
    # Loop through the options to use full word arguments instead of letter
    while [ $# -gt 0 ]
    do
        case $1 in
            apply | reset) 
                # Ensure the apply and reset options are not followed by an argument
                if ! [ -z $2 ]
                then
                    # If the argument is not help, display an error and then display the help
                    if ! ([ $2 = "help" ] || [ $2 = "--help" ] || [ $2 = "-h" ])
                    then
                        echo -e "$1 option does not use an option.\n"
                    fi
                    helper
                    exit
                else
                    action=$1
                fi;;
            override) 
                # Check if there is a argument following override option
                # If there isn't or the argument calls help, display the help
                if [ -z $2 ] || [ $2 = "help" ] || [ $2 = "--help" ] || [ $2 = "-h" ]
                then
                    if [ -z $2 ]
                    then
                        echo -e "IP argument cannot be empty"
                    fi
                    helper "override"
                    exit
                else
                    action="$1"
                    usrIP=$2
                    break
                fi;;
            
            *) helper
                exit;;
        esac
        shift
    done
else
    action="apply"
fi

# Lab array
labs=("2.1" "5.3")

# Get the DNS server used by the VM
if [ $action = "apply" ]
then
    usrIP=$(systemd-resolve --status | grep -m1 -Po 'DNS Servers: \K(\d{1,3}\.){3}\d{1,3}')
fi


if [ $action != "reset" ]
then
    # Ensure the DNS IP is a valid IPv4 IP and that it is a DNS server
    # If fails any test ask for a new IP from the user
    while [ -z $usrIP ] || check_valid_ip $usrIP || 
        [ $(dig @"$usrIP" sec450.com A +time=1 +tries=1 | grep "connection timed out" -c) -gt 0 ]
    do
        echo "IP cannot be used or DNS server cannot be reached."
        read -p "Specify a valid DNS address: " usrIP
    done
    # Ensure that the IP is not used as a DNS server already
    if [ $(egrep -A5 "dns|WEBPASSWORD" /labs/2.1/docker-compose.yaml /labs/5.3/docker-compose.yaml | grep -iv "#Restricted DNS Fix" | grep $usrIP -c) -gt 0 ]
    then
        echo "Cannot use $usrIP as the DNS server, it already exists as a DNS server in the lab config file"
        exit
    fi
fi

# Loop through the labs array and implement fix in each lab
for lab in ${labs[@]}
do
    cd /labs/$lab
    if [ $action == "apply" ] || [ $action == "override" ]
    then
        # Create backup only if a backup does not already exist
        if ! [ -f docker-compose.yaml.bk ]
        then
            cp docker-compose.yaml docker-compose.yaml.bk
        fi

        # Remove previous instances of the fix
        # Find instance of "#Restricted DNS Fix" comment and delete the line on that
        if [ $(grep -c "#Restricted DNS Fix" docker-compose.yaml) -gt 0 ]
        then
            sed -i '/#Restricted DNS Fix/d' docker-compose.yaml
        fi

        # Add lines to define DNS config
        sed -i "/dns:/a \      - $usrIP #Restricted DNS Fix" docker-compose.yaml
        sed -i "/WEBPASSWORD/i \      DNS1: '$usrIP' #Restricted DNS Fix \n      DNS2: 'no' #Restricted DNS Fix \n      PIHOLE_DNS_1: '$usrIP' #Restricted DNS Fix \n      PIHOLE_DNS_2: 'no' #Restricted DNS Fix" docker-compose.yaml

        echo "Fix applied to $lab"
    else
        # Replace current config with backups created during initial fix
        if [ -f docker-compose.yaml.bk ]
        then
            mv docker-compose.yaml.bk docker-compose.yaml
        fi

        # Ensure DNS definitions are deleted in the case the backups were corrupted
        if [ $(grep -c "#Restricted DNS Fix" docker-compose.yaml) -gt 0 ]
        then
            sed -i '/#Restricted DNS Fix/d' docker-compose.yaml
        fi
        
        echo "Fix has been removed from $lab"
    fi
done