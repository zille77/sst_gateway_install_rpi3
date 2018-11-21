Use Raspberry 1, 2, 3 or zero

Use RPI image:
2018-04-18-raspbian-stretch-lite
or 
2018-10-09-raspbian-stretch-lite

1. sudo su
2. raspi-config

SSH enable
Set Keyboard Layout 

Installation process:
still as sudo su
(for setup with AP and WLAN)

1. wget -N http://www.smart-sensor-technology.de/download/install_sst_gateway3.sh

(for setup with Ethernet Connection only)

2. wget -N http://www.smart-sensor-technology.de/download/install_sst_gateway_eth.sh		

3. chmod +x install_sst_gateway3.sh						
4. ./install_sst_gateway3.sh		
If you want to see all log data during installation install like this
4.1 ./install_sst_gateway3.sh >> log.txt			
4.2 view data with nano log.txt
