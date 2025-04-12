resource "aws_launch_template" "csye6225_asg" {
  name          = "webapp-launch-template"
  image_id      = var.custom_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.cloudwatch_agent_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    # subnet_id                   = aws_subnet.public[*].id
    security_groups = [aws_security_group.webapp-security-group.id]
  }

  user_data = base64encode(templatefile("./scripts/user_data_script.sh", {
    DB_HOST        = substr(aws_db_instance.rds_instance.endpoint, 0, length(aws_db_instance.rds_instance.endpoint) - 5)
    DB_USER        = var.db_username
    DB_PASSWORD    = random_password.db_password.result
    DB_PORT        = var.db_port
    DB_DIALECT     = var.db_dialect
    DB_NAME        = var.database_name
    PORT           = var.server_port
    S3_BUCKET_NAME = aws_s3_bucket.bucket.bucket
    AWS_REGION     = var.region
    NODE_ENV       = var.node_env
    SECRET_ID      = aws_secretsmanager_secret.db_password.id
  }))

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_key.arn
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp-ec2-instance"
    }
  }
  depends_on = [
    aws_db_instance.rds_instance,
    aws_secretsmanager_secret_version.db_password,
    aws_kms_key.ec2_key,
    aws_kms_key.rds_key,
    aws_kms_key.s3_key,
    aws_kms_key.secrets_manager_key
  ]
}