#!/bin/bash

# helm repo add for AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts

# helm eks repo update
helm repo update eks

# Install AWS Load Balancer Controller
# cluster-name, service-account, and region need to be updated
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-cicd-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=ap-northeast-2 \
  --version 1.13.0 \
  --set vpcId=vpc-04ba6696a5be2445e
