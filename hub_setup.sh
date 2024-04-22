#!/usr/bin/env bash

settings_file=$1
secrets_file=./settings/secrets.sh

if [ -z $settings_file ]; then
    echo -e "${RED}Settings file were not provided as the first script argument${NOCOLOR}"
    exit 1
elif [ ! -f $settings_file ]; then
    echo -e "${RED}File $settings_file were not found${NOCOLOR}"
    exit 1
fi
source $settings_file
source $secrets_file

sudo apt-get update
sudo apt-get install --no-install-recommends xserver-xorg xinit x11-xserver-utils -y
sudo apt-get install matchbox-window-manager xautomation unclutter fonts-noto-color-emoji -y

chromium_package=chromium-browser
sudo apt-get install $chromium_package
chromium_installation_status=$?
if [ $chromium_installation_status -ne 0 ]; then
    chromium_package=chromium
    sudo apt-get install $chromium_package
fi

cat >$HOME/kiosk <<EOL
#/bin/sh
xset -dpms     # disable DPMS (Energy Star) features.
xset s off     # disable screen saver
xset s noblank # don't blank the video device
matchbox-window-manager -use_titlebar no &
unclutter &    # hide X mouse cursor unless mouse activated
$chromium_package --display=:0 --kiosk --incognito --window-position=0,0 --disable-features=WebRtcHideLocalIpsWithMdns https://${settings["workstation_host"]}:3000/
EOL

line='if [ -z "$DISPLAY" -a $(tty) = /dev/tty1 ]; then xinit $HOME/kiosk -- vt$(fgconsole); fi'
grep -qxF "$line" .bashrc || echo "$line" >> .bashrc # append above line to .bashrc only if doesn't exist

sudo raspi-config nonint do_overscan_kms 1 1
sudo raspi-config nonint do_boot_behaviour B2

sudo shutdown --reboot now
