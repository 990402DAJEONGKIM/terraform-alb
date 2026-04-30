# 시작 템플릿 생성
resource "aws_launch_template" "std4_launch_template" {
  name_prefix   = "std4_launch_template"
  image_id      = "ami-00a6136dabd1f25ae" # 사용하려는 리전의 AL2023 EKS AMI ID 확인 필요
  instance_type = "t3.large"
  key_name      = "std4-keypair"

  vpc_security_group_ids = [
    aws_security_group.std4_ssh_sg.id,
    aws_security_group.std4_web_sg.id,
    aws_security_group.std4_eks_node_sg.id,

    # vpc_config[0]: 클러스터 네트워크 설정의 첫 번째 블록
    # cluster_security_group_id: AWS가 자동으로 만든 보안그룹 ID 추출
    aws_eks_cluster.std4_eks_cluster.vpc_config[0].cluster_security_group_id
  ]

  # AL2023은 nodeadm 형식을 사용하며 base64encode를 써야 합니다.
  user_data = base64encode(<<-EOF
    apiVersion: node.eks.aws/v1alpha1
    kind: NodeConfig
    spec:
      cluster:
        name: ${aws_eks_cluster.std4_eks_cluster.name}
        apiServerEndpoint: ${aws_eks_cluster.std4_eks_cluster.endpoint}
        certificateAuthority: ${aws_eks_cluster.std4_eks_cluster.certificate_authority[0].data}
        cidr: ${aws_eks_cluster.std4_eks_cluster.kubernetes_network_config[0].service_ipv4_cidr}
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "std4_asg_instance"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "std4_asg_instance_volume"
    }
  }
}

# 노드 그룹 생성
resource "aws_eks_node_group" "std4_eks_node_group" {
  cluster_name = aws_eks_cluster.std4_eks_cluster.name
  node_group_name = "std4_eks_node_group"
  node_role_arn = aws_iam_role.std4_eks_node_role.arn
  subnet_ids = data.aws_subnets.std4_subnets.ids

# 노드 배포 환경 설정부
scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 1
  }

# 시작 템플릿 정보
launch_template {
    name =aws_launch_template.std4_launch_template.name
    version = "$Latest" # $Default

  }

# 종속성 문제 해결을 위해서
depends_on = [
    aws_iam_role_policy_attachment.std4_eks_AmazonEKSClusterPolicy

  ]

}



