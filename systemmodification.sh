#!/bin/bash

# Define the new hostname
new_hostname="autosrv"

# Check the current hostname
current_hostname=$(hostname)
echo "Current hostname: $current_hostname"

# Check if the hostname needs to be changed
if [ "$current_hostname" != "$new_hostname" ]; then
  # Change the hostname
  echo "Changing hostname to $new_hostname"
  sudo hostnamectl set-hostname "$new_hostname"
  sudo sed -i "s/$current_hostname/$new_hostname/g" /etc/hosts
  echo "Hostname changed to $new_hostname"
else
  echo "Hostname is already $new_hostname. No changes needed."
fi

