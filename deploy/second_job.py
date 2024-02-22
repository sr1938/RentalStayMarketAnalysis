import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
import pyspark
from awsglue.job import Job
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.functions import lit, rand, col, regexp_replace, when, round, floor, mean
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, FloatType, DoubleType, LongType


## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

df_rds_new = spark.read.parquet('s3://group4-raw-data-zone/job1/')

df = spark.read.format('csv').options(sep=",", escape='"', mode="PERMISSIVE", header=True, multiLine=True).load('s3://final-044/zip/total_data.csv')


selected_columns = [
"id", "name", "host_name", "host_response_time", "host_listings_count", "host_verifications",
"host_identity_verified", "neighbourhood", "city", "latitude", "longitude", "property_type",
"room_type", "accommodates", "bathrooms", "bedrooms", "beds", "amenities", "price",
"security_deposit", "guests_included", "extra_people", "availability_30", "availability_60",
"availability_90", "availability_365", "number_of_reviews", "review_scores_rating",
"instant_bookable", "month", "minimum_minimum_nights", "maximum_maximum_nights",
"calculated_host_listings_count", "cancellation_policy"
]


# Selecting columns
df = df.select(selected_columns)
df1_rds_new = df_rds_new.select(selected_columns)


# Union dataframes
new_df = df.union(df1_rds_new)

df8=new_df.dropDuplicates()
new_df=df8


# replace $
columns_to_replace = ["price", "security_deposit", "extra_people"]
for col_name in columns_to_replace:
    new_df = new_df.withColumn(col_name, regexp_replace(col(col_name), "\\$", ""))

# 2)name:
new_df = new_df.dropna(subset=["name"])

# 3)host_name:
new_df = new_df.dropna(subset=["host_name"])


#4)host_response_time:

#mode_time = new_df.groupBy("host_response_time").count().orderBy(col("count").desc()).limit(1).select("host_response_time").collect()[0][0]
mode_time= "within an hour"

new_df = new_df.fillna({"host_response_time": "within an hour"})



#5) host_listings_count:

new_df = new_df.withColumn("host_listings_count", round(col("host_listings_count")).cast("int"))



#8)neighbourhood:

# Replace null values in the neighbourhood column with "Unknown"

new_df = new_df.withColumn("neighbourhood", when(new_df["neighbourhood"].isNull(), "Unknown").otherwise(new_df["neighbourhood"]))



#9)city:


default_value = "Rio"
new_df = new_df.withColumn("city", when(new_df["city"].isNull(), default_value).otherwise(new_df["city"]))




#15)bathrooms:
# replace null value using mean value

#mean_bathrooms = new_df.select(mean(col('bathrooms'))).collect()[0][0]
#--> 1.6951  ====> 1.0

rounded_mean_bathrooms = 1.0

new_df = new_df.withColumn('bathrooms', when(col('bathrooms').isNull(), rounded_mean_bathrooms).otherwise(col('bathrooms')))

#new_df.filter(col('bathrooms').isNull()).count()

new_df = new_df.withColumn("bathrooms", round(col("bathrooms")).cast("int"))



#16)bedrooms:


# replace null value using mean value
#mean_bedrooms = new_df.select(mean(col('bedrooms'))).collect()[0][0]
#1.65
rounded_mean_bedrooms = 1.0

new_df = new_df.withColumn('bedrooms', when(col('bedrooms').isNull(), rounded_mean_bedrooms).otherwise(col('bedrooms')))


new_df = new_df.withColumn("bedrooms", round(col("bedrooms")).cast("int"))





#17)beds:

# replace null value using mean value
#mean_beds = new_df.select(mean(col('beds'))).collect()[0][0]
#---> 2.59516   =======>  3.0

rounded_mean_beds = 3.0
new_df = new_df.withColumn('beds', when(col('beds').isNull(), rounded_mean_beds).otherwise(col('beds')))

# make it integer
new_df = new_df.withColumn("beds", round(col("beds")).cast("int"))





#19)price column:

#mean_price = new_df.filter(col("price") != 0).select(mean(col("price"))).first()[0]
#mean_price=int(mean_price)
mean_price =542
new_df = new_df.withColumn("price", when((col("price").isNull()) | (col("price") == 0), mean_price).otherwise(col("price")))



#20) security_deposit:


#replacing NA values with zero
new_df = new_df.na.fill({"security_deposit": 0})



#22)extra_people: 

# Replace null values in the column 'extra_people' with 0
new_df = new_df.fillna({"extra_people": 0.0})
new_df = new_df.withColumn("extra_people", round(col("extra_people")).cast("int"))




#28)review_scores_rating:

new_df = new_df.withColumn("review_scores_rating",
when(col("review_scores_rating").isNull(), None)
.otherwise(floor((col("review_scores_rating") - 10) / 9).cast(IntegerType())))

#absolute_mean = new_df.filter(col("review_scores_rating").isNotNull()).select(mean(col("review_scores_rating"))).collect()[0][0]
# print(absolute_mean)


rounded_abs_mean = 7

new_df = new_df.withColumn("review_scores_rating", when(col("review_scores_rating").isNull(), rounded_abs_mean).otherwise(col("review_scores_rating")))





#29)"instant_bookable":




new_df = new_df.withColumn('instant_bookable', when(col('instant_bookable') == 't', 'yes')
.when(col('instant_bookable') == 'f', 'no')
.when(col('instant_bookable').isNull() | (col('instant_bookable') == ''), 'yes')
.otherwise(col('instant_bookable')))




#30)month:


new_df = new_df.withColumn("month",
when(col("month") == 1, "january")
.when(col("month") == 2, "february")
.when(col("month") == 3, "march")
.when(col("month") == 4, "april")
.when(col("month") == 5, "may")
.when(col("month") == 6, "june")
.when(col("month") == 7, "july")
.when(col("month") == 8, "august")
.when(col("month") == 9, "september")
.when(col("month") == 10, "october")
.when(col("month") == 11, "november")
.when(col("month") == 12, "december")
.otherwise(col("month")))




#38)"minimum_minimum_nights":


#mean_value = new_df.select(mean(col("minimum_minimum_nights"))).collect()[0][0]

mean_value= 5.0
new_df = new_df.withColumn("minimum_minimum_nights", when(col("minimum_minimum_nights").isNull(), mean_value).otherwise(col("minimum_minimum_nights")))


# make it integer
new_df = new_df.withColumn("minimum_minimum_nights", round(col("minimum_minimum_nights")).cast("int"))




#39)"maximum_maximum_nights":


#mean_value = new_df.filter(col("maximum_maximum_nights") != 999999999.0).select(mean(col("maximum_maximum_nights"))).collect()[0][0]
mean_value=1104
new_df = new_df.withColumn("maximum_maximum_nights", when((col("maximum_maximum_nights") == 999999999.0) | (col("maximum_maximum_nights").isNull()), mean_value).otherwise(col("maximum_maximum_nights")))


# make it integer
new_df = new_df.withColumn("maximum_maximum_nights", round(col("maximum_maximum_nights")).cast("int"))

# give new schema to df

new_schema = StructType([
StructField("id", LongType()),
StructField("name", StringType()),
StructField("host_name", StringType()),
StructField("host_response_time", StringType()),
StructField("host_listings_count", IntegerType()),
StructField("host_verifications", StringType()),
StructField("host_identity_verified", StringType()),
StructField("neighbourhood", StringType()),
StructField("city", StringType()),
StructField("latitude", DoubleType()),
StructField("longitude", DoubleType()),
StructField("property_type", StringType()),
StructField("room_type", StringType()),
StructField("accommodates", IntegerType()),
StructField("bathrooms", IntegerType()),
StructField("bedrooms", IntegerType()),
StructField("beds", IntegerType()),
StructField("amenities", StringType()),
StructField("guests_included", IntegerType()),
StructField("availability_30", IntegerType()),
StructField("availability_60", IntegerType()),
StructField("availability_90", IntegerType()),
StructField("availability_365", IntegerType()),
StructField("number_of_reviews",IntegerType()),
StructField("review_scores_rating", IntegerType()),
StructField("instant_bookable", StringType()),
StructField("month", StringType()),
StructField("minimum_minimum_nights", IntegerType()),
StructField("maximum_maximum_nights", IntegerType()),
StructField("calculated_host_listings_count", IntegerType()),
StructField("cancellation_policy", StringType())
])


for field in new_schema:
        new_df = new_df.withColumn(field.name, new_df[field.name].cast(field.dataType))




# to write in s3 bucket cleaned data in parquet format

output_path = "s3://group4-enrich-data-zone/job2/rio-airbnb/"

new_df.coalesce(1).write \
.option("header", "True") \
.option("multiline", True) \
.parquet(output_path)


job.commit()