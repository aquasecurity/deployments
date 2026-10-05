# Deploy Aqua Server Networking using Kubernetes Gateway API

## Overview

This directory provides manifests to expose the Aqua Envoy proxy using the
[Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/) with **TLS Passthrough**
for multi-gateway deployments.

In this mode, the Gateway forwards TLS connections from Enforcers directly to the
Envoy proxy **without terminating TLS**. Envoy handles TLS termination, gRPC
load balancing, and distributes traffic across multiple Aqua Gateway pods.

```
Enforcer ──TLS──▶ Gateway (Passthrough) ──TLS──▶ Envoy ──gRPC──▶ Aqua Gateway Pods
```

> The Aqua Web Console is exposed separately via its own LoadBalancer service and
> is not routed through the Gateway API.

## Prerequisites

### 1. Kubernetes Gateway API CRDs (v1.6.2+)

TLSRoute is available in the standard channel from v1.6.2 onwards. Install the CRDs
as required by your cluster or follow your organisation's standard process.

Refer to the [Gateway API installation guide](https://gateway-api.sigs.k8s.io/guides/).

### 2. A Gateway API Implementation with TLS Passthrough Support

This solution requires a Gateway API implementation that supports `TLSRoute` with
`Passthrough` mode. Supported implementations include:

| Implementation | GatewayClass Name | Notes |
|---|---|---|
| [Envoy Gateway](https://gateway.envoyproxy.io/) | `eg` | Open source, CNCF project |
| [Istio](https://istio.io/) | `istio` | Service mesh with Gateway API support |
| [Contour](https://projectcontour.io/) | `contour` | CNCF project |
| [NGINX Gateway Fabric](https://github.com/nginxinc/nginx-gateway-fabric) | `nginx` | NGINX implementation |

**Note:** Check whether a GatewayClass already exists with `kubectl get gatewayclass`. 
If one exists for your implementation, reuse its name in `002_gateway.yaml` and **skip** applying `000_gatewayclass.yaml`.

**Note:** `TLSRoute` support and enablement vary by implementation and version — some require experimental features to be enabled. 
Confirm your implementation supports `TLSRoute` with `Passthrough` before deploying.

Enterprise and commercial Gateway implementations that support the Kubernetes
Gateway API spec with TLS Passthrough are also compatible. Refer to your vendor's
documentation for installation and the GatewayClass name to use.

For a full list of implementations, see the
[Gateway API implementations page](https://gateway-api.sigs.k8s.io/implementations/).

### 3. TLS Secrets

Three TLS secrets are required in the `aqua` namespace before deploying:

| Secret Name | Type | Used By |
|---|---|---|
| `envoy-ssl` | `kubernetes.io/tls` | Envoy — downstream TLS with Enforcers. The envoy-ssl SANs must include the Gateway's external DNS name or IP. |
| `aqua-grpc-web` | `Opaque` | aqua-web — gRPC TLS with Gateway pods |
| `aqua-grpc-gateway` | `Opaque` | aqua-gateway — TLS with Envoy upstream |

Note: With TLS Passthrough, Enforcers receive Envoy's certificate (envoy-ssl) directly. Its Subject Alternative Names (SANs) must 
include the external DNS name and/or IP address of the Gateway.

Refer to the Aqua documentation for certificate requirements and generation steps.

### 4. Required Changes to Existing Manifests

The following changes must be made to existing manifests **before** deploying:

#### a) Enable TLS environment variables (`aqua_csp_004_configMaps/aqua_server.yaml`)

Uncomment the TLS certificate path variables:

```yaml
AQUA_PRIVATE_KEY: "/opt/aquasec/ssl/key.pem"
AQUA_PUBLIC_KEY: "/opt/aquasec/ssl/cert.pem"
AQUA_ROOT_CA: "/opt/aquasec/ssl/ca.pem"
```

#### b) Mount TLS secrets into the server deployment

In your chosen server deployment file (`aqua_csp_006_server_deployment/`), uncomment
the volume mounts for `aqua-web` and `aqua-gateway`:

**aqua-web**:
```yaml
        volumeMounts:
        - mountPath: /opt/aquasec/ssl
          name: aqua-grpc-web
          readOnly: true
      volumes:
      - name: aqua-grpc-web
        secret:
          secretName: aqua-grpc-web
          items:
          - key: aqua_web.crt
            path: cert.pem
          - key: aqua_web.key
            path: key.pem
          - key: rootCA.crt
            path: ca.pem
```

**aqua-gateway**:
```yaml
        volumeMounts:
        - mountPath: /opt/aquasec/ssl
          name: aqua-grpc-gateway
          readOnly: true
      volumes:
      - name: aqua-grpc-gateway
        secret:
          secretName: aqua-grpc-gateway
          items:
          - key: aqua_gateway.crt
            path: cert.pem
          - key: aqua_gateway.key
            path: key.pem
          - key: rootCA.crt
            path: ca.pem
```

#### c) Scale aqua-gateway for multi-gateway

Set the desired number of Gateway replicas (minimum 2 for high availability):

```bash
kubectl -n aqua scale --replicas=<N> deployment/aqua-gateway
```

### 5. Envoy Stack

Deploy the following Envoy prerequisites from the `envoy/` directory:
- `001_server_gateway_service-envoy.yaml` — aqua-web LoadBalancer + aqua-gateway-headless Services
- `003_envoy-configmap.yaml` — Envoy static configuration
- `004b_envoy-deployment.yaml` — Envoy Deployment with `envoy-ssl` secret mounted

> Use `004b_envoy-deployment.yaml` for Gateway API deployments. In this mode,
> external access is provided by the Gateway — Envoy does not require its own
> LoadBalancer service. Do not apply together with 004_envoy-deployment.yaml.

## Configuration

Before deploying, update `002_gateway.yaml` to match your environment:

**`<GATEWAY_CLASS_NAME>`** — replace with the GatewayClass name of your installed
implementation (e.g. `eg` for Envoy Gateway, `istio` for Istio).
Skip creating gatewayclass if your implementation already created a GatewayClass (kubectl get gatewayclass).

**`<GATEWAY_CONTROLLER_NAME>`** — replace with the Gateway controller name of your installed
implementation (e.g. `eg` for Envoy Gateway, `istio` for Istio).

  # Controller name must match the installed Gateway API implementation.
  # Common values:
  #   - "gateway.envoyproxy.io/gatewayclass-controller"  (Envoy Gateway)
  #   - "istio.io/gateway-controller"                    (Istio)
  #   - "projectcontour.io/gateway-controller"           (Contour)
  #   - "gateway.nginx.org/nginx-gateway-controller"     (NGINX Gateway Fabric)

**`<PORT>`** — replace with the external port Enforcers will use to connect. Choose
a port that does not conflict with other services in your cluster. 

**Hostname-based SNI routing (optional)** — if your Enforcers connect using a specific
FQDN, uncomment and set `hostname` in `002_gateway.yaml` and `hostnames` in
`003_tls-route.yaml`.

## Deployment

```bash
# 1. Deploy Aqua prerequisites (with TLS changes applied — see Prerequisites above)
kubectl apply -f aqua_csp_001_namespace/
kubectl apply -f aqua_csp_002_RBAC/<platform>/
kubectl apply -f aqua_csp_003_secrets/
kubectl apply -f aqua_csp_004_configMaps/
kubectl apply -f aqua_csp_005_storage/
kubectl apply -f aqua_csp_006_server_deployment/

# 2. Deploy Envoy stack
kubectl apply -f aqua_csp_007_networking/envoy/001_server_gateway_service-envoy.yaml
kubectl apply -f aqua_csp_007_networking/envoy/003_envoy-configmap.yaml
kubectl apply -f aqua_csp_007_networking/envoy/004b_envoy-deployment.yaml

# 3. Deploy Gateway API resources
# (Optional) Apply only if no suitable GatewayClass exists — see Prerequisites
kubectl apply -f aqua_csp_007_networking/gateway_api/000_gatewayclass.yaml

kubectl apply -f aqua_csp_007_networking/gateway_api/001_envoy-service.yaml
kubectl apply -f aqua_csp_007_networking/gateway_api/002_gateway.yaml
kubectl apply -f aqua_csp_007_networking/gateway_api/003_tls-route.yaml
```

## Verification

```bash
# Check GatewayClass is accepted by your implementation
kubectl get gatewayclass

# Check Gateway is programmed and has an address
kubectl get gateway aqua-gateway-proxy -n aqua
# Expected: PROGRAMMED=True, ADDRESS populated

# Check TLSRoute is accepted
kubectl get tlsroute aqua-envoy-passthrough -n aqua

# Check all Aqua pods are running
kubectl get pods -n aqua

# Get the Gateway's external address — configure Enforcers to connect here
kubectl get gateway aqua-gateway-proxy -n aqua -o jsonpath='{.status.addresses[0].value}'
```

## Connecting Enforcers

Once the Gateway is programmed and has an address, configure your Enforcers to connect to the Gateway's external address and the listener port you configured. 

If you are deploying Enforcers via Helm, set the gateway address in your `values.yaml` (or via `--set`):

```yaml
global:
  gateway:
    address: "<gateway-address>"
    port: <PORT>
