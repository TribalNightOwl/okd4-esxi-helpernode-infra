#!/bin/bash
source .env

docker build  . -t helpernode-builder

function docker_run {
        # First argument = working directory
        # Second argument = command to execute in the container
        docker run --rm -v $(pwd):/files -v ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}  -e SSH_AUTH_SOCK="${SSH_AUTH_SOCK}" --env-file .env --workdir $1 helpernode-builder $2
}


echo Creating VMs in the ESXi server
docker_run /files/terraform  "terraform init"
docker_run /files/terraform  "terraform apply -auto-approve"

read -p "Press ENTER to continue" CONTINUE


echo Start web server to offer kickstart file
KICKSTART_DIR=/tmp/kickstart-helpernode
mkdir ${KICKSTART_DIR}
cp files/ks.cfg ${KICKSTART_DIR}
chmod -R 755 ${KICKSTART_DIR}
docker run --rm --name helpernode-nginx -v ${KICKSTART_DIR}:/usr/share/nginx/html:ro -p 80:80 -d nginx:1.19

echo curl http://${LOCAL_IP}/ks.cfg

read -p "Press ENTER to continue" CONTINUE


echo Attaching ISO to helpernode VM and booting it
docker_run /files "ansible-playbook playbooks/attach-iso-to-vm.yaml -vv"

echo Open the console and install the OS then,
echo vmlinux initrd=initrd.img ks=http://${LOCAL_IP}/ks.cfg
echo Close the vmrc window after successful installation and rebooting the helpernode
BOOTSTRAPVM=$(ssh root@${ESXI_SERVER} vim-cmd vmsvc/getallvms |grep ocp4-helpernode | cut -f1 -d ' ')
vmrc --host=${ESXI_SERVER} --user=root --password=$TF_VAR_esxi_password --moid=$BOOTSTRAPVM
read -p "Press ENTER to continue" CONTINUE

echo Stopping web server
docker stop helpernode-nginx
rm -rf ${KICKSTART_DIR}

read -p "Press ENTER to continue" CONTINUE

echo Copy your ssh key to helpernode
echo ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "${HELPERNODE}"
echo ssh-copy-id -o StrictHostKeyChecking=no root@${HELPERNODE}

read -p "Press ENTER to continue" CONTINUE

echo Initial configuration of helpernode
docker_run /files "ansible-playbook playbooks/main.yaml -vv"


echo Configuring machind as Helpernode
ssh root@${HELPERNODE} <<EOT
cd ~/ocp4-helpernode
ansible-playbook -e @vars.yaml tasks/main.yml
EOT

for CHECK in dns-masters dns-workers dns-etcd dns-other local-registry-info install-info haproxy services nfs-info ; do
        ssh root@${HELPERNODE}  /usr/local/bin/helpernodecheck $CHECK
        read -p "press ENTER to continue" ENTER
done

echo Generating ignition configs
docker_run /files "ansible-playbook playbooks/ignition-configs.yaml -vv"

read -p "Press ENTER to continue" CONTINUE


echo Booting cluster VMs
docker_run /files "ansible-playbook playbooks/boot-cluster-vms.yaml -vv"

read -p "Press ENTER to continue" CONTINUE


echo check HAProxy stats:  http://${HELPERNODE}:9000
echo Wait until all are green
read -p "Press ENTER to continue" CONTINUE

echo Waiting for bootstrap to complete
ssh root@${HELPERNODE} <<EOT
cd ${INSTALL_DIR}
export KUBECONFIG=${INSTALL_DIR}/auth/kubeconfig
openshift-install wait-for bootstrap-complete --log-level debug
EOT
read -p "Press ENTER to continue" CONTINUE

docker_run /files "ansible-playbook playbooks/approve-csrs.yaml -vv"
read -p "Press ENTER to continue" CONTINUE


docker_run /files "ansible-playbook playbooks/set-managementState-to-Managed.yaml -vv"
read -p "Press ENTER to continue" CONTINUE

docker_run /files "ansible-playbook playbooks/open-image-registry-route.yaml -vv"
read -p "Press ENTER to continue" CONTINUE

echo Setting up NFS in helpernode
ssh root@${HELPERNODE} <<EOT
cd ${INSTALL_DIR}
export KUBECONFIG=${INSTALL_DIR}/auth/kubeconfig
openshift-install wait-for install-complete
cat ${INSTALL_DIR}/auth/kubeadmin-password
helpernodecheck nfs-setup
EOT
read -p "Press ENTER to continue" CONTINUE

echo Use NFS for PVCs
docker_run /files "ansible-playbook playbooks/use-nfs-for-pvc.yaml -vv"

read -p "Press ENTER to continue" CONTINUE

echo Shutting down bootstrap VM
docker_run /files "ansible-playbook playbooks/shutdown-bootstrap-vm.yaml -vv"
