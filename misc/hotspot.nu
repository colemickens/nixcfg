#!/usr/bin/env nu

sudo cp /etc/iwd/main.conf /etc/iwd/main.conf1
sudo rm /etc/iwd/main.conf
sudo cp /etc/iwd/main.conf1 /etc/iwd/main.conf
echo "EnableNetworkConfiguration=true" | sudo tee /etc/iwd/main.conf out+err> /dev/null

sudo sysctl -w net.ipv4.ip_forward=1
sudo systemctl restart iwd

sudo iwctl device wlan0 set-property Mode ap
sudo iwctl ap wlan0 start-profile GoonNet

# sudo systemctl stop firewall

