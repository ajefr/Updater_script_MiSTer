#!/bin/bash
#MISTER2JAMMA Version, aje_fr

URL="https://github.com"
MISTER2JAMMA_UBOOT_VERSION="MISTER2JAMMA_1.0"
MISTER2JAMMA_UBOOT_URL="${URL}/ajefr/Updater_script_MiSTer/blob/master/release//uboot.img_${MISTER2JAMMA_UBOOT_VERSION}"
MISTER2JAMMA_UBOOT_DEST="/media/fat/linux/uboot.img_${MISTER2JAMMA_UBOOT_VERSION}"

MISTER2JAMMA_KERNEL_VERSION="MISTER2JAMMA_1.0"
MISTER2JAMMA_KERNEL_URL="${URL}/ajefr/Updater_script_MiSTer/blob/master/release/zImage_dtb_${MISTER2JAMMA_UBOOT_VERSION}"
MISTER2JAMMA_KERNEL_DEST="/media/fat/linux/zImage_dtb_${MISTER2JAMMA_UBOOT_VERSION}"

if [ ! -f "$MISTER2JAMMA_UBOOT_DEST" ]; then
	wget "$MISTER2JAMMA_UBOOT_URL" -o $MISTER2JAMMA_UBOOT_DEST
	if [ $? -eq 0 ]; then
		echo "Updating MISTER2JAMMA uboot"
		cp $MISTER2JAMMA_UBOOT_DEST /media/fat/linux/uboot
		cd /media/fat/linux/
		./updateboot
		cd -
	else
		echo "Cannot update MISTER2JAMMA uboot, network error"
	fi
fi

if [ ! -f "$MISTER2JAMMA_KERNEL_DEST" ]; then
	wget "$MISTER2JAMMA_KERNEL_URL" -o $MISTER2JAMMA_KERNEL_DEST
	if [ $? -eq 0 ]; then
		echo "Updating MISTER2JAMMA uboot"
		cp $MISTER2JAMMA_KERNEL_DEST /media/fat/linux/zImage_dtb
		cd -
	else
		echo "Cannot update MISTER2JAMMA kernel, network error"
	fi
fi

exit 0
