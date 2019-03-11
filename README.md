解决大数据基准测试的各种坑，自动执行测试并生成结果。  
测试基准和工具包括但不仅限于TPC-DS，Terasort.  
  
Solve the various bugs of big data benchmarks, automate run benchmarks and generate results.  
Benchmarks include, but are not limited to, TPC-DS, Terasort.

# TPC-DSB
### Prepare
1、Start HDFS, Yarn, Spark in the cluster.  

2、Install build environment
```powershell
yum -y install gcc gcc-c++ expect
```  
  
3、Use hadoop account
```powershell
su hadoop
cd ~
```  
  
4、Clone the code and Enter TPC-DS folder
```powershell
git clone https://github.com/gdchaochao/easy_benchmark.git
cd ./easy_benchmark/TPC-DS
```  
  
  
### Generate data and create tables
```powershell
sh ./tpcds_gen.sh --scale 10
```
You can also specify data folder and result folder
```powershell
sh ./tpcds_gen.sh --scale 10 --data ~/tpcds/data
```  
  
If you see this information, please wait a moment.
```powershell
dsdgen Population Generator (Version 2.10.0)
Copyright Transaction Processing Performance Council (TPC) 2001 - 2018
Warning: This scale factor is valid for QUALIFICATION ONLY
```  
  
### Run queries in Background
```powershell
nohup sh ./tpcds_query.sh --sql spark-sql --result ~/tpcds/result > query_log 2>&1 &
```  
  
### Quick Start( Generate data + Run queries)
If you want to perform a query immediately after generating the data, just execute the following command:
```powershell
nohup sh ./tpcds.sh --sql spark-sql --scale 10 --data ~/tpcds/data --result ~/tpcds/result > query_log 2>&1 &
```

### Result like this:
```powershell
...
Executing query98.sql now, please wait a moment
cost time:12.391
Executing query99.sql now, please wait a moment
cost time:7.557
Executing query9.sql now, please wait a moment
cost time:13.808
==========================================================
Finish query...
==========================================================
total time:1556.53  

```  
  
## Terasort
TODO
