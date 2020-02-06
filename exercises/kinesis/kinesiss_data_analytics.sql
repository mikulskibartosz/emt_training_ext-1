CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (event_time timestamp, city VARCHAR(4), district VARCHAR(64), eventName VARCHAR(32), nr_of_events INT );

CREATE OR REPLACE PUMP "STREAM_PUMP" AS 
  INSERT INTO "DESTINATION_SQL_STREAM" 
    SELECT STREAM STEP("SOURCE_SQL_STREAM_001".ROWTIME BY INTERVAL '10' SECOND) as event_time,
        "city", 
				"district", 
				"eventName",
         count(*) AS nr_of_events
    FROM    "SOURCE_SQL_STREAM_001"
    GROUP BY "city", "district", "eventName", 
             STEP("SOURCE_SQL_STREAM_001".ROWTIME BY INTERVAL '10' SECOND);