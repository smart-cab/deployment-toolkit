# SmartCab Deployment Toolkit

This repository provides tools for **automated deployment** of the [SmartCab](https://github.com/smart-cab) ecosystem to local Vagrant-based environments or production servers.  

It uses **Vagrant** for VM provisioning and **bash deployment scripts** with `sshpass` for remote setup.

---

## 📂 Repository Structure

```
.
├── deploy.sh              # Main deployment script
├── hub_setup.sh           # Hub machine setup script
├── workstation_setup.sh   # Workstation machine setup script
├── Vagrantfile            # Vagrant config for local testing
└── settings/              # Environment-specific configs
    ├── settings.prod.sh
    └── settings.vagrant.sh
```

---

## Quick Start (Local with Vagrant)

### 1. Install dependencies
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)  
- [Vagrant](https://developer.hashicorp.com/vagrant/downloads)  
- `sshpass` (required for deployment script)  

On Ubuntu/Debian:
```bash
sudo apt-get install sshpass
```

### 2. Start VMs
Bring up both `workstation` and `hub` VMs:
```bash
vagrant up
```

- **Workstation**  
  - Ubuntu 18.04 (`hashicorp/bionic64`)  
  - Ports:  
    - SSH → `2201`  
    - Redis → `6379`  
    - Hub Frontend → `3000`  
    - Conference Camera Frontend → `8787`  

- **Hub**  
  - Raspberry Pi Desktop (32-bit) image  
  - GUI enabled  
  - SSH → `2202`  

Check status:
```bash
vagrant status
```

### 3. Deploy SmartCab software
Run deployment script using the Vagrant settings:
```bash
./deploy.sh ./settings/settings.vagrant.sh
```

This will:
- Upload setup scripts and configs to both VMs.  
- Run `hub_setup.sh` on the hub.  
- Run `workstation_setup.sh` on the workstation.  
- Place SmartCab in the target deploy directory (`/home/vagrant/smartcab` by default).

---

## Production Deployment

For real hardware / production servers, use `settings.prod.sh` instead:

```bash
./deploy.sh ./settings/settings.prod.sh
```

- `workstation` and `hub` connection details, credentials, and deployment directories are defined in `settings.prod.sh`.  
- Also contains PBX (telephony) configuration and repository release tags.

---

## Configuration

- **`settings.vagrant.sh`** – default local dev configuration (VM IPs, ports, vagrant/vagrant credentials).  
- **`settings.prod.sh`** – production settings (real hosts, users, deploy dirs, release tags).  
- **Secrets** – loaded from `./settings/secrets.sh` (not included in repo, must be created manually).  

---

## Managing VMs

- Suspend:
  ```bash
  vagrant suspend
  ```
- Halt:
  ```bash
  vagrant halt
  ```
- Destroy:
  ```bash
  vagrant destroy
  ```

