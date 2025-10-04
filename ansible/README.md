# Void Linux Ansible Configuration

Comprehensive Ansible configuration for Void Linux systems covering all areas documented in the [Void Linux Handbook](https://docs.voidlinux.org/about/index.html).

## What's Included

### Custom Modules
- **`xbps.py`** - Native XBPS package manager module
- **`runit.py`** - Native runit service supervisor module

### Complete Role Coverage

#### Core System (3.1, 3.6, 3.7, 3.8)
- **void-core** - Package documentation, rc.conf/rc.local/rc.shutdown, cron, SSD optimization

#### User Management (3.4)
- **void-users** - Users and groups management with sudo configuration, wheel group support

#### Services (3.5, 3.5.1, 3.5.2)
- **void-services** - runit services, per-user services, logging, service testing

#### Network (3.13, 3.13.1, 3.13.2, 3.13.3, 3.13.4, 3.13.5)
- **void-network** - Network configuration, NetworkManager, conflict resolution
- **void-wifi** - wpa_supplicant, IWD
- **void-firewall** - Firewalls, iptables, nftables, UFW

#### Graphics & Desktop (3.16, 3.16.1-3.16.8)
- **void-graphics** - Graphics drivers (AMD/Intel/NVIDIA), Xorg, Wayland, fonts, icons, XDG portals
- **void-desktop** - GNOME, KDE, XFCE desktop environments with latest packages

#### Multimedia (3.17, 3.18)
- **void-multimedia** - ALSA, PipeWire (with WirePlumber), PulseAudio, latest audio configuration
- **void-bluetooth** - Bluetooth configuration

#### System Configuration
- **void-locales** - Locales and translations (3.3)
- **void-firmware** - Firmware management (3.2)
- **void-kernel** - Kernel configuration (3.11)
- **void-power** - Power management (3.12)

#### Security (3.9, 3.9.1)
- **void-security** - SSH, AppArmor

#### Additional Features
- **void-printing** - Printing/CUPS (3.21)
- **void-containers** - Containers and VMs, libvirt, LXC (3.22)
- **void-openpgp** - OpenPGP configuration (3.23)

## Quick Start

### 1. Bootstrap System
```bash
sudo ./files/void-bootstrap.sh
```

### 2. Run Complete Setup
```bash
ansible-playbook playbooks/void-complete-setup.yml
```

### 3. Run Specific Components
```bash
# Only network configuration
ansible-playbook playbooks/void-complete-setup.yml --tags network

# Only desktop environment
ansible-playbook playbooks/void-complete-setup.yml --tags desktop

# Only security configuration
ansible-playbook playbooks/void-complete-setup.yml --tags security
```

## Configuration

### WiFi Setup
Set your WiFi credentials in the playbook:
```yaml
wifi_ssid: "your-wifi-name"
wifi_password: "your-wifi-password"
```

### Desktop Environment
Choose your preferred desktop:
```yaml
# For XFCE (lightweight)
void_install_xfce: true
void_install_xfce_apps: true
void_display_manager: "lightdm"

# For GNOME (full-featured)
void_install_gnome: true
void_install_gnome_apps: true
void_display_manager: "gdm"

# For KDE (feature-rich)
void_install_kde: true
void_display_manager: "sddm"
```

### Audio Configuration
```yaml
# PipeWire (recommended)
void_audio_backend: "pipewire"
void_audio_services: ["pipewire", "wireplumber", "pipewire-pulse"]

# PulseAudio (legacy)
void_audio_backend: "pulse"
void_audio_services: ["pulseaudio"]
```

### Security Options
```yaml
# SSH configuration
void_ssh_config:
  port: 2222  # Change default port
  permit_root_login: "no"
  password_authentication: "no"
  pubkey_authentication: "yes"

# Enable firewall
void_enable_firewall: true
void_ufw_rules:
  - rule: "allow"
    port: "22"
    proto: "tcp"
    comment: "SSH"
```

## Files Structure

```
ansible/
├── library/                    # Custom modules
│   ├── xbps.py               # XBPS package manager
│   └── runit.py              # runit service supervisor
├── playbooks/                 # Main playbooks
│   ├── void-complete-setup.yml # Complete system setup
│   └── uconsole-setup.yml    # Simple uConsole setup
├── roles/                     # All Void Linux roles
│   ├── void-core/            # Core system
│   ├── void-users/           # User management
│   ├── void-services/        # Service management
│   ├── void-network/         # Network configuration
│   ├── void-wifi/            # WiFi configuration
│   ├── void-firewall/        # Firewall configuration
│   ├── void-graphics/        # Graphics drivers
│   ├── void-desktop/         # Desktop environments
│   ├── void-multimedia/      # Audio configuration
│   ├── void-bluetooth/       # Bluetooth
│   ├── void-security/        # Security settings
│   ├── void-locales/         # Locale configuration
│   ├── void-firmware/        # Firmware management
│   ├── void-kernel/          # Kernel configuration
│   ├── void-power/           # Power management
│   ├── void-printing/        # Printing
│   ├── void-containers/      # Containers/VMs
│   └── void-openpgp/         # OpenPGP
├── files/                     # Configuration files
│   ├── void-bootstrap.sh    # System bootstrap
│   ├── wpa_supplicant.conf  # WiFi example
│   ├── rc.local.example     # Startup script
│   └── rc.shutdown.example  # Shutdown script
├── ansible.cfg               # Ansible configuration
└── README.md                 # This file
```

## Usage Examples

### uConsole Setup

For the ClockworkPi uConsole, use the single setup playbook:
```bash
ansible-playbook playbooks/uconsole-setup.yml
```

This playbook handles the complete setup in one run:
- ✅ Configures pre-installed `wpa_supplicant` with WiFi credentials
- ✅ Enables `dhcpcd` for IP address assignment
- ✅ Waits for network connectivity
- ✅ Installs NetworkManager for desktop network management
- ✅ Installs desktop environment (XFCE)
- ✅ Installs multimedia packages (PipeWire)
- ✅ Installs development tools
- ✅ Installs SDR packages
- ✅ Configures display manager
- ✅ Sets up users and services

**Note**: The uConsole base image includes `wpa_supplicant` for WiFi connectivity. The playbook configures WiFi first, establishes internet connectivity, then installs all additional packages that require internet access.

### Desktop Workstation
For a full desktop system:
```bash
ansible-playbook playbooks/void-complete-setup.yml
```

### Server Configuration
For a server system, disable desktop components:
```yaml
void_install_xfce: false
void_install_gnome: false
void_install_kde: false
void_enable_display_manager: false
void_install_bluetooth: false
```

### Development Environment
Add development tools:
```yaml
void_development_packages:
  - gcc
  - make
  - python3
  - nodejs
  - docker
  - git
```

## Requirements

- Void Linux system
- Root access
- Internet connection for package installation

## License

GPL-3.0 - Same as Void Linux

## Package Groups

The `void-core` role includes comprehensive package groups for easy installation of related software. See `roles/void-core/PACKAGE_GROUPS.md` for complete documentation.

### Example Usage

```yaml
# Install SDR tools
- name: Install SDR software
  xbps:
    name: "{{ void_pkg_sdr }}"
    state: present

# Install complete development environment
- name: Install dev tools
  xbps:
    name: "{{ void_pkg_dev_core + void_pkg_dev_languages }}"
    state: present
```

### Available Categories

- **Browsers**: Chromium, Firefox, qutebrowser, etc.
- **Multimedia**: Audio players, video editors, image tools
- **SDR**: GNURadio, GQRX, hardware support
- **Ham Radio**: WSJT-X, fldigi, digital modes
- **Development**: Languages, IDEs, editors
- **Communication**: Email, chat, VoIP
- **Security**: Password managers, encryption, pen-testing
- **Gaming**: Steam, emulators, Wine
- **Cloud**: Docker, Kubernetes, Terraform
- **Scientific**: Octave, R, Python scientific stack
- And many more!

## Contributing

This configuration follows the official [Void Linux documentation](https://docs.voidlinux.org/about/index.html) exactly. Contributions should maintain compatibility with the documented Void Linux way of doing things.