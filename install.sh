#!/bin/bash
cp ./pi-hole/install.sh ~/install.sh
if [ ! -f "/home/pi/.pswrd" ]; then
    if [ $# -ne 1 ]; then
        echo $0: usage: ./install.sh  password
        exit 0
    fi

    echo $1 > /home/pi/.pswrd

    sudo apt-get update
    sudo apt-get autoremove

    sudo apt-get install git -y

    # Install Ansible and Git on the machine.
    sudo apt-get install python-pip git python-dev sshpass -y
    sudo pip install ansible
    sudo pip install markupsafe

    # Configure IP address in "hosts" file. If you have more than one
    # Raspberry Pi, add more lines and enter details
    i=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    h=$(hostname)

    echo "$h ansible_host=$i" >> /home/pi/ansible.log

    echo "[rpi]" > /home/pi/ansible/hosts
    echo "$i  ansible_connection=ssh ansible_ssh_user=pi >> ~/ansible/hosts

    git clone https://github.com/Revenberg/pi-hole.git
fi

cd ~/pi-hole
git pull
cd ~

ansible-playbook /home/pi/pi-hole/playbook.yml --vault-password-file /home/pi/.pswrd
