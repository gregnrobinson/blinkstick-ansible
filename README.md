# Blinkstick Ansible

![deploy workflow](https://github.com/gregnrobinson/blinkstick-ansible/actions/workflows/test.yml/badge.svg)

Much of the inspiration is from https://github.com/arvydas/blinkstick-python/wiki where some of the python snippets worked as-is and some did not. Some of the snippets are from Python 2.7 and wouldn't work on Python 3.X. I am using At least Python 3.8 for everything python related.

The reason for creating this repository was for me to have an easy way to operate 4 Blinkstick Nanos that I had bought for my raspberry pi kubernetes cluster. Having multiple nodes with separate Blinksticks, I wanted an abstraction layer on all four nodes that makes managing the configurations less monotonous. I have supplied several roles that can be executed against the blinksticks.

<p align="center">
  <img src="https://user-images.githubusercontent.com/26353407/126090043-1788cdf8-8f37-4aba-a160-d526d99923f5.jpg" width="415" />
  <img src="https://user-images.githubusercontent.com/26353407/126090049-028d24e4-5ed2-4389-b4d3-83007da041b6.jpg" width="415" />
</p>

## Install

## Instructions

Get the following packages and materials on the machine executing Ansible. I am using 4 Blinkstick Nanos for this project, but any blinkstick should work.

- [Get some Blinksticks](https://www.blinkstick.com/products/blinkstick-nano)
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

## Available Tags

| tag      |      description     |
|:----------|:-------------|
| get-info       | Collects all blinkstick information across all nodes. This includes serial numbers. |
| install         | Install all python packages defined in the `python_packages` list variable in `main.yaml`. |
| cpu-usage       | Monitors CPU usage using `psutil` and returns the appropriate color based on the percentage. This script runs indefinitely and checks every second. | 
| internet-status | When executed, a python script checks for internet access. If internet is up, color is green, if internet is down, color switches to purple. |
| aliases | Used to create aliases that can be used directly in the command-line to execute the defined roles without knowing the full ansible-playbook command.  |
| rave | Executes a sequenece to perform a lightshow on all blinksticks. |
| off | Turn all blinksticks off. |

```bash
# Deploy everything !!
ansible-playbook main.yaml -t deploy
  # executes the following...
  # -t get-info
  # -t install
  # -t cpu-usage
  # -t internet-status
  # -t aliases

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

## Cron Scheduler

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

## Troubleshooting

Blinkstick is having problems with python `3.9.2`. I installed the latest version of Raspian (Debian Bullseye) and it ships with `3.9.2`. On the other nodes, I was using `<=3.8.2` so installed python `3.8.2` on Debian and got it to work using the steps below.

the issue appears when executing blinkstick using `sudo blinkstick`. This is essentially a workaround using a workaround because even with Python 3.8 there are problems which are outlined in [this issue](https://github.com/arvydas/blinkstick-python/issues/34).  Shown below is the output on each version followed by steps to get it working on your system using Python 3.8. I think even using Python 3.7 would just work out of the box without the extra steps...

### Python 3.9 Output

```bash
pi@kube1:~/python38-env $ python3 --version
Python 3.9.2

pi@kube1:~/python38-env $ sudo blinkstick --blink green
Traceback (most recent call last):
  File "/usr/local/bin/blinkstick", line 331, in <module>
    sys.exit(main())
  File "/usr/local/bin/blinkstick", line 220, in main
    sticks = blinkstick.find_all()
  File "/usr/local/lib/python3.9/dist-packages/blinkstick/blinkstick.py", line 1566, in find_all
    result.extend([BlinkStick(device=d)])
  File "/usr/local/lib/python3.9/dist-packages/blinkstick/blinkstick.py", line 217, in __init__
    self.bs_serial = self.get_serial()
  File "/usr/local/lib/python3.9/dist-packages/blinkstick/blinkstick.py", line 283, in get_serial
    return self._usb_get_string(self.device, 3)
  File "/usr/local/lib/python3.9/dist-packages/blinkstick/blinkstick.py", line 221, in _usb_get_string
    return usb.util.get_string(device, index, 1033)
  File "/usr/local/lib/python3.9/dist-packages/usb/util.py", line 260, in get_string
    return buf[2:buf[0]].tostring().decode('utf-16-le')
IndexError: array index out of range
```

### Python 3.8 Output

```
pi@kube1:~/python38-env $ source ./bin/activate
(python38-env) pi@kube1:~/python38-env $ python --version
Python 3.8.2
```

Change file `/usr/local/bin/blinkstick` interpretor from `#!/usr/bin/env python` to `#!/home/pi/python38-env/bin/python3`

```bash
(python38-env) pi@kube1:~/python38-env $ head -5 /usr/local/bin/blinkstick
#!/home/pi/python38-env/bin/python3

from optparse import OptionParser, IndentedHelpFormatter, OptionGroup
from blinkstick import blinkstick
```

Run `sudo blinkstick --blink green`

```bash
(python38-env) pi@kube1:~/python38-env $ sudo blinkstick --blink green
(python38-env) pi@kube1:~/python38-env $
```

## Install Blinkstick inside Python 3.8 virtual environment

### Create Python 3.8 virtual environment
```bash
# Install python 3.8 on debian: https://linuxize.com/post/how-to-install-python-3-8-on-debian-10/

mkdir ~/python38-env && cd ~/python38-env
python3.8 -m venv .
source ./bin/activate
```

*Perform Python 3.8  workaround steps*

```bash
sudo apt-get install dos2unix
pip install pyusb
pip install blinkstick
sudo chmod +x /usr/local/bin/blinkstick
```

### Change python interpretor for blinktick module

*Note: In my case I used python38-env as the target folder when creating the virtual env in the early steps.*

By changing the interpreter in the module directly will allow Blinkstick to function when the virtual env is deactivated.

`#!/usr/bin/env python` to `#!/home/pi/python38-env/bin/python3`

Run `sudo blinkstick` and you should see the help menu.

Running `sudo blinkstick --blink green` works on the host.

## Reference

Install Python 3.8 on Debian 10: https://linuxize.com/post/how-to-install-python-3-8-on-debian-10/
Install Python 3.8 on Debian 11: https://www.linuxcapable.com/how-to-install-python-3-8-on-debian-11-bullseye/ *I used the Debian 10 tutorial for installing on bullseye but then found this version. Looks like it installs 3.8.12 instead of 3.8.2*
Python 3.8 workaround reference: https://github.com/arvydas/blinkstick-python/issues/34
