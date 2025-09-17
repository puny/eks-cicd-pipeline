#!/bin/bash

# Policy and service account creation for AWS Load Balancer Controller


# IAM Policy download URL
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json

# Create IAM policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

# Create Load Balancer Controller service account
# cluser, attach-policy-arn, and region need to be updated
eksctl create iamserviceaccount \
    --cluster=eks-cicd-cluster \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::533267419021:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region ap-northeast-2 \
    --approve
