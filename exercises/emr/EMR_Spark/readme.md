# EMR SPARK

## Prerequisites

* EMR Cluster pem key (emrmaster.pem)
* A running EMR Cluster with m5.xlarge instances (if its not running please create one in version EMR 5.2* as described in chapter EMR Cluster Installation)

## Exercise I - Calculate resources available in EMR (m5.xlarge, 8 worker nodes) for Spark processing

### Part I - Gather information about the cluster size in terms of CPU and RAM available.

#### Step 1 - Exercise description and goal

Lets assume we have a cluster with 8 m5.xlarge worker nodes (and at least 1 master node).

We want to answer the following question at the end of this exercise:

* How much memory in total we have to distribute in a Hadoop system (reserved by YARN)?
* How much CPU in total we have to distribute in a Hadoop System (reserved by YARN)?
* What is the min/max allocation per Container (in terms of number of CPUs and RAM)?
* What is the resource increment in terms of CPU and RAM that can be assigned to a container?
* How many containers could run on 1 node?
* How much RAM and CPU could be assigned to the biggest container?
* How many containers we could run on te cluster?
* Compare those values above (cpu and ram per node allocated to YARN) to CPU and RAM for EC2 instance (m5.xlarge). What can you say about the proportions?

#### Step 2 - Find values for required parameters set on m5.xlarge worker nodes

Go to the [m5.xlarge EMR config page](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-hadoop-task-config.html#emr-hadoop-task-config-m5) and note down values for:
(NOTE: You wont find information for all of the parameters)
* yarn.scheduler.minimum-allocation-mb
* yarn.scheduler.maximum-allocation-mb 
* yarn.scheduler.minimum-allocation-vcores  
* yarn.scheduler.maximum-allocation-vcores   
* yarn.nodemanager.resource.memory-mb  
* yarn.nodemanager.resource.cpu-vcores

For the parameters you couldn't find go to EMR RM page and find it there. If you wont be able to find it on the main page click on Tools. There will be links to hadoop configurations files with current contiguration values.
If you forgot what these properties mean please go to [yarn-default.xml description](https://hadoop.apache.org/docs/r2.8.5/hadoop-yarn/hadoop-yarn-common/yarn-default.xml) 
for explanation or ask the lecturer.


### Part II - Setup optimal spark settings on m5.xlarge

Lets follow the below reasoning to find an optimal (does it exist?) spark configuration (number of executors, RAM, threads, ...).
Please fill the fields marked with X with values from Part I.

* How many executors, cores per executor and memory can we set on this cluster?
    * **Best practice memory**: Leave 1 GB for other processes per node: that is already done by EMR because yarn reserved **C** GB RAM
(yarn.nodemanager.resource.memory-mb) out of 256 GB (we could increase till 256-1 GB). What is the value of **C**?.
    * **Best practice**: leave 1 cpu for os and other process: hence lets assume we can assign yarn.nodemanager.resource.cpu-vcores-1 (**A**) out of yarn.nodemanager.resource.cpu-vcores cpus 
    * **Best practice**: Running small executors (ram) is not efficient, the upper setting is by experience no more then 5 cores per executor (5 tasks running on 1 executor in parallel)
    * Which is bigger on this cluster, 5 or value of **A**?   
* On cluster we have then 12 nodes * **A** cores available (**B** cores in total, what is the value of B?) and 12 nodes * **C** GB = **D** GB (what is the value of D?).
* How many executors can we have in total? 
    * There is also the driver process but it runs on the master node, hence it doesnt change our calculations
    * Theoretically on cluster: 12 nodes * **A** cores available = **E** Executors in total (when is **B** different from **E**?)  with 1 CPU 
and RAM per Executor calculated as **C**/**A** = 4GB but to accommodate the spark overhead of max(384 MB, 10% of spark memory) 
in reality we need to set executor RAM as **F** GB (10% or 0,375 GB) executor memory (to stay below 4 GB). What is the value of **F**?
* Finally we have **E** executors with 1 core (3 per node) with RAM per executor (and hence per task as assumed we have 1 core per executor) set to **F** GB 
* On the cluster the executors can leverage  **E** (number of executors) * **F** GB RAM per Executor = **G** GB RAM available for a spark job.


Alternatively (to have bigger executors with more RAM and cores), 
lets assume 1 big executor per node (how much CPU cores (max)
 and RAM (max) can we assign to it?.
* First question to answer to optimally leverage CPUs:
     * How many executors can we run per node if the number of cores per executor is set to 3? (**H**)
     * Assuming we know **H** how much RAM can we assign to an executor? Provide this number (**C**/**H**). **I** - the target value we will reference later.
     * We will need to adjust value of **I** to the 10% rule. What is the adjusted value of **I**?
* How many executors with 3 cores per executor and RAM in total can be used on the cluster? 
* Compare this to when we set 1 core per executor.
* Which setting is better?
* What is the advantage of many cores per executor?

Additional questions:
* Could you run Executors with 24 GB RAM assigned?
* Does it make sense to run 6 executors with 10,8 GB (why 10,8 GB and not 11 GB?)?

* Can you propose different config options for running spark that could be useful?

 ## Exercise II - Calculate resources available in EMR (r5.8xlarge, 12 worker nodes) for Spark processing
 
 Repeat the steps for Exercise I (we dont need to start a cluster), this time assuming we have a 12 worker node EMR cluster.
 
 Go to the page [r5.8xlarge EMR config page](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-hadoop-task-config.html#emr-hadoop-task-config-r5) to find values for:
 * yarn.scheduler.minimum-allocation-mb
 * yarn.scheduler.maximum-allocation-mb
 * yarn.nodemanager.resource.memory-mb 

For the remaining required values assume (where on Resource Manager could you find the values?)
 * yarn.scheduler.minimum-allocation-vcores  1
 * yarn.scheduler.maximum-allocation-vcores  32 
 * yarn.nodemanager.resource.cpu-vcores 32

Answer the following questions:
* How much memory in total we have to distribute in a Hadoop system (reserved by YARN)?
* How much CPU in total we have to distribute in a Hadoop System (reserved by YARN)?
* What is the min/max allocation per Container (in terms of number of CPUs and RAM)?
* What is the resource increment in terms of CPU and RAM that can be assigned to a container?
* How many containers could run on 1 node?
* How much RAM and CPU could be assigned to the biggest container?
* How many containers we could run on te cluster?
* Compare those values above (cpu and ram per node allocated to YARN) to CPU and RAM for EC2 instance (m5.xlarge). What can you say about the proportions?

### Part II - Setup optimal spark settings on r5.8xlarge

Based on Part II from the previous exercise calculated on m5.xlarge find optimal setting for a cluster with 12 worker nodes of type r5.8xlarge.
* Calculate 2 variants: 
    * one with number of cores per executor set to 1 
    * and once with number of cores per executor set to 5.
* Provide some good and bad configurations? Why is that? 






  


