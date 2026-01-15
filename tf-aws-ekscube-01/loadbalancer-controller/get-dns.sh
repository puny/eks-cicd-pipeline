#!/bin/bash

aws elbv2 describe-load-balancers --query 'LoadBalancers[].DNSName'
