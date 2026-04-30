# eks 생성
resource "aws_eks_cluster" "std4_eks_cluster" {
       name = "std4_eks_cluster"
       role_arn = aws_iam_role.std4_eks_cluser_role.arn

       # 워커 노드가 위치할 서브넷 아이디 목록
       vpc_config {
         subnet_ids = local.my_subnets
       }

       # 생성자 권한 부여
       access_config {
         authentication_mode = "API_AND_CONFIG_MAP"
         # true로 설정하면 클러스터 생성자에 관리자 권한이 부여됨
         bootstrap_cluster_creator_admin_permissions = true
       }
       # 역할 연결 수행 후 실행 하기
       depends_on = [
       aws_iam_role_policy_attachment.std4_eks_AmazonEKSClusterPolicy,
       # 만약 VPC 리소스 생성이 완료된 후 보장하고 싶다면 추가 가능
       aws_vpc.std4_vpc]
 }


 