#!/bin/bash
# Automatic install 

## check root level
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

## Install required packages
sudo apt-get update
sudo apt-get -y install apache2 php7.0 libusb-1.0-0-dev lsof

## Install sst cpp program
cd /home/pi
sudo rm sst_gateway_program.zip
sudo rm sst_gateway_program2.zip
wget www.smart-sensor-technology.de/download3/sst_gateway_program.zip
sudo unzip -o sst_gateway_program.zip -d /home/pi
sudo rm sst_gateway_program.zip

cd /home/pi
sudo chmod +x wlan_reset.sh
sudo chmod +x wlan_ap0_test.sh
sudo chmod +x script-reset.sh

cd /home/pi/cpp_program
sudo chmod +x run.sh
sudo chmod +x stop.sh
sudo chmod +x check_presence.sh
sudo chmod +x script.sh
sudo chmod +x sst_gw_sw
echo "C Program created and built"

cd /home/pi/event_touch_program
sudo chmod +x script-reset.sh
sudo chmod +x evtest2
#sudo adduser pi www-data

## Install freeboard to client/ethernet connection folder
#sudo mkdir /home/pi/tmp
cd /home/pi
sudo rm install_sst_freeboard.zip
wget www.smart-sensor-technology.de/download/install_sst_freeboard.zip
sudo rm -R /var/www/html
sudo unzip -o install_sst_freeboard.zip -d /var/www
sudo rm install_sst_freeboard.zip

cd /home/pi
sudo rm install_sst_freeboard_ap.zip
wget www.smart-sensor-technology.de/download/install_sst_freeboard_ap.zip
sudo rm -R /var/www/html_access_point
sudo unzip -o install_sst_freeboard_ap.zip -d /var/www
sudo rm install_sst_freeboard_ap.zip
echo "Freeboard directory created"

## change ownership of files for php setup
echo "now modifying ownership of files in folder json_files"
cd /var/www/html/json_files
sudo chown www-data:www-data *.*
cd /var/www/html_access_point/json_files
sudo chown www-data:www-data *.*
echo "modified ownership of json_files/*.* files"

cd /var/www/html/php
sudo chown www-data:www-data *.*
cd /var/www/html_access_point
sudo chown www-data:www-data *.*

## create 70-persistent ap0 rules.d file
cd /home/pi
sudo rm create_70_rule_ap0.zip
wget www.smart-sensor-technology.de/download/create_70_rule_ap0.zip
sudo mkdir /home/pi/pers_rul_write
sudo unzip -o create_70_rule_ap0.zip -d /home/pi/pers_rul_write
cd /home/pi/pers_rul_write
sudo chmod +x create_70_rule_ap0.sh
sudo ./create_70_rule_ap0.sh
sudo rm create_70_rule_ap0.zip
echo "Persistent Rule 70-... created"

echo "Now installing dnsmasq and hostapd"
sudo apt-get -y install dnsmasq hostapd

file=/etc/dnsmasq.conf
word="ap0"
cmd=$(grep -ci "$word" $file)

if [ "$cmd" != "0" ]; then
        echo "ap0 already exists in /etc/dnsmasq.conf"
else
        echo "ap0 does not exist."
		echo "Now appending AP0 data to etc/dnsmasq.conf file"
		echo -e "\ninterface=lo,ap0
no-dhcp-interface=lo,wlan0
bind-interfaces
server=8.8.8.8
domain-needed
bogus-priv
dhcp-range=192.168.10.50,192.168.10.150,12h" >> /etc/dnsmasq.conf
fi

mac="$(ip -o link show dev wlan0 | grep -Po 'ether \K[^ ]*')"
submac=`echo $mac | cut -d":" -f4-6`
mod=${submac//[:]/}
echo $mod

#will use $mod as part of mac in hostapd and wpa_supplicant
var1="ctrl_interface=/var/run/hostapd"
var2="ctrl_interface_group=0"
var3="interface=ap0"
var4="driver=nl80211"
var5="ssid=SST_GATEWAY"
#echo -e $mod >> /etc/hostapd/hostapd.conf
var6="hw_mode=g"
var7="channel=11"
var8="wmm_enabled=0"
var9="macaddr_acl=0"
var10="auth_algs=1"
var11="wpa=2"
var12="wpa_passphrase=sst_gateway_"
#echo -e $mod >> /etc/hostapd/hostapd.conf
var13="wpa_key_mgmt=WPA-PSK"
var14="wpa_pairwise=TKIP CCMP"
var15="rsn_pairwise=CCMP"
target_text="${var1}\n${var2}\n${var3}\n${var4}\n${var5}${mod}\n${var6}\n${var7}\n${var8}\n${var9}\n${var10}\n${var11}\n${var12}${mod}\n${var13}\n${var14}\n${var15}\n"
#echo $target_text >> /etc/hostapd/hostapd.conf
varx="some data"
echo "some data" > /etc/hostapd/hostapd.conf
sed -i "s,$varx,$target_text,g" /etc/hostapd/hostapd.conf

echo "now analyzing file /etc/default/hostapd"
file=/etc/default/hostapd
line_number=$(grep -n "DAEMON_CONF=" /etc/default/hostapd | awk -F  ":" '{print $1}')
var=$(DAEMON_CONF="/etc/hostapd/hostapd.conf")
#sed -i "${line_number}s/.*/$var/" /etc/default/hostapd
sed -i 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd
#awk '{ if (NR == $line_number) print $var; else print $0}' /etc/default/hostapd > /etc/default/new_hostapd2.txt
if [ $[$line_number] -gt "0" ]; then		# line found with string "DAEMON_CONF="
        echo "modified /etc/default/hostapd file"
else
        echo "hostapd file not modified because string #DAEMON_CONF=\"\" not found"
fi

#/etc/wpa/wpa_supplicant.conf file--------------------------------------------------------------------------------------------------------------------
echo "now analyzing file /etc/wpa/wpa_supplicant.conf"
file=/etc/wpa_supplicant/wpa_supplicant.conf
word="AP1"
cmd=$(grep -ci "$word" $file)

if [ "$cmd" != "0" ]; then
        echo "AP1 already exists in /etc/wpa_supplicant/wpa_supplicant.conf - no changes made"
else
        echo "AP1 does not exist."
		echo "Now appending AP1 +AP2 data to /etc/wpa_supplicant/wpa_supplicant.conf file"
		var1="ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev"
		var2="update_config=1"
		var3="country=DE"
		var4="network={"
		var5=" ssid=\"ASUS\""
		var6=" psk=\"0000000000\""
		var7=" id_str=\"AP1\""
		var8="}"
		var9=" ssid=\"SST_GATEWAY"
		#$mod
		var10="\""
		var11=" psk=\"sst_gateway_"
		#$mod
		var12=" id_str=\"AP2\""
		var13="}"
		target_text="${var1}\n${var2}\n${var3}\n\n${var4}\n${var5}\n${var6}\n${var7}\n${var8}\n\n${var4}\n${var9}${mod}${var10}\n${var11}${mod}${var10}\n${var12}\n${var13}\n"
		varx="some data"
		echo "some data" > /etc/wpa_supplicant/wpa_supplicant.conf
		sed -i "s,$varx,$target_text,g" /etc/wpa_supplicant/wpa_supplicant.conf
fi
#/etc/wpa/wpa_supplicant.conf file----END-------------------------------------------------------------------------------------------------------------


#/etc/network/interfaces file--------------------------------------------------------------------------------------------------------------------
echo "now analyzing file /etc/network/interfaces"
file=/etc/network/interfaces
word="auto ap0"
#word2="allow-hotplug ap0"

cmd=$(grep -ci "$word" $file)
#cmd2=$(grep -ci "$word2" $file)

if [ "$cmd" != "0" ]; then
	echo "auto ap0 already exists in /etc/network/interfaces - no changes made"
else
	echo "auto ap0 not found - therefore I assume no changes made yet - will modify /etc/network/interfaces now"
	echo -e "\n
auto lo
auto ap0
auto wlan0
auto eth0
iface lo inet loopback

allow-hotplug ap0
iface ap0 inet static
    address 192.168.10.1
    netmask 255.255.255.0
    hostapd /etc/hostapd/hostapd.conf

allow-hotplug wlan0
iface wlan0 inet manual
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
	
allow-hotplug eth0

iface eth0 inet dhcp
iface AP1 inet dhcp
iface AP2 inet dhcp
" >> /etc/network/interfaces
fi
#/etc/network/interfaces file----END-------------------------------------------------------------------------------------------------------------

#rc.local--------------------------------------------------------------------------------------------------------------------
echo "now adding 4 lines to rc.local file so that AP0 come up before WLAN0"
file=/etc/rc.local
word="sudo ifdown --force ap0"
word2="exit 0"

cmd=$(grep -ci "$word" $file)
cmd2=$(grep -ci "$word2" $file)

if [ "$cmd" != "0" ]; then
	echo "sudo ifdown --force ap0 already exists in rc.local file - no changes made"
else
	echo "sudo ifdown --force ap0 not found - therefore I assume no changes made yet - will modify /etc/rc.local now"
	
	word_wrong_exit="exit 0"
	word_wrong_exit2="will exit 0"

	cmd3=$(grep -ci "$word_wrong_exit" $file)
	cmd4=$(grep -ci "$word_wrong_exit2" $file)
	local_exit_target_text="e x i t 0"	
	local_exit_target_text2="will e x i t 0"
	if [ "$cmd3" != "0" ]; then
		echo "found string exit 0 in paranthesis" 
		echo "will replace \"exit 0\" first now so that rest of script works fine" 
		sed -i "s,$word_wrong_exit,$local_exit_target_text,g" /etc/rc.local 	#replace ""exit 0"" in comments at top of file so that this will not be found with sed below
	else
		echo "\"exit 0\" in parenthesis not found"
		if [ "$cmd4" != "0" ]; then
			echo "found \"will exit 0\" in comments"
			echo "will replace this first now so that rest of script works fine"
			sed -i "s,$word_wrong_exit2,$local_exit_target_text2,g" /etc/rc.local 	#replace "will exit 0" in comments at top of file so that this will not be found with sed below
		else
			echo "\"will exit 0\" not found"
		fi
	fi
	
	var0_1="sudo sysctl -w net.ipv4.ip_forward=1"
	var0_2="sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE"
	var0_3="sudo systemctl restart dnsmasq"
		
	var1="sudo ifdown --force wlan0"
	var2="sudo ifdown --force ap0"
	var2_2="sleep 3"
	var3="sudo ifup ap0"
	#same string used here again 3 sec
	var4="sudo ifup wlan0"
	var4_1="sleep 1"
	var5="cd /home/pi/cpp_program"
	var6="sudo ./script.sh \&"
	var7="cd /home/pi/event_touch_program"
	var8="./evtest2 /dev/input/event0 &"
	var_exit="exit 0"
	#target_text="${var0_1}\n${var0_2}\n${var0_3}\n\n${var1}\n${var2}\n${var2_2}\n${var3}\n${var2_2}\n${var4}\n${var4_1}\n${var5}\n${var6}\n${var7}\n${var8}\n\n${var_exit}"
	target_text="${var0_1}\n${var0_2}\n${var0_3}\n\n${var5}\n${var6}\n${var7}\n${var8}\n${var1}\n${var2}\n${var2_2}\n${var3}\n${var2_2}\n${var4}\n${var4_1}\n\n${var_exit}"
	#3 lines for forwarding 
	#then new linefeed 
	#wlan down, ap down, sleep 3, up ap, sleep 3, up wlan, 
	#new linefeed then 
	#start cpp program, then 
	#"exit 0"
	sed -i "s,$word2,$target_text,g" /etc/rc.local			#replace "exit 0" with longer target string generated above
fi
#rc.local-end-------------------------------------------------------------------------------------------------------------------

#modify /etc/sudoers file -------------------------------for www-data privilegues to execute run.sh and stop.sh
echo "now analyzing file /etc/sudoers"
file=/etc/sudoers
word="/home/pi/cpp_program/run.sh"
cmd=$(grep -ci "$word" $file)

if [ "$cmd" != "0" ]; then
	echo "/home/pi/cpp_program/run.sh already exists in /etc/sudoers - no changes made"
else
	echo "/home/pi/cpp_program/run.sh not found - therefore I assume no changes made yet - will modify /etc/sudoers now"
	echo -e "\n
www-data ALL=(ALL) NOPASSWD: /home/pi/cpp_program/run.sh
www-data ALL=(ALL) NOPASSWD: /home/pi/cpp_program/stop.sh
" >> /etc/sudoers
fi
#modify /etc/sudoers file---END--------------------for www-data privilegues to execute run.sh and stop.sh

#modify /etc/apache2/sites-available files ----------------------------------------------------------
echo "now analyzing files /etc/apache2/sites-available"
cd /etc/apache2/sites-available
file="001-access-point.conf"
if [ -f "$file" ]
then
	echo "$file 001-access-point.conf found."
else
	echo "$file not found. Will create it."
	sudo cp 000-default.conf 001-access-point.conf
fi
#target_word_to_replace="<VirtualHost *:80>"
#var1="<VirtualHost 192.168.10.*:80>"
#target_text="${var1}\n"
#sed -i "s/$target_word_to_replace/$target_text/g" "/etc/apache2/sites-available/001-access-point.conf"			#replace "exit 0" with longer target string generated above
sed -i "s/VirtualHost \*:80/VirtualHost 192.168.10.\*:80/g" /etc/apache2/sites-available/001-access-point.conf


target_root_dir_to_replace="DocumentRoot /var/www/html"
this_not_to_find="html_access_point"

cmd=$(grep -ci "$this_not_to_find" $file)

if [ "$cmd" != "0" ]; then
	echo "html_access_point directory found defined in 001-access-point.conf already"
else
	echo "html_access_point not defined yet in 001-access-point.conf - will do now."
	var2="DocumentRoot /var/www/html_access_point"
	target_text="${var2}\n"
	sed -i "s,$target_root_dir_to_replace,$target_text,g" /etc/apache2/sites-available/001-access-point.conf			#replace "exit 0" with longer target string generated above
fi
	
file="002-client.conf"
if [ -f "$file" ]
then
	echo "$file 002-client.conf found."
else
	echo "$file not found. Will create it."
	sudo cp 000-default.conf 002-client.conf
fi
#target_word_to_replace="<VirtualHost *:80>"
#var1="<VirtualHost 192.168.3.*:80>"
#target_text="${var1}\n"
#sed -i "s/$target_word_to_replace/$target_text/g" "/etc/apache2/sites-available/002-client.conf"			#replace "exit 0" with longer target string generated above
sed -i "s/VirtualHost \*:80/VirtualHost 192.168.3.\*:80/g" /etc/apache2/sites-available/002-client.conf
#modify /etc/apache2/sites-available files -----END-----------------------------------------------------

#modify /etc/apache2/sites-enabled files ----------------------------------------------------------
echo "now analyzing files /etc/apache2/sites-enabled"
cd /etc/apache2/sites-enabled
file="001-access-point.conf"
if [ -f "$file" ]
then
	echo "$file 001-access-point.conf found."
else
	echo "$file not found. Will create it."
	sudo cp 000-default.conf 001-access-point.conf
fi
#target_word_to_replace="<VirtualHost *:80>"
#var1="<VirtualHost 192.168.10.*:80>"
#target_text="${var1}\n"
sed -i "s/VirtualHost \*:80/VirtualHost 192.168.10.1:80/g" /etc/apache2/sites-enabled/001-access-point.conf


target_root_dir_to_replace="DocumentRoot /var/www/html"
this_not_to_find="html_access_point"

cmd=$(grep -ci "$this_not_to_find" $file)

if [ "$cmd" != "0" ]; then
	echo "DocumentRoot /var/www/html_access_point directory found defined in 001-access-point.conf already"
else
	echo "DocumentRoot /var/www/html_access_point not defined yet in 001-access-point.conf - will do now."
	var2="DocumentRoot /var/www/html_access_point"
	target_text="${var2}\n"
	sed -i "s,$target_root_dir_to_replace,$target_text,g" /etc/apache2/sites-enabled/001-access-point.conf			
fi
	
file="002-client.conf"
if [ -f "$file" ]
then
	echo "$file 002-client.conf found."
else
	echo "$file not found. Will create it."
	sudo cp 000-default.conf 002-client.conf
fi
#target_word_to_replace="<VirtualHost *:80>"
#var1="<VirtualHost 192.168.3.*:80>"
#target_text="${var1}\n"

sed -i "s/VirtualHost \*:80/VirtualHost 192.168.3.\*:80/g" /etc/apache2/sites-enabled/002-client.conf
#modify /etc/apache2/sites-enabled files -----END-----------------------------------------------------

#sudo service apache2 restart

sudo crontab /home/pi/crontab.bak #overwrite crontab file

sudo reboot
## add user to group
## sudo adduser {username} www-data

## https://github.com/larsks/gpio-watch
## download gpip-watch
## make
## sudo make install
## example: gpio-watch -e falling switch 21

## chown root:root run.sh
## chown root:root stop.sh

## sudoers file under /etc/
## www-data ALL=(ALL) NOPASSWD: ...

## raspi 2 B v1.1 MAC: 00:87:35:1c:75:2f

