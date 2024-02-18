#!/bin/bash

# Install Kaggle CLI
pip3 install kaggle

# Create Kaggle directory
mkdir -p ~/.kaggle

# Configure AWS CLI
aws configure set aws_access_key_id <AWS_ACCESS_KEY_ID>
aws configure set aws_secret_access_key <AWS_SECRET_ACCESS_KEY>
aws configure set default_region <DEFAULT_REGION>
aws configure set output json

# Download Kaggle credentials file from S3
aws --no-sign-request s3 cp s3://shubh-datalak-raw/kaggle.json ~/.kaggle

# Add Kaggle CLI to PATH
export PATH=$PATH:~/.local/bin
source ~/.bashrc

# Install specific version of urllib3
pip3 install urllib3==1.26.8

# Set appropriate permissions for Kaggle credentials
chmod 600 /home/ec2-user/.kaggle/kaggle.json

# Download Kaggle dataset
kaggle datasets download -d allanbruno/airbnb-rio-de-janeiro

# Unzip downloaded dataset
unzip airbnb-rio-de-janeiro.zip

# Upload dataset to S3
aws s3 cp /home/ec2-user/total_data.csv s3://shubh-datalak-raw/
