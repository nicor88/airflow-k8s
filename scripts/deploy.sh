#!/usr/bin/env bash

IMAGE_NAME=airflow
K8S_NAMESPACE=airflow
: "${COMMIT_HASH:="$(git log -1 --pretty=%H)"}"

echo ${COMMIT_HASH}

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
docker tag ${IMAGE_NAME} ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:latest || EXIT_STATUS=$?
docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:latest || EXIT_STATUS=$?

# tag and push image with commit hash
docker tag ${IMAGE_NAME} $AWS_ACCOUNT.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${COMMIT_HASH} || EXIT_STATUS=$?
docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${COMMIT_HASH} || EXIT_STATUS=$?

if [ "$EXIT_STATUS" = "1" ]; then
  echo "There was an issue with the building, skipping k8s deployment"
else

echo "Update Kubernetes containers image"
    # update deployments image
	kubectl set image deployment/airflow-worker worker=${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/airflow:$COMMIT_HASH -n ${K8S_NAMESPACE} || EXIT_STATUS=$?
	kubectl set image deployment/airflow-scheduler scheduler=${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/airflow:$COMMIT_HASH -n ${K8S_NAMESPACE} || EXIT_STATUS=$?
	kubectl set image deployment/airflow-web web=${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/airflow:$COMMIT_HASH  -n ${K8S_NAMESPACE} || EXIT_STATUS=$?
fi

exit $EXIT_STATUS
