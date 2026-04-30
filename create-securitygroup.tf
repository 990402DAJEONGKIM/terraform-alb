# alb용 보안그룹 생성
resource "aws_security_group" "std4_eks_node_sg" {
       name = "std4_alb_sg"
       vpc_id = aws_vpc.std4_vpc.id
       description = "Allow http and https traffics"

       tags = {
              Name = "std4_eks_node_sg"
       }

       # ingress {
       #        from_port = 80
       #        to_port = 80
       #        protocol = "tcp"
       #        cidr_blocks = ["0.0.0.0/0"]
       # }
       ingress {
              from_port = 0
              to_port = 0
              protocol = "-1"
              self = true
       }

       ingress {
              from_port = 10250
              to_port = 10250
              protocol = "tcp"
              cidr_blocks = ["0.0.0.0/0"]
       }
       egress {
              from_port = 0  # 모든 포트
              to_port = 0    # 모든 포트
              protocol = "-1" # 모든 프로토콜
              cidr_blocks = ["0.0.0.0/0"]
       }
} 

# ssh용 보안그룹 생성
resource "aws_security_group" "std4_ssh_sg" {
       name = "std4_ssh_sg"
       vpc_id = aws_vpc.std4_vpc.id
       description = "Allow ssh"

       tags = {
              Name = "std4_ssh_sg"
       }

       ingress {
              from_port = 22
              to_port = 22
              protocol = "tcp"
              cidr_blocks = ["0.0.0.0/0"]
       }

       egress {
              from_port = 0  # 모든 포트
              to_port = 0    # 모든 포트
              protocol = "-1" # 모든 프로토콜
              cidr_blocks = ["0.0.0.0/0"]
       }

} 

# web용 보안그룹 생성
# HTTP 및 HTTPS용 보안그룹 생성
resource "aws_security_group" "std4_web_sg" {
  name        = "std4_web_sg"
  vpc_id      = aws_vpc.std4_vpc.id
  description = "Allow HTTP and HTTPS for web services"

  # HTTP (80포트) 허용
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  # HTTPS (443포트) 허용
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  # 아웃바운드 규칙 (모든 곳으로 나감)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "std4_web_sg"
  }
}



# # 보안 그룹 규칙 생성 (alb와 http를 연결해주는 징검다리 역할을 함)
# resource "aws_security_group_rule" "std4_sg_rule" {
#        type = "ingress"
#        from_port = 8080
#        to_port = 8085
#        protocol = "tcp"
#        # 이 보안 규칙을 어디에 추가할 것인가? 
#        security_group_id = aws_security_group.std4_web_sg.id

#        # 누구를 추가할 것인가
#        source_security_group_id = aws_security_group.std4_alb_sg.id

# }
