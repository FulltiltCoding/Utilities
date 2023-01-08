#!/bin/bash

# For VMware Fusion 13 and Lunar Lobster.
# This is only to be executed on a GUEST linux OS.
# No warranty, use at your own will.

# ===========================================
# Install All Updates========================
# ===========================================

clear

if (( $EUID != 0 )); then
    echo "Please run as sudo. eg. sudo ./lobster"
    exit
fi

# updates apt packages
apt update && apt full-upgrade -y

# updates snap packages
snap refresh

# install development software
apt install open-vm-tools-desktop build-essential git-all htop neofetch chromium-browser nodejs npm curl -y

# install TypeScript
if ! [ $(command -v tsc) ];
	then
		npm install -g typescript
  	else
  		echo "TypeScript installed $(tsc -v)"
fi

# install Visual Studio Code
if ! [ $(command -v code) ]; then
  curl -L https://aka.ms/linux-arm64-deb > code.deb
  dpkg -i code.deb
  else
  echo "VS Code is installed"
fi

echo "NodeJS Version $(node -v)"
echo "NPM Version $(npm -v)"
echo "TypeScript $(tsc -v)"

# clean up
apt autoremove -y

# ===========================================
# Setup Fusion Shared Folders================
# ===========================================
# ***** open-vm-tools-desktop required ******

# does the hgfs dir even exist?
DIR=/mnt/hgfs
if [ -d "$DIR" ];
	then
		echo "$DIR directory exists...nothing to do."
	else
		echo "$DIR directory does not exist."
		echo "...creating $DIR"
		mkdir /mnt/hgfs
fi

# mount hgfs - open vm tools required first
if mountpoint -q /mnt/hgfs;
	then
		echo "/mnt/hgfs is already mounted...nothing do to."
	else
		echo "not mounted. mounting /mnt/hgfs..."
		mount -t fuse.vmhgfs-fuse .host:/ /mnt/hgfs
		systemctl daemon-reload
fi

#make share volume accessible
/usr/bin/vmhgfs-fuse .host:/ /mnt/hgfs -o subtype=vmhgfs-fuse,allow_other

# create link to the shared folder in home dir called MacBook
HOST_SHARE=Downloads
LOCAL_FOLDER=MacBook
GUEST_SYMLINK=/home/$SUDO_USER/$LOCAL_FOLDER

if [ -L $GUEST_SYMLINK ];
	then
		echo "$GUEST_SYMLINK Already created...nothing to do."
	else
		ln -s /mnt/hgfs/$HOST_SHARE/ $GUEST_SYMLINK
fi

echo "Complete. Your Host directory can be accessed at $GUEST_SYMLINK"
