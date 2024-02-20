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


#-------------------------  GLUE JOB -----------------------------#
resource "aws_glue_job" "ingestion" {
  glue_version = "4.0" 
  max_retries = 0 
  name = "Ingestion_job-${random_id.random_id_generator.hex}" 
  description = "Ingesting data from s3" 
  role_arn = "arn:aws:iam::199657276973:role/LabRole"
  
  number_of_workers = 2 
  worker_type = "G.1X" 
  timeout = "60" 
  
  command {
    name="glueetl" 
    script_location = "s3://${aws_s3_bucket.scripts.id}/first_job.py" 
    python_version = "3"
  }

}

resource "aws_glue_job" "cleaning" {
  glue_version = "4.0"
  max_retries = 0 
  name = "Cleaning_job-${random_id.random_id_generator.hex}" 
  description = "Cleaning and preprocessing" 
  role_arn = "arn:aws:iam::199657276973:role/LabRole"
  
  number_of_workers = 2 
  worker_type = "G.1X" 
  timeout = "60" 
 
  command {
    name="glueet1" 
    script_location = "s3://${aws_s3_bucket.scripts.id}/second_job.py" 
    python_version = "3"
  }
  default_arguments = {
    "--job-language" = "python"
    
  }
  
}


#---------- STEP FUNCTION TO TRIGGER GLUE JOB AND NOTIFY---------------#
resource "aws_sfn_state_machine" "glue_job_trigger" {
  name     = "group4stepfunction"
  role_arn = "arn:aws:iam::199657276973:role/LabRole"

  definition = <<EOF
{
  "Comment": "ingesting data from rds to s3",
  "StartAt": "GlueJob1",
  "States": {
    "GlueJob1": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun.sync",
      "Parameters": {
        "JobName": "${aws_glue_job.ingestion.name}"
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
        "JobName": "${aws_glue_job.cleaning.name}"
      },
      "Next": "WaitForGlueJob2Completion"
    },
    "WaitForGlueJob2Completion": {
      "Type": "Wait",
      "Seconds": 300,  
      "Next": "RunCrawler"
    },
    "RunCrawler": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startCrawler.sync",
      "Parameters": {
        "Name": "${aws_glue_crawler.rental_market_analysis.name}"
      },
      "Next": "SNSPublish3"
    },
    "SNSPublish3": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${aws_sns_topic.glue_job_notification.arn}",
        "Message": "Greetings Group 4,\n\nYour Glue Crawler is completed successfully."
      },
      "End": true
    }
  }
}
EOF
}