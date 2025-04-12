#!/bin/bash
echo "Setting up .env file..."
# Remove any existing .env file
rm -f /opt/csye6225/.env
touch /opt/csye6225/.env
chown csye6225:csye6225 /opt/csye6225/.env
chmod 600 /opt/csye6225/.env

SECRET_STRING=$(aws secretsmanager get-secret-value \
  --region "${AWS_REGION}" \
  --secret-id "${SECRET_ID}" \
  --query SecretString \
  --output text)


DB_PASSWORD=$(echo $SECRET_STRING | jq -r '.password')


# Write environment variables to .env file
cat <<EOT > /opt/csye6225/.env
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_NAME=${DB_NAME}
DB_PORT=${DB_PORT}
DB_DIALECT=${DB_DIALECT}
DB_PASSWORD=${DB_PASSWORD}
S3_BUCKET_NAME=${S3_BUCKET_NAME}
AWS_REGION=${AWS_REGION}
NODE_ENV=${NODE_ENV}
PORT=${PORT}
EOT

# Set correct permissions                                    
chown csye6225:csye6225 /opt/csye6225/.env
chmod 640 /opt/csye6225/.env

# Create log file for CloudWatch logs
touch /var/log/csye6225.log
chown csye6225:csye6225 /var/log/csye6225.log
chmod 644 /var/log/csye6225.log

# Start CloudWatch agent
cp /home/ubuntu/amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
sleep 60
sudo systemctl restart csye6225.service