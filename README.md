# okd4-esxi-helpernode-infra

** THIS IS A WORK IN PROGRESS **

Set up ESXi infra for ocp4-helpernode

# Before executing the deployment

Load the necessary ssh keys into an ssh-agent

Create a .env file based on the env.example from the repo

Configure playbooks/vars.yaml to fit your environment

# To install the helper node

`helpernode.sh deploy`

and follow the prompts

# To remove the helper node

`helpernode.sh destroy`
