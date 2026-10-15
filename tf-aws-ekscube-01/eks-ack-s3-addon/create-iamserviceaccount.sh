#!/bin/bash
export CLUSTER_NAME=eks-cicd-cluster

eksctl create iamserviceaccount \
  --name ack-$SERVICE-controller \
  --namespace ack-system \
  --cluster $CLUSTER_NAME \
  --attach-policy-arn $(aws iam list-policies --query 'Policies[?PolicyName==`AmazonS3FullAccess`].Arn' --output text) \
  --override-existing-serviceaccounts --approve
