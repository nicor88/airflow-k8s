#!/usr/bin/env bash

IMAGE_NAME=airflow


if [ -z ${AWS_ACCOUNT} ]; then
    echo "Set AWS_ACCOUNT as env variable"
    exit 1
fi

if [ -z ${AWS_DEFAULT_REGION} ]; then
    echo "Set AWS_DEFAULT_REGION as env variable"
    exit 1
fi

### ECR - build images and push to remote repository

echo "Building image: ${IMAGE_NAME}:latest"

docker build --rm -t ${IMAGE_NAME}:latest .

aws ecr create-repository --repository-name ${IMAGE_NAME} --region ${AWS_DEFAULT_REGION}  || echo "AWS ECR Repository ${IMAGE_NAME} exists"

eval $(aws ecr get-login --no-include-email)

# tag and push image using latest
docker tag ${IMAGE_NAME} ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:latest
docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:latest

# tag and push image with commit hash
COMMIT_HASH="init"
docker tag ${IMAGE_NAME} $AWS_ACCOUNT.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${COMMIT_HASH}
docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${COMMIT_HASH}
