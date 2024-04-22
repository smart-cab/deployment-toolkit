#!/usr/bin/env bash

declare -A settings

# Deploy settings
settings["deploy_dir"]=.

# Connection settings
settings["workstation_host"]=192.168.200.11
settings["workstation_ssh_port"]=22
settings["workstation_ssh_user"]=school
settings["workstation_ssh_password"]=1357

settings["hub_host"]=192.168.200.5
settings["hub_ssh_port"]=22
settings["hub_ssh_user"]=hubuser
settings["hub_ssh_password"]=hubuser

# PBX settings
settings["pbx_station_ip"]=192.168.200.7
settings["pbx_station_port"]=8089
settings["pbx_endpoint"]=100
settings["pbx_password"]=LzJxci8yWnV4Z1k9
