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