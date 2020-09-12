# okd4-esxi-helpernode-infra

Automated install of an OpenShift 4 cluster in the free version of VMware ESXi 6.5


## Requirements

- Free version of VMware ESXi 6.5 (might work with other versions)
- SSH-enabled in the ESXi server
- Passwordless login (ssh authorized keys) to ESXi server
- Docker
- RedHat pull secret from: https://cloud.redhat.com/openshift/install/metal
- VMware Remote Console (vmrc) from: http://www.vmware.com/go/download-vmrc



## Usage
Load the necessary ssh keys into an ssh-agent

Update `files/pull-secret.json` with your own pull secret from RedHat

Create a `.env` file based on the env.example from the repo

Configure `playbooks/vars.yaml` and `hosts` to fit your environment


## To install the helper node

`helpernode.sh deploy`

and follow the prompts

## To remove the helper node

`helpernode.sh destroy`


## Credits
I am leveraging the work from: https://github.com/RedHatOfficial/ocp4-helpernode

