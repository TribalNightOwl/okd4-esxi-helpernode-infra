# okd4-esxi-helpernode-infra

Automated install of an OpenShift 4 cluster in the free version of VMware ESXi 6.5


## Requirements

- Free version of VMware ESXi 6.5 (might work with other versions)
- SSH-enabled in the ESXi server
- Passwordless login (ssh authorized keys) to ESXi server
- Docker
- RedHat pull secret from: https://cloud.redhat.com/openshift/install/metal
- VMware Remote Console (vmrc) from: http://www.vmware.com/go/download-vmrc
- Ansible
- Docker SDK for Python https://pypi.org/project/docker



## Usage
Load the necessary ssh keys into an ssh-agent

Configure `playbooks/vars.yaml` to fit your environment

## To install the helper node

`helpernode.sh deploy`

and follow the prompts

## To remove the helper node

`helpernode.sh destroy`


## Credits
I am leveraging the work from: https://github.com/RedHatOfficial/ocp4-helpernode

