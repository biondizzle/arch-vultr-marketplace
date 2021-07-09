#!/bin/bash

WHAT_ARE_WE_CALLING_THIS="Arch For Vultr Marketplace"
BLOCK_SEPARATOR=$(seq -s- 100|tr -d '[:digit:]')
RUN_HELPER=0
INSTALL_CLOUD_INIT=0
PREPARE_FOR_MARKETPLACE=0

case "$1" in
	# Run the helper
	"-h" | "--help")
		RUN_HELPER=1
	;;

	# Run the installer
	"-i" | "--install")
		INSTALL_CLOUD_INIT=1
	;;

	# Prepare for the marketplace
	"-p" | "--prepare-for-marketplace")
		PREPARE_FOR_MARKETPLACE=1
	;;

	# Nothing to do?
	*)
		echo "Please add the flag of what you want to do. See --help for more options"
		exit 1
	;;
esac

# WANTS TO RUN HELPER
if [[ $RUN_HELPER -gt 0 ]]; then
	echo "$WHAT_ARE_WE_CALLING_THIS"
	echo ""
	echo "options:"
	echo "-h, --help                          shows the options (you're on this right now)"
	echo "-i, --install                       installs cloud-init"
	echo "-p, --prepare-for-marketplace       prepares instance for the vultr marketplace. This should be the last thing you do before taking a snapshot"
	exit 0
fi

# WANTS TO INSTALL CLOUD INIT
if [[ $INSTALL_CLOUD_INIT -gt 0 ]]; then
	# install required packages
	pacman -S --noconfirm dhclient # THIS IS VERY IMPORTANT! cloud-init will not work right without this
	pacman -S --noconfirm git
	pacman -S --noconfirm make
	pacman -S --noconfirm python-pip
	pacman -S --noconfirm cloud-guest-utils

	# checkout nightly branch branch
	# THE MASTER BRANCH ON THE UPSTREAM HAS BEEN RENAMED TO 'MAIN'
	# If you get an error about version differences, I HAVE do this
	# git checkout vultr-nightly
	# git remote add upstream https://github.com/canonical/cloud-init.git
	# git fetch upstream
	# git checkout main
	# git merge upstream/main
	# git pull upstream
	# git checkout vultr-nightly
	# git merge main
	# git push
	# THEN THE PERSON RUNNING this script has to do this
	# git checkout vultr-nightly
	# git remote add upstream https://git.launchpad.net/cloud-init
	# git fetch upstream --tags
	# and THEEENNN they can build
	git clone https://github.com/biondizzle/cloud-init.git
	cd cloud-init
	git checkout vultr-nightly
	git remote add upstream https://git.launchpad.net/cloud-init
	git fetch upstream --tags

	# Compile
	pip3 install -r requirements.txt
	pip3 install pytest
	python3 setup.py build

	# Install
	python3 setup.py install --init-system systemd
	#ln -s /usr/local/bin/cloud-init /usr/bin/cloud-init # dont need to do this for arch??

	# Enable service
	systemctl enable --now cloud-init-local.service
	systemctl enable --now cloud-init.service
	systemctl enable --now cloud-config.service
	systemctl enable --now cloud-final.service

	# Some messaging on the next steps
	echo ""
	echo "$BLOCK_SEPARATOR"
	echo ""
	echo "Time to add the Vultr Kernel Option!!!"
	echo "run nano /etc/default/grub"
	echo "add vultr to GRUB_CMDLINE_LINUX_DEFAULT=''"
	echo "Then just run update-grub (available on AUR) OR sudo grub-mkconfig -o /boot/grub/grub.cfg"
	echo ""
	echo "$BLOCK_SEPARATOR"
	echo ""

	exit 0
fi


# WANTS TO PREPARE FOR THE MARKETPLACE
if [[ $PREPARE_FOR_MARKETPLACE -gt 0 ]]; then
	# Clean up for marketplace
	sudo pacman -Sc # Answer yes to both of these?
	rm -rf cloud-init # This is assuming you installed cloud init here and there is the repo folder still there
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
	cloud-init clean

	# Really clear out that bash history
	cat /dev/null > ~/.bash_history
	cat /dev/null > ~/home/yay/.bash_history

	exit 0
fi

