# S3 code begins here
resource "random_uuid" "bucket_name" {}


resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "S3BucketAccessPolicy"
  description = "Required policies for S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
        ]
      }
    ]
  })

  depends_on = [aws_s3_bucket.bucket]
}


resource "aws_iam_role" "s3_access_role" {
  name = "S3AccessRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy_atachment" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
}

resource "aws_s3_bucket" "bucket" {
  bucket        = random_uuid.bucket_name.result
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_server_side_config" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket]
  bucket     = aws_s3_bucket.bucket.id
  acl        = "private"
}
# I'm setting lifecycle configuration to transition objects to STANDARD_IA after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_rule" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    id     = "TransitionToStandardIA"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_iam_instance_profile" "file_bucket_instance_profile" {
  name = "ec2-s3-access-instance-profile"
  role = aws_iam_role.s3_access_role.name
}
# resource "aws_kms_key" "kms_s3_key" {
#   description             = "This key is used to encrypt S3 buckets"
#   deletion_window_in_days = 10
#   enable_key_rotation     = true
#   tags = {
#     Name = "kms-key-s3"
#   }
# }

# I'm blocking all the public access to s3 bucket
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

