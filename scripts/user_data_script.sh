#!/bin/bash

# Enable logging for troubleshooting
exec > /tmp/update_env.log 2>&1
set -e

# Create directory if it doesn't exist
mkdir -p /opt/csye6225/

# Database variables
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
S3_BUCKET_NAME=${S3_BUCKET_NAME}

# AWS Credentials
AWS_REGION=${AWS_REGION}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

# Log variables for debugging
echo "DB_HOST=${DB_HOST}"
echo "DB_USER=${DB_USER}"
echo "DB_PASSWORD=${DB_PASSWORD}"
echo "DB_DATABASE=${DB_NAME}"
echo "S3_BUCKET_NAME=${S3_BUCKET_NAME}"
echo "AWS_REGION=${AWS_REGION}"
echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"

# Update .env file in /opt/csye6225/
sudo -u csye6225 bash -c "sed -i '/^DB_HOST=/d' /opt/csye6225/.env && echo \"DB_HOST=${DB_HOST}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^DB_USER=/d' /opt/csye6225/.env && echo \"DB_USER=${DB_USER}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^DB_PASSWORD=/d' /opt/csye6225/.env && echo \"DB_PASSWORD=${DB_PASSWORD}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^DB_DATABASE=/d' /opt/csye6225/.env && echo \"DB_DATABASE=${DB_NAME}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^DB_PORT=/d' /opt/csye6225/.env && echo \"DB_PORT=5432\" >> /opt/csye6225/.env"

# Add AWS credentials to .env
sudo -u csye6225 bash -c "sed -i '/^S3_BUCKET_NAME=/d' /opt/csye6225/.env && echo \"S3_BUCKET_NAME=${S3_BUCKET_NAME}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^AWS_REGION=/d' /opt/csye6225/.env && echo \"AWS_REGION=${AWS_REGION}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^AWS_ACCESS_KEY_ID=/d' /opt/csye6225/.env && echo \"AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^AWS_SECRET_ACCESS_KEY=/d' /opt/csye6225/.env && echo \"AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}\" >> /opt/csye6225/.env"

# Set proper permissions
sudo chown csye6225:csye6225 /opt/csye6225/.env
sudo chmod 600 /opt/csye6225/.env

# Restart web application
sudo systemctl daemon-reload
sudo systemctl restart csye6225.service
