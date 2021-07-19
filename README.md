# Blinkstick Ansible Tools

The reason for creating this repository was for me to have an easy way to operate 4 Blinkstick Nanos that I had bought for my Raspberry pi cluster. When you have multiple nodes with separate Blinksticks, having an abstraction layer on all four nodes makes it much easier to build tools that execute against all nodes, or a subset of nodes, or a subset of a subset of nodes, and so on.

Ansible seemed like the easiest path forward as I can make each tool as a role and use jinja templating for the python scripts that need to execute on the remote nodes. Using the python library directly, there is much more flexibility as to what can be achieved vs the cli tool that is provided also. When thinking about future development, this makes sense to be the standard method for all roles.

Much of the inspiration is from https://github.com/arvydas/blinkstick-python/wiki where some of the python snippets worked as-is and some did not. Some of the snippets are from Python 2.7 and wouldn't work on Python 3.X. I am using At least Python 3.8 for everything python related.

<p align="center">
  <img src="https://user-images.githubusercontent.com/26353407/126086407-b12d67a9-ed40-4127-b408-b52fa5732079.jpg" width="700" />
</p>

## Instructions

Get the following packages and materials on the machine executing Ansible. I am using 4 Blinkstick Nanos for this project, but any blinkstick should work.

- [Get a Blinkstick](https://www.blinkstick.com/products/blinkstick-nano) 
- [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [python 3.X](https://www.python.org/downloads/)
- [pip](https://pip.pypa.io/en/stable/installing/)

Modify the inventory file with your own IP addresses. Ensure that you have passwordless ssh setup to all nodes before proceeding with any Ansible configuration.

Example entry looks like...
```yaml
node1: # name of the host. Arbitruary, it can be anything.
  ansible_host: 192.168.0.1 # IP address of the host
  serial: BS000001-3.0 # Run ansible-playbook main.yaml -t get-info to get this value for each node.
```

If you want to find the blinkstick serial numbers after mofifying the IP addresses, run the `get-info` tag. This saves you from logging into each node to find the serials.

## Available Commands

```bash
# Retrieve all Blinkstick information and serial number. Ensure the blinkstick is plugged into a USB slot before executing.
ansible-playbook main.yaml -t get-info

# Install all python library dependancies. Add or removes in the the python_packages list in main.yaml and re run this command to make the change on all nodes. 
ansible-playbook main.yaml -t install

# This roles uses the blinkstick python library to substitute the serial number from the ansible inventory and parse it as python. The script is then executed on the remote machines.
ansible-playbook main.yaml -t cpu_usage

# This roles uses the blinkstick python library to substitute the serial number from the ansible inventory and parse it as python. The script is then executed on the remote machines.
ansible-playbook main.yaml -t internet_status

# Throw a party to celebrate getting everything installed.
ansible-playbook main.yaml -t party

# Turn all the Blinksticks off. (Useful for nighttime when you want to sleep. Use a cron to turn off automatically.)
ansible-playbook main.yaml -t turnoff
```

# Challenges

The biggest thought experiment was around how I would use Ansible to make sure when the python script executes that the serial number being used is the serial number of that particular instance. 

There are three main options when selecting a blinkstick in python.

```python
# get all blinksticks
bstick = blinkstick.find_all():

# This was the method chosen for most roles. Even tho it requires the serial to be set for each node prior to execution, I decided to go for the slightly harder way of doing this using jinja2 templating to substitute the serial for each node during role execution.
bstick = blinkstick.find_by_serial():

# Grab only the first blinkstick, this is good for when you only have one blinkstick plugged into a node. Saves you from getting the serial number everytime. As I write this, I think it would be easier to just use this method.
bstick = blinkstick.first():
```
