#!/bin/bash

# laodbalancer controller uninstall
helm uninstall aws-load-balancer-controller -n kube-system

# service account delete
eksctl delete iamserviceaccount --cluster=eks-cicd-cluster --namespace=kube-system \
    --name=aws-load-balancer-controller --region=ap-northeast-2 --wait
