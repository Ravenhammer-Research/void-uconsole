# Void Linux Package Groups

This file documents the package groups available for easy installation of related software.

## Usage

To use these package groups in your Ansible playbooks, include them in your variables:

```yaml
# Example: Install browsers
- name: Install web browsers
  xbps:
    name: "{{ void_pkg_browsers }}"
    state: present

# Example: Install SDR tools
- name: Install SDR software
  xbps:
    name: "{{ void_pkg_sdr }}"
    state: present

# Example: Install complete development environment
- name: Install development tools
  xbps:
    name: "{{ void_pkg_dev_core + void_pkg_dev_languages + void_pkg_dev_editors }}"
    state: present
```

## Available Package Groups

### Web Browsers
- `void_pkg_browsers` - Modern and text-based web browsers

### Multimedia

#### Audio
- `void_pkg_audio_players` - Audio playback applications
- `void_pkg_audio_production` - DAW, synthesizers, and music creation tools
- `void_pkg_audio_tools` - Audio utilities and processing tools

#### Video
- `void_pkg_video_players` - Video playback applications
- `void_pkg_video_editors` - Video editing software
- `void_pkg_video_tools` - Video conversion, streaming, and utilities

#### Graphics & Imaging
- `void_pkg_image_editors` - Raster and vector image editors
- `void_pkg_image_viewers` - Image viewing applications
- `void_pkg_3d_graphics` - 3D modeling and rendering

### SDR (Software Defined Radio)
- `void_pkg_sdr` - Complete SDR suite including GNURadio, GQRX, and hardware support
- `void_pkg_hamradio` - Amateur radio applications

### Development
- `void_pkg_dev_core` - Compilers, build tools, version control
- `void_pkg_dev_languages` - Programming language runtimes
- `void_pkg_dev_editors` - Text editors and code editors
- `void_pkg_dev_ide` - Integrated Development Environments

### Communication
- `void_pkg_comm_email` - Email clients
- `void_pkg_comm_chat` - Instant messaging and IRC
- `void_pkg_comm_voip` - Voice and video calling

### Office & Productivity
- `void_pkg_office` - Office suites and word processors
- `void_pkg_pdf` - PDF viewers and editors
- `void_pkg_ebooks` - E-book readers and managers

### System Tools
- `void_pkg_system_monitors` - System monitoring utilities
- `void_pkg_system_utils` - General system utilities
- `void_pkg_disk_tools` - Disk partitioning and management
- `void_pkg_backup` - Backup and snapshot tools

### Networking
- `void_pkg_network_tools` - Network analysis and monitoring
- `void_pkg_network_apps` - FTP, SSH, VPN clients

### Security & Privacy
- `void_pkg_security` - Password managers, encryption tools
- `void_pkg_security_tools` - Penetration testing and security auditing
- `void_pkg_anonymity` - Tor, I2P, and privacy tools

### Gaming
- `void_pkg_gaming` - Game launchers, Steam, Wine
- `void_pkg_emulators` - Console emulators

### Cloud & Containers
- `void_pkg_containers` - Docker, Podman, Kubernetes
- `void_pkg_cloud_tools` - Cloud platform CLI tools

### Databases
- `void_pkg_databases` - SQL and NoSQL database servers

### Web Development
- `void_pkg_webdev` - Web servers and development tools

### Virtualization
- `void_pkg_virtualization` - QEMU, VirtualBox, libvirt

### Desktop Environments
- `void_pkg_desktop_kde` - KDE Plasma complete setup
- `void_pkg_desktop_gnome` - GNOME complete setup
- `void_pkg_desktop_xfce` - XFCE complete setup
- `void_pkg_desktop_mate` - MATE complete setup
- `void_pkg_desktop_cinnamon` - Cinnamon complete setup

### Utilities
- `void_pkg_fonts` - Font collections
- `void_pkg_filemanagers` - GUI and TUI file managers
- `void_pkg_terminals` - Terminal emulators
- `void_pkg_wm_x11` - X11 window managers
- `void_pkg_wm_wayland` - Wayland compositors
- `void_pkg_archiving` - Archive and compression tools
- `void_pkg_downloaders` - Download managers and torrent clients
- `void_pkg_screenshot` - Screenshot utilities
- `void_pkg_screencast` - Screen recording tools

### Specialized Software
- `void_pkg_scientific` - Scientific computing and mathematics
- `void_pkg_astronomy` - Astronomy and planetarium software
- `void_pkg_music_production` - Music composition and production
- `void_pkg_cad` - Computer-Aided Design
- `void_pkg_electronics` - Electronics design and Arduino

### Workstation Meta-Groups
- `void_pkg_workstation_complete` - Essential applications for a complete workstation

## Examples

### Complete Development Workstation

```yaml
- name: Setup development environment
  xbps:
    name: "{{ void_pkg_dev_core + void_pkg_dev_languages + void_pkg_dev_editors + void_pkg_dev_ide }}"
    state: present
```

### Multimedia Production Studio

```yaml
- name: Setup multimedia production
  xbps:
    name: "{{ void_pkg_audio_production + void_pkg_video_editors + void_pkg_image_editors }}"
    state: present
```

### SDR and Ham Radio Station

```yaml
- name: Setup SDR station
  xbps:
    name: "{{ void_pkg_sdr + void_pkg_hamradio }}"
    state: present
```

### Security and Penetration Testing

```yaml
- name: Setup security tools
  xbps:
    name: "{{ void_pkg_security + void_pkg_security_tools }}"
    state: present
```

### Gaming Setup

```yaml
- name: Setup gaming environment
  xbps:
    name: "{{ void_pkg_gaming + void_pkg_emulators }}"
    state: present
```

## Custom Package Groups

You can create your own custom package groups in your playbooks:

```yaml
my_custom_group:
  - package1
  - package2
  - package3

- name: Install custom group
  xbps:
    name: "{{ my_custom_group }}"
    state: present
```

## Combining Groups

Combine multiple groups using the `+` operator:

```yaml
- name: Install combined groups
  xbps:
    name: "{{ void_pkg_browsers + void_pkg_comm_email + void_pkg_office }}"
    state: present
```

## Notes

- All package names correspond to actual packages in the Void Linux repositories
- Some packages may require the `nonfree` or `multilib` repositories
- Hardware-specific packages (like SDR hardware drivers) may require additional setup
- Desktop environments include essential applications but not all optional packages

## Contributing

To add new package groups or update existing ones, edit the `package_groups.yml` file and submit a pull request.

