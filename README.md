# Blinkstick Ansible

![deploy workflow](https://github.com/gregnrobinson/blinkstick-ansible/actions/workflows/test.yml/badge.svg)

Much of the inspiration is from https://github.com/arvydas/blinkstick-python/wiki where some of the python snippets worked as-is and some did not. Some of the snippets are from Python 2.7 and wouldn't work on Python 3.X. I am using At least Python 3.8 for everything python related.

The reason for creating this repository was for me to have an easy way to operate 4 Blinkstick Nanos that I had bought for my Raspberry pi cluster. When you have multiple nodes with separate Blinksticks, having an abstraction layer on all four nodes allows for complete control of of all blinksticks using only single commands. This repository makes it possible to create patterns and sequences using blinksticks no matter where they are plugged in.

<p align="center">
  <img src="https://user-images.githubusercontent.com/26353407/126090043-1788cdf8-8f37-4aba-a160-d526d99923f5.jpg" width="415" />
  <img src="https://user-images.githubusercontent.com/26353407/126090049-028d24e4-5ed2-4389-b4d3-83007da041b6.jpg" width="415" />
</p>

## Instructions

Get the following packages and materials on the machine executing Ansible. I am using 4 Blinkstick Nanos for this project, but any blinkstick should work.

- [Get a Blinkstick](https://www.blinkstick.com/products/blinkstick-nano) 
- [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [python 3.X](https://www.python.org/downloads/)
- [pip](https://pip.pypa.io/en/stable/installing/)

Modify `inventory/all.yaml` with your own IP addresses and blinkstick serial numbers. Ensure that you have passwordless ssh setup to all nodes before proceeding with any Ansible configuration.

Example entry looks like...
```yaml
node1: # name of the host. Arbitruary, it can be anything.
  ansible_host: 192.168.0.1 # IP address of the host
  serial: BS000001-3.0 # Run ansible-playbook main.yaml -t get-info to get this value for each node.
```

If you want to find the blinkstick serial numbers after mofifying the IP addresses, run the `get-info` tag. This saves you from logging into each node to find the serials.

## Available Commands

```bash
# Deploy everything !!
ansible-playbook main.yaml -t deploy
  # executes the following...
  # -t get-info
  # -t install
  # -t cpu-usage
  # -t internet-status
  # -t aliases
  # -t daynight

# Retrieve all Blinkstick information and serial number. Ensure the blinkstick is plugged into a USB slot before executing.
ansible-playbook main.yaml -t get-info

# Install all python library dependancies. Add or removes in the the python_packages list in main.yaml and re run this command to make the change on all nodes. 
ansible-playbook main.yaml -t install

# This roles uses the blinkstick python library to substitute the serial number from the ansible inventory and parse it as python. The script is then executed on the remote machines.
ansible-playbook main.yaml -t cpu-usage

# This roles uses the blinkstick python library to substitute the serial number from the ansible inventory and parse it as python. 
# A python script will continuously monitor the CPU percentage of the nodes and update the color accordingly.
ansible-playbook main.yaml -t internet-status

# Throw a party to celebrate getting everything installed.
ansible-playbook main.yaml -t rave

# Set the base color and brightness
ansible-playbook main.yaml -t base-config

# Or... pass the brightness and color inline using extra vars
ansible-playbook main.yaml -t base-config -e color=cyan -e brightness=50

# Turn all the Blinksticks off. (Useful for nighttime when you want to sleep. Use a cron to turn off automatically.)
ansible-playbook main.yaml -t off

# Creates aliases in either ~/.zprofile or ~/.bashrc, dynamically decided by the role.
ansible-playbook main.yaml -t aliases
  # The following aliases are added to either ~/.zprofile or ~/.bashrc....
  # blink-base
  # blink-day
  # blink-night
  # blink-rave
  # blink-off
```

## Cron Schedules

Add lines to the `vars.crons` section of `cron.yaml` to create cron jobs that execute locally on the machine running Ansible.

```yaml
vars:
  crons:
    day:   { minute: '0', hour: '8',  weekday: '*',   disabled: 'no', tag: 'base-config', brightness: '70', color: 'green' }
    night: { minute: '0', hour: '21', weekday: '*',   disabled: 'no', tag: 'base-config', brightness: '20', color: 'cyan' }
    rave:  { minute: '0', hour: '17', weekday: 'FRI', disabled: 'no', tag: 'rave',        brightness: '80', color: 'cyan' }
```

To apply cron schedules from the root of the repository...

```bash
ansible-playbook cron.yaml
```
