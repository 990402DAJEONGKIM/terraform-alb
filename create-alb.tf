# alb 생성
resource "aws_lb" "std4_lb" {
    name = "std4-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [data.aws_security_group.std4_alb_sg.id]
    
    # 서로 다른 가용 영역에 있는 서브넷을 사용해야함 
    subnets = [
        data.aws_subnets.std4_public_subnets.ids[0],
        data.aws_subnets.std4_public_subnets.ids[1]
    ]

    tags = {
        Name = "std4_lb"
    }
}


# alb 리스너 생성
resource "aws_lb_listener" "std_alb_https_listener" {
    load_balancer_arn = aws_lb.std4_lb.arn
    port = 443
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-2016-08"
    certificate_arn = "arn:aws:acm:ap-south-2:476293896981:certificate/b33f5d1e-f655-4ed1-b0b4-6e1b398683bc"  # acm 에서 발급받은 인증서 arn

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.std4_docker_main_tg.arn
    }
    tags = {
        Name = "std_alb_https_listener"
    }
 }


 # alb 리스너 생성
resource "aws_lb_listener" "std_alb_http_listener" {
    load_balancer_arn = aws_lb.std4_lb.arn
    port = 80
    protocol = "HTTP"
    
    default_action {
        type = "redirect"
        redirect {
            protocol = "HTTPS"
            port = "443"
            status_code = "HTTP_301"
        }
    }
    tags = {
        Name = "std_alb_http_listener"
    }
 }


# ===================================================================================================
# 서비스 리스트와 우선순위 정의 (Main은 제외)
locals {
  services = {
    "install" = { priority = 20, target_group_arn = aws_lb_target_group.std4_docker_install_tg.arn }
    "main" = { priority = 10, target_group_arn = aws_lb_target_group.std4_docker_main_tg.arn }
    # "command" = { priority = 20, target_group_arn = aws_lb_target_group.std4_docker_command_tg.arn }
    # "build"   = { priority = 30, target_group_arn = aws_lb_target_group.std4_docker_build_tg.arn }
    # "compose" = { priority = 40, target_group_arn = aws_lb_target_group.std4_docker_compose_tg.arn }
    # "swarm"   = { priority = 50, target_group_arn = aws_lb_target_group.std4_docker_swarm_tg.arn }
  }
}

# 하나의 리소스 블록으로 5개 규칙 생성
resource "aws_lb_listener_rule" "std4_service_rules" {
  for_each     = local.services
  listener_arn = aws_lb_listener.std_alb_https_listener.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = each.value.target_group_arn
  }

  condition {
    path_pattern {
      values = ["/${each.key}*"] # 주소 뒤에 /install*, /command* 등을 자동으로 매칭
    }
  }
}



