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