#!/bin/bash
set -e
kind create cluster --config cluster.yml
kubectl get nodes --show-labels
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
cd .infrastructure/helm-chart/todoapp
helm dependency build
cd ../../..
helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp --create-namespace --namespace todo-apps
kubectl wait --namespace todo-apps --for=condition=available --timeout=300s deployment -l app.kubernetes.io/name=todoapp || true
kubectl get all,cm,secret,ing -A > output.log