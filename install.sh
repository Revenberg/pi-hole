#!/bin/bash
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

    mkdir /home/pi/ansible

    git clone https://github.com/Revenberg/pi-hole.git

    ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'  | while read line;
    do
        ssh-keyscan -H $line >> ~/.ssh/known_hosts
    done
fi

echo "[rpi]" > /home/pi/ansible/hosts

pswrd=$(cat /home/pi/.pswrd)
echo "---" > /home/pi/ansible/vault.yml
echo "ansible_become_pass: $pswrd" >> /home/pi/ansible/vault.yml
ansible-vault encrypt --vault-password-file /home/pi/.pswrd /home/pi/ansible/vault.yml

ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'  | while read line;
do
    echo "$line ansible_connection=ssh ansible_ssh_user=pi ansible_ssh_private_key_file=/home/pi/ansible/vault.yml" >> /home/pi/ansible/hosts
    
done

#echo /home/pi/ansible/hosts
#ansible-vault encrypt_string --vault-password-file /home/pi/.pswrd '$pswrd' --name 'ansible_ssh_pass'  >> /home/pi/ansible/hosts

cd ~/pi-hole
git pull
cd ~

cp ./pi-hole/install.sh ~/install.sh

ansible-playbook /home/pi/pi-hole/playbook.yml --vault-password-file /home/pi/.pswrd -i /home/pi/ansible/hosts
