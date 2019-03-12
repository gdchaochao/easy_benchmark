#!/usr/bin/env bash

_WORKING_DIR="$(pwd)"
echo $_WORKING_DIR

# 输入参数
while [ -n "$1" ]
do
  case "$1" in
    --help)
        echo "
        --help                      Show this help
        --scale                     The size of the generated data, (Default: 10G)
        --data                      Directory for storing data
        --result                    Directory for storing result
        --sql                       sql type, hive or spark-sql

        spark-sql only:
        --master                    spark://host:port, mesos://host:port, yarn, or local(Default: yarn).
        --driver-memory MEM         Memory for driver (e.g. 1000M, 2G) (Default: 1024M).
        --executor-memory MEM       Memory per executor (e.g. 1000M, 2G) (Default: 1G).

        Spark standalone and YARN only:
        --executor-cores NUM        Number of cores per executor. (Default: 1 in YARN mode, or all available cores on the worker in standalone mode)

        YARN-only:
        --driver-cores NUM          Number of cores used by the driver, only in cluster mode(Default: 1).
        --num-executors NUM         Number of executors to launch (Default: 2). If dynamic allocation is enabled, the initial number of  executors will be at least NUM.
        "
        exit
        ;;
    --sql)
        _SQL_TYPE=$2
        shift
        ;;
    --result)
        _RESULT_DIR=$2
        shift
        ;;
    --time)
        _TIMESTAMP=$2
        shift
        ;;
    --master)
        MASTER_URL=$2
        shift
        ;;
    --num-executors)
        EXECUTORS_NUM=$2
        shift
        ;;
    --executor-cores)
        EXECUTOR_CORES=$2
        shift
        ;;
    --executor-memory)
        EXECUTOR_MEMORY=$2
        shift
        ;;
    --driver-memory)
        DRIVER_MEMORY=$2
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

if [ -z "$_RESULT_DIR" ]; then
    _RESULT_DIR=$_WORKING_DIR/result
fi
mkdir -p $_RESULT_DIR
echo "Directory for storing result is：$_RESULT_DIR"

if [ -z "$_TIMESTAMP" ]; then
    _TIMESTAMP=$(date +%s)
fi
echo "Timestamp:$_TIMESTAMP"

# spark 相关的参数
spark_param_str=""
if [ "$_SQL_TYPE" = "spark-sql" ];then
    if [ -n "$MASTER_URL" ]; then
        spark_param_str=$spark_param_str" --master "$MASTER_URL
    fi
    if [ -n "$EXECUTORS_NUM" ]; then
        spark_param_str=$spark_param_str" --num-executors "$EXECUTORS_NUM
    fi
    if [ -n "$EXECUTOR_CORES" ]; then
        spark_param_str=$spark_param_str" --executor-cores "$EXECUTOR_CORES
    fi
    if [ -n "$EXECUTOR_MEMORY" ]; then
        spark_param_str=$spark_param_str" --executor-memory "$EXECUTOR_MEMORY
    fi
    if [ -n "$DRIVER_MEMORY" ]; then
        spark_param_str=$spark_param_str" --driver-memory "$DRIVER_MEMORY
    fi
    echo "spark param is:$spark_param_str"
fi

echo "=========================================================="
echo "start query..."
echo "=========================================================="
# start query
_TIMESTAMP=$(date +%s)
mkdir -p $_RESULT_DIR/$_TIMESTAMP
nohup sh $_WORKING_DIR/tpcds_query.sh --sql $_SQL_TYPE --result $_RESULT_DIR --time $_TIMESTAMP > $_RESULT_DIR/$_TIMESTAMP/$_TIMESTAMP'_'log 2>&1 &
echo "=========================================================="
echo "Run queries in Background, please wait and check result in $_RESULT_DIR/$_TIMESTAMP..."
echo "=========================================================="
