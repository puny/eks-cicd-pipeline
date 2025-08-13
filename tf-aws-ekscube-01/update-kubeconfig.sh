#!/bin/bash

CLUSTER_NAME="${1:-eks-cicd-cluster}"
REGION="${2:-ap-northeast-2}"

aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"
