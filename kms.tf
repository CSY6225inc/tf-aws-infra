resource "random_password" "db_password" {
  length  = 16
  special = false
}

data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "db_password" {
  name_prefix = "db-password-"
  kms_key_id  = aws_kms_key.secrets_manager_key.arn
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "aws_iam_policy" "secrets_manager_access" {
  name        = "SecretsManagerDBPasswordAccess"
  description = "Allows access to DB secrets"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey",
        "kms:DescribeKey",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      Resource = aws_secretsmanager_secret.db_password.arn
    }]
  })
}

# # EC2 KMS Key for EBS Encryption
resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2 EBS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "AllowRootAccountToManageKey",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "AllowTerraformCallerToManageKeyPolicy",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${data.aws_caller_identity.current.arn}"
        },
        "Action" : [
          "kms:PutKeyPolicy",
          "kms:GetKeyPolicy",
          "kms:DeleteKeyPolicy"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowEC2InstanceRoleAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.s3_access_role.name}"
        },
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowEC2Service",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowSecretsManagerServiceUse",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "secretsmanager.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowRDSServiceUse",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "rds.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowS3ServiceUse",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "s3.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowTerraformUserToUseKey",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.profile}-user"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowAutoScalingService",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "autoscaling.amazonaws.com"
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowServiceLinkedRoleAutoScaling",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Secrets Manager KMS Key
resource "aws_kms_key" "secrets_manager_key" {
  description             = "KMS key for Secrets Manager"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90
  policy                  = aws_kms_key.ec2_key.policy
}


# RDS KMS Key
resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = aws_kms_key.ec2_key.policy
  rotation_period_in_days = 90
  tags                    = { Name = "rds-key" }
}

# S3 KMS Key
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = aws_kms_key.ec2_key.policy
  rotation_period_in_days = 90
  tags                    = { Name = "s3-key" }
}

resource "aws_iam_role_policy_attachment" "secrets_manager_attachment" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.secrets_manager_access.arn
}
