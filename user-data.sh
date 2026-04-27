#!/bin/bash
# 1. 중복 실행 방지 로직
FLAG_FILE="/var/log/first-boot-done"
if [ -f "$FLAG_FILE" ]; then
    exit 0
fi

# 1. 필수 패키지 및 Docker 설치
# AL2023은 공식 리포지토리에 Docker가 포함되어 있어 dnf로 즉시 설치 가능합니다.
dnf update -y

# 2. 좀더 쉽게 dnf에 외부 레포지토리 등록을 하기 위해 dnf-plugins-core을 설치합니다.
dnf install -y docker wget

# Docker Compose v2 플러그인 설치: 공식문서
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# 3. Docker 서비스 활성화 및 실행
systemctl enable --now docker
usermod -aG docker ec2-user

# 4. 프로젝트 디렉토리 설정 및 파일 다운로드
mkdir -p /opt/std4-alb-project && cd /opt/std4-alb-project
# wget https://raw.githubusercontent.com/csjin21c/lab-repo/refs/heads/main/docker-compose-alb.yaml

# 본인 깃허브 주소로 변경
wget https://raw.githubusercontent.com/990402DAJEONGKIM/terraform-alb/refs/heads/main/yaml/docker-compose.yaml

# --pull always를 통해 인스턴스 생성 시점에 가장 최신 이미지를 가져옵니다.
docker compose -f docker-compose-alb.yaml up -d --pull always

# 6. 완료 플래그 생성
# touch 대신 이렇게 쓰면 날짜와 시간이 파일 안에 기록됩니다.
date > "$FLAG_FILE"
echo "Terraform App Instance Setup Complete" >> "$FLAG_FILE"