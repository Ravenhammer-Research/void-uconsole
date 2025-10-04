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
module: runit
short_description: Manage services with runit service supervisor
description:
    - Manage services using runit, the service supervisor used by Void Linux.
    - Supports starting, stopping, restarting, and querying services.
    - Can also enable/disable services and manage service status.
version_added: "1.0.0"
author: "Void Linux Community"
requirements:
    - sv (runit service control utility)
options:
    name:
        description:
            - Name of the service to manage.
        type: str
        required: true
    state:
        description:
            - Desired state of the service.
        type: str
        choices: [ started, stopped, restarted, reloaded ]
        default: started
    enabled:
        description:
            - Whether the service should be enabled (linked in /var/service).
        type: bool
    user:
        description:
            - Run service as a specific user (for per-user services).
        type: str
    timeout:
        description:
            - Timeout in seconds for service operations.
        type: int
        default: 10
    service_dir:
        description:
            - Directory where services are located (default /etc/sv for system services).
        type: str
        default: /etc/sv
notes:
    - runit is the service supervisor used by Void Linux.
    - Services are typically located in /etc/sv for system services.
    - Per-user services are located in ~/.local/share/sv or ~/.config/sv.
    - This module requires appropriate privileges to manage system services.
examples:
    - name: Start a service
      runit:
        name: sshd
        state: started

    - name: Stop a service
      runit:
        name: sshd
        state: stopped

    - name: Restart a service
      runit:
        name: sshd
        state: restarted

    - name: Enable and start a service
      runit:
        name: nginx
        state: started
        enabled: yes

    - name: Disable a service
      runit:
        name: nginx
        enabled: no

    - name: Manage per-user service
      runit:
        name: myapp
        user: myuser
        state: started
'''

EXAMPLES = '''
# Start sshd service
- runit:
    name: sshd
    state: started

# Stop nginx service
- runit:
    name: nginx
    state: stopped

# Restart a service
- runit:
    name: sshd
    state: restarted

# Enable and start a service
- runit:
    name: nginx
    state: started
    enabled: yes

# Disable a service
- runit:
    name: nginx
    enabled: no

# Manage per-user service
- runit:
    name: myapp
    user: myuser
    state: started
'''

RETURN = '''
service:
    description: Name of the service
    returned: always
    type: str
    sample: "sshd"
state:
    description: Current state of the service
    returned: always
    type: str
    sample: "running"
enabled:
    description: Whether the service is enabled
    returned: always
    type: bool
    sample: true
changed:
    description: Whether any changes were made
    returned: always
    type: bool
    sample: true
'''

import os
import subprocess
import time
from ansible.module_utils.basic import AnsibleModule


def run_command(module, cmd, check_rc=True):
    """Run a command and return the result."""
    try:
        rc, stdout, stderr = module.run_command(cmd, check_rc=check_rc)
        return rc, stdout, stderr
    except subprocess.CalledProcessError as e:
        module.fail_json(msg="Command failed: %s" % str(e))


def get_service_path(module, service_name, user=None, service_dir="/etc/sv"):
    """Get the full path to a service directory."""
    if user:
        # Per-user service
        user_home = os.path.expanduser(f"~{user}")
        # Try different locations for user services
        possible_paths = [
            os.path.join(user_home, ".local/share/sv", service_name),
            os.path.join(user_home, ".config/sv", service_name),
            os.path.join(user_home, "sv", service_name)
        ]
        for path in possible_paths:
            if os.path.exists(path):
                return path
        return possible_paths[0]  # Default to first location
    else:
        # System service
        return os.path.join(service_dir, service_name)


def get_service_link_path(service_name, user=None):
    """Get the path where the service should be linked."""
    if user:
        # Per-user service link
        user_home = os.path.expanduser(f"~{user}")
        return os.path.join(user_home, ".local/share/service", service_name)
    else:
        # System service link
        return os.path.join("/var/service", service_name)


def service_exists(module, service_path):
    """Check if a service directory exists."""
    return os.path.exists(service_path)


def service_enabled(module, service_name, user=None):
    """Check if a service is enabled (linked in service directory)."""
    link_path = get_service_link_path(service_name, user)
    return os.path.exists(link_path) or os.path.islink(link_path)


def service_running(module, service_name, user=None, timeout=10):
    """Check if a service is running."""
    cmd = ['sv', 'status', service_name]
    if user:
        cmd = ['sudo', '-u', user] + cmd
    
    rc, stdout, stderr = run_command(module, cmd, check_rc=False)
    
    if rc != 0:
        return False
    
    # Check if service is up and running
    return 'run:' in stdout and 'up' in stdout


def sv_control(module, service_name, action, user=None, timeout=10):
    """Control a service using sv command."""
    cmd = ['sv', action, service_name]
    if user:
        cmd = ['sudo', '-u', user] + cmd
    
    rc, stdout, stderr = run_command(module, cmd, check_rc=False)
    
    if rc != 0:
        return False, stdout, stderr
    
    # Wait for service to reach desired state
    if action in ['start', 'stop', 'restart']:
        time.sleep(1)  # Give service time to change state
    
    return True, stdout, stderr


def enable_service(module, service_name, service_path, user=None):
    """Enable a service by creating a symlink."""
    link_path = get_service_link_path(service_name, user)
    link_dir = os.path.dirname(link_path)
    
    # Create link directory if it doesn't exist
    if not os.path.exists(link_dir):
        if user:
            cmd = ['sudo', '-u', user, 'mkdir', '-p', link_dir]
        else:
            cmd = ['mkdir', '-p', link_dir]
        run_command(module, cmd)
    
    # Create symlink
    if user:
        cmd = ['sudo', '-u', user, 'ln', '-sf', service_path, link_path]
    else:
        cmd = ['ln', '-sf', service_path, link_path]
    
    rc, stdout, stderr = run_command(module, cmd)
    return rc == 0


def disable_service(module, service_name, user=None):
    """Disable a service by removing the symlink."""
    link_path = get_service_link_path(service_name, user)
    
    if os.path.exists(link_path) or os.path.islink(link_path):
        if user:
            cmd = ['sudo', '-u', user, 'rm', '-f', link_path]
        else:
            cmd = ['rm', '-f', link_path]
        
        rc, stdout, stderr = run_command(module, cmd)
        return rc == 0
    
    return True  # Already disabled


def main():
    module = AnsibleModule(
        argument_spec=dict(
            name=dict(type='str', required=True),
            state=dict(type='str', default='started', choices=['started', 'stopped', 'restarted', 'reloaded']),
            enabled=dict(type='bool'),
            user=dict(type='str'),
            timeout=dict(type='int', default=10),
            service_dir=dict(type='str', default='/etc/sv'),
        ),
        supports_check_mode=True
    )
    
    service_name = module.params['name']
    state = module.params['state']
    enabled = module.params['enabled']
    user = module.params['user']
    timeout = module.params['timeout']
    service_dir = module.params['service_dir']
    
    service_path = get_service_path(module, service_name, user, service_dir)
    link_path = get_service_link_path(service_name, user)
    
    changed = False
    result = {
        'service': service_name,
        'state': 'unknown',
        'enabled': False,
        'changed': False
    }
    
    # Check if service exists
    if not service_exists(module, service_path):
        module.fail_json(msg="Service %s does not exist at %s" % (service_name, service_path))
    
    # Get current state
    currently_enabled = service_enabled(module, service_name, user)
    currently_running = service_running(module, service_name, user, timeout)
    
    result['enabled'] = currently_enabled
    result['state'] = 'running' if currently_running else 'stopped'
    
    # Handle enabled/disabled state
    if enabled is not None:
        if enabled and not currently_enabled:
            if module.check_mode:
                changed = True
            else:
                if enable_service(module, service_name, service_path, user):
                    changed = True
                    result['enabled'] = True
                else:
                    module.fail_json(msg="Failed to enable service %s" % service_name)
        elif not enabled and currently_enabled:
            if module.check_mode:
                changed = True
            else:
                if disable_service(module, service_name, user):
                    changed = True
                    result['enabled'] = False
                else:
                    module.fail_json(msg="Failed to disable service %s" % service_name)
    
    # Handle service state
    if state == 'started' and not currently_running:
        if module.check_mode:
            changed = True
        else:
            success, stdout, stderr = sv_control(module, service_name, 'start', user, timeout)
            if success:
                changed = True
                result['state'] = 'running'
            else:
                module.fail_json(msg="Failed to start service %s: %s" % (service_name, stderr))
    
    elif state == 'stopped' and currently_running:
        if module.check_mode:
            changed = True
        else:
            success, stdout, stderr = sv_control(module, service_name, 'stop', user, timeout)
            if success:
                changed = True
                result['state'] = 'stopped'
            else:
                module.fail_json(msg="Failed to stop service %s: %s" % (service_name, stderr))
    
    elif state == 'restarted':
        if module.check_mode:
            changed = True
        else:
            success, stdout, stderr = sv_control(module, service_name, 'restart', user, timeout)
            if success:
                changed = True
                result['state'] = 'running' if service_running(module, service_name, user, timeout) else 'stopped'
            else:
                module.fail_json(msg="Failed to restart service %s: %s" % (service_name, stderr))
    
    elif state == 'reloaded':
        if module.check_mode:
            changed = True
        else:
            success, stdout, stderr = sv_control(module, service_name, 'reload', user, timeout)
            if success:
                changed = True
            else:
                module.fail_json(msg="Failed to reload service %s: %s" % (service_name, stderr))
    
    result['changed'] = changed
    module.exit_json(**result)


if __name__ == '__main__':
    main()
