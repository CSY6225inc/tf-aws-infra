# tf-aws-infra
## Setting Up AWS VPC and Subnets with Terraform  

This project helps create a Virtual Private Cloud (VPC) on AWS along with public and private subnets using Terraform.

## What This Does  

- Sets up a VPC with a custom IP range.  
- Divides the network into public and private subnets across available zones.  
- Adds an internet gateway for public subnet access.  
- Uses variables to keep things flexible and easy to configure.  

## What You Need Before You Start  

Before running this setup, make sure you have:  

- An AWS account  
- Terraform installed ([Download Terraform](https://developer.hashicorp.com/terraform/downloads))  
- AWS CLI set up with your credentials  

## Configurable Settings  

You can tweak these values in the `variables.tf` file to fit your needs:

- **`vpc_cidr`** → Defines the network range for the VPC.  
- **`region`** → AWS region where everything will be created (default: `us-east-1`).  
- **`subnet_prefix_length`** → Controls subnet size (default: `20`).  
- **`profile`** → AWS profile to use (default: `dev`). You can also specify it when running commands like this:  ```terraform apply -var="profile=dev"```

## Usage

1. **Initialize Terraform:**  
   ```sh
   terraform init
   ```
2. **Plan Terraform:**
   ```bash
   terraform plan
   ```
3. **Apply the Terraform configuration:**
   ```bash
   terraform apply
   ```
4. **Destory the Terraform:**
   ```bash
   terraform destroy 
   ```
5. **Get RDS instance name:**
   ```bash 
   aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier,Endpoint.Address]" --output table
   ```
6. Other commands
   ```bash
   sudo apt-get install -y postgresql postgresql-contrib
   
    psql -h csye6225 -U postgres -d postgres
   ```