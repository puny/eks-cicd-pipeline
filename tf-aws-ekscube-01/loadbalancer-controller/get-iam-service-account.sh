#!/bin/bash

eksctl get iamserviceaccount --cluster=eks-cicd-cluster --namespace=kube-system \
    --name=aws-load-balancer-controller --region=ap-northeast-2