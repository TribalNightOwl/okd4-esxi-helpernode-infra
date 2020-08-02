#!/bin/bash
ESXI_SERVER=192.168.1.200
HELPERNODE=192.168.1.203
INSTALL_DIR=~/ocp4

echo Creating VMs in the ESXi server
cd terraform
terraform init
terraform apply
cd ..

read -p "Press ENTER to continue" CONTINUE


echo Start web server to offer kickstart file
mkdir /tmp/kickstart
cp files/ks.cfg /tmp/kickstart
chmod -R 755 /tmp/kickstart
docker run --rm --name helpernode-nginx -v /tmp/kickstart:/usr/share/nginx/html:ro -p 80:80 -d nginx

echo curl http://192.168.1.150/ks.cfg

read -p "Press ENTER to continue" CONTINUE


echo Attaching ISO to helpernode VM and booting it
ansible-playbook playbooks/attach-iso-to-vm.yaml -vv

echo Open the console and install the OS then,
echo vmlinux initrd=initrd.img ks=http://192.168.1.150/ks.cfg
echo Close the vmrc window after successful installation and rebooting the helpernode
BOOTSTRAPVM=$(ssh root@${ESXI_SERVER} vim-cmd vmsvc/getallvms |grep ocp4-helpernode | cut -f1 -d ' ')
vmrc --host=${ESXI_SERVER} --user=root --password=$TF_VAR_esxi_password --moid=$BOOTSTRAPVM
read -p "Press ENTER to continue" CONTINUE

echo Copy your ssh key to helpernode
echo ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "${HELPERNODE}"
echo ssh-copy-id root@${HELPERNODE}

read -p "Press ENTER to continue" CONTINUE

echo Initial configuration of helpernode
ansible-playbook playbooks/main.yaml -vv

echo Stop here and ssh into the helpernode to execute the following:
cat <<EOT
ssh root@${HELPERNODE}
cd ~/ocp4-helpernode
ansible-playbook -e @vars.yaml tasks/main.yml

for CHECK in dns-masters dns-workers dns-etcd dns-other local-registry-info install-info haproxy services nfs-info ; do
        printf "\n\n##############################################\n\n"
        /usr/local/bin/helpernodecheck $CHECK
        read -p "press ENTER to continue" ENTER
done
EOT

read -p "Press ENTER to continue" CONTINUE

echo Generating ignition configs
ansible-playbook playbooks/ignition-configs.yaml -vv

read -p "Press ENTER to continue" CONTINUE


echo Booting cluster VMs
ansible-playbook playbooks/boot-cluster-vms.yaml -vv

read -p "Press ENTER to continue" CONTINUE


echo check HAProxy stats:  http://${HELPERNODE}:9000
echo Wait until all are green

read -p "Press ENTER to continue" CONTINUE

echo Stop here and ssh into the helpernode to execute the following:
cat <<EOT
ssh root@${HELPERNODE}
cd ${INSTALL_DIR}
export KUBECONFIG=${INSTALL_DIR}/auth/kubeconfig
openshift-install wait-for bootstrap-complete --log-level debug
EOT
read -p "Press ENTER to continue" CONTINUE

echo Approving CSRs
echo this needs improvement
ansible-playbook playbooks/approve-csrs.yaml -vv

read -p "Press ENTER to continue" CONTINUE

echo Reconfiguring operators
ansible-playbook playbooks/patch-operators.yaml -vv

read -p "Press ENTER to continue" CONTINUE

echo Stop here and ssh into the helpernode to execute the following:
cat <<EOT
ssh root@${HELPERNODE}
cd ${INSTALL_DIR}
export KUBECONFIG=${INSTALL_DIR}/auth/kubeconfig
openshift-install wait-for install-complete
cat ${INSTALL_DIR}/auth/kubeadmin-password
helpernodecheck nfs-setup
oc patch configs.imageregistry.operator.openshift.io cluster --type=json -p '[{"op": "remove", "path": "/spec/storage/emptyDir" }]'
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"pvc":{ "claim": "registry-pvc"}}}}'
EOT
