resource "aws_security_group" "webapp-security-group" {
  name        = "web-app-sg"
  description = "Security group for EC2 instances hosting the web application"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH for administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow custom application port"
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound connections"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webapp-security-group"
  }
}

resource "aws_instance" "web_app_instance" {
  ami                         = var.custom_ami_id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public[0].id
  iam_instance_profile        = aws_iam_instance_profile.file_bucket_instance_profile.name
  vpc_security_group_ids      = [aws_security_group.webapp-security-group.id]
  associate_public_ip_address = true
  disable_api_termination     = false

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }
  user_data = templatefile("./scripts/user_data_script.sh", {
    DB_HOST        = substr(aws_db_instance.rds_instance.endpoint, 0, length(aws_db_instance.rds_instance.endpoint) - 5)
    DB_USER        = var.db_username
    DB_PASSWORD    = var.db_password
    DB_NAME        = var.database_name
    APP_PORT       = var.application_port
    S3_BUCKET_NAME = aws_s3_bucket.bucket.bucket
    AWS_REGION     = var.region
    NODE_ENV = var.node_env
  })
  tags = {
    Name = "web-app-instance"
  }
}
