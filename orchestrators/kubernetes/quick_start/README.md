## Introduction

The quick-start deployment is suited for proofs-of-concept (POCs) and environments intended for instruction, development, and test. 
Refer to the product documentation: [Quick-Start Guide for Kubernetes](https://docs.aquasec.com/v6.0/docs/quick-start-guide-for-kubernetes).

For enterprise-grade deployments, see [Deploy Aqua Enterprise](https://docs.aquasec.com/v6.0/docs/deployment-overview) and select the procedure that is relevant to your orchestration platform.

## Purpose of the files in this directory

| File                                   | Purpose                                                                                             |
|----------------------------------------|---------------------------------------------------------------------------------------------------|
| aqua-csp-quick-DaemonSet-hostPath.yaml | Deploy Aqua Enterprise with the Aqua Enforcer only, and use the host-path for storage             |
| aqua-csp-quick-DaemonSet-storage.yaml  | Deploy Aqua Enterprise with the Aqua Enforcer only, and use default-storage                       |
| aqua-csp-quick-default-storage.yaml    | Deploy Aqua Enterprise with the Aqua Enforcer and KubeEnforcer, and use default-storage           |
| aqua-csp-quick-hostpath.yaml           | Deploy Aqua Enterprise with the Aqua Enforcer and KubeEnforcer, and use the host-path for storage |
