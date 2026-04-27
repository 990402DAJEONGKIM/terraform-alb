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
#     value = data.aws_lb.std4_lb.do=dns_name
#     description = "ALB DNS 이름"
# }