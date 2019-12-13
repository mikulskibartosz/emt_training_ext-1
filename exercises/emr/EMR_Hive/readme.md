We will analyze the Sofia air quality data set https://airsofia.info/.

Please take a look at the dataset on kaggle.com [here](https://www.kaggle.com/hmavrodiev/sofia-air-quality-dataset/).
We will analyze the files with 9 columns (bme).

The data sets contains the following columns (format: csv)  
* Columns:
    * sensor_id
    * location
    * lat
    * lon
    * timestamp
    * pressure
    * temperature
    * humidity

# Exercise I - Create an external hive table of type csv pointing to the above dataset
A copy of the dataset is stored in s3 bucket at s3://trainingdatabecloudata/sofia_air_quality/temp    
We will copy this data set to a bucket within your account and point EMR Hive to it

Follow these steps

* Create a bucket in your AWS account (accept default settings), try to give it a meaningful name
* Open on windows your command prompt
* In the command below substitute **$YOUR_PROFILE** with your aws profile name and **$your_bucket** with the bucket you created previously.
* Issue the following command to copy the dataset from original location to your bucket in S3

`
aws s3 cp s3://trainingdatabecloudata/sofia_air_quality/temp s3://$your_bucket/sofia_air_quality/temp --recursive  --profile $YOUR_PROFILE
`

* Now ssh to EMR master node and type:

`
hive
`

* Execute the following statement (substitute **$YOURBUCKET** with the name of the bucket you created)

`
CREATE EXTERNAL TABLE sofia_original_dataset (
api_call_id int,
sensor_id SMALLINT, 
location SMALLINT,
lat float, 
lon float,
event_timestamp string,
pressure float,
temperature float,
humidity float
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://$YOURBUCKET/sofia_air_quality/temp'
tblproperties ("skip.header.line.count"="1");
`

* Now execute 2 sqls, measure the time and try to note how many executors were running (how many CPU cores and RAM were used)?
    * count the data set size
    * select api_call_id where api_call_id < 100
* Write down those execution times,we will compare them with our later experiments
* Check the execution engine (type set; and search for hive.execution.engine) - what is the execution engine?    

# Exercise II - Create an external hive table of type s3select pointing to the above dataset

With Amazon EMR release version 5.18.0 and later, you can use S3 Select with Hive on Amazon EMR. 
S3 Select allows applications to retrieve only a subset of data from an object. For Amazon EMR,
 the computational work of filtering large data sets for processing is "pushed down" 
 from the cluster to Amazon S3, which can improve performance in some applications and reduces the amount
  of data transferred between Amazon EMR and Amazon S3.

S3 Select is supported with Hive tables based on CSV and JSON files and by 
setting the s3select.filter configuration variable to true during your Hive session. 
For more information and examples, see Specifying S3 Select in Your Code.

* Please read the details/usage [here](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-hive-s3select.html)

* Lets create the table 
* ssh to master node and type:

`
hive
`

* Execute the following statement (substitute **$YOURBUCKET** with the name of the bucket you created):

`
CREATE EXTERNAL TABLE sofia_s3select (
api_call_id int,
sensor_id int, 
location int,
lat float, 
lon float,
event_timestamp string,
pressure float,
temperature float,
humidity float
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS
INPUTFORMAT
  'com.amazonaws.emr.s3select.hive.S3SelectableTextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://$YOURBUCKET/sofia_air_quality/sofia_s3select'
TBLPROPERTIES (
  "s3select.format" = "csv",
  "s3select.headerInfo" = "ignore"
);
`

* Take a look at the current hive setting for this session. Type set;

`
set;
`

* Scan the list. Do you have any questions? Can you find values related to tez, orc and vectorization?

* Check [here](https://docs.aws.amazon.com/AmazonS3/latest/dev/s3-glacier-select-sql-reference.html) if the function count is supported and if the data types used in table ddl are supported?

* Before running sqls that leverage s3select capabilities you need to enable it in your session be executing a command defined [here](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-hive-s3select.html)
* Execute the command from previous point like this (verify with teh instructor that the command is correct)

`
SET $PASTE_YOUR_COMMAND;
`

* Now execute 2 sqls, measure the time and try to note how many executors were running (how many CPU cores and RAM were used)?
    * count the data set size
    * select api_call_id where api_call_id < 100
* Write down those execution times,we will compare them with our later experiments 
* Now execute the 2 sqls above one more time but this time specify in hive before running them (we will disable s3 pushdown):

`
SET s3select.filter=false;
`

* Write down those execution times,we will compare them with our later experiments 
* What can you say about the performance? How does the result compare to our csv based table?

# Exercise III - Create an external hive table of type orc pointing to the above dataset

Now we will create a copy of the table in one of hive supported columnar formats, ORC.
Overview of ORC can be found [here](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+ORC).

* Lets create the table 
* Ssh to master node and type

`
hive
`

* Execute the following statement (substitute **$YOURBUCKET** with the name of the bucket you created)

`
CREATE EXTERNAL TABLE sofia_orc (
api_call_id int,
sensor_id int, 
location int,
lat float, 
lon float,
event_timestamp string,
pressure float,
temperature float,
humidity float
)
STORED AS ORC
LOCATION 's3://$YOURBUCKET/sofia_air_quality/sofia_orc'
;
`

* Now we need to fill the new table with data. To accomplish this execute this statement

`
INSERT INTO TABLE sofia_orc SELECT * FROM sofia_original_dataset;
`

* Now execute 2 sqls, measure the time and try to note how many executors were running (how many CPU cores and RAM were used)?
    * count the data set size
    * select api_call_id where api_call_id < 100
* Write down those execution times, we will compare them with our later experiments 



* Now lets analyze the contents (metadata) of an orc file. There is a tool named orfiledump that is integrated wit hive. 
* Read about the available options [here](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+ORC#LanguageManualORC-ORCFileDumpUtility)
* Use the -j option to view the metadata of one of the generated orc files
* select one of the orc files and execute

`
hive --orcfiledump -j s3://$YOURBUCKET/sofia_air_quality/sofia_orc/$SELECTED_ORC_FILE
`

* Copy the json output to a json editor (e.g. notepad ++ with json viewer plugin).
    * What kind of metadata can you find?
    * How many stripes are within this file?
    * The different statistics - on which granularity are they (file, stripe,...)?
    
# Exercise IV - Create an external partitioned hive table of type orc pointing to the above dataset

Now we will create a partitioned copy of the original table, in ORC format.

* Lets create the table 
* Ssh to master node and type
`
hive
`

* Execute the following statement (substitute **$YOURBUCKET** with the name of the bucket you created)

`
CREATE EXTERNAL TABLE sofia_orc_part (
api_call_id int,
sensor_id int, 
location int,
lat float, 
lon float,
event_timestamp string,
pressure float,
temperature float,
humidity float
)
partitioned by(yearmonth int)
STORED AS ORC
LOCATION 's3://$YOURBUCKET/sofia_air_quality/sofia_orc_part'
;
`

* Now we need to fill the new table with data. To accomplish this we will need to create an expression that
will generate the yearmonth value (in format YYYYMM, eg.g 201807) from _**event_timestamp**_ column.
After the function is created we will run the INSERT OVERWRITE statement below. 
* Go to hue"s hive editor and try to come up with an expression
that will generate the required values for yearmonth.
HINT: Try to leverage the hive string functions: [hive string functions](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+UDF#LanguageManualUDF-StringFunctions)
* Confirm with the instructor that the function is valid
* To run the insert below (dynamic partitioning) we need to enable dynamic partitioning - there is a setting 
hive.exec.dynamic.partition.mode that needs to be set to the correct value. Read [here](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DML#LanguageManualDML-DynamicPartitionInserts) what is this value and confirm with the instructor.
* Execute this statement (from hue or from hive cli)  to enable dynamic partitioning inserts (replace $VALUE with the correct value):

`
set set hive.exec.dynamic.partition.mode=$VALUE;
`

* Execute then from hue or from hive cli (substitute $YOUR_EXPRESSION with your expression to get YYYYMM)

`
INSERT OVERWRITE TABLE sofia_orc_part PARTITION(yearmonth) SELECT 
api_call_id,
sensor_id, 
location,
lat, 
lon,
event_timestamp,
pressure,
temperature,
humidity,
$YOUR_EXPRESSION
FROM sofia_original_dataset;
`

* Now execute 2 sqls, measure the time and try to note how many executors were running (how many CPU cores and RAM were used)?
    * count the data set size
    * select api_call_id where api_call_id < 100
* Are you surprised by the speed of the count select?
* Write down those execution times,we will compare them with our later experiments 
* Do these above sqls leverage the partitioning scheme? Which sqls would better leverage the partitioning scheme? 
* Write an sql to show this (against the original table and the partitioned table).

# Exercise V - Create an external partitioned and bucketed hive table of type orc pointing to the above dataset

Now we will create a partitioned bucketed copy of the original table, in ORC format.

* Lets create the table 
* Now ssh to master node and type

`
hive
`

* Execute the following statement (substitute **$YOURBUCKET** with the name of the bucket you created)

`
CREATE EXTERNAL TABLE sofia_orc_part_bucket (
api_call_id int,
sensor_id int, 
location int,
lat float, 
lon float,
event_timestamp string,
pressure float,
temperature float,
humidity float
)
partitioned by(yearmonth int)
clustered by (sensor_id) into 8 Buckets
STORED AS ORC
LOCATION 's3://$YOURBUCKET/sofia_air_quality/sofia_orc_part_bucket'
;
`

* Why are we creating 8 buckets?

* Now we need to fill the new table with data. To accomplish this we will copy our data from table sofia_orc_part.
* Remember that before executing the insert you need to enable dynamic partitioning 
be setting correctly hive.exec.dynamic.partition.mode (substitute the $VALUE with correct value below)
* On which position the partitioning column needs to be placed?

`
set hive.exec.dynamic.partition.mode=$VALUE;
`

`
INSERT OVERWRITE TABLE sofia_orc_part_bucket PARTITION(yearmonth) SELECT 
api_call_id,
sensor_id, 
location,
lat, 
lon,
event_timestamp,
pressure,
temperature,
humidity,
yearmonth
FROM sofia_orc_part;
`

* Now execute 2 sqls, measure the time and try to note how many executors were running (how many CPU cores and RAM were used)?
    * count the data set size
    * select api_call_id where api_call_id < 100
* Are you surprised by the speed of the count select?
* Write down those execution times.

* Compare the execution times of the 2 sqls for 5 tables. What can you say? 

* Now as we have 5 different tables lets try to execute 2 sqls against them, one that leverages only partitioning information and a 
second one that also leverages clustering information:
   * SQL nr 1: count the number of measurements for the month 201905 (Hint: for the non partitioned tables use the previously created expression in where clause)
   * SQL nr 2: count the number of measurements for the month 201905 done by sensor 7474 
* Do clustering added any performance improvement, especailly in the case part+bucketed table vs partitioned only table?

# Exercise VI - Compare the size and objects created in s3 for different tables.

Lets compare how the different tables compare in terms of objects and structure.

* Login to S3 Management Console
* Find the bucket where our tables were created
* Check the size of each table
* Check the structure of directories
    * What implications on folder structure has partitioning?
    * What implications on folder structure has bucketing?
    * Why there is different number of files in ORC based tables in comparison to csv tables? Can you explain that?
    
    
# Exercise VII - Enabling vectorization on ORC tables

Now we will test some performance improvement technique, called vectorization, that works on ORC tables.

You can find basic information about vectorized query execution [here](https://cwiki.apache.org/confluence/display/Hive/Vectorized+Query+Execution).

We will do some tests and see if it helps improve performance.

Vectorization is disabled by default. To enable it we need to set hive.vectorized.execution.enabled to the value of true.


* Ssh to master node and type

`
hive
`

* Verify the current setting of hive.vectorized.execution.enabled by executing set;

`
set;
`

* Execute the following statement to check if vectorization woudl be used when executing a given sql

`
EXPLAIN VECTORIZATION  select count(*), 1 from sofia_orc_part where yearmonth = 201905 and sensor_id = 7474;
`

`
set hive.vectorized.execution.enabled = true;
`

`
EXPLAIN VECTORIZATION  select count(*), 1 from sofia_orc_part where yearmonth = 201905 and sensor_id = 7474;
`

`
set hive.vectorized.execution.enabled = false;
`

* Do you see the difference?
* Execute the above query on the partitioned table 2x times (on/off on vectorization) and compare the times. Is there any difference?

* Lets us now execute a query on non partitioned table in orc format 2 times again, with on/off vectorization
    * Query the table sofia_orc with filter on (first find some rows that would match your search criteria for Z,Y,X)
    * sensor_id = Z
    * location = Y
    * temperature > X
* Do you see the difference?
* Run explain plan (EXPLAIN VECTORIZATION) for you query and check if vectorization is used.


