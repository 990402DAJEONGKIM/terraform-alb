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
