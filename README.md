# This is a starter template for deploying [Next.js](https://nextjs.org/learn) on AWS Fargate.

## Local Development

```
yarn install
yarn dev
```

## Production build

```
yarn install --frozen-lockfile
yarn build
```

## Docker build

```
docker build -t nextjs-demo .
```

## Deploying to AWS

There are 3 major steps to deploying to AWS.

1. Deploy the networking stack (VPC) to AWS
1. Build and push the docker image to AWS Elastic Container Service (ECS)
1. Deploy the compute stack to (Fargate) AWS

### Deploying the networking stack

```
cd .aws/live/dev/networking
terraform init
terraform apply
```

### Build and push docker image

```
export VERSION=1
export IMAGE=formidablelabs/nextjs-fargate-demo
export REGISTRY=168765413198.dkr.ecr.us-east-1.amazonaws.com/nextjs-fargate-demo

docker build -t $IMAGE:$VERSION . --no-cache

eval $(aws ecr get-login --no-include-email --region us-east-1)

docker tag $IMAGE:$VERSION $REGISTRY:$VERSION
docker push $REGISTRY:$VERSION
```

### Deploying the compute stack

```
export VERSION=1
cd .aws/live/dev/compute
terraform init
terraform apply -var "image=168765413198.dkr.ecr.us-east-1.amazonaws.com/nextjs-fargate-demo:$VERSION"
```
