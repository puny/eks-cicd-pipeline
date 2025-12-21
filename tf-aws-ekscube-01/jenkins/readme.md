

# helm 설치시 필요한 value 다운로드

https://raw.githubusercontent.com/jenkinsci/helm-charts/main/charts/jenkins/values.yaml
에서 다운받아 아래 내용을 수정

```
- serviceType: NodePort
- existingClaim: jenkins-pvc
- storageClass:
- serviceAccount:
    create: false
    name: jenkins
```