#!/bin/bash
#MISTER2JAMMA Version, aje_fr

reboot_de10=0
sed -i 's/^direct_video=0/direct_video=1/g' /media/fat/MiSTer.ini

URL="https://github.com"
MISTER2JAMMA_UBOOT_VERSION="MISTER2JAMMA_1.0"
MISTER2JAMMA_UBOOT_URL="${URL}/ajefr/Updater_script_MiSTer/blob/master/release//uboot.img_${MISTER2JAMMA_UBOOT_VERSION}?raw=true"
MISTER2JAMMA_UBOOT_DEST="/media/fat/linux/uboot.img_${MISTER2JAMMA_UBOOT_VERSION}"

MISTER2JAMMA_KERNEL_VERSION="MISTER2JAMMA_1.2"
MISTER2JAMMA_KERNEL_URL="${URL}/ajefr/Updater_script_MiSTer/blob/master/release/zImage_dtb_${MISTER2JAMMA_KERNEL_VERSION}?raw=true"
MISTER2JAMMA_KERNEL_DEST="/media/fat/linux/zImage_dtb_${MISTER2JAMMA_KERNEL_VERSION}"

echo "Searching for $MISTER2JAMMA_UBOOT_DEST"
if [ ! -f "$MISTER2JAMMA_UBOOT_DEST" ]; then
	echo "Not found, updating"
	wget "$MISTER2JAMMA_UBOOT_URL" -O $MISTER2JAMMA_UBOOT_DEST
	if [ $? -eq 0 ]; then
		echo "Updating MISTER2JAMMA uboot"
		cp $MISTER2JAMMA_UBOOT_DEST /media/fat/linux/uboot.img
		cd /media/fat/linux/
		./updateboot
		cd -
		reboot_de10=1
	else
		echo "Cannot update MISTER2JAMMA uboot, network error"
	fi
fi

echo "Searching for $MISTER2JAMMA_KERNEL_DEST"
if [ ! -f "$MISTER2JAMMA_KERNEL_DEST" ]; then
	echo "Not found, updating"
	wget "$MISTER2JAMMA_KERNEL_URL" -O $MISTER2JAMMA_KERNEL_DEST
	if [ $? -eq 0 ]; then
		echo "Updating MISTER2JAMMA zImage"
		cp $MISTER2JAMMA_KERNEL_DEST /media/fat/linux/zImage_dtb
		cd -
		reboot_de10=1
	else
		echo "Cannot update MISTER2JAMMA kernel, network error"
	fi
fi

if [ $reboot_de10 == 1 ]; then
 echo "Rebooting board"
 sudo reboot
fi

echo "MISTER2JAMMA Update Finished !"

exit 0
