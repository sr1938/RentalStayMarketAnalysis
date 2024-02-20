# provider
provider "aws" {
    region = "us-east-1"
  }
# generate randomised names
resource "random_id" "random_id_generator" {
    byte_length = 8
}

#------------------- STEP FUNCTION TO TRIGGER GLUE JOB ------------------------#
#  Define an SNS topic : 

resource "aws_sns_topic" "glue_job_notification" {
  name = "glue_job_notification_topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.glue_job_notification.arn
  protocol  = "email"
  endpoint  = "shubhamr1938@gmail.com"
}

####--------------------------------------- S3 bucket --------------------------------------------####
resource "aws_s3_bucket" "scripts" {
    bucket = "deployingscripts-${random_id.random_id_generator.hex}"
    
    tags = {
        project_type = "demo"
    } 
}
resource "aws_s3_bucket_ownership_controls" "scripts" {
  bucket = aws_s3_bucket.scripts.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "scripts" {
  bucket = aws_s3_bucket.scripts.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_acl" "scripts" {
  depends_on = [
    aws_s3_bucket_ownership_controls.scripts,
    aws_s3_bucket_public_access_block.scripts,
  ]

  bucket = aws_s3_bucket.scripts.id
  acl    = "public-read"
}

####--------------------------------------- EC2 Instance --------------------------------------------####

# resource "aws_instance" "ec2ingest"{
#   ami            = "ami-0cf10cdf9fcd62d37" 
#   instance_type  = "t2.micro"
#   key_name       = "shubhamkey"
#   vpc_security_group_ids = [aws_security_group.main.id]

#   root_block_device {
#         volume_size = 30  # Set the root volume size to 30 GB
#   }
#    tags = {
#     Name = "Kaggle-EC2"
#   }
# }

# resource "aws_security_group" "main" {
  
#   ingress {
#     from_port   = 22
#     protocol    = "TCP"
#     to_port     = 22
#     cidr_blocks = ["0.0.0.0/0"]

#   }

#   egress {
#     from_port  = 0
#     protocol   = "-1"
#     to_port    = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# ####--------------------------------------- EMR --------------------------------------------####

# resource "aws_emr_cluster" "emr_cluster" {
#   name          = "emr-ingest-rds"
#   release_label = "emr-6.15.0"
#   applications  = ["Spark"]

#   termination_protection            = false
#   keep_job_flow_alive_when_no_steps = true

#   ec2_attributes {
#     emr_managed_master_security_group = aws_security_group.main.id
#     emr_managed_slave_security_group  = aws_security_group.main.id
#     instance_profile                  = "EMR_EC2_DefaultRole"
#   }

#   master_instance_group {
#     instance_type = "m5.xlarge"
#   }

#   ebs_root_volume_size = 30

#   tags = {
#     Name = "EMR-RDS-S3"
#     role = "rolename"
#     env  = "env"
#   }

#   service_role = "EMR_DefaultRole"
# }

# ####--------------------------------------- RDS --------------------------------------------####

# resource "aws_db_instance" "rds_ingest_instance" {
#   engine                   = "mysql"
#   db_name                  = "group4"
#   username                 = "admin"
#   password                 = "123456789"
#   skip_final_snapshot      = true
#   delete_automated_backups = true
#   multi_az                 = false
#   publicly_accessible      = true
#   instance_class           = "db.t3.micro"
#   allocated_storage        = 20
#   availability_zone        = "us-east-1c"
  
# }