'''
This script is used to test AWS Glue Configuration for an aws glue with public data on a S3 bucket.

'''
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
inputDF = glueContext.create_dynamic_frame_from_options(
    connection_type="s3",
    connection_options={"paths": ['s3://airbnbrawdata/airbnb_data/']}, 
    format_options={"withHeader": True, "optimizePerformance": True} 
)
#converting to pandas dataframe
df = inputDF.toDF()
df_pd = df.toPandas()
print('test script has successfully ran')