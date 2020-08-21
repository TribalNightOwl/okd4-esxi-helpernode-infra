# Download oc tool
curl --insecure https://downloads-openshift-console.apps.ocp4.example.com/amd64/linux/oc.tar | tar -x -C ../bin

# Download helm
curl https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest/helm-linux-amd64 --output ../bin/helm && chmod +x ../bin/helm

# set PATH ./bin
`export PATH=$(pwd)/../bin:$PATH`

# export KUBECONFIG=./kubeconfig
`export KUBECONFIG=$(pwd)/../kubeconfig`

# Create htpasswd file:
`htpasswd -c -B htpasswdfile cluster-admin`

`htpasswd -B htpasswdfile user01`

`htpasswd -B htpasswdfile user02`

# Create secret to keep htpasswd file
`oc create secret generic htpasswd-secret --from-file=htpasswd=./htpasswdfile -n openshift-config`

# Create a Custom Resource to use htpasswd as identity provider

```
cat <<EOT | oc create -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: my_identity_provider 
    mappingMethod: claim 
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpasswd-secret
EOT
```

# Create RBAC for cluster-admin

`oc adm policy add-cluster-role-to-user cluster-admin cluster-admin`

# Remove the kubeadmin user

Login as the cluster-admin user

`oc delete secrets kubeadmin -n kube-system`