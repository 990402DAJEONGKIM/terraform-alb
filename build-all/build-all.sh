#!/bin/bash

# 6개 nginx 컨테이너 빌드 및 도커 허브 푸시 통합 스크립트

set -e

SERVICES=("main" "install" "command" "build" "compose" "swarm")
TAG="1.29.7"
USER="dajeongkim"

BASE_DIR=$(dirname "$0")

echo "------------------------------------------------"
echo "도커 빌드 및 푸시 작업을 시작합니다."
echo "------------------------------------------------"

for SVC in "${SERVICES[@]}"
do
    IMAGE_NAME="$USER/nginx:$TAG-docker-$SVC"
    # 폴더 경로를 정확히 맞추기 위해 다시 확인
    TARGET_DIR="$BASE_DIR/$SVC"
    
    if [ -d "$TARGET_DIR" ]; then
        echo ">>> [$SVC] 작업 중..."
        
        # 1. 빌드
        docker build -t "$IMAGE_NAME" "$TARGET_DIR"
        
        # 2. 푸시
        docker push "$IMAGE_NAME"
        
        echo "✅ 완료: $IMAGE_NAME"
    else
        echo "❌ 실패: $TARGET_DIR 폴더를 찾을 수 없습니다."
    fi
done

echo "------------------------------------------------"
echo "모든 작업이 끝났습니다! 이제 EC2에서 다시 시도해 보세요."