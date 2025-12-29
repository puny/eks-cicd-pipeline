#!/bin/bash

kubectl port-forward service/prometheus-grafana -n monitor --address 0.0.0.0 3000:80 > /dev/null 2>&1 &