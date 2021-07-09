#!/bin/bash
echo "Dont actually run this thing, it's just a guide for right now"
exit 1

# Cloud arch setup
# dont actually run this, this is just some instructions

# Use the smaller swap size archian script
curl -q https://raw.githubusercontent.com/biondizzle/archian/smaller-swap/web.sh | bash

# CHANGE MAIN REPO TO CONSTANT
sudo nano /etc/pacman.d/mirrorlist
# Server = https://arch.mirror.constant.com/$repo/os/$arch

# Enable Root Login
sudo nano /etc/ssh/sshd_config
# PermitRootLogin yes
# PasswordAuthentication yes
sudo systemctl restart sshd

# Reboot if you werent already logged in as root
reboot

# Login as root

# delete default user
userdel -r mike

# add a user for yay with a home directory (-m)
useradd -m yay

# add yay to sudoers file (DO NOT ADD THIS USER TO ANY GROUPS OR IT WILL OVERRIDE THE NOPASSWD POLICY)
sudo nano /etc/sudoers
# yay  ALL=(ALL) NOPASSWD:ALL

# login as yay and install yay
su yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Ctrl + d to go back to root
# create a .bash_profile file
nano .bash_profile
# explain_yay ... Explains how to run yay as root
explain_yay() {
    BLOCK_SEPARATOR=$(seq -s- 100|tr -d '[:digit:]')
    TITLE_ASCII_ART_B64="X19fX19fICAgICAgICAgICAgIF9fICAgX19fX19fXyAgIF9fICAgX19fICAgICAgIF9fX19fXyAgICAgICAgICAgIF8gIF9fXyAgCnwgX19fIFwgICAgICAgICAgICBcIFwgLyAvIF8gXCBcIC8gLyAgLyBfIFwgICAgICB8IF9fXyBcICAgICAgICAgIHwgfHxfXyBcIAp8IHxfLyAvICAgXyBfIF9fICAgIFwgViAvIC9fXCBcIFYgLyAgLyAvX1wgXF9fXyAgfCB8Xy8gL19fXyAgIF9fXyB8IHxfICApIHwKfCAgICAvIHwgfCB8ICdfIFwgICAgXCAvfCAgXyAgfFwgLyAgIHwgIF8gIC8gX198IHwgICAgLy8gXyBcIC8gXyBcfCBfX3wvIC8gCnwgfFwgXCB8X3wgfCB8IHwgfCAgIHwgfHwgfCB8IHx8IHwgICB8IHwgfCBcX18gXCB8IHxcIFwgKF8pIHwgKF8pIHwgfF98X3wgIApcX3wgXF9cX18sX3xffCB8X3wgICBcXy9cX3wgfF8vXF8vICAgXF98IHxfL19fXy8gXF98IFxfXF9fXy8gXF9fXy8gXF9fKF8pICAK"
    echo ""
    echo "$TITLE_ASCII_ART_B64" | base64 --decode
    echo "$BLOCK_SEPARATOR"
    echo "No, You can not run yay as root. So we made a yay user for you. Run yay as the yay user like this:"
    echo ""
    echo "runuser -l yay -c 'yay -S gotop'"
    echo ""
    echo "--OR--"
    echo ""
    echo "Login as the yay user and then run yay like this:"
    echo ""
    echo "su yay"
    echo "yay -S gotop"
    echo "$BLOCK_SEPARATOR"
}

# Explian to users how to run yay as root
alias yay=explain_yay