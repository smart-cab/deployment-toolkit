#!/usr/bin/env bash

declare -A settings

# Connection settings
settings["workstation_host"]=192.168.200.9
settings["workstation_ssh_port"]=22
settings["workstation_ssh_user"]=school
settings["workstation_ssh_password"]=1357
settings["workstation_deploy_dir"]=/home/school/smartcab

settings["hub_host"]=192.168.200.5
settings["hub_ssh_port"]=22
settings["hub_ssh_user"]=hubuser
settings["hub_ssh_password"]=hubuser
settings["hub_deploy_dir"]=/home/hubuser/smartcab

# PBX settings
settings["pbx_station_ip"]=192.168.200.10
settings["pbx_station_port"]=8089
settings["pbx_endpoint"]=100
settings["pbx_password"]=LzJxci8yWnV4Z1k9

# Repository clone settings

# If debug is 0, then repositories will be cloned completely, from the latest
# commit. Else only one commit pinned to provided in the release setting tag
# will be cloned.
settings["debug"]=1

settings["release"]=v0.0.1-alpha

settings["smartcab-hub"]=${settings["release"]}
settings["smartcab-bot"]=${settings["release"]}
settings["conference-camera"]=${settings["release"]}
settings["rpicam"]=${settings["release"]}
