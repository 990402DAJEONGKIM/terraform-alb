# 대상 그룹 지정
resource "aws_lb_targer_group" "std4_docker_main_tg" {
    name = "std4_docker_main_tg"
    port = 8080
    protocol = "HTTP"
    vpc_id = data.aws_vpc.std4_vpc.id


# 헬스 체크 지정


}




# 대상 그룹 인스턴스 등록


# 