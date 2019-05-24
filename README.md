# airflow-k8s
Setup to deploy Airflow in Kubernetes

## Requirements
* K8S cluster
* kubectl install locally
* kube config to interact with your cluster

## Deployment
Run first the command: `make deploy`, that will create an ECR repository and push the image to that repository.

<pre>
kube apply -f 
</pre>