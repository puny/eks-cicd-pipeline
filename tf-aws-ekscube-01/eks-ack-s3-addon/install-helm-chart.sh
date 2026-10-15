#!/bin/bash

# 1. 파일 다운로드
# ACK-S3-Controller helm을 이용해서 download
# file s3-chart-1.2.2.tgz 형태의 파일을 다운받음

export SERVICE=s3
export RELEASE_VERSION=$(curl -sL https://api.github.com/repos/aws-controllers-k8s/${SERVICE}-controller/releases/latest | jq -r '.tag_name | ltrimstr("v")')
if [ ! -f $SERVICE-chart-$RELEASE_VERSION.tgz ]; then
    echo "s3-chart-controller download ..."
    helm pull oci://public.ecr.aws/aws-controllers-k8s/$SERVICE-chart --version=$RELEASE_VERSION
fi

# 2. 네임스페이스 만들고 헬름 페키지 배포
export ACK_SYSTEM_NAMESPACE=ack-system
export AWS_REGION=ap-northeast-2
ACK_HELM_CHART=$(helm list -n ack-system | awk 'NR>1 {print $1}')
if [ "$ACK_HELM_CHART" != "ack-s3-controller" ]; then
    echo "ack-s3-controller helm chart install ..."
    helm install --create-namespace -n $ACK_SYSTEM_NAMESPACE ack-$SERVICE-controller --set aws.region="$AWS_REGION" $SERVICE-chart-$RELEASE_VERSION.tgz
fi