-- to create a aws terraform automated infrastructure


-- terraform aws provider :- for the documentation of providers
-- create provider.tf

provider "aws" {
    region = "region"
    access_key = "access_key"
    secret_key = "secret_key"
    token = "token"
}

resource "aws_instance" "name" {
    ami = "ami_key_provided_on_ec2_instance_select_amazon-linux_as_well"
    instance_type = "t2.micro"
}




## AWS Glue Script -- to read the data of the table -- using aws glue

-- refer TestDeploy.py -- script for the transformation

%idle_timeout 2880
%glue_version 4.0
%worker_type G.1X
%number_of_workers 5

import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
  
sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

airbnb_table = glueContext.create_dynamic_frame_from_options(
    connection_type="s3",
    connection_options={"paths": ['s3://airbnbrawdata/airbnb_data/']},  # Corrected S3 path
    format="csv",
    format_options={"withHeader": True, "optimizePerformance": True}  # Corrected format options
)



## To create a bucket using automation tool -- terraform

-- refer s3.tf file

resource "aws_s3_bucket" "group4" {
  bucket = "group4bucket12"
#   acl    = "public-read-write"  # You can set the ACL as per your requirements

  # Optionally, you can add tags to your S3 bucket
  tags = {
    Name        = "MyGroup4Bucket12"
    Environment = "Test"
    Project     = var.project
  }
}



## To create glue script using terraform

-- refer Glue.tf file

resource "aws_s3_object" "test_deploy_s3" {
  bucket = "group4bucket12"
  key = "glue/scripts/TestDeploy.py"
  source = "${local.glue_src_path}TestDeploy.py"
  etag = filemd5("${local.glue_src_path}TestDeploy.py")
}

resource "aws_glue_job" "test_deploy" {
  glue_version = "4.0" #optional
  max_retries = 0 #optional
  name = "TestDeploy" #required
  description = "test the deployment of an aws glue job to aws glue service with terraform" #description
  role_arn = "arn:aws:iam::126751535369:role/LabRole"
  number_of_workers = 2 #optional, defaults to 5 if not set
  worker_type = "G.1X" #optional
  timeout = "60" #optional
  execution_class = "FLEX" #optional
  tags = {
    project = var.project #optional
  }
  command {
    name="glueetl" #optional
    script_location = "s3://group4bucket12/glue/scripts/TestDeploy.py" #required
  }
  default_arguments = {
    "--class"                   = "GlueApp"
    "--enable-job-insights"     = "true"
    "--enable-auto-scaling"     = "false"
    "--enable-glue-datacatalog" = "true"
    "--job-language"            = "python"
    "--job-bookmark-option"     = "job-bookmark-disable"
    "--datalake-formats"        = "iceberg"
    "--conf"                    = "spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions  --conf spark.sql.catalog.glue_catalog=org.apache.iceberg.spark.SparkCatalog  --conf spark.sql.catalog.glue_catalog.warehouse=s3://tnt-erp-sql/ --conf spark.sql.catalog.glue_catalog.catalog-impl=org.apache.iceberg.aws.glue.GlueCatalog  --conf spark.sql.catalog.glue_catalog.io-impl=org.apache.iceberg.aws.s3.S3FileIO"
  }
}



## To take dynamic input for the project.

-- refer variables.tf

locals {
  glue_src_path = "D:\\CDAC\\Terraform\\ec2-tf1-script\\"
}

variable "project" {
    type=string
}




terraform init -- to connect your Local windows machine with your AWS account(Providers).
terraform plan -- It shows the details of the resource creation step by step.
terraform apply -- to execute the applied plan.
terraform destroy -- It destroy's the resources which have been created by terraform apply command.
