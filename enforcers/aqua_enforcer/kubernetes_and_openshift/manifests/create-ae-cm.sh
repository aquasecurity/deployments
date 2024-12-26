#!/bin/bash

echo "Starting..."

# Get KUBE_SYSTEM_UID
KUBE_SYSTEM_UID=$(kubectl get namespace kube-system -o jsonpath='{.metadata.uid}' 2>&1)

# Check if kubectl command was successful
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to get KUBE_SYSTEM_UID. kubectl command failed with the following output:"
  echo "$KUBE_SYSTEM_UID"
  exit 1
else
  echo "Got the UID of the kube-system namespace successfully: $KUBE_SYSTEM_UID"
fi

# Create ConfigMap
kubectl create configmap aqua-cluster-metadata --from-literal=CLUSTER_UID="$KUBE_SYSTEM_UID" -n aqua 2>&1

# Check if ConfigMap creation was successful
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to create ConfigMap. kubectl command failed with the following output:"
  echo "$KUBE_SYSTEM_UID"
  exit 1
  else
  echo "Successfully created the configmap aqua-cluster-metadata in the aqua namespace"
fi

echo "Done!"