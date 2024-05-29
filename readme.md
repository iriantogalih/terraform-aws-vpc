# Project 1 - AWS VPC

## Description
This project aims to create an AWS Virtual Private Cloud (VPC) using Terraform.

## Features
- Creates a VPC with specified CIDR block
- Configures subnets, route tables, and internet gateway
- Sets up security groups and network ACLs
- Deploys EC2 instances within the VPC

## Prerequisites
- AWS account with appropriate permissions
- Terraform installed on your local machine

## Usage
1. Clone this repository.
2. Navigate to the project directory.
3. Run `terraform init` to initialize the project.
4. Modify the `variables.tf` file to customize your VPC configuration.
5. Run `terraform plan` to see the execution plan.
6. Run `terraform apply` to create the VPC and associated resources.
7. Run `terraform destroy` to tear down the infrastructure when no longer needed.

## Resources
- [Terraform Documentation](https://www.terraform.io/docs/index.html)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/index.html)

## License
This project is licensed under the [MIT License](LICENSE).