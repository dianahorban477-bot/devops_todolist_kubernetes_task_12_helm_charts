#!/bin/bash
kind create cluster --config cluster.yml
kubectl get nodes --show-labels
MYSQL_NODE=$(kubectl get nodes -l app=mysql -o jsonpath='{.items[0].metadata.name}')
kubectl taint nodes $MYSQL_NODE app=mysql:NoSchedule
cd helm-chart/todoapp
helm dependency build
cd ../..
helm upgrade --install todoapp ./helm-chart/todoapp --create-namespace --namespace todo-apps
kubectl get all,cm,secret,ing -A > output.log