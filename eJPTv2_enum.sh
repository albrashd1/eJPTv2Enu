#!/bin/bash

#defining the color of the output
RED='\033[0;31m'
GREEN='\033[0;32m'

#functions definition

#function to split between each scan
function SCAN_SPLIT(){
SERVICE=$1
for ((i=1; i<=114; i++)); do
	echo -n "-"
done

echo -n "$SERVICE scan"

for ((i=1; i<=115; i++)); do
	echo -n "-"
done

echo ""
}

#function contain smb enumeration commands
function SMB_ENUMERATE(){
SCAN_SPLIT "SMB" #indicate start of smb scan
#Handle the ip address which will be pushed as a parameter
IP=$1
echo -e "\n"
echo -e "${RED}[-] ${GREEN}SMB diaclets enumeration: \033[0m" #stop coloring nmap scan
nmap $IP -p445 --script smb-protocols | tail -n +10 | head -n -2 #cut first 10 lines, and the last two, formatting the output
 
echo -e "\n"
echo -e "${RED}[-] ${GREEN}SMB security mode enumeration: \033[0m"
nmap $IP -p445 --script smb-security-mode |tail -n +10 | head -n -2

echo -e "\n"
echo -e "${RED}[-] ${GREEN}SMB session enumeration in case guess account is found: \033[0m"
nmap $IP -p445 --script smb-enum-sessions | tail -n +10 | head -n -2

echo -e "\n"
echo -e "${RED}[-] ${GREEN}SMB shares enumeration without authentication: \033[0m"
nmap $IP -p445 --script smb-enum-shares | tail -n +10 | head -n -2

echo -e "\n"
echo -e "${RED}[-] ${GREEN}SMB users enumeration without authentication: \033[0m"
nmap $IP -p445 --script smb-enum-users | tail -n +10 | head -n -2

echo -e "\n"
echo -e "${RED}[-] ${GREEN}SMB OS discovery: \033[0m"
nmap $IP -p445 --script smb-os-discovery | tail -n +10 | head -n -2

echo -e "\n"
echo -e "${RED}[-] ${GREEN}SMB netBIOS protocol: \033[0m"
nmblookup -A $IP

echo -e "\n"
echo -e "${RED}[-] ${GREEN}SMB enumeration for UDP ports: \033[0m"
nmap $IP -sU -p138,139 --open -sV | tail -n +10 | head -n -2
}

#function for ftp enumerations command
function FTP_ENUMERATE(){
SCAN_SPLIT "FTP" #start of ftp scan
echo -e "\n"
echo -e "${RED}[-] ${GREEN}FTP anpnymous login check: \033[0m"
nmap $IP -p21 --script ftp-anon | tail -n +7 | head -n -3
}

#ssh enumeration commands
function SSH_ENUMERATE(){
SCAN_SPLIT "SSH"
IP=$1
echo -e "\n"
echo -e "${RED}[-] ${GREEN}SSH banner of the machine: \033[0m"
echo "CHECK" | nc $IP 22 | head -n +1 #send check to disconnect from netcat


echo -e "\n"
echo -e "${RED}[-] ${GREEN}SSH algorithms to creat the key of the encryption: \033[0m"
nmap $IP -p22 --script ssh2-enum-algos | tail -n +7 | head -n -3

echo -e "\n"
echo -e "${RED}[-] ${GREEN}SSH RSA key of the machine: \033[0m"
nmap $IP -p22 --script ssh-hostkey --script-args ssh_hostkey=full | tail -n +7 | head -n -3
}
#END OF FUNCTIONS

#print logo
echo "
                                           
										   @@@@@@  @@@           @@    @!       @!
										   @@      @@ @@         @@    @!       @!  
										   @@      @@  @@        @@    @!       @!  
										   @@      @@   @@       @@    @!       @!   
										   @@      @@    @@      @@    @!       @!  
										   @@@@@@  @@     @@     @@    @!       @!  
										   @@      @@      @@    @@    @!       @!   
										   @@      @@       @@   @@    @!       @!  
										   @@      @@        @@  @@    @!       @!   
										   @@      @@         @@ @@    @!       @! 
										   @@@@@@  @@           @@@    @@@@@@@@@@!"

echo -e "\n"
echo "Welcome to eJPTv2 enumeration script!"
echo "This script provide some enumeration commands for SMB, SSH, FTP"

#read IP from user
echo "Please enter the IP address of the target: "
read IP

#check if the user provided the IP, quit if not
if [ -z "$IP" ]; then
	echo -e "${RED}[-]${GREEN} No IP address was provided."
	echo -e "${RED}[-] ${GREEN}Quitting"
	exit
fi

#check if the user input is valid, quit if not
IP_REGEX="^([0-9]{1,3}\.){3}[0-9]{1,3}$" #regular experession for IP
if [[ $IP =~ $ip_regex ]]; then #compare user input to the regular experssion of IP
	echo ""
else
	echo "The IP address provided is not valid! the expected input something like e.g. 192.168.123.15"
	echo "Quitting"
	exit
fi

#start of nmap scan
SCAN_SPLIT "Nmap"
echo "nmap scanning the target for all the ports!"

nmap $IP -T4

echo -e "\n"

#if the user want to continue scanning the services or quit
echo "Do you want to continue? (Y/N)"
read DECISION

#to check the user input is valid (y or n)
CHECK_DECISION=0 #to quit from the while loop
while [ "$CHECK_DECISION" -ne 1 ] #loop if not equal to one
do
	case "$DECISION" in
		[yY])
			echo ""
			CHECK_DECISION=1 #update CHECK_DECISION to exit the loop
			;;
		[nN])
			echo "Quitting"
			exit
			;;
		*)
			echo "Invalid input, please provide valid input"
			echo "Please enter (y or n)"
			read DECISION
			;;
	esac
done
	
#asking the user for service enumerate
echo "What services do you want to enumerate? enter SMB, SSH, or FTP. To enumerate all of them enter ALL, to quit neter QUIT"
read SERVICES

CHECK_SERVICES=0 #to check the user input a valid service

while [ "$CHECK_SERVICES" -ne 1 ]
do

	case "$SERVICES" in
		[Ss][mM][bB])
			SMB_ENUMERATE "$IP"
			CHECK_SERVICES=1
			;;
			
		[Ff][Tt][Pp])
			FTP_ENUMERATE "$IP"
			CHECK_SERVICES=1
			;;
			
		[Ss][Ss][Hh])
			SSH_ENUMERATE "$IP"
			CHECK_SERVICES=1
			;;
		
		[Aa][Ll][Ll])	
			SMB_ENUMERATE "$IP"
			FTP_ENUMERATE "$IP"
			SSH_ENUMERATE "$IP"
			CHECK_SERVICES=1
			;;
		
		[Qq][Uu][Ii][Tt])
			exit
			;;	
		*)
			echo "Invalid input, please provide a valid input"
			echo "What services do you want to enumerate? enter SMB, SSH, or FTP. To enumerate all of them 			enter ALL, to quit enter QUIT"
			read SERVICES
			;;
	esac
done

