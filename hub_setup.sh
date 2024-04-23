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

password=${settings[hub_ssh_password]}

echo $password | sudo -SE apt-get update
echo $password | sudo -SE apt-get install --no-install-recommends xserver-xorg xinit x11-xserver-utils -y
echo $password | sudo -SE apt-get install matchbox-window-manager xautomation unclutter fonts-noto-color-emoji -y

chromium_package=chromium-browser
echo $password | sudo -SE apt-get install $chromium_package
chromium_installation_status=$?
if [ $chromium_installation_status -ne 0 ]; then
    chromium_package=chromium
echo $password | sudo -SE apt-get install $chromium_package
fi

cat >$HOME/kiosk <<EOF
#/bin/sh
xset -dpms     # disable DPMS (Energy Star) features.
xset s off     # disable screen saver
xset s noblank # don't blank the video device
matchbox-window-manager -use_titlebar no &
unclutter &    # hide X mouse cursor unless mouse activated
$chromium_package --display=:0 --kiosk --incognito --window-position=0,0 --disable-features=WebRtcHideLocalIpsWithMdns http://${settings["workstation_host"]}:3000/
EOF

target=$HOME/.bashrc
while IFS= read -r line ; do
    if ! grep -Fqxe "$line" "$target" ; then
        printf "%s\n" "$line" >> "$target"
    fi
done <<EOF
if [ -z "\$DISPLAY" -a \$(tty) = /dev/tty1 ]; then xinit /home/${settings[hub_ssh_user]}/kiosk -- vt\$(fgconsole); fi
EOF
tail -n 5 $HOME/.bashrc

echo $password | sudo -SE raspi-config nonint do_overscan_kms 1 1
echo $password | sudo -SE raspi-config nonint do_boot_behaviour B2

echo $password | sudo -SE shutdown --reboot now
