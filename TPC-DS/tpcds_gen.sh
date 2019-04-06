#!/usr/bin/env bash

_WORKING_DIR="$(pwd)"
echo $_WORKING_DIR

# 输入参数
while [ -n "$1" ]
do
  case "$1" in
    --help)
        echo "
        --help     Show this help
        --scale    The size of the generated data
        --data     Directory for storing data
        --result   Directory for storing result
        --sql      sql type, hive or spark-sql"
        exit
        ;;
    --sql)
        _SQL_TYPE=$2
        shift
        ;;
    --scale)
        _DATA_SCALE=$2
        shift
        ;;
    --data)
        _DATA_DIR=$2
        shift
        ;;
    --result)
        _RESULT_DIR=$2
        shift
        ;;
    --report)
        REPORT_TOKEN=$2
        shift
        ;;
    *)
        echo "$1 is not an option"
        exit
        ;;
  esac
  shift
done

if [ -z "$_SQL_TYPE" ]; then
    _SQL_TYPE='spark-sql'
fi
echo "SQL type is：$_SQL_TYPE "

if [ -z "$_DATA_SCALE" ]; then
    _DATA_SCALE=10
fi
echo "The size of the generated data is：$_DATA_SCALE GB"

if [ -z "$_DATA_DIR" ]; then
    _DATA_DIR=$_WORKING_DIR/data
fi
mkdir -p $_DATA_DIR
echo "Directory for storing data is：$_DATA_DIR"

if [ -z "$_RESULT_DIR" ]; then
    _RESULT_DIR=$_WORKING_DIR/result
fi
mkdir -p $_RESULT_DIR
echo "Directory for storing result is：$_RESULT_DIR"


echo "=========================================================="
echo "start generate data..."
echo "=========================================================="
# 利用TPC-DS产生数据
# unzip tpc-ds
echo "unzip tpc-ds"
_TPCDS_DIR=$_WORKING_DIR/tpcds
echo $_TPCDS_DIR
unzip -o ./resource/v2.10.1rc3.zip
mv $_WORKING_DIR/v2.10.1rc3 $_WORKING_DIR/tpcds
#rm -rf $_WORKING_DIR/__MACOSX

# make tpc-ds
echo "make"
cd $_TPCDS_DIR/tools
make clean all

echo "dsdgen data"
chmod +x $_TPCDS_DIR/tools/dsdgen
$_TPCDS_DIR/tools/dsdgen -SCALE $_DATA_SCALE -DIR $_DATA_DIR -PARALLEL 100

echo "=========================================================="
echo "Finish generate data..."
echo "=========================================================="


#echo "=========================================================="
#echo "start create table and load data..."
#echo "=========================================================="
#
## create table
#$HIVE_HOME/bin/hive -f $_WORKING_DIR/resource/create_table.sql
#
## load data to table
#echo "=========================================================="
#echo "loading data..."
#echo "=========================================================="
#_TIMESTAMP=$(date +%s)
#mkdir -p $_RESULT_DIR/$_TIMESTAMP
#cd $_DATA_DIR/
#$HIVE_HOME/bin/hive -f $_WORKING_DIR/resource/load_data.sql > $_RESULT_DIR/$_TIMESTAMP/load_data 2>&1
#cd $_WORKING_DIR/
#load_result=$(python get_load_data_time.py $_RESULT_DIR/$_TIMESTAMP/load_data)
#echo $load_result
#if [ -n "$REPORT_TOKEN" ]; then
#    python ../Report/yunyu.py $REPORT_TOKEN "spark-sql" $_DATA_SCALE $load_result
#fi
#
#echo "=========================================================="
#echo "Finish create table and load data..."
#echo "=========================================================="