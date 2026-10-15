#!/bin/bash

 k port-forward service/jenkins -n jenkins --address 0.0.0.0 8080:8080 > /dev/null 2>&1 &


