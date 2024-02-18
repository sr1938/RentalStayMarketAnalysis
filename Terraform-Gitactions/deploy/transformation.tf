# s3 object to upload the file
resource "aws_s3_object" "test_glue_script" {
    bucket = aws_s3_bucket.raw_data_zone.id
    
    key = "/TestDeploy.py"
    source = "./TestDeploy.py"
    tags = {
        project_type = "demo"
    }
}



resource "aws_glue_job" "glue_deploy" {
  glue_version = "4.0" 
  max_retries = 0 
  name = "Cleaning_Deploy" 
  description = "importing, cleaning and preprocessing" 
  role_arn = "arn:aws:iam::199657276973:role/LabRole"
  
  number_of_workers = 2 
  worker_type = "G.1X" 
  timeout = "60" 
  
  tags = {
    project = "final_project" 
  }
  command {
    name="gluel" 
    script_location = "s3://${aws_s3_bucket.raw_data_zone.id}/TestDeploy.py" 
  }
  default_arguments = {
    "--output-dir"              = "s3://shubh-datalak-enrich/final-enriched-project-data/"
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