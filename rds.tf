# Creating Security Group for DB 
resource "aws_security_group" "database-security-group" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp-security-group.id]
  } # allowing incoming connection from EC2 instance security group

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp-security-group.id]
  }

  tags = {
    Name = "database-security-group"
  }
}

# Parameter Group for DB
resource "aws_db_parameter_group" "postgresql_parameter_group" {
  name        = "csye6225-postgresql-params"
  family      = "postgres16"
  description = "DB Parameter Group for webapp"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

  tags = {
    Name = "csye6225-postgresql-params"
  }
}

# DB Subnet Group using only private subnets
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "csye6225-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id # Using private subnets for RDS instance

  tags = {
    Name = "csye6225-db-subnet-group"
  }
}
# I
resource "aws_iam_service_linked_role" "rds_service_role" {
  aws_service_name = "rds.amazonaws.com"
  description      = "Service-linked role for RDS"
}


# RDS Instance
resource "aws_db_instance" "rds_instance" {
  allocated_storage      = 20
  instance_class         = "db.t3.micro"
  engine                 = "postgres"
  engine_version         = "16"
  identifier             = "csye6225"
  db_name                = var.database_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.postgresql_parameter_group.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.database-security-group.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name # Using DB Subnet Group
  multi_az               = false

  tags = {
    Name = "csye6225"
  }
   depends_on = [aws_iam_service_linked_role.rds_service_role]
}
