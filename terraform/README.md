# cloud
Terraform, Helm을 위한 클라우드 저장소입니다.

### manual
- 생성 순서
1. terraform apply -target=module.vpc
2. terraform apply -target=module.eks
3. terraform apply
- 삭제는 생성의 역순
