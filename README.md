Use Hardware Raspberry 1, 2, 3 or zero

Use Software Raspberry image:
2018-04-18-raspbian-stretch-lite
or 
2018-10-09-raspbian-stretch-lite

1. sudo su
2. raspi-config

SSH enable<br>
Set Keyboard Layout 

Installation process:
still as sudo su

(for setup with AP and WLAN)<br>
1. wget -N http://www.smart-sensor-technology.de/download/install_sst_gateway3.sh<br>

(for setup with Ethernet Connection only)<br>
2. wget -N http://www.smart-sensor-technology.de/download/install_sst_gateway_eth.sh<br>

3. chmod +x install_sst_gateway3.sh						
4. ./install_sst_gateway3.sh		<br>
If you want to see all log data during installation install like this<br>
4.1 ./install_sst_gateway3.sh >> log.txt			<br>
4.2 view data with nano log.txt
