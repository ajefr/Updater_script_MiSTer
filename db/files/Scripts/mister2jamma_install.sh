#!/bin/bash
# MiSTer2JAMMA : installation a lancer UNE SEULE FOIS depuis le menu Scripts.
# Ajoute le chargement du driver au demarrage (linux/user-startup.sh) puis le charge.
US=/media/fat/linux/user-startup.sh
START=/media/fat/linux/mister2jamma/start.sh
LINE="[ -f $START ] && sh $START"

if [ ! -f "$START" ]; then
	echo "Driver absent : lance d'abord update_all (ou downloader)."
	exit 1
fi

if [ ! -f "$US" ]; then
	if [ -f /media/fat/linux/_user-startup.sh ]; then
		cp /media/fat/linux/_user-startup.sh "$US"
	else
		printf '#!/bin/sh\n\necho "***" $1 "***"\n' > "$US"
	fi
fi
sed -i 's/\r$//' "$US"	# fins de ligne Windows

if grep -qF "mister2jamma/start.sh" "$US"; then
	echo "Demarrage automatique deja configure."
else
	printf '\n# MiSTer2JAMMA\n%s\n' "$LINE" >> "$US"
	echo "Demarrage automatique ajoute dans $US"
fi

sh "$START"
if lsmod | grep -q '^mister2jamma '; then
	echo "Driver MiSTer2JAMMA charge."
else
	echo "Driver non charge : voir 'dmesg | grep -i mister2jamma'"
fi
