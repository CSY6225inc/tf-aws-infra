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
AWS_REGION=${AWS_REGION}
NODE_ENV=${NODE_ENV}

# Log variables for debugging
echo "DB_HOST=${DB_HOST}"
echo "DB_USER=${DB_USER}"
echo "DB_PASSWORD=${DB_PASSWORD}"
echo "DB_DATABASE=${DB_NAME}"
echo "S3_BUCKET_NAME=${S3_BUCKET_NAME}"
echo "AWS_REGION=${AWS_REGION}"
echo "NODE_ENV=${NODE_ENV}"

# Update .env file in /opt/csye6225/
sudo -u csye6225 bash -c "sed -i '/^DB_HOST=/d' /opt/csye6225/.env && echo \"DB_HOST=${DB_HOST}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^DB_USER=/d' /opt/csye6225/.env && echo \"DB_USER=${DB_USER}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^DB_PASSWORD=/d' /opt/csye6225/.env && echo \"DB_PASSWORD=${DB_PASSWORD}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^DB_DATABASE=/d' /opt/csye6225/.env && echo \"DB_DATABASE=${DB_NAME}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^DB_PORT=/d' /opt/csye6225/.env && echo \"DB_PORT=5432\" >> /opt/csye6225/.env"

# Add AWS credentials to .env
sudo -u csye6225 bash -c "sed -i '/^S3_BUCKET_NAME=/d' /opt/csye6225/.env && echo \"S3_BUCKET_NAME=${S3_BUCKET_NAME}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^AWS_REGION=/d' /opt/csye6225/.env && echo \"AWS_REGION=${AWS_REGION}\" >> /opt/csye6225/.env"
sudo -u csye6225 bash -c "sed -i '/^NODE_ENV=/d' /opt/csye6225/.env && echo \"NODE_ENV=${NODE_ENV}\" >> /opt/csye6225/.env"

# Set proper permissions
sudo chown csye6225:csye6225 /opt/csye6225/.env
sudo chmod 600 /opt/csye6225/.env

# Restart web application
# sudo systemctl daemon-reload

# CloudWatch Agent Config
sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null <<EOF
{
  "metrics": {
    "namespace": "webapplogs",
    "append_dimensions": false,
    "metrics_collected": {
      "statsd": {
        "service_address": ":8125",
        "metrics_collection_interval": 60,
        "metrics_aggregation_interval": 300
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/csye6225-web-app/logs",
            "log_stream_name": "web-app",
            "retention_in_days": 1
          }
        ]
      }
    }
  }
}
EOF

# Set CloudWatch config permissions
sudo chown cwagent:cwagent /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo chmod 644 /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo systemctl restart csye6225.service
sudo systemctl restart amazon-cloudwatch-agent  