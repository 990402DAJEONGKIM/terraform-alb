
# 리전 정보
data "aws_region" "std4_region" {
}

# 현재 리전의 가용영역 정보
data "aws_availability_zones" "std4_availability_zones" {
    state = "available" # 현재 aws에서 사용가능한 정보
}

# Local 상수 정의
locals {
  vpc_nameTag = "std4_vpc"
  my_subnets = data.aws_subnets.std4_subnets.ids
}


# vpc 정보
data "aws_vpc" "std4_vpc" {
    filter {
        name = "tag:Name"
        values = [local.vpc_nameTag] # 로컬 변수 사용
    }
}

# subnet 정보
data "aws_subnets" "std4_subnets" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.std4_vpc.id]
    }
    filter {
        name = "tag:kubernetes.io/role/internal-elb"
        values = ["1"]
    }
}


# # subnet 정보
# data "aws_subnets" "std4_private_subnets" {
#     filter {
#         name = "tag:Name"
#         values = ["std4_private1_subnet", "std4_private2_subnet", "std4_private3_subnet"]
#     }
# }

# data "aws_subnets" "std4_public_subnets" {
#     filter {
#         name = "tag:Name"
#         values = ["std4_public1_subnet", "std4_public2_subnet", "std4_public3_subnet"]
#     }
# }


data "aws_security_group" "std4_web_sg" {
    filter {
        name = "tag:Name"
        values = ["std4_web_sg"]
    }
}

# data "aws_security_group" "std4_alb_sg" {
#     filter {
#         name = "tag:Name"
#         values = ["std4_alb_sg"]
#     }
# }


data "aws_security_group" "std4_ssh_sg" {
    filter {
        name = "tag:Name"
        values = ["std4_ssh_sg"]
    }
}

data "aws_security_group" "std4_eks_node_sg" {
    filter {
        name = "tag:Name"
        values = ["std4_eks_node_sg"]
    }
}

# data "aws_launch_template" "std4_launch_template" {
#     filter {
#         name = "tag:Name"
#         values = ["std4_launch_template"]
#     }
#}


