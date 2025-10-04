# Package Groups Quick Reference

## Quick Install Commands

### Multimedia & Creative

```bash
# Audio workstation
ansible-playbook -e "packages={{ void_pkg_audio_production }}"

# Video editing suite
ansible-playbook -e "packages={{ void_pkg_video_editors }}"

# Graphics design
ansible-playbook -e "packages={{ void_pkg_image_editors }}"

# Complete multimedia production
ansible-playbook -e "packages={{ void_pkg_audio_production + void_pkg_video_editors + void_pkg_image_editors }}"
```

### SDR & Ham Radio

```bash
# SDR tools
ansible-playbook -e "packages={{ void_pkg_sdr }}"

# Ham radio
ansible-playbook -e "packages={{ void_pkg_hamradio }}"

# Complete radio station
ansible-playbook -e "packages={{ void_pkg_sdr + void_pkg_hamradio }}"
```

### Development

```bash
# Core development tools
ansible-playbook -e "packages={{ void_pkg_dev_core }}"

# Add programming languages
ansible-playbook -e "packages={{ void_pkg_dev_languages }}"

# Complete dev environment
ansible-playbook -e "packages={{ void_pkg_dev_core + void_pkg_dev_languages + void_pkg_dev_editors }}"
```

### Desktop Environments

```bash
# KDE Plasma
ansible-playbook -e "packages={{ void_pkg_desktop_kde }}"

# GNOME
ansible-playbook -e "packages={{ void_pkg_desktop_gnome }}"

# XFCE
ansible-playbook -e "packages={{ void_pkg_desktop_xfce }}"
```

### Gaming

```bash
# Gaming platform
ansible-playbook -e "packages={{ void_pkg_gaming }}"

# Emulators
ansible-playbook -e "packages={{ void_pkg_emulators }}"

# Complete gaming setup
ansible-playbook -e "packages={{ void_pkg_gaming + void_pkg_emulators }}"
```

## Package Groups by Category

| Category | Variable Name | Description |
|----------|---------------|-------------|
| **Browsers** | `void_pkg_browsers` | Web browsers (chromium, firefox, etc.) |
| **Audio Players** | `void_pkg_audio_players` | Music players and audio software |
| **Audio Production** | `void_pkg_audio_production` | DAWs, synthesizers, production tools |
| **Video Players** | `void_pkg_video_players` | Video playback applications |
| **Video Editors** | `void_pkg_video_editors` | Video editing software |
| **Image Editors** | `void_pkg_image_editors` | Raster & vector graphics |
| **Image Viewers** | `void_pkg_image_viewers` | Image viewing applications |
| **SDR** | `void_pkg_sdr` | Software-defined radio suite |
| **Ham Radio** | `void_pkg_hamradio` | Amateur radio applications |
| **Dev Core** | `void_pkg_dev_core` | Compilers, build tools, VCS |
| **Dev Languages** | `void_pkg_dev_languages` | Programming language runtimes |
| **Dev Editors** | `void_pkg_dev_editors` | Code editors |
| **Dev IDEs** | `void_pkg_dev_ide` | Integrated development environments |
| **Email** | `void_pkg_comm_email` | Email clients |
| **Chat** | `void_pkg_comm_chat` | Instant messaging & IRC |
| **VoIP** | `void_pkg_comm_voip` | Voice/video calling |
| **Office** | `void_pkg_office` | Office suites & productivity |
| **PDF Tools** | `void_pkg_pdf` | PDF viewers and editors |
| **eBooks** | `void_pkg_ebooks` | E-book readers |
| **System Monitors** | `void_pkg_system_monitors` | htop, btop, glances, etc. |
| **System Utils** | `void_pkg_system_utils` | Essential utilities |
| **Disk Tools** | `void_pkg_disk_tools` | Partition & disk management |
| **Backup** | `void_pkg_backup` | Backup solutions |
| **Network Tools** | `void_pkg_network_tools` | Network analysis |
| **Network Apps** | `void_pkg_network_apps` | FTP, SSH, VPN clients |
| **Security** | `void_pkg_security` | Encryption & password managers |
| **Security Tools** | `void_pkg_security_tools` | Pen-testing tools |
| **Anonymity** | `void_pkg_anonymity` | Tor, I2P, privacy tools |
| **Gaming** | `void_pkg_gaming` | Game platforms & launchers |
| **Emulators** | `void_pkg_emulators` | Console emulators |
| **Containers** | `void_pkg_containers` | Docker, Podman, k8s |
| **Cloud Tools** | `void_pkg_cloud_tools` | AWS, Azure, GCP CLIs |
| **Databases** | `void_pkg_databases` | Database servers |
| **Webdev** | `void_pkg_webdev` | Web servers & tools |
| **Virtualization** | `void_pkg_virtualization` | QEMU, VirtualBox, etc. |
| **Fonts** | `void_pkg_fonts` | Font collections |
| **File Managers** | `void_pkg_filemanagers` | GUI & TUI file managers |
| **Terminals** | `void_pkg_terminals` | Terminal emulators |
| **WM X11** | `void_pkg_wm_x11` | X11 window managers |
| **WM Wayland** | `void_pkg_wm_wayland` | Wayland compositors |
| **Scientific** | `void_pkg_scientific` | Math & science software |
| **Astronomy** | `void_pkg_astronomy` | Planetarium & astronomy |
| **Archiving** | `void_pkg_archiving` | Compression tools |
| **Downloaders** | `void_pkg_downloaders` | Download & torrent managers |
| **Screenshot** | `void_pkg_screenshot` | Screenshot utilities |
| **Screencast** | `void_pkg_screencast` | Screen recording |
| **Music Production** | `void_pkg_music_production` | Music composition |
| **CAD** | `void_pkg_cad` | Computer-aided design |
| **Electronics** | `void_pkg_electronics` | Electronics & Arduino |
| **RSS Readers** | `void_pkg_rss` | RSS/Atom feed readers |

## Desktop Environment Bundles

| DE | Variable | Includes |
|----|----------|----------|
| **KDE Plasma** | `void_pkg_desktop_kde` | Plasma, Dolphin, Konsole, Kate, etc. |
| **GNOME** | `void_pkg_desktop_gnome` | GNOME Shell, Apps, Tweaks |
| **XFCE** | `void_pkg_desktop_xfce` | XFCE4, Thunar, Terminal |
| **MATE** | `void_pkg_desktop_mate` | MATE Desktop, Caja |
| **Cinnamon** | `void_pkg_desktop_cinnamon` | Cinnamon, Nemo |

## Workstation Bundles

| Bundle | Variable | Description |
|--------|----------|-------------|
| **Complete Workstation** | `void_pkg_workstation_complete` | Firefox, Thunderbird, LibreOffice, GIMP, VLC, etc. |

## Combining Groups

You can combine multiple groups in your playbooks:

```yaml
# Development + Multimedia workstation
packages: "{{ void_pkg_dev_core + void_pkg_dev_languages + void_pkg_audio_production + void_pkg_image_editors }}"

# Security research station
packages: "{{ void_pkg_security + void_pkg_security_tools + void_pkg_network_tools }}"

# Complete radio station
packages: "{{ void_pkg_sdr + void_pkg_hamradio + void_pkg_audio_production }}"
```

## Tips

1. **Start Small**: Install base groups first, then add specialized tools
2. **Check Dependencies**: Some packages may require additional repos (nonfree, multilib)
3. **Combine Wisely**: Don't install conflicting packages (e.g., multiple desktop environments)
4. **Update Regularly**: Keep package groups aligned with latest Void packages

## See Also

- Full documentation: `PACKAGE_GROUPS.md`
- Package group definitions: `defaults/package_groups.yml`
- Void Linux documentation: https://docs.voidlinux.org

