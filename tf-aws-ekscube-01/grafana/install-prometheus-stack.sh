#!/bin/bash

kcns monitor

helm install prometheus -n monitor prometheus-community/kube-prometheus-stack -f values.yaml