#!/bin/bash
# 6개 nginx 컨테이너 한번에 도커 이미지 만드는 쉘 스크립트

# 에러 발생 시 즉시 중단 (안정성 확보)
set -e

# 서비스 리스트
SERVICES=("main" "install" "command" "build" "compose" "swarm")
TAG="1.29.7"
USER="dajeongkim"

# 스크립트 파일이 위치한 실제 경로를 파악 (어디서 실행하든 안전하게)
BASE_DIR=$(dirname "$0")

for SVC in "${SERVICES[@]}"
do
    echo "------------------------------------------"
    echo "Building image for: $USER/nginx:$TAG-docker-$SVC"
    echo "------------------------------------------"
    
    # 실제 Dockerfile이 있는 경로 지정 (./build-all/$SVC)
    TARGET_DIR="$BASE_DIR/$SVC"
    
    if [ -d "$TARGET_DIR" ]; then
        docker build -t $USER/nginx:$TAG-docker-$SVC "$TARGET_DIR"
        # docker push $USER/nginx:$TAG-docker-$SVC
    else
        echo "경고: $TARGET_DIR 폴더를 찾을 수 없습니다. 건너뜁니다."
    fi
done

echo "모든 이미지 빌드 완료!"