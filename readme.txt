download the sh file and execute it on Debian Stretch, e.g. Raspi Zero W or Raspberry Pi 3

Update about new device

Install (Thanks Tass to fix this guide)

ssh into your raspiberry

git clone https://github.com/zille77/wsst_gateway_install_rpi3
chmod +x install.sh
sudo apt-get update
sudo ./install.sh
sudo restart
