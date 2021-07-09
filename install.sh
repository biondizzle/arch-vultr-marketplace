#!/bin/bash

# install required packages
pacman -S --noconfirm git
pacman -S --noconfirm make
pacman -S --noconfirm python-pip
pacman -S --noconfirm cloud-guest-utils

# checkout benner's branch
git clone https://github.com/eb3095/cloud-init.git
cd cloud-init
git checkout vultr-nightly

# Compile
pip3 install -r requirements.txt
pip3 install pytest
python3 setup.py build

# Install
python3 setup.py install --init-system systemd
ln -s /usr/local/bin/cloud-init /usr/bin/cloud-init

# Enable service
systemctl enable --now cloud-init-local.service
systemctl enable --now cloud-init.service
systemctl enable --now cloud-config.service
systemctl enable --now cloud-final.service

# Clean up for marketplace
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -f /root/.ssh/authorized_keys /etc/ssh/*key*
touch /etc/ssh/revoked_keys
chmod 600 /etc/ssh/revoked_keys
find /var/log -mtime -1 -type f -exec truncate -s 0 {} \;
rm -rf /var/log/*.gz
rm -rf /var/log/*.[0-9]
rm -rf /var/log/*-????????
echo "" >/var/log/auth.log
rm -rf /var/lib/cloud/instances/*
history -c
cat /dev/null > /root/.bash_history
unset HISTFILE
rm -f /var/lib/systemd/random-seed
rm -f /etc/machine-id
touch /etc/machine-id
cat /dev/null > /var/log/lastlog
cat /dev/null > /var/log/wtmp
dd if=/dev/zero of=/zerofile
sync
rm /zerofile
sync
fstrim /

echo "Should be ready to go, just shutdown and take a snapshot"