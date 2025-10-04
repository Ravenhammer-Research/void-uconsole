#!/usr/bin/python3
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Void Linux Community
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = '''
---
module: xbps
short_description: Manage packages with XBPS package manager
description:
    - Manage packages using Void Linux's XBPS (X Binary Package System) package manager.
    - Supports installation, removal, upgrade, and query operations.
version_added: "1.0.0"
author: "Void Linux Community"
requirements:
    - xbps-install
    - xbps-remove
    - xbps-query
    - xbps-pkgdb
options:
    name:
        description:
            - Package name(s) to manage.
        type: list
        elements: str
    state:
        description:
            - Desired state of the package.
        type: str
        choices: [ absent, present, latest ]
        default: present
    update_cache:
        description:
            - Update the package database before installing packages.
        type: bool
        default: yes
    force:
        description:
            - Force operations (equivalent to xbps-install -f).
        type: bool
        default: no
    repository:
        description:
            - Specify repository to use.
        type: str
    autoremove:
        description:
            - Remove orphaned packages when removing packages.
        type: bool
        default: no
    recursive:
        description:
            - Remove packages and their dependencies.
        type: bool
        default: no
notes:
    - XBPS is the package manager used by Void Linux.
    - This module requires root privileges to install/remove packages.
    - For querying packages, root privileges are not required.
examples:
    - name: Install a package
      xbps:
        name: vim
        state: present

    - name: Install multiple packages
      xbps:
        name:
          - vim
          - git
          - curl
        state: present

    - name: Remove a package
      xbps:
        name: vim
        state: absent

    - name: Update all packages
      xbps:
        name: "*"
        state: latest

    - name: Install package without updating cache
      xbps:
        name: vim
        state: present
        update_cache: no

    - name: Query package information
      xbps:
        name: vim
        state: query
'''

EXAMPLES = '''
# Install vim
- xbps:
    name: vim
    state: present

# Install multiple packages
- xbps:
    name:
      - vim
      - git
      - curl
    state: present

# Remove vim
- xbps:
    name: vim
    state: absent

# Update all packages
- xbps:
    name: "*"
    state: latest

# Query package information
- xbps:
    name: vim
    state: query
'''

RETURN = '''
packages:
    description: List of packages affected
    returned: always
    type: list
    elements: str
    sample: ["vim", "git"]
changed:
    description: Whether any changes were made
    returned: always
    type: bool
    sample: true
'''

import os
import re
import subprocess
import sys
from ansible.module_utils.basic import AnsibleModule


def run_command(module, cmd, check_rc=True):
    """Run a command and return the result."""
    try:
        rc, stdout, stderr = module.run_command(cmd, check_rc=check_rc)
        return rc, stdout, stderr
    except subprocess.CalledProcessError as e:
        module.fail_json(msg="Command failed: %s" % str(e))


def xbps_installed(module, package):
    """Check if a package is installed."""
    cmd = ['xbps-query', '-l', package]
    rc, stdout, stderr = run_command(module, cmd, check_rc=False)
    return rc == 0


def xbps_available(module, package):
    """Check if a package is available in repositories."""
    cmd = ['xbps-query', '-Rs', package]
    rc, stdout, stderr = run_command(module, cmd, check_rc=False)
    return rc == 0 and stdout.strip()


def xbps_install(module, packages, update_cache=True, force=False, repository=None):
    """Install packages using xbps-install."""
    cmd = ['xbps-install']
    
    if update_cache:
        cmd.append('-S')
    
    if force:
        cmd.append('-f')
    
    if repository:
        cmd.extend(['-r', repository])
    
    cmd.extend(packages)
    
    rc, stdout, stderr = run_command(module, cmd)
    return rc, stdout, stderr


def xbps_remove(module, packages, autoremove=False, recursive=False):
    """Remove packages using xbps-remove."""
    cmd = ['xbps-remove']
    
    if autoremove:
        cmd.append('-o')
    
    if recursive:
        cmd.append('-R')
    
    cmd.extend(packages)
    
    rc, stdout, stderr = run_command(module, cmd)
    return rc, stdout, stderr


def xbps_update(module, packages=None, update_cache=True):
    """Update packages using xbps-install."""
    cmd = ['xbps-install', '-u']
    
    if update_cache:
        cmd.append('-S')
    
    if packages and packages != ["*"]:
        cmd.extend(packages)
    elif packages == ["*"]:
        cmd.append('-u')
    
    rc, stdout, stderr = run_command(module, cmd)
    return rc, stdout, stderr


def xbps_query(module, package):
    """Query package information."""
    cmd = ['xbps-query', '-R', package]
    rc, stdout, stderr = run_command(module, cmd, check_rc=False)
    
    if rc != 0:
        return None
    
    # Parse package information
    info = {}
    for line in stdout.split('\n'):
        if ':' in line:
            key, value = line.split(':', 1)
            info[key.strip()] = value.strip()
    
    return info


def main():
    module = AnsibleModule(
        argument_spec=dict(
            name=dict(type='list', elements='str', required=True),
            state=dict(type='str', default='present', choices=['absent', 'present', 'latest', 'query']),
            update_cache=dict(type='bool', default=True),
            force=dict(type='bool', default=False),
            repository=dict(type='str'),
            autoremove=dict(type='bool', default=False),
            recursive=dict(type='bool', default=False),
        ),
        supports_check_mode=True
    )
    
    name = module.params['name']
    state = module.params['state']
    update_cache = module.params['update_cache']
    force = module.params['force']
    repository = module.params['repository']
    autoremove = module.params['autoremove']
    recursive = module.params['recursive']
    
    changed = False
    packages_affected = []
    
    # Handle query state
    if state == 'query':
        results = {}
        for package in name:
            info = xbps_query(module, package)
            if info:
                results[package] = info
            else:
                results[package] = {'status': 'not_found'}
        
        module.exit_json(
            changed=False,
            packages=name,
            query_results=results
        )
    
    # Handle other states
    for package in name:
        installed = xbps_installed(module, package)
        
        if state == 'present' and not installed:
            if module.check_mode:
                changed = True
                packages_affected.append(package)
            else:
                try:
                    rc, stdout, stderr = xbps_install(module, [package], update_cache, force, repository)
                    if rc == 0:
                        changed = True
                        packages_affected.append(package)
                    else:
                        module.fail_json(msg="Failed to install package %s: %s" % (package, stderr))
                except Exception as e:
                    module.fail_json(msg="Error installing package %s: %s" % (package, str(e)))
        
        elif state == 'absent' and installed:
            if module.check_mode:
                changed = True
                packages_affected.append(package)
            else:
                try:
                    rc, stdout, stderr = xbps_remove(module, [package], autoremove, recursive)
                    if rc == 0:
                        changed = True
                        packages_affected.append(package)
                    else:
                        module.fail_json(msg="Failed to remove package %s: %s" % (package, stderr))
                except Exception as e:
                    module.fail_json(msg="Error removing package %s: %s" % (package, str(e)))
        
        elif state == 'latest' and installed:
            if module.check_mode:
                changed = True
                packages_affected.append(package)
            else:
                try:
                    rc, stdout, stderr = xbps_update(module, [package], update_cache)
                    if rc == 0:
                        changed = True
                        packages_affected.append(package)
                    else:
                        module.fail_json(msg="Failed to update package %s: %s" % (package, stderr))
                except Exception as e:
                    module.fail_json(msg="Error updating package %s: %s" % (package, str(e)))
    
    module.exit_json(
        changed=changed,
        packages=packages_affected
    )


if __name__ == '__main__':
    main()
