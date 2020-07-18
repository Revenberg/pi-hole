#!/bin/bash
cp ./pi-hole/usb.sh ~/usb.sh
chmod +x ~/usb.sh

ansible-playbook /home/pi/pi-hole/usbdrive.yml --vault-password-file /home/pi/.pswrd -i /home/pi/ansible/hosts 
