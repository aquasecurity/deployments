## Overview

The Kube Enforcer runs as single replica deployment and provides runtime security for your Kubernetes workloads and infrastructure. Kube enforcer can be deployed in combination with co-requisite Starboard and/or Advanced deployment for Pod Enforcer injection. Kube Enforcer(s) can be deployed manually with one of the following combinations per your requirement, using manifest yaml files:

* [Kube enforcer](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/2_enforcers/kube_enforcer/manifests/kube-enforcer)
* [Kube enforcer advanced](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/2_enforcers/kube_enforcer/manifests/kube_enforcer_advanced)
* [Kube enforcer starboard](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/2_enforcers/kube_enforcer/manifests/kube_enforcer_starboard)
* [Kube enforcer advanced starboard](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/2_enforcers/kube_enforcer/manifests/kube_enforcer_advanced_starboard)

Navigate to the respective directory (hyperlinked above) to know more about each Kube enforcer component and its deployment method using manifest yaml files