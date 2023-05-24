#!/bin/bash
#created may 24 by kashish to perform a system update task for the lab

#update the software cache in case it is needed 
sudo apt update

#upgrade using  new software package versions
sudo apt upgrade -y
