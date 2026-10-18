# Sample client app

한국어 클라이언트 페이지와 번호 생성 백엔드를 함께 배포하는 예제입니다. 클라이언트에서 **번호 뽑기**를 누르면 브라우저가 `/api/lotto`를 호출하고, 백엔드가 1~45 중 중복 없는 6개 숫자를 JSON으로 반환합니다.

## 배포

AWS Load Balancer Controller와 `alb` IngressClass가 클러스터에 설치되어 있어야 합니다. 백엔드 이미지는 ECR에 올려야 하므로 먼저 저장소를 만들고 이미지를 빌드/푸시합니다. 계정 ID를 실제 AWS 계정 ID로 설정합니다.

```sh
AWS_ACCOUNT_ID=123456789012
aws ecr create-repository --repository-name sample-lottery-backend --region ap-northeast-2
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com
docker build -t sample-lottery-backend:1.0 sample-client-app/backend
docker tag sample-lottery-backend:1.0 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com/sample-lottery-backend:1.0
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com/sample-lottery-backend:1.0
```

`sample-client-app/backend/deployment.yaml`에서 `REPLACE_WITH_ECR_URI`를 `${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com`에 해당하는 실제 주소로 바꾼 후 적용합니다.

```sh
kubectl apply -f sample-client-app/deployment.yaml
kubectl apply -f sample-client-app/backend/deployment.yaml
kubectl -n sample-client-app rollout status deployment/sample-client-app
kubectl -n sample-client-app rollout status deployment/sample-lottery-backend
kubectl -n sample-client-app get ingress sample-client-app
```

Ingress의 `ADDRESS`에 표시되는 ALB 주소를 브라우저에서 열면 됩니다. 주소가 할당될 때까지 몇 분 걸릴 수 있습니다.

Ingress 없이 클러스터 안에서만 확인하려면 다음 명령으로 포트 포워딩합니다.

```sh
kubectl -n sample-client-app port-forward service/sample-client-app 8080:80
```

그 다음 `http://localhost:8080`을 엽니다.

Ingress 없이 로컬에서 백엔드 API를 확인하려면 별도 터미널에서 다음 명령을 실행하고 `http://localhost:8080/api/lotto`를 엽니다.

```sh
kubectl -n sample-client-app port-forward service/sample-lottery-backend 8080:8080
```

## 삭제

```sh
kubectl delete -f sample-client-app/backend/deployment.yaml
kubectl delete -f sample-client-app/deployment.yaml
```
