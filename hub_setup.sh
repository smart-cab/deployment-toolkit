#!/usr/bin/env bash

apps=( rpicam )

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

GREEN='\033[1;32m'
RED='\033[1;31m'
NOCOLOR='\033[0m'

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

# sudo apt update && sudo apt upgrade -y
if ! command_exists docker; then
    curl -fsSL https://get.docker.com | sh
fi
echo $password | sudo -SE usermod -aG docker $USER

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
$chromium_package --display=:0 --window-position=0,0 --disable-features=WebRtcHideLocalIpsWithMdns --allow-insecure-localhost https://${settings["pbx_station_ip"]}:8089/asterisk/ws https://localhost:5050/thisisunsafe
$chromium_package --display=:0 --kiosk --window-position=0,0 --disable-features=WebRtcHideLocalIpsWithMdns https://${settings["workstation_host"]}:3000/
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

export COMPOSE_PARALLEL_LIMIT=1

for app in "${apps[@]}"
do
    if [ ${settings["debug"]} -eq 1 ]; then
        git clone https://github.com/smart-cab/${app}.git ${settings["hub_deploy_dir"]}/${app}
    else
        git clone --depth=1 --branch ${settings[${app}]} https://github.com/smart-cab/${app}.git ${settings["hub_deploy_dir"]}/${app}
    fi

    cd ${settings["hub_deploy_dir"]}/$app

    echo -e "${GREEN}Stopping existing $app app${NOCOLOR}"
    newgrp docker <<EOF
docker compose down -v
EOF

    echo "Start building of the $app app"
    newgrp docker <<EOF
docker compose build
EOF

    build_status=$?
    if [ $build_status -eq 0 ]; then
        echo -e "${GREEN}App $app was built successfully${NOCOLOR}"
    else
        echo -e "${RED}Failed to build $app app${NOCOLOR}"
        break
    fi

    echo -e "${GREEN}Running the $app app${NOCOLOR}"
    newgrp docker <<EOF
docker compose up -d
EOF
done

echo $password | sudo -SE shutdown --reboot now
