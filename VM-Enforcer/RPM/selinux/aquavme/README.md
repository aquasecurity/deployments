
<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua VM Enforcer Selinux Policy


##### Prerequisites
1) Selinux
2) Selinux Policy Devel 
    `sudo yum install setools-console selinux-policy-devel`

##### Build
1) Update Policy Source File (.te) according to requirements
2) Compile the policy (in directory with .te file),
    `sudo make NAME=targeted -f /usr/share/selinux/devel/Makefile` 
    `sudo make NAME=targeted -f /usr/share/selinux/devel/Makefile clean`
3) Use the compiled policy (.pp) file inside Aqua VM Enforcer RPM 
