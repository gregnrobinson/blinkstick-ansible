#!/usr/bin/env bash

# add ansible paths for project
export BLINK_PATH="{{ BLINK_PATH }}"
export ANSIBLE_CONFIG="{{ ANSIBLE_CONFIG }}"

# blinksticks - base-config
alias blink-base='ansible-playbook ${BLINK_PATH}/main.yaml -i ${BLINK_PATH}/inventory/all.yaml -t base-config'

# blinksticks - turnoff
alias blink-off='ansible-playbook ${BLINK_PATH}/main.yaml -i ${BLINK_PATH}/inventory/all.yaml -t off'

# blinksticks - rave
alias blink-rave='ansible-playbook ${BLINK_PATH}/main.yaml -i ${BLINK_PATH}/inventory/all.yaml -t rave'

# blinksticks - night mode
alias blink-night='ansible-playbook ${BLINK_PATH}/main.yaml -i ${BLINK_PATH}/inventory/all.yaml -t base-config -e color=cyan -e brightness=30'

# blinksticks - day mode
alias blink-day='ansible-playbook ${BLINK_PATH}/main.yaml -i ${BLINK_PATH}/inventory/all.yaml -t base-config -e color=green -e brightness=70'

shopt -s expand_aliases