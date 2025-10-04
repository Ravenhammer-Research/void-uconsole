# Sideload Ansible Setup

This Ansible configuration is designed to be copied from `/mnt/sideload` to `/opt/ansible` and run from there.

## Setup Process

1. **Copy Ansible to /opt/ansible:**
   ```bash
   cp -r /mnt/sideload/ansible /opt/ansible
   chown -R root:root /opt/ansible
   chmod -R 755 /opt/ansible
   ```

2. **Set WiFi credentials in /mnt/sideload:**
   ```bash
   echo "wifi_ssid: 'YOUR_WIFI_NAME'" > /mnt/sideload/wifi_vars.yml
   echo "wifi_password: 'YOUR_WIFI_PASSWORD'" >> /mnt/sideload/wifi_vars.yml
   ```

3. **Run the setup from /opt/ansible:**
   ```bash
   cd /opt/ansible
   ansible-playbook examples/uconsole-setup.yml -e @/mnt/sideload/wifi_vars.yml
   ```

## Directory Structure

- `/mnt/sideload/ansible/` - Source configuration (read-only)
- `/opt/ansible/` - Installed Ansible (executable)
- `/mnt/sideload/wifi_vars.yml` - WiFi credentials (external)

## Configuration Files

- `ansible.cfg` - Configured for `/opt/ansible` installation
- `playbooks/uconsole-setup.yml` - Main setup playbook
- `roles/` - All Void Linux roles
- `library/` - Custom XBPS and runit modules

## Usage

The setup will:
1. Configure WiFi connection
2. Install Wayland, PipeWire, and Plasma 6 (KDE)
3. Set up user accounts and services
4. Configure the uConsole for desktop use
