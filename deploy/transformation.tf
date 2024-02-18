# uploading objects to s3
resource "aws_s3_object" "upload-glue-script-1" {
  bucket = aws_s3_bucket.scripts.id
  key    = "first_job.py"
  source = "./first_job.py"
}

resource "aws_s3_object" "upload-glue-script-2" {
  bucket = aws_s3_bucket.scripts.id
  key    = "second_job.py"
  source = "./second_job.py"
}


resource "aws_glue_job" "glue_job_1" {
  glue_version = "4.0" 
  max_retries = 0 
  name = "Ingestion_job" 
  description = "Ingesting data from s3" 
  role_arn = "arn:aws:iam::199657276973:role/LabRole"
  
  number_of_workers = 2 
  worker_type = "G.1X" 
  timeout = "60" 
  
  tags = {
    project = "final_project" 
  }
  command {
    name="gluel" 
    script_location = "s3://${aws_s3_bucket.scripts.id}/first_job.py" 
  }
  default_arguments = {
    "--output-dir"              = "s3://group4-enrich-data-zone/"
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


resource "aws_glue_job" "glue_job_2" {
  glue_version = "4.0" 
  max_retries = 0 
  name = "Cleaning_job" 
  description = "Cleaning and preprocessing" 
  role_arn = "arn:aws:iam::199657276973:role/LabRole"
  
  number_of_workers = 2 
  worker_type = "G.1X" 
  timeout = "60" 
  
  tags = {
    project = "final_project" 
  }
  command {
    name="glue2" 
    script_location = "s3://${aws_s3_bucket.scripts.id}/second_job.py" 
  }
  default_arguments = {
    "--output-dir"              = "s3://group4-enrich-data-zone/"
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


#---------- STEP FUNCTION TO TRIGGER GLUE JOB AND NOTIFY---------------#
resource "aws_sfn_state_machine" "glue_job_trigger" {
  name     = "glue-job-trigger"
  role_arn = "arn:aws:iam::199657276973:role/LabRole"

  definition = <<EOF
{
  "Comment": "Firstly, Combining Data and Secondly Cleaning and modifying the data",
  "StartAt": "GlueJob1",
  "States": {
    "GlueJob1": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun.sync",
      "Parameters": {
        "JobName": "${aws_glue_job.glue_job_1.name}"
      },
      "Next": "SNSPublish1"
    },
    "SNSPublish1": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${aws_sns_topic.glue_job_notification.arn}",
        "Message": "Greetings Group 4,\n\nYour Glue Job 1 is completed successfully."
      },
      "Next": "GlueJob2"
    },
    "GlueJob2": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun.sync",
      "Parameters": {
        "JobName": "${aws_glue_job.glue_job_2.name}"
      },
      "Next": "SNSPublish2"
    },
    "SNSPublish2": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${aws_sns_topic.glue_job_notification.arn}",
        "Message": "Greetings Group 4,\n\nYour Glue Job 2 is completed successfully\n\nThe Data is cleaned and loaded to enriched zone Successfully."
      },
      "End": true
    }
  }
}
EOF
}


