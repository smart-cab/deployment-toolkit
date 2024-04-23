#!/usr/bin/env bash

declare -A settings

# Deploy settings
settings["deploy_dir"]=/home/vagrant/smartcab

# Connection settings
settings["workstation_host"]=192.168.200.1
settings["workstation_ssh_port"]=2201
settings["workstation_ssh_user"]=vagrant
settings["workstation_ssh_password"]=vagrant

settings["hub_host"]=192.168.200.2
settings["hub_ssh_port"]=2202
settings["hub_ssh_user"]=vagrant
settings["hub_ssh_password"]=vagrant

# PBX settings
settings["pbx_station_ip"]=192.168.200.7
settings["pbx_station_port"]=8089
settings["pbx_endpoint"]=100
settings["pbx_password"]=LzJxci8yWnV4Z1k9
