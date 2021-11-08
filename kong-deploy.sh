#!/bin/bash
read -p 'Please enter your Kong EE license path:' licensePath
kubectl create ns kong-gw
echo "workspace kong-gw created"
kubectl create secret generic kong-enterprise-license -n kong-gw --from-file=license=$licensePath
echo "License secret created"
kubectl apply -f https://git.io/JXgjL -n kong-gw
echo "Wait for Kong Gateway deployment"
kubectl wait --for=condition=available --timeout=500s --namespace=kong-gw deployment/kong-enterprise
echo "Kong Gateway deployed successfully"

cat <<EOF | kubectl create -n kong-gw -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:   
    kubernetes.io/ingress.class: kong
    namespace: kong-gw
  name: gateway-ingress
  namespace: kong-gw
spec:
  rules:
  - host: kong-proxy.local
    http:
      paths:
      - backend:
          service:
            name: kong-proxy
            port:
              number: 8000
        path: /
        pathType: Prefix
EOF
echo "Kong Gateway Ingress Created"
echo "Please add following line to your /etc/host file"
echo "127.0.0.1	localhost,kong-proxy.local"
echo "Next you need to run 'minikube tunnel' in order to access the ports from localhost"