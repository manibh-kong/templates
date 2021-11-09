#!/bin/bash
#read -p 'Please enter your Kong EE license path:' licensePath
kubectl create namespace kong-gw
echo "workspace kong-gw created"
kubectl create secret generic kong-enterprise-license -n kong-gw --from-file=license=$1
echo "License secret created"
kubectl apply -f https://git.io/JX2cK -n kong-gw

echo "Wait for Kong Gateway deployment"
kubectl wait --for=condition=available --timeout=500s --namespace=kong-gw deployment/kong-enterprise
echo "Kong Gateway deployed successfully"

kubectl create -f https://git.io/JX20O -n kong-gw

echo "Kong Gateway Ingress Created"
echo "Please add following line to your /etc/host file"
echo "127.0.0.1	localhost,kong-proxy.local"
echo "Next you need to run 'minikube tunnel' in order to access the ports from localhost"