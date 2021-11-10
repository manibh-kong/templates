#!/bin/bash
curl -L https://docs.konghq.com/mesh/installer.sh | sh -
echo "Kong Mesh downloaded into current folder"
$PWD/kong-mesh-*/bin/kumactl install control-plane --license-path=$1 | kubectl apply -f -
kubectl wait --for=condition=available --timeout=500s -n kong-mesh-system deployment/kong-mesh-control-plane
echo "Kong Mesh Deployed Successfully"
echo "Restarting pods to start with Kong Mesh sidecar container"
kubectl get pods  -n kong --no-headers=true | awk '/ingress-kong/{print $1}' | xargs kubectl delete -n kong pod
echo "Kong ingress pod restarted"
kubectl get pods  -n kong-gw --no-headers=true | awk '/kong-enterprise/{print $1}' | xargs kubectl delete -n kong-gw pod
echo "Kong gateway pod restarted"
kubectl get pods  -n kuma-demo --no-headers=true | awk '/demo-app/{print $1}' | xargs kubectl delete -n kuma-demo  pod
echo "Kuma demo-app pod restarted"
kubectl get pods  -n kuma-demo --no-headers=true | awk '/redis/{print $1}' | xargs kubectl delete -n kuma-demo  pod
echo "Kuma redis po restarted"
echo "Now all of your existing pods should have mesh sidecar container"

echo 'apiVersion: kuma.io/v1alpha1
kind: Mesh
metadata:
  name: default
spec:
  mtls:
    enabledBackend: ca-1
    backends:
    - name: ca-1
      type: builtin' | kubectl apply -f -

kubectl get trafficpermissions.kuma.io --no-headers=true | awk '/allow-all-default/{print $1}' | xargs kubectl delete trafficpermissions.kuma.io
echo "Kong Mesh Zero trust Enabled, You need to define traffic permissions now"