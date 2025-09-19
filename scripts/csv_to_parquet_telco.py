import sys
from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession, functions as F, types as T

args = getResolvedOptions(sys.argv, [
    "INPUT_BUCKET", "INPUT_PREFIX",
    "OUTPUT_BUCKET", "OUTPUT_PREFIX",
    "TEMP_DIR", "INGEST_DATE"
])

INPUT_BUCKET  = args["INPUT_BUCKET"]
INPUT_PREFIX  = args["INPUT_PREFIX"].rstrip("/") + "/"
OUTPUT_BUCKET = args["OUTPUT_BUCKET"]
OUTPUT_PREFIX = args["OUTPUT_PREFIX"].rstrip("/") + "/"
TEMP_DIR      = args["TEMP_DIR"]
INGEST_DATE   = args["INGEST_DATE"]  # e.g., 2025-09-14

spark = (SparkSession.builder
         .appName("telco-csv-to-parquet")
         .config("spark.sql.sources.partitionOverwriteMode", "dynamic")
         .getOrCreate())

# ---- Read CSV (header row, safe types) ----
input_path = f"s3://{INPUT_BUCKET}/{INPUT_PREFIX}"
df = (spark.read
      .option("header", "true")
      .option("mode", "PERMISSIVE")
      .csv(input_path))

# Drop any header rows that slipped in as data
df = df.filter(F.lower(F.col("customerID")) != F.lit("customerid"))

# Trim whitespace
for c in df.columns:
    df = df.withColumn(c, F.trim(F.col(c)))

# Safe numeric casts
def to_int(col):
    return F.when(F.col(col) == "", None).otherwise(F.col(col).cast(T.IntegerType()))

def to_double(col):
    return F.when(F.col(col) == "", None).otherwise(F.col(col).cast(T.DoubleType()))

df = (df
      .withColumn("SeniorCitizen", to_int("SeniorCitizen"))
      .withColumn("tenure",        to_int("tenure"))
      .withColumn("MonthlyCharges", to_double("MonthlyCharges"))
      .withColumn("TotalCharges",   to_double("TotalCharges"))
)

# Normalize partition columns for consistency
df = (df
      .withColumn("Churn",    F.lower(F.col("Churn")))
      .withColumn("Contract", F.lower(F.col("Contract")))
)

# Attach ingest_date for time partitioning
df = df.withColumn("ingest_date", F.lit(INGEST_DATE))

# ---- Write Parquet partitioned by Churn, Contract, ingest_date ----
output_path = f"s3://{OUTPUT_BUCKET}/{OUTPUT_PREFIX}"
(df.write
   .mode("overwrite")  # use "append" for incremental runs
   .partitionBy("Churn", "Contract", "ingest_date")
   .option("compression", "snappy")
   .parquet(output_path))

spark.stop()
