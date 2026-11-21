# MiSTer2JAMMA for MiSTer

Support for the **MiSTer2JAMMA** board (4 players JAMMA controls, volume/balance, mono/stereo) on a
**standard MiSTer installation**: no custom kernel, no custom U-Boot.

The driver is a small kernel module (`mister2jamma.ko`) loaded at boot. It is distributed through a
[MiSTer Downloader](https://github.com/MiSTer-devel/Downloader_MiSTer) database, so it is updated
together with everything else when you run `update_all` or `downloader`.

## Installation (recommended)

> Until the driver is installed, the JAMMA controls do not work. If you cannot reach the Scripts menu,
> see [First setup without any working controls](#first-setup-without-any-working-controls) below.

1. **Update your MiSTer** to the latest official release (run `update_all` or `downloader` once).
2. **Add the MiSTer2JAMMA database.** Open `downloader.ini` at the root of the SD card
   (`/media/fat/downloader.ini`) with a text editor and add these two lines at the end:

   ```ini
   [mister2jamma]
   db_url = https://raw.githubusercontent.com/ajefr/Updater_script_MiSTer/master/db/db.json.zip
   ```
3. **Run `update_all`** (or `downloader`) from the Scripts menu. It installs:
   - `linux/mister2jamma/` : the driver module and its start script
   - `Scripts/mister2jamma_install.sh` : the one-time setup script
4. **Run `mister2jamma_install`** from the Scripts menu, **once**. It adds the driver to
   `linux/user-startup.sh` so that it is loaded at every boot, then loads it immediately.
5. Reboot. The four players, the volume and the balance now work from the JAMMA connector.

From now on, just run `update_all` as usual: when the official MiSTer Linux kernel changes, a new
module is built automatically and delivered by the database.

### First setup without any working controls

Before the driver is installed, the JAMMA controls do not work, so the Scripts menu may not be reachable.
Use one of these methods for the first setup only:

**A. Temporary USB keyboard or USB controller (easiest).** Plug it into the MiSTer, follow steps 1 to 5 above
(on a keyboard: `F12` opens the menu, arrows and `Enter` to navigate), then unplug it.

**B. Over the network with SSH (no USB device needed).** Connect the MiSTer with an Ethernet cable, find its IP
address on your router, and log in with `ssh root@<ip>` (password `1`). Then run:

```sh
# 1. add the MiSTer2JAMMA database
printf '\n[mister2jamma]\ndb_url = https://raw.githubusercontent.com/ajefr/Updater_script_MiSTer/master/db/db.json.zip\n' >> /media/fat/downloader.ini
# 2. update the MiSTer and download the driver
/media/fat/Scripts/update_all.sh      # or: /media/fat/Scripts/downloader.sh
# 3. enable the driver at boot, then reboot
bash /media/fat/Scripts/mister2jamma_install.sh
reboot
```

**C. Prepare the SD card on a PC.** Only if the SD card already holds an up-to-date MiSTer (Linux 6.18 or
later). With the SD card in your PC:
1. Add the two `[mister2jamma]` lines to `downloader.ini` (step 2 above).
2. Create the folder `linux/mister2jamma/` and copy into it `start.sh` and the `mister2jamma-*.ko` files from
   [`db/files/linux/mister2jamma/`](db/files/linux/mister2jamma/).
3. If `linux/user-startup.sh` does not exist, copy [`extras/sdcard/linux/user-startup.sh`](extras/sdcard/linux/user-startup.sh)
   there. If it exists, add this line at the end, with an editor that keeps Unix (LF) line endings
   (Notepad++, VS Code...):
   `[ -f /media/fat/linux/mister2jamma/start.sh ] && sh /media/fat/linux/mister2jamma/start.sh`
4. Put the SD card back and boot: the controls work right away. Run `update_all` as usual afterwards.

### Checking that the driver is loaded

Over SSH (user `root`, password `1`):

```sh
lsmod | grep mister2jamma
dmesg | grep -i mister2jamma
```

`dmesg` should show `carte MiSTer2JAMMA prete` (board ready).

### Options

The input scan period defaults to 1 ms. It can be changed at runtime, for instance:

```sh
echo 2 > /sys/module/mister2jamma/parameters/scan_ms
```

### Troubleshooting

- **Controls stopped working right after a MiSTer Linux update**: the module for the new kernel may not be
  published yet (it is built within 24 hours). Run `update_all` again later, with a keyboard or USB controller.
  `uname -r` shows your kernel version; the matching file is `linux/mister2jamma/mister2jamma-<version>.ko`.
- **Nothing happens at boot**: check that `/media/fat/linux/user-startup.sh` contains the line
  `[ -f /media/fat/linux/mister2jamma/start.sh ] && sh /media/fat/linux/mister2jamma/start.sh`
  and was not saved with Windows line endings. Running `mister2jamma_install` again fixes both.
- **Uninstall**: remove the `[mister2jamma]` section from `downloader.ini`, remove the line above from
  `linux/user-startup.sh`, and run `update_all`.

## How it works

On load, the module releases the LTC header pins from the official `i2c-gpio` bus, switches them to the
hardware I2C1 controller (what the old custom U-Boot did), enables I2C1 at 400 kHz with a device tree overlay
(including the RTC chips that used the same pins), then probes the board. If no MiSTer2JAMMA board answers,
everything is restored and the module refuses to load.

The module is rebuilt by the GitHub workflow in `.github/workflows/build-module.yml`, which checks the official
distribution every day. The database is generated by `tools/make_db.py`.

---

## Legacy method (old custom kernel)

> **Warning:** the files below (`update_mister2jamma.sh` and `release/`) install a custom **5.15** kernel and
> U-Boot. They are kept for existing users of old MiSTer releases only. **Do not use them on a current MiSTer
> release** (Linux 6.18 and later): the custom kernel does not boot there. Use the installation above instead,
> and stop running `update_mister2jamma.sh` once you have switched.

# Updater script for MiSTer
The script updates all [MiSTer](https://github.com/MiSTer-devel/Main_MiSTer/wiki) cores, including menu.rbf and the main MiSTer Linux executable; it updates scaler filters, GameBoy palettes and scripts; it can (experimental and risky) optionally update the whole Linux system.<br>
Simply put [update.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/update.sh?raw=true) in your SD and launch it through MiSTer main menu OSD (press F12 and then Scripts).<br>
Please right click (save link as...) on the links in this README (inside the README, not in the GitHub repository) or on the RAW button in GitHub script pages in order to actually download the raw Bash scripts, otherwise you could download an HTML page which isn’t a script and won’t be executed by MiSTer (you will see no output, but just an OK button in MiSTer Script menu interface); please don't copy and paste any script code or you may end with a non working script if you use Windows (different end of line character).<br>
[update.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/update.sh?raw=true) will always download and execute the latest [mister_updater.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/mister_updater.sh?raw=true) (where the real update code is) from GitHub, so you will never have to deal with "updater updates". You can make an update.ini (same name as the script and placed in the same directory) file with custom user options: see [mister_updater.sh USER OPTIONS section](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/ef7593624c672309c78d5acc57018d689de37f82/mister_updater.sh#L92-L208) (please click the link) for all user options and their detailed explanations. If you feel uncomfortable, for security reasons, with a script which downloads and executes another script from the Internet, you can directly download and use [mister_updater.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/mister_updater.sh?raw=true) and it will work the same, all ini file considerations will still be valid, but you will have to update the script manually.<br>
You can have many differently named copies of [update.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/update.sh?raw=true) (or [mister_updater.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/mister_updater.sh?raw=true) if you prefer) and its ini file, for different updating behaviours i.e.:<br>
- you can make an *update_arcade.sh* with its *[update_arcade.ini](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/examples/update_arcade.ini?raw=true)* using these settings (simply copy this code in an empty text file named *update_arcade.ini* and put it in the same directory as *update_arcade.sh*):
```
REPOSITORIES_FILTER="arcade-cores"
ADDITIONAL_REPOSITORIES=( )
UPDATE_CHEATS="false"
UPDATE_LINUX="false"
```
- you can make an *update_commodore.sh* with its *[update_commodore.ini](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/examples/update_commodore.ini?raw=true)* using these settings:
```
REPOSITORIES_FILTER="PET2001 VIC20 C64 C16 Minimig"
ADDITIONAL_REPOSITORIES=( )
UPDATE_CHEATS="false"
UPDATE_LINUX="false"
```
- you can make an *update_additional_repositories.sh* with its *[update_additional_repositories.ini](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/examples/update_additional_repositories.ini?raw=true)* using these settings:
```
REPOSITORIES_FILTER="ZZZZZZZZZ"
UPDATE_CHEATS="false"
UPDATE_LINUX="false"
```
- you can make an *update_fonts.sh* with its *[update_fonts.ini](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/examples/update_fonts.ini?raw=true)* using these settings:
```
REPOSITORIES_FILTER="ZZZZZZZZZ"
ADDITIONAL_REPOSITORIES=( "https://github.com/MiSTer-devel/Fonts_MiSTer|pf|$BASE_PATH/font" )
UPDATE_CHEATS="false"
UPDATE_LINUX="false"
```
- you can make an *update_linux.sh* with its *[update_linux.ini](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/examples/update_linux.ini?raw=true)* using these settings:
```
REPOSITORIES_FILTER="ZZZZZZZZZ"
UPDATE_CHEATS="false"
UPDATE_LINUX="true"
```
- you can make an update_all.sh with its [update_all.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/examples/update_all.ini?raw=true) using these settings:
```
UPDATE_CHEATS="true"
UPDATE_LINUX="true"
ADDITIONAL_REPOSITORIES+=( "https://github.com/MiSTer-devel/Fonts_MiSTer|pf|$BASE_PATH/font" )

```
I take no responsibility for any data loss or anything, if your DE10-Nano catches fire it’s up to you: **use the script at your own risk**.
