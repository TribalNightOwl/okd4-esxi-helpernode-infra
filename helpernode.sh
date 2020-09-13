#!/bin/bash
COMMAND=$1

function initialize_project {
        if [[ ! -e files/pull-secret.json ]] ; then
                printf "\nObtain your RedHat pull secret from: https://cloud.redhat.com/openshift/install/metal\n"
                printf "and create the 'files/pull-secret.json' file\n"
                read -p "Press <ENTER> when done" CONTINUE
        fi

        if [[ ! -e .env ]] ; then
                read -s -p "Enter the password for your ESXi server: " TF_VAR_esxi_password
                printf "\n"
                read -s -p "Enter the public SSH key used to ssh into the hosts: " PUBSSHKEY

                echo TF_VAR_esxi_password=${TF_VAR_esxi_password} >> .env
                echo PUBSSHKEY=\'${PUBSSHKEY}\' >> .env
        fi
}       

case "$COMMAND" in
        deploy ) initialize_project
                source .env
                export PUBSSHKEY
                ansible-playbook playbooks/configure-project.yaml
                ./deploy-helpernode.sh ;;

        destroy ) source config.sh
                docker_run /files/terraform "terraform destroy -auto-approve"
                rm -f deploy-helpernode.sh
                rm -f files/ks.cfg
                rm -f files/vars.yaml
                rm -f kubeadmin-password
                rm -f kubeconfig
                rm -f config.sh
                rm -rf terraform
                rm -f hosts
                ;;    
        * ) cat <<EOT
Usage:
        helpernode.sh deploy
        helpernode.sh destroy
EOT
        exit 0;;
esac
