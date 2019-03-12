解决大数据基准测试的各种坑，自动执行测试并生成结果。  
测试基准和工具包括但不仅限于TPC-DS，Terasort.  
  
Solve the various bugs of big data benchmarks, automate run benchmarks and generate results.  
Benchmarks include, but are not limited to, TPC-DS, Terasort.

# TPC-DS
### Prepare
1、Start hadoop, HDFS, Yarn, Spark in the cluster.  

2、Install build environment
```
yum -y install gcc gcc-c++ expect
```  
  
3、Use hadoop account
```
su hadoop
cd ~
```  
  
4、Clone the code and Enter TPC-DS folder
```
git clone https://github.com/gdchaochao/easy_benchmark.git
cd ./easy_benchmark/TPC-DS
```  
  
### Generate data
Generate data and create tables, "--scale" indicates how big the generated data is (GB).
```
sh ./tpcds_gen.sh --scale 10 --data ~/data
```
  
If you see this information, please wait a moment.
```powershell
dsdgen Population Generator (Version 2.10.0)
Copyright Transaction Processing Performance Council (TPC) 2001 - 2018
Warning: This scale factor is valid for QUALIFICATION ONLY
```  
  
### Run queries
Run spark-sql queries in Background, please wait.
```
sh ./tpcds.sh --sql spark-sql --result ./result
```  
The result will be in "--result" you set or default in "./result"  
For more information, use "tpcds.sh --help"   
If you want to run queries in *hive*, just set "--sql hive" like this:
```
sh ./tpcds.sh --sql hive --result ./result
```  

  
### Result like this:
```
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
