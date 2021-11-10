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

