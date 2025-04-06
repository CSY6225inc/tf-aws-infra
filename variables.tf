variable "vpc_name" {
  description = "Unique identfier tag for VPC we create"
  type        = string
  default     = "main-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "50.0.0.0/16"
}

variable "region" {
  description = "AWS region where vpc will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "subnet_prefix_length" {
  description = "Defines how big each subnet will be inside the VPC"
  type        = number
  default     = 20
}

variable "profile" {
  description = "choose AWS profile which we are usign for terraform"
  type        = string
  default     = "dev"
}
variable "vpc_subnet_mask" {
  description = "Subnet mask for the VPC subnets"
  type        = number
  default     = 4
}

variable "custom_ami_id" {
  description = "The custom AMI ID built via Packer"
  type        = string
}

variable "server_port" {
  description = "Port on which the web application listens"
  type        = number
  default     = 8080
}

variable "account_id" {
  type    = string
  default = "value"
}

variable "application_port" {
  description = "Port on which your application runs"
  type        = number
  default     = 3000
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 25
}

variable "key_name" {
  description = "SSH key pair to access EC2"
  type        = string
  default     = ""
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  default     = "password"
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "postgres"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "postgres"
}

variable "node_env" {
  description = "Node environment"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "domain name user defined"
  type        = string
  default     = "demo"
}
variable "sub_domain_name" {
  description = "sub domain name user defined"
  type        = string
  default     = "bhuvanraj.me"
}

variable "lb_dns_name" {
  description = "The DNS name of the load balancer"
  type        = string
}

variable "lb_zone_id" {
  description = "The Zone ID of the load balancer"
  type        = string
}

variable "certificate_arn" {
  description = "arn for load balancer listener to allow HTTPS SSL certificate"
  type        = string
}