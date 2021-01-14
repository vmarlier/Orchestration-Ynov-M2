### Setup
To choose the workspace
```bash
export TF_WORKSPACE=production
# or
export TF_WORKSPACE=development
```

then
```bash
export TF_CLI_ARGS_apply="-parallelism=3 -auto-approve"
export TF_IN_AUTOMATION=1
export KUBECONFIG="$PWD/kubeconfig"
export KUBE_CONFIG_PATH=$KUBECONFIG
```

For the remote tfstate
```bash
export ARM_SECRET_KEY=
```

### How to use terraform
```bash
terraform init
terraform plan
terraform apply
```
