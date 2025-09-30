#!/bin/bash
set -euo pipefail

# Create release directory
mkdir void_uconsole_os
mv installer.* void_uconsole_os/

# Create archive with maximum compression
sudo 7z -mx=9 a "void_uconsole_os-${1}.7z" void_uconsole_os/