Alternative way to download the shell script:

wget -N http://www.smart-sensor-technology.de/download/install_sst_gateway.sh

then chmod +x install_sst_gateway.sh
then ./install_sst_gateway.sh

in case of Bash ^M error during this last command
     modify file from Windows to Linux format with
     cat install_sst_gateway.sh | tr -d '\r' > install_exec.sh
     then exec ./install_exec.sh
