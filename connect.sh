#!/bin/bash

# ABOUT ==============================
# For VMware Fusion 13. This is only to be executed on a GUEST linux OS.
# No warranty, use at your own will.

# USAGE ==============================
# copy file to root of home directory
# sudo chmod +x connect.sh
# sudo ./connect.sh

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
