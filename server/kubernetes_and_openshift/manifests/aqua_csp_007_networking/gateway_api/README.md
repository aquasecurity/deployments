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
`Passthrough` mode. `TLSRoute` support varies by implementation and version, and
some implementations require it to be explicitly enabled — confirm this in your
vendor's documentation before deploying.

Examples include [Envoy Gateway](https://gateway.envoyproxy.io/),
[Istio](https://istio.io/), [Contour](https://projectcontour.io/) and
[NGINX Gateway Fabric](https://github.com/nginxinc/nginx-gateway-fabric).
Enterprise and commercial implementations that support the Gateway API spec with
TLS Passthrough are also compatible. For a full list, see the
[Gateway API implementations page](https://gateway-api.sigs.k8s.io/implementations/).

### 3. TLS Secrets

Three TLS secrets are required in the `aqua` namespace before deploying:

| Secret Name | Type | Used By |
|---|---|---|
| `envoy-ssl` | `kubernetes.io/tls` | Envoy — downstream TLS with Enforcers |
| `aqua-grpc-web` | `Opaque` | aqua-web — gRPC TLS with Gateway pods |
| `aqua-grpc-gateway` | `Opaque` | aqua-gateway — TLS with Envoy upstream |

> **Important:** With TLS Passthrough, Enforcers receive Envoy's certificate
> (`envoy-ssl`) directly. Its Subject Alternative Names (SANs) must include the
> external DNS name and/or IP address of the Gateway.

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

> Use `004b_envoy-deployment.yaml` for Gateway API deployments — external access is
> provided by the Gateway, so Envoy does not need its own LoadBalancer. Do not apply
> it together with `004_envoy-deployment.yaml`.
>
> If you are migrating from `004_envoy-deployment.yaml`, delete its LoadBalancer
> Service so Envoy is no longer exposed directly, bypassing the Gateway:
>
> ```bash
> kubectl delete service aqua-lb -n aqua
> ```

## Configuration

Replace the placeholders in the following files before deploying.

### GatewayClass (`000_gatewayclass.yaml`) — optional

Run `kubectl get gatewayclass`. If your implementation already created a
GatewayClass (for example, Istio creates `istio`), skip this file and use that
name for `<GATEWAY_CLASS_NAME>` in `002_gateway.yaml`.

Otherwise, set:

| Placeholder | Value |
|---|---|
| `<GATEWAY_CLASS_NAME>` | A new, unused GatewayClass name (e.g. `aqua-gateway-class`) |
| `<GATEWAY_CONTROLLER_NAME>` | The controller name of your implementation (see below) |

Controller names for common implementations:

| Implementation | `<GATEWAY_CONTROLLER_NAME>` |
|---|---|
| Envoy Gateway | `gateway.envoyproxy.io/gatewayclass-controller` |
| Istio | `istio.io/gateway-controller` |
| Contour | `projectcontour.io/gateway-controller` |
| NGINX Gateway Fabric | `gateway.nginx.org/nginx-gateway-controller` |

For other implementations, refer to your vendor's documentation.

> The controller name of an existing GatewayClass cannot be changed. Do not reuse
> the name of a GatewayClass that already exists, or the apply will fail.

### Gateway (`002_gateway.yaml`)

| Placeholder | Value |
|---|---|
| `<GATEWAY_CLASS_NAME>` | The existing GatewayClass name, or the same name set in `000_gatewayclass.yaml` |
| `<PORT>` | The external port Enforcers connect to, as an integer (e.g. `443`) |

> If the Gateway shares its external address with other services (for example,
> on clusters where all LoadBalancer services use a single IP, or behind a shared
> ingress), choose a `<PORT>` that is not already used on that address, such as
> the aqua-web port `443`.

### Hostname-based SNI routing (optional)

If your Enforcers connect using a specific FQDN, uncomment and set `hostname` in
`002_gateway.yaml` and `hostnames` in `003_tls-route.yaml`. The values must match.

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
# (Optional) Only if no suitable GatewayClass exists — see Configuration
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

# Get the Gateway's external address
kubectl get gateway aqua-gateway-proxy -n aqua -o jsonpath='{.status.addresses[0].value}'
```

## Connecting Enforcers

Configure Enforcers and KubeEnforcers to connect to the Gateway's external address
(from the Verification step above) and the `<PORT>` set in `002_gateway.yaml`.

**Helm** — set in `values.yaml` or via `--set`:

```yaml
global:
  gateway:
    address: "<gateway-address>"
    port: <PORT>
```

**Manifests** — set the gateway address environment variable:

| Component | Variable | Value |
|---|---|---|
| Enforcer | `AQUA_SERVER` | `<gateway-address>:<PORT>` |
| KubeEnforcer | `AQUA_GATEWAY_SECURE_ADDRESS` | `<gateway-address>:<PORT>` |
