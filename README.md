# aws-fargate-example

This is a practical example to launch a service on AWS Fargate.

## Prerequisites

- AWS CLI
  - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
  - https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
  - In this example, the "dev" profile is needed. If you want to use another profile, please replace the name with your profile name.
- ECS CLI
  - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html
- Terraform
  - https://learn.hashicorp.com/terraform/getting-started/install.html

```console
$ aws --version
aws-cli/1.16.193 Python/3.7.3 Darwin/18.6.0 botocore/1.12.183
$ ecs-cli --version
ecs-cli version 1.14.1 (f73f9e3)
$ terraform version
Terraform v0.12.3
```

## Launch services on Fargate

First, create your S3 bucket by AWS CLI to store your tfstate file. You can specify `<BUCKET_NAME>` as you like.

```console
$ aws --profile dev s3api create-bucket --bucket <BUCKET_NAME> --acl private --create-bucket-configuration LocationConstraint=ap-northeast-1
```

Then, apply Terraform to create a Fargate cluster. It takes a while to create RDS instance and ElastiCache cluster.

```console
$ cd terraform
$ terraform init
$ terraform apply
var.cidr_office
  CIDR allowed connecting to resources, like your office's IP

  Enter a value: x.x.x.x/32

var.owner
  Owner name of resources

  Enter a value: your.name

var.s3_bucket_name
  Your S3 bucket name

  Enter a value: your-s3-bucket-name
...
```

After that, apply Terraform again to create a PostgreSQL database. It's needed to separate directories to avoid the postgresql provider issue. https://github.com/terraform-providers/terraform-provider-postgresql/issues/2

```console
$ cd terraform/postgresql
$ terraform init
$ terraform apply
var.db_root_password
  RDS root password

  Enter a value: db_root_pasword

var.owner
  Owner name of resources

  Enter a value: your.name
...
```

Finally, deploy Redash service to the Fargate cluster. Please set `<TARGET_GROUP_ARN>` and `<OWNER>` correctly, the owner tag is just a metadata though.

```console
$ ecs-cli compose --aws-profile dev --cluster dev-fargate --project-name redash service up --launch-type FARGATE --target-group-arn <TARGET_GROUP_ARN> --container-name server --container-port 5000 --tags Owner=<OWNER>
```

## Verify services and monitoring

TBD

## Destroy resources

If you want to destroy all resources of this example, please follow the steps below.

Delete the Redash service on Fargate cluster by ECS CLI.

```console
$ ecs-cli compose --aws-profile dev --cluster dev-fargate --project-name redash service down
```

Delete the PostgreSQL database by Terraform. Some error may occur but you can ignore it and remove the state if you also destroy the RDS instance. https://github.com/terraform-providers/terraform-provider-postgresql/issues/36

```console
$ cd terraform/postgresql
$ terraform destroy
...
Error: Error deleting role: pq: permission denied to reassign objects


$ terraform state rm postgresql_role.redash
$ terraform destroy
```

Destroy the remaining resources by Terraform. It takes a while to delete RDS instance and ElastiCache cluster.

```console
$ cd terraform
$ terraform destroy
```

Furthermore, if you want to delete the S3 bucket you created, please execute the following command. `<BUCKET_URL>` is like `s3://bucket-name`.

```console
$ aws --profile dev s3 rb <BUCKET_URL> --force
```
