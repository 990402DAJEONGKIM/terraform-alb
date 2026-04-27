# 이미지 생성
resource "aws_ami_from_instance" "std4_ami" {
  count=1
  name = "std4-ami"
  # ami를 만들 인스턴스 정의
  source_instance_id = aws_instance.std4_instance[count.index].id  
  # ami 생성 시 인스턴스 재부팅 여부 (반드시 인스턴스 중단 후 만들어야함, 디폴트는 true)
  snapshot_without_reboot = false # 인스턴스 재부팅 한다는 의미

  tags = {
    Name = "std4_ami"
  }
}


# 시작 템플릿 생성
resource "aws_launch_template" "std4_launch_template" {
  count = 1
  image_id = aws_ami_from_instance.std4_ami[count.index].id
  name_prefix = "std4_launch_template"
  instance_type = "t3.micro"
  key_name = "std4-keypair"

  vpc_security_group_ids = [data.aws_security_group.std4_ssh_sg.id]


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "std4_asg_instance"
    }

  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "std4_asg_instance_volume"
    }

  }
}

# 오토스케일링 그룹 생성
resource "aws_autoscaling_group" "std4_asg" {
    count = 1
    name = "std4-asg"

    max_size = 3
    min_size = 1
    desired_capacity = 1
    launch_template {
        id = aws_launch_template.std4_launch_template[count.index].id
        # version = "$Default" # 항상 디폴트 버전으로 지정
        version = "$Latest"
    }

    # 위치할 서브넷 지정
    vpc_zone_identifier = [
        data.aws_subnets.std4_private_subnets.ids[0],
        data.aws_subnets.std4_private_subnets.ids[1],
        data.aws_subnets.std4_private_subnets.ids[2]
    ]

    # 테라폼이 서버 개수 차이를 무시하게 해서 의도치 않은 서버 종료를 막는 설정
    lifecycle {
        ignore_changes = [desired_capacity]
    }


    # 대상 그룹 지정
    target_group_arns = [
        aws_lb_target_group.std4_docker_main_tg.arn,
        aws_lb_target_group.std4_docker_install_tg.arn 
    ]

    # 헬스 체크
    health_check_type = "ELB" 
    health_check_grace_period = 300 # 안스턴스 시작 후 헬스체크 시작 전까지 얼마나 기다릴 것인지 초 지정
}


# 오토스케일 그룹 인스턴스 조정 기준
resource "aws_autoscaling_policy" "std4_asg_policy" {
    name = "std4-asg-policy"
    autoscaling_group_name = aws_autoscaling_group.std4_asg.name
    # 대상 추적 유형 - StepScaling : 지표가 특정 임계값을 초과할 때 단계적으로 조정, SimpleScaling :  지표가 특정 임계값을 초과할 때 단일 조정, PredictiveScaling : 과거 지표를 기반으로 미래 수요 예측하여 조정
    policy_type = "TargetTrackingScaling" # 특정 지표가 목표값을 유지하도록 자동으로 조정

    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 50.0

    }
}