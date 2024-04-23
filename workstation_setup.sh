#!/usr/bin/env bash

apps=( smartcab-hub smartcab-bot conference-camera )

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

password=${settings["workstation_ssh_password"]}

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

# sudo apt update && sudo apt upgrade -y
if ! command_exists docker; then
    curl -fsSL https://get.docker.com | sh
fi
echo $password | sudo -SE usermod -aG docker $USER

apply_hub_settings() {
     cat >${settings["workstation_deploy_dir"]}/smartcab-hub/.env <<EOF
ZIGBEE_ADAPTER=/dev/ttyACM0
EOF
    cat >${settings["workstation_deploy_dir"]}/smartcab-hub/frontend/.env <<EOF
VITE_PBX_STATION_IP=${settings["pbx_station_ip"]}
VITE_PBX_STATION_PORT=${settings["pbx_station_port"]}
VITE_PBX_ENDPOINT=${settings["pbx_endpoint"]}
VITE_PBX_PASSWORD=${settings["pbx_password"]}
VITE_BACKEND_HOST=http://${settings["workstation_host"]}:5000
VITE_CONFCAM_BACKEND_HOST=http://${settings["workstation_host"]}:8787
EOF
}

apply_bot_settings() {
    cat >${settings["workstation_deploy_dir"]}/smartcab-bot/.env <<EOF
TELEGRAM_BOT_TOKEN=${settings["telegram_token"]}
EOF
}

export COMPOSE_PARALLEL_LIMIT=1

for app in "${apps[@]}"
do
    if [ ${settings["debug"]} -eq 1 ]; then
        git clone https://github.com/smart-cab/${app}.git ${settings["workstation_deploy_dir"]}/${app}
    else
        git clone --depth=1 --branch ${settings[${app}]} https://github.com/smart-cab/${app}.git ${settings["workstation_deploy_dir"]}/${app}
    fi

    cd ${settings["workstation_deploy_dir"]}/$app

    echo -e "{GREEN}Stopping existing $app app{NOCOLOR}"
    newgrp docker <<EOF
docker compose down -v
EOF

    if [ $app = "smartcab-hub" ]; then
        apply_hub_settings
    elif [ $app = "smartcab-bot" ]; then
        apply_bot_settings
    fi

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

    echo -e "{GREEN}Running the $app app{NOCOLOR}"
    newgrp docker <<EOF
docker compose up -d
EOF
done
