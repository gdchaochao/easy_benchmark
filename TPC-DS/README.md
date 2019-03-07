# 自动化执行TPC-DS测试
#### Install build environment
```powershell
yum -y install gcc gcc-c++ expect
```  
  
#### Clone the code
```powershell
git clone http://git.code.oa.com/tencent_cloud_mobile_tools/easy_benchmark.git
```  
  
#### Enter TPC-DS folder
```powershell
cd ./easy_benchmark/TPC-DS
```  
  
#### Run TPC-DS test
```powershell
sh ./tpcds.sh --scale 10
```
You can also specify data folder and result folder
```powershell
sh ./tpcds.sh --scale 10 --data /data/tpcds/data --result /data/tpcds/result
```  
  
If you see this information, please wait a moment.
```powershell
dsdgen Population Generator (Version 2.10.0)
Copyright Transaction Processing Performance Council (TPC) 2001 - 2018
Warning: This scale factor is valid for QUALIFICATION ONLY
```  
  
#### Result like this:
```powershell
total time:  2456s
query2:      126s
query3:      231s
...
```  

# 手工执行TPC-DS测试
1、购买EMR集群，或者在集群里面部署Hadoop（过程省略）

2、安装与编译
解压v2.10.1rc3.zip（TPC-DS）到master节点的目录下，工具已经编译好了无需再make
```powershell
unzip v2.10.1rc3.zip
``` 

3、生成测试数据
进入tools文件夹，使用下面语句生成测试数据（-SCALE是数据量，至少1G；-DIR是生成数据存放的地方，文件夹需要事先mkdir）
```powershell
./dsdgen -SCALE 1GB -DIR /data/tpcdsdata
```

4、建表
在hive下，执行create_table.sql里面的建表语句

5、导入测试数据数据到hive表
测试数据在刚才建的目录/data/tpcdsdata中，.dat作为尾缀。导入数据到hive表有两种方法

方法一：
```powershell
show create table web_page;
```

LOCATION
```powershell
'hdfs://10.16.0.108:4007/tpc-ds-data/web_page'
```
 
 也就是说，要把生成的*.dat文件复制到 hdfs 的 /tpc-ds-data/*/路径下
 执行 hdfs 数据加载，从本地文件系统导入到hdfs文件系统
```powershell
hdfs dfs -put /data/tpcdsdata/web_page.dat /tpc-ds-data/web_page/web_page.dat
```


 方法二：
 ```powershell
load data local inpath "/data/tpcdsdata/web_site.dat" overwrite into table web_site;
 load data local inpath "/data/tpcdsdata/web_page.dat" overwrite into table web_page;
 load data local inpath "/data/tpcdsdata/web_sales.dat" overwrite into table web_sales;
 load data local inpath "/data/tpcdsdata/date_dim.dat" overwrite into table date_dim; 
 load data local inpath "/data/tpcdsdata/item.dat" overwrite into table item; 
 load data local inpath "/data/tpcdsdata/warehouse.dat" overwrite into table warehouse;
 load data local inpath "/data/tpcdsdata/promotion.dat" overwrite into table promotion;
 load data local inpath "/data/tpcdsdata/time_dim.dat" overwrite into table time_dim;
 load data local inpath "/data/tpcdsdata/ship_mode.dat" overwrite into table ship_mode;
 load data local inpath "/data/tpcdsdata/customer_demographics.dat" overwrite into table customer_demographics;
 load data local inpath "/data/tpcdsdata/customer.dat" overwrite into table customer;
 load data local inpath "/data/tpcdsdata/customer_address.dat" overwrite into table customer_address;
 load data local inpath "/data/tpcdsdata/household_demographics.dat" overwrite into table household_demographics;
 load data local inpath "/data/tpcdsdata/income_band.dat" overwrite into table income_band;
 load data local inpath "/data/tpcdsdata/reason.dat" overwrite into table reason;
 load data local inpath "/data/tpcdsdata/web_returns.dat" overwrite into table web_returns;
 load data local inpath "/data/tpcdsdata/call_center.dat" overwrite into table call_center;
 load data local inpath "/data/tpcdsdata/catalog_page.dat" overwrite into table catalog_page;
 load data local inpath "/data/tpcdsdata/catalog_returns.dat" overwrite into table catalog_returns;
 load data local inpath "/data/tpcdsdata/catalog_sales.dat" overwrite into table catalog_sales;
 load data local inpath "/data/tpcdsdata/dbgen_version.dat" overwrite into table dbgen_version;
 load data local inpath "/data/tpcdsdata/inventory.dat" overwrite into table inventory;
 load data local inpath "/data/tpcdsdata/store.dat" overwrite into table store;
 load data local inpath "/data/tpcdsdata/store_returns.dat" overwrite into table store_returns;
 load data local inpath "/data/tpcdsdata/store_sales.dat" overwrite into table store_sales;

```
 
6、执行查询语句
在hive中，执行query.sql的查询语句，每个语句执行结束会有查询时间

