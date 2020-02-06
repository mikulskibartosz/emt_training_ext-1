# List of exercises

## Module EMR Cluster Installation

### Exercise I   - Get familiar with EMR Mgmt Console 15 min
### Exercise II  - Create an EMR cluster 15 min
### Exercise III - Create a cluster bootstrap action (on startup and shut down) 20 min

## Module EMR Basic Workflows 

### Exercise I   - enable web access 15 min
### Exercise II  - View current Hadoop and Spark Settings 25 min
### Exercise III - Change current Hadoop and Spark Settings (in a running cluster)  40 min

## Module Hive
### Exercise I   - Create an external hive table of type csv pointing to the above dataset 15 min
### Exercise II  - Create an external hive table of type s3select pointing to the above dataset 15 min
### Exercise III - Create an external hive table of type orc pointing to the above dataset 25 min
### Exercise IV  - Create an external partitioned hive table of type orc pointing to the above dataset 25 min
### Exercise V   - Create an external partitioned and bucketed hive table of type orc pointing to the above dataset 15 min
### Exercise VI  - Compare the size and objects created in s3 for different tables. 10 min 
### Exercise VII - Enabling vectorization on ORC tables 15 min

# Module Spark
### Exercise I   - Calculate resources available in EMR (m5.xlarge, 8 worker nodes) for Spark processing (Part 1 - 15 min, Part 2 - 20 min) 
### Exercise II  - Calculate resources available in EMR (r5.8xlarge, 12 worker nodes) for Spark processing (20 min) 

## Module EMR queues

### Exercise I   - Disable the default queue 10 min
### Exercise II   - Create a queue configuration with 3 queues 20 min
### Exercise III   - Create an EMR Cluster with 2 queues 25 min 
 
## Module EMR hive metastore integration with RDS and Glue Metadata Catalog

### Exercise I  - Create a EMR Cluster with Glue Data Catalog as external hive metastore  25 min
### Exercise II - Create new tables from Athena that will be available also in EMR CLuster (with Glue Data Catalog as external hive metastore) 20 min 
### Exercise III - Crawl an S3 Datastore to register data with Glue Data Catalog 15 min
### Exercise IV - Create a Glue ETL Job that will copy data from Exercise III into an RDS database 20 min
### Exercise V - Crawl the RDS database to register the dataset into Glue Data Catalog 15 min

 