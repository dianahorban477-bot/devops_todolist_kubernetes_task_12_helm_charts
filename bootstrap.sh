#!/bin/bash
kind delete cluster --name kind || true
kind create cluster --config cluster.yml --name kind
sleep 30
kubectl get nodes
kubectl label node kind-worker app=mysql --overwrite
MYSQL_NODE=$(kubectl get nodes -l app=mysql -o jsonpath='{.items[0].metadata.name}')
kubectl taint nodes $MYSQL_NODE app=mysql:NoSchedule --overwrite
cd helm-chart/todoapp
helm dependency build
cd ../..
helm upgrade --install todoapp ./helm-chart/todoapp \
  -f ./helm-chart/todoapp/values.yaml \
  --set mysql.ingress.enabled=false \
  --set mysql.httpRoute.enabled=false \
  --create-namespace --namespace todo-apps
sleep 45
kubectl get all,cm,secret,ing -A > output.log