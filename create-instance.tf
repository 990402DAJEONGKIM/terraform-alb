# # 키 페어 생성
# resource "aws_key_pair" "std4_key_pair" {
#        key_name = "std4_key_pair"
#        public_key = file("~/.ssh/std4-keypair.pub")
# }
 # ===========================================================================================================================================================================
 
# ===========================================================================================================================================================================
# 인스턴스 생성
resource "aws_instance" "std4_instance" {
  count=1
  ami           = "ami-0aa31b568c1e8d622" # 서울 리전 기준 Ubuntu 22.04
  instance_type = "t3.micro"

  subnet_id = data.aws_subnets.std4_public_subnets.ids[0]
  
  # 퍼블릭 IP 활성화
  associate_public_ip_address = true

  vpc_security_group_ids = [
  data.aws_security_group.std4_ssh_sg.id,
  data.aws_security_group.std4_web_sg.id
]

  # 볼륨 지정
  root_block_device {
       volume_size = 10
       volume_type = "gp3"
       delete_on_termination = true  # 인스턴스 삭제 시 함께 삭제
  }

  # user data
  user_data = file("${path.module}/user-data.sh")
  key_name = "std4-keypair"
  tags = { Name = "std4-instance" }
}
# ===========================================================================================================================================================================
