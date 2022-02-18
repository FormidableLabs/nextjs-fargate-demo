# This is a demo of deploying [Next.js](https://nextjs.org/learn) on AWS Fargate.

The demo application contains static content, dynamic routes, and API routes.

Please read the [Real World Notes](#real-world-notes) before continuing.

#### Requirements

- [Nodejs](https://nodejs.org/en/download/) 12.16+ or higher
- [Yarn](https://classic.yarnpkg.com/en/docs/install)
- [AWS CLI V2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Terraform 13.5](https://www.terraform.io/downloads.html) (exact version)

#### Local Development

```
yarn install
yarn dev
```

#### Production build

```
yarn install --frozen-lockfile
yarn build
```

#### Docker build

```
docker build -t nextjs-demo .
```

## Deploying to AWS

There are several high level steps to deploying to AWS.

1. Bootstrap the AWS account to prepare for Terraform
1. Deploy the networking stack (VPC & ECR) to AWS
1. Build and push the docker image to AWS Elastic Container Registry (ECR)
1. Deploy the compute stack (Fargate, Load Balancer) to AWS

The stack is segmented in layers to allow you to precisely target the deployment you need.
For example, changing just the number of containers you want running in ECS only requires
you to rerun the compute stack. Changing the application requires rerunning the build and
the compute stack. The networking layer only needs to be run when changes are made to the
underlying VPC. 

This allows each layer to be more focused and modular while allowing you to skip steps in
a CI or manual deployment process.

### Bootstrap the AWS Account

In order to track the state of deployed Terraform resources, we need to Bootstrap the
AWS account for use with Terraform. This will deploy an S3 Bucket and Dynamodb table for
state locking that will be used when running Terraform commands.

```
cd .aws/live/dev

terraform init
terraform apply
```

This will bootstrap the `dev` environment into your aws account. Make note of the S3 bucket
name, it is unique to the AWS account you deployed in and will be needed in later steps.

```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

state_bucket = nextjs-fargate-demo-168765413198-terraform-state
```

To create a new
stage/environment, simply create a new level adjacent to dev, eg `.aws/live/prod`.

This setup works for both a single environment per AWS Account (recommended) or multiple 
environments per AWS Account. See the section later on real world differences.

### Deploying the networking stack

Run the following in your terminal with [Terraform](https://www.terraform.io/downloads.html) 13.x.

```
cd .aws/live/dev/networking

export TF_CLI_ARGS_init="-backend-config=\"bucket=$(cd ../ && terraform output state_bucket)\""
terraform init 
terraform apply
```

### Build and push docker image

Run the following in a terminal or as a Bash script from the root directory.

```
export VERSION=1
export IMAGE=formidablelabs/nextjs-fargate-demo
export REGISTRY=$(cd .aws/live/dev/networking && terraform output repository_url)

docker build -t $IMAGE:$VERSION . --no-cache

eval $(aws ecr get-login --no-include-email --region us-east-1)

docker tag $IMAGE:$VERSION $REGISTRY:$VERSION
docker push $REGISTRY:$VERSION
```

### Deploying the compute stack

Run the following in a terminal or as a Bash script.

```
cd .aws/live/dev/compute

export VERSION=1
export TF_CLI_ARGS_init="-backend-config=\"bucket=$(cd ../ && terraform output state_bucket)\""
terraform init
terraform apply -var "image_version=$VERSION"
```

It will take a few moments to fully launch the server, but you will see an output with a DNS url that allows you to hit the service when it is online.

This project is currently configured for HTTP (80), it will require adding a domain and ACM SSL Certs for HTTPS (443).

```
Outputs:

alb_hostname = nextjs-fargate-demo-dev-alb-<accountid>.us-east-1.elb.amazonaws.com
```

## AWS Architecture

*Coming Soon*

## Real World Notes

This reference application tries to strike a balance between a real world production setup, and
something that is easy to understand for the purposes of teaching the primary goal of
how to launch Nextjs on AWS Fargate. As such, there are some differences to keep in mind.

### ECR

In a typical production setup, you would only have a single ECR repository for an application
and not one for each stage. The CI would build a new version of your docker image and deploy
it once to ECR. As your promote the application from `dev` to `qa` to `prod`, you would simply
reference the image version you wish to deploy.

### VPC

Typically you would create the VPC as part of the AWS Account provisioning process, so you would have a single VPC per account instead of a VPC per stage, regardless of how many stages you deploy to an account.

### Bootstrap and S3 Backends

The bootstrap file is typically a per-account process and is often part of account provisioning
in an enterprise setup of AWS and Terraform. Its included here as a quick way to get up and
running, but may not reflect the best way forward for your organization since it stores its
state on your local disk and if lost, would need to be manually cleaned up.

The S3 backends use static strings for the bucket keys. In order to deploy multiple stages
to a single AWS account you would need to modify that string to include the stage or modify
the `TF_CLI_ARGS_init` environment variable to include a new `key` param.

### Dockerfile

The current dockerfile installs both devDependencies and dependencies. For production usage you should slim this docker image down to only what is required for runtime.

### HTTPS

In a real world deployment you would not use HTTP for this application. In order to use HTTPS/SSL, you will need to provision a domain and SSL certificate and attach that to the load balancer. SSL Certs for load balancers require a custom domain.


## Maintenance Status

**Archived:** This project is no longer maintained by Formidable. We are no longer responding to issues or pull requests unless they relate to security concerns. We encourage interested developers to fork this project and make it their own!
