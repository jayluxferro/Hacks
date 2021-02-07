#!/bin/bash
# Make bootable macOS drive on Linux
# Author: Jay Lux Ferro <jayluxferro@sperixlabs.org>
#
dmg2imgLoc=`which dmg2img` 
checkInstalled(){
	echo "checking if dmg2img is installed"
	if [ -n "$dmg2imgLoc" ]
	then
		echo "dmg2img is installed"
	else
		echo "Installing dm2img"
		echo "Checking internet access"
		checkInternetAccess 
		apt-get install dmg2img -y
	fi
}

checkInternetAccess(){
	ping -c 1 8.8.8.8 -W 5
	if [ "$?" != "0" ];then
		echo "No internet access.."
		exit
	fi
}

printUsage(){
	echo "Usage: ./macBootable.sh [dmg source] [usb drive block]"
	echo "eg. ./macBootable.sh /home/jayluxferro/Sierra.dmg /dev/sdb"
}

checkAccess(){
	if [ "$(whoami)" != "root" ]; then
    	echo "You must be root to do this"
    	su -c "$0 $*"
    	exit
	fi
}

checkAccess
checkInstalled

newFilePath="$HOME/uncompressed.dmg"
if [ -z "$1" ] || [ -z "$2" ]
then
	printUsage
else
	echo "Processing .."
	echo "Please wait.."
	dmg2img -v -i "$1" -o "$newFilePath"
	dd if="$newFilePath" of="$2" bs=1M status=progress
	rm "$newFilePath"
	echo "Process completed"
	
fi
#dmg2img -v -i /path/to/Hackintosh-Sierra-Zone.dmg -o /path/to/Hackintosh-Sierra-Zone-Uncompressed.dmg
#dd if=/path/to/Hackintosh-Sierra-Zone-Uncompressed.dmg of=/dev/sdb bs=1m status=progess


