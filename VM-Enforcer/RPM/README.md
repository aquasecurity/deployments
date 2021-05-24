<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Building VM Enforcer RPM 

##### Prerequisites
1) NFPM (RPM Package Creator)
`curl -sfL https://install.goreleaser.com/github.com/goreleaser/nfpm.sh | sh`
2) Create json config file in the target machine at `/etc/conf/aquasec.json` with the following syntax (Install only)
```
{
  "AQUA_SERVER": "<HOSTENAME>:<PORT>",
  "AQUA_TOKEN": "<TOKEN VALUE>"
}
```



##### Build
1) Update the RPM scripts as required
2) Update the RPM version in `nfpm.yaml`
3) Change the architecture in `nfpm.yaml` if required (supported values: `x86_64`, `arm64`)
4) Build the RPM
`~/bin/nfpm pkg --packager rpm --target ./pkg/`
5) Use the RPM <aqua-vm-enforcer-{version}.{arch}.rpm> produced in ./pkg directory and use yum to install it
`sudo yum install aqua-vm-enforcer-{version}.{arch}.rpm`