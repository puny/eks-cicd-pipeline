#!/bin/bash

# Policy and service account creation for AWS Load Balancer Controller


# IAM Policy download URL
if [ ! -f ./iam_policy.json ]; then
  curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json
fi

POLICY_NAME=AWSLoadBalancerControllerIAMPolicy 

POLICY_ARN=$(aws iam list-policies \
  --scope Local \
  --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" \
  --output text)

if [ ! -n "$POLICY_ARN" ]; then
  # Create IAM policy
  aws iam create-policy \
    --policy-name $POLICY_NAME \
    --policy-document file://iam_policy.json
fi


# Create Load Balancer Controller service account
# cluser, attach-policy-arn, and region need to be updated
eksctl create iamserviceaccount \
    --cluster=eks-cicd-cluster \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn="arn:aws:iam::533267419021:policy/$POLICY_NAME" \
    --override-existing-serviceaccounts \
    --region ap-northeast-2 \
    --approve

