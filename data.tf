# vpc 정보
data "aws_vpc" "std4_vpc" {
    filter {
        name = "tag:Name"
        values = ["std4_vpc"]
    }
}

# subnet 정보
data "aws_subnets" "std4_private_subnets" {
    filter {
        name = "tag:Name"
        values = ["std4_private1_subnet", "std4_private2_subnet", "std4_private3_subnet"]
    }
}

data "aws_subnets" "std4_public_subnets" {
    filter {
        name = "tag:Name"
        values = ["std4_public1_subnet", "std4_public2_subnet", "std4_public3_subnet"]
    }
}


data "aws_security_group" "std4_web_sg" {
    filter {
        name = "tag:Name"
        values = ["std4_web_sg"]
    }
}

data "aws_security_group" "std4_alb_sg" {
    filter {
        name = "tag:Name"
        values = ["std4_alb_sg"]
    }
}


data "aws_security_group" "std4_ssh_sg" {
    filter {
        name = "tag:Name"
        values = ["std4_ssh_sg"]
    }
}



