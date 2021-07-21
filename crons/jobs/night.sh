# BEGIN ANSIBLE MANAGED BLOCK
 #!/bin/bash

# add ansible paths for project
export BLINK_PATH="/home/pi/blinkstick-ansible"
export ANSIBLE_CONFIG="/home/pi/blinkstick-ansible/ansible.cfg"

# blink-night
ansible-playbook ${BLINK_PATH}/main.yaml -i ${BLINK_PATH}/inventory/all.yaml -t blink-night
# END ANSIBLE MANAGED BLOCK
