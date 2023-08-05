#!/bin/bash

# Adding values in the script
TARGET1_MGMT="172.16.1.10"
TARGET2_MGMT="172.16.1.11"
LOGHOST_IP="192.168.16.3"
WEBHOST_IP="192.168.16.4"

# Function to execute commands on a remote machine
execute_remote() {
    ssh remoteadmin@"$1" "$2"
}

# To configure target1
execute_remote "$TARGET1_MGMT" "
sudo hostnamectl set-hostname loghost
sudo ip addr add $LOGHOST_IP/24 dev eth0
echo '$WEBHOST_IP webhost' | sudo tee -a /etc/hosts
sudo apt update
sudo apt install -y ufw
sudo ufw allow from 172.16.1.0/24 to any port 514/udp
sudo sed -i '/^#$ModLoad imudp/s/^#//' /etc/rsyslog.conf
sudo sed -i '/^#$UDPServerRun/s/^#//' /etc/rsyslog.conf
sudo systemctl restart rsyslog
"

# To configure target2
execute_remote "$TARGET2_MGMT" "
sudo hostnamectl set-hostname webhost
sudo ip addr add $WEBHOST_IP/24 dev eth0
echo '$LOGHOST_IP loghost' | sudo tee -a /etc/hosts
sudo apt update
sudo apt install -y ufw apache2
sudo ufw allow 80/tcp
echo '*.* @loghost' | sudo tee -a /etc/rsyslog.conf
sudo systemctl restart rsyslog
"

# For updating NMS /etc/hosts
sudo sed -i "/$LOGHOST_IP/d" /etc/hosts
sudo sed -i "/$WEBHOST_IP/d" /etc/hosts
echo "$LOGHOST_IP loghost" | sudo tee -a /etc/hosts
echo "$WEBHOST_IP webhost" | sudo tee -a /etc/hosts

# For tessting and output and results
if ping -c 1 -W 1 webhost >/dev/null && \
   ssh remoteadmin@loghost grep webhost /var/log/syslog >/dev/null; then
    echo "Configuration update succeeded."
else
    echo "Configuration update failed. Please check the tasks manually."
fi

