# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.ssh.insert_key = false

  config.vm.define "workstation" do |workstation|
    workstation.vm.box = "hashicorp/bionic64"

    workstation.vm.network "public_network", ip: "192.168.200.1"

    workstation.vm.network "forwarded_port", id: "ssh", host: 2201, guest: 22
    workstation.vm.network "forwarded_port", id: "redis", host: 6379, guest: 6379
    workstation.vm.network "forwarded_port", id: "hub-frontend", host: 3000, guest: 3000
    workstation.vm.network "forwarded_port", id: "confcam-frontend", host: 8787, guest: 8787

    workstation.vm.provider "virtualbox" do |vb|
      vb.memory = "3072"
    end
  end

  config.vm.define "hub" do |hub|
    hub.vm.box = "PersistentCoder/raspberry-pi-desktop-32bit"

    hub.vm.network "public_network", ip: "192.168.200.2"

    hub.vm.network "forwarded_port", id: "ssh", host: 2202, guest: 22

    hub.vm.provision "setup_ssh_term_colors", type: "shell",
      inline: "grep -qxF \"export TERM='xterm-256color'\" /home/vagrant/.bashrc || echo \"export TERM='xterm-256color'\" >> /home/vagrant/.bashrc"

    hub.vm.provider "virtualbox" do |vb|
      vb.gui = true
      vb.memory = "1024"
    end

    hub.ssh.username = "vagrant"
  end
end
