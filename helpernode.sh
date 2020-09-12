#!/bin/bash
COMMAND=$1

case "$COMMAND" in
        deploy ) source .env
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
                rm -f terraform/main.tf
                rm -f terraform/vars.tf
                rm -f hosts
                ;;    
        * ) cat <<EOT
Usage:
        helpernode.sh deploy
        helpernode.sh destroy
EOT
        exit 0;;
esac
