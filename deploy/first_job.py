import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
import pyspark
from awsglue.job import Job
from pyspark.sql import SparkSession

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)




jdbc_url = "jdbc:mysql://database-1.cbx6lq4lpptb.us-east-1.rds.amazonaws.com:3306/rdsdata"

jdbc_pro = {
    "user":"admin",
    "password":"12345678",
    "driver":"com.mysql.jdbc.Driver"
    }
table_name = "latestdata"

# To read data from rds


rds_df = spark.read.jdbc(url=jdbc_url,table=table_name,properties=jdbc_pro)


# To write data to s3 Datalake 

output_path = "s3://group4-raw-data-zone/job1/" 
rds_df.coalesce(1).write \
    .option("header", "True") \
    .option("multiline", True) \
    .parquet(output_path)


job.commit()