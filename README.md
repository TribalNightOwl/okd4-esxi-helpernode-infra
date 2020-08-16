# okd4-esxi-helpernode-infra

Automated install of an OpenShift 4 cluster in the free version of VMware ESXi 6.5


## Requirements

- Free version of VMware ESXi 6.5 (might work with other versions)
- SSH-enabled in the ESXi server
- Passwordless login (ssh authorized keys) to ESXi server
- Docker


## Usage
Load the necessary ssh keys into an ssh-agent

Create a .env file based on the env.example from the repo

Configure playbooks/vars.yaml to fit your environment


## To install the helper node

`helpernode.sh deploy`

and follow the prompts

## To remove the helper node

`helpernode.sh destroy`


## Credits
I am leveraging the work from: https://github.com/RedHatOfficial/ocp4-helpernode

