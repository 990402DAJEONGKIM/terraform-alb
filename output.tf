output "vpc_id" {
    value = data.aws_vpc.std4_vpc.id
}

output "public_subnet" {
    value = data.aws_subnets.std4_public_subnets.ids[0]
}

output "private_subnet" {
    value = data.aws_subnets.std4_private_subnets.ids[0]
}


output "web_sg_id" {
    value = data.aws_security_group.std4_web_sg.id
}

# output "az_names" {
#     value = data.availability_zones.available.names
#     description = "사용 가능한 가용영역 정보"
# }


# output "dockr_alb_dns_name" {
#     value = data.aws_lb.std4_lb.dns_name
#     description = "ALB DNS 이름"
# }

# # 시작 템플릿
# output "launch_template_latest_version" {
#     value = data.aws_launch_template.std4_launch_template.latest_version
#     description = "시작 템플릿의 최신 버전"
# }


# output "launch_template_default_version" {
#     value = data.aws_launch_template.std4_launch_template.default_version
#     description = "시작 템플릿의 기본(Default) 버전"
# }


# output "launch_template_description" {
#     value = data.aws_launch_template.std4_launch_template.description
#     description = "시작 템플릿의 설명"
# }