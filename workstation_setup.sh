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

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

# sudo apt update && sudo apt upgrade -y
if ! command_exists docker; then
    curl -fsSL https://get.docker.com | sh
fi
sudo usermod -aG docker $USER

apply_pbx_settings() {
    cat >${settings["deploy_dir"]}/smartcab-hub/frontend/.env <<EOF
VITE_PBX_STATION_IP=${PBX_STATION_IP}
VITE_PBX_STATION_PORT=${PBX_STATION_PORT}
VITE_PBX_ENDPOINT=${PBX_ENDPOINT}
VITE_PBX_PASSWORD=${PBX_PASSWORD}
EOF
}

apply_bot_settings() {
    cat >${settings["deploy_dir"]}/smartcab-bot/.env <<EOF
TELEGRAM_BOT_TOKEN=${settings["telegram_token"]}
EOF
}

export COMPOSE_PARALLEL_LIMIT=1

for app in "${apps[@]}"
do
    git clone https://github.com/smart-cab/${app}.git ${settings["deploy_dir"]}/${app}

    cd ${settings["deploy_dir"]}/$app

    if [ $app = "smartcab-hub" ]; then
        apply_pbx_settings
    elif [ $app = "smartcab-bot" ]; then
        apply_bot_settings
    fi

    echo "--- Start building of the $app app ---"
    newgrp docker <<EOF
docker compose build
EOF

    build_status=$?
    if [ $build_status -eq 0 ]; then
        echo -e "--- ${GREEN}App $app was built successfully${NOCOLOR} ---"
    else
        echo -e "--- ${RED}Failed to build $app app${NOCOLOR} ---"
        break
    fi

    newgrp docker <<EOF
docker compose up -d
EOF
done
