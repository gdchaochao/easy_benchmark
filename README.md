解决大数据基准测试的各种坑，自动执行测试并生成结果。  
测试基准和工具包括但不仅限于TPC-DS，Terasort.  
  
Solve the various pits of big data benchmarks, automate tests and generate results.  
Test benchmarks and tools include, but are not limited to, TPC-DS, Terasort.

# TPC-DS
### Install build environment
```powershell
yum -y install gcc gcc-c++ expect
```  
  
### Change to hadoop user 
```powershell
su hadoop
cd ~
```  
  
### Clone the code
```powershell
git clone https://github.com/gdchaochao/easy_benchmark.git
```  
  
### Enter TPC-DS folder
```powershell
cd ./easy_benchmark/TPC-DS
```  
  
### Generate data
```powershell
sh ./tpcds.sh --scale 10
```
You can also specify data folder and result folder
```powershell
sh ./tpcds.sh --scale 10 --data ~/tpcds/data --result ~/tpcds/result
```  
  
If you see this information, please wait a moment.
```powershell
dsdgen Population Generator (Version 2.10.0)
Copyright Transaction Processing Performance Council (TPC) 2001 - 2018
Warning: This scale factor is valid for QUALIFICATION ONLY
```  
  
### Run query in blackgroup
```powershell
nohup sh ./tpcds_query.sh --sql spark-sql --result ~/tpcds/result > query_log 2>&1 &
```  
  
### Quick Start( Generate data + Run query)
If you want to generate data and then run tpc-ds queries, just run this command:
```powershell
nohup sh ./tpcds.sh --sql spark-sql --scale 10 --data ~/tpcds/data --result ~/tpcds/result > query_log 2>&1 &
```

### Result like this:
```powershell
total time:  2456s
query2:      126s
query3:      231s
...
```  
  
## Terasort
TODO