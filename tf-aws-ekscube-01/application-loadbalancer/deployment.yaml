#/bin/bash


if [ ! -f "2048_full.yaml" ]; then
    echo "Downloading 2048_full.yaml"
    curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/examples/2048/2048_full.yaml
fi

kubectl apply -f 2048_full.yaml
