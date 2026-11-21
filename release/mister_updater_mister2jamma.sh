#!/bin/bash
#MISTER2JAMMA Version, aje_fr
#
# Migration to the new MiSTer2JAMMA driver (https://github.com/ajefr/mister2jamma):
# a kernel module loaded on the OFFICIAL MiSTer kernel, delivered by a downloader database.
# The old custom 5.15 kernel and U-Boot are not installed any more (they do not boot on current
# MiSTer releases). This script:
#   1. installs the driver, the database drop-in file and the boot line in linux/user-startup.sh
#   2. if the custom kernel is still installed, reinstalls the official Linux system with the
#      official downloader (it reboots by itself); otherwise loads the driver right away
# Running it again later is harmless.

FAT=/media/fat
ZIP_URL="https://github.com/ajefr/mister2jamma/raw/main/sdcard/mister2jamma_sdcard.zip"
US="$FAT/linux/user-startup.sh"
START="$FAT/Scripts/.config/mister2jamma/start.sh"
LINE="[ -f $START ] && sh $START"

echo
echo "=== MiSTer2JAMMA: switching to the new driver (official kernel + module) ==="

# 1. driver files
TMP=$(mktemp -d)
if ! curl --connect-timeout 15 --max-time 300 --retry 3 -sSfL ${SSL_SECURITY_OPTION:-} -o "$TMP/m2j.zip" "$ZIP_URL" \
	|| ! unzip -o -q "$TMP/m2j.zip" -d "$TMP/x"; then
	echo "Cannot download the MiSTer2JAMMA driver, nothing changed. Try again later."
	rm -rf "$TMP"
	exit 1
fi
mkdir -p "$FAT/Scripts/.config/mister2jamma"
cp -f "$TMP"/x/Scripts/.config/mister2jamma/* "$FAT/Scripts/.config/mister2jamma/"
cp -f "$TMP/x/Scripts/mister2jamma_install.sh" "$FAT/Scripts/"
grep -qi '^[[:space:]]*\[mister2jamma\]' "$FAT/downloader.ini" 2>/dev/null \
	|| cp -f "$TMP/x/downloader_mister2jamma.ini" "$FAT/"
NEW_US="$TMP/x/linux/user-startup.sh"

# 2. boot line in linux/user-startup.sh
if [ -f "$US" ] && grep -q "MISTER2JAMMA Version, aje_fr" "$US"; then
	# old boot script that reinstalls the custom kernel at every boot: replace it
	cp "$US" "$US.mister2jamma_old"
	echo "Old MiSTer2JAMMA user-startup.sh saved as $US.mister2jamma_old"
	cp -f "$NEW_US" "$US"
elif [ ! -f "$US" ]; then
	cp -f "$NEW_US" "$US"
fi
sed -i 's/\r$//' "$US"
sed -i "s#/media/fat/linux/mister2jamma/start.sh#$START#g" "$US"
if ! grep -qF "$START" "$US"; then
	if grep -qE '^[[:space:]]*exit' "$US"; then
		awk -v l="$LINE" '!done && /^[[:space:]]*exit/ {print "# MiSTer2JAMMA"; print l; done=1} {print}' "$US" > "$US.tmp" && mv "$US.tmp" "$US"
	else
		printf '\n# MiSTer2JAMMA\n%s\n' "$LINE" >> "$US"
	fi
fi
echo "Driver installed, loaded at every boot by $US"
rm -rf "$TMP"
sync

# 3. kernel
custom=0
for f in "$FAT"/linux/zImage_dtb_MISTER2JAMMA_*; do
	[ -f "$f" ] && cmp -s "$f" "$FAT/linux/zImage_dtb" && custom=1
done

if [ $custom -eq 1 ]; then
	echo "The custom MiSTer2JAMMA kernel is installed: reinstalling the official MiSTer Linux system."
	echo "The MiSTer reboots by itself at the end, please do not turn it off."
	# forget the installed Linux version so that the downloader installs it again
	if ! echo "000000" > /MiSTer.version; then
		echo "Cannot reset the Linux version. Please reinstall MiSTer with Mr. Fusion, see"
		echo "https://github.com/ajefr/mister2jamma"
		exit 1
	fi
	sync
	DL="$FAT/Scripts/downloader.sh"
	if [ ! -f "$DL" ]; then
		DL=/tmp/downloader.sh
		curl -sSfL ${SSL_SECURITY_OPTION:-} -o "$DL" https://raw.githubusercontent.com/MiSTer-devel/Downloader_MiSTer/main/downloader.sh
	fi
	UPDATE_LINUX=true bash "$DL" < /dev/null
	# reached only if the downloader did not reboot
	echo "The official Linux system could not be installed. Run update_all again, or reinstall MiSTer with"
	echo "Mr. Fusion and follow https://github.com/ajefr/mister2jamma"
	exit 1
fi

if [ -f /tmp/downloader_needs_reboot_after_linux_update ]; then
	echo "Linux was updated: rebooting."
	sync
	reboot
	exit 0
fi

sh "$START" < /dev/null
if lsmod | grep -q '^mister2jamma '; then
	echo "MiSTer2JAMMA driver loaded."
fi
echo "MISTER2JAMMA Update Finished !"
exit 0
