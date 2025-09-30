# KDE Plasma 6## Playbooks Overview

The playbooks will be executed in the following order (as defined in `main.yml`):

1. `setup-network.yml`: Sets up WiFi connection using wpa_supplicant
2. `install-plasma.yml`: Installs KDE Plasma 6 and essential KDE applications
3. `configure-wayland.yml`: Configures SDDM to use Wayland
4. `configure-user-env.yml`: Sets up user environment variables for Waylandnd Setup Example

This directory contains Ansible playbooks that demonstrate how to install and configure KDE Plasma 6 with Wayland on Void Linux.

## Network Configuration

Before running these playbooks, you need to set up WiFi connectivity. Export these environment variables with your WiFi credentials:

```bash
export WIFI_SSID="your_wifi_network_name"
export WIFI_PSK="your_wifi_password"
export WIFI_INTERFACE="wlan0"  # or your wireless interface name
```

## Playbooks Overview

1. `00-configure-network.yml`: Sets up WiFi connection using wpa_supplicant
2. `00-install-plasma.yml`: Installs KDE Plasma 6 and essential KDE applications
2. `01-configure-wayland.yml`: Configures SDDM to use Wayland
3. `02-configure-user-env.yml`: Sets up user environment variables for Wayland
4. `main.yml`: Main playbook that runs all other playbooks in the correct order

## Usage

When these playbooks are placed in `/mnt/sideload` on the uConsole, they will be automatically run at boot time by the `rc.local` script.

To run them manually:

```bash
ansible-playbook -c local main.yml
```

## What gets installed

- KDE Plasma Desktop
- Wayland support
- SDDM display manager
- Essential KDE applications:
  - Dolphin (file manager)
  - Konsole (terminal emulator)
  - Audio and network management
  - Power management
  - Bluetooth support
  - Disk management
  - System monitoring
  - Firewall configuration
  - Browser integration
  - Archive management
  - Image viewer (Gwenview)
  - Document viewer (Okular)

## Configuration

The playbooks will:

1. Install all necessary packages
2. Configure SDDM to use Wayland
3. Enable SDDM service with runit
4. Set up proper environment variables for Wayland
5. Configure user permissions (add to input group)

## Notes

- These playbooks are idempotent and can be run multiple times safely
- They will automatically detect if components are already installed/configured
- User environment changes require a logout/login to take effect