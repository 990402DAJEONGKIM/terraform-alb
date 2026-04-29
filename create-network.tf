resource "aws_vpc" "std4_vpc" {
       cidr_block="10.0.0.0/16"
       enable_dns_hostnames = true
       enable_dns_support = true
       tags ={
        Name = "std4_vpc"
       }
}
 # ===========================================================================================================================================================================
# public subnet 구성
resource "aws_subnet" "std4_public_subnet" {
       # count가 포함된 리소스를 지정된 횟수만큼 반복
       count = 3 
       vpc_id = aws_vpc.std4_vpc.id
       cidr_block = "10.0.${count.index+1}.0/24"
       # availability_zone = "ap-south-2a"
       # [반복사용 방법 1] availability_zone = data.aws_availability_zone.names[count.index]
       # [반복사용 방법 2]
       availability_zone = ["ap-south-2a","ap-south-2b","ap-south-2c"][count.index]
       # ipv4 주소 자동 할당(default 값은 false)
       map_public_ip_on_launch = true
       # 시작 시 리소스 이름 dns a 레코드 활성화(default 값은 false)
       enable_resource_name_dns_a_record_on_launch = true

       tags = {
              Name = "std4_public${count.index+1}_subnet"
              "kubernetes.io/role/elb" = "1"
       }
}

# 인터넷 게이트 웨이
resource "aws_internet_gateway" "std4_internet_gateway" {
       vpc_id = aws_vpc.std4_vpc.id
       tags = {
              Name = "std4_internet_gateway"
       }
}

# 퍼블릭 서브넷 라우터
resource "aws_route_table" "std4_route_table" {
       vpc_id = aws_vpc.std4_vpc.id
       route {
              cidr_block = "0.0.0.0/0"
              gateway_id = aws_internet_gateway.std4_internet_gateway.id
       }
       tags = {
              Name = "std4_route_table"
       }
} 


resource "aws_route_table_association" "std4_route_table_association" {
       count = 3
       route_table_id=aws_route_table.std4_route_table.id
       subnet_id = aws_subnet.std4_public_subnet[count.index].id
}

 # ===========================================================================================================================================================================
 # 프라이빗 서브넷 구성
 resource "aws_subnet" "std4_private_subnet" {
       count = 3
       vpc_id = aws_vpc.std4_vpc.id
       cidr_block = "10.0.${count.index+11}.0/24"
       availability_zone = ["ap-south-2a","ap-south-2b","ap-south-2c"][count.index]
       tags = {
              Name = "std4_private${count.index+1}_subnet"
              "kubernetes.io/role/internal-elb" = "1"
       }
}

# eip 생성
resource "aws_eip" "std4_eip" {
       domain = "vpc"
       tags = { Name = "std4_eip" }
}

# nat 게이트웨이 - 두 단계 (* 반드시 고정ip 부여 필요)
resource "aws_nat_gateway" "std4_nat_gateway" {
       # eip 할당
       allocation_id=aws_eip.std4_eip.id
       subnet_id = aws_subnet.std4_public_subnet[0].id
       depends_on = [ aws_internet_gateway.std4_internet_gateway ]
       tags = { Name = "std4_nat_gateway" }
}

# 프라이빗 서브넷 라우터
resource "aws_route_table" "std4_private_route_table" {
       vpc_id = aws_vpc.std4_vpc.id
       route {
              cidr_block = "0.0.0.0/0"
              gateway_id = aws_nat_gateway.std4_nat_gateway.id
       }
       tags = {
              Name = "std4_private_route_table"
       }
} 

# "프라이빗 서브넷아, 방금 만든 프라이빗 라우팅 테이블을 사용하렴!"
resource "aws_route_table_association" "std4_private_route_table_association" {
  count = 3
  subnet_id      = aws_subnet.std4_private_subnet[count.index].id
  route_table_id = aws_route_table.std4_private_route_table.id
}
 # ===========================================================================================================================================================================
 # 1. IAM Role 생성
resource "aws_iam_role" "std4_eks_cluser_role" {
  name = "std4_eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# 2. 필요한 정책 연결 (이게 있어야 EKS가 리소스를 관리할 수 있음)
resource "aws_iam_role_policy_attachment" "std4_eks_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.std4_eks_cluser_role.name
}


 # node IAM Role 생성
resource "aws_iam_role" "std4_eks_node_role" {
  name = "std4_eks_node_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# 반복문 사용을 통한 정책 부여를 위해 로컬 변수 선언
locals {
       node_policies = [
       "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
       "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
       "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
       "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
       "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
       "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}

# 정책들을 role에 attachment
resource "aws_iam_role_policy_attachment" "std4_node_attachments" {
  for_each = toset (local.node_policies)
       policy_arn = each.value
       role       = aws_iam_role.std4_eks_node_role.name
}



# ================================================================================================
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
