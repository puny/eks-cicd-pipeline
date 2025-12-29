#!/bin/bash

kcns jenkins

helm install jenkins -n jenkins -f jenkins-values.yaml jenkins/jenkins
