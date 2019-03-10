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
    --result)
        _RESULT_DIR=$2
        shift
        ;;
    --time)
        _TIMESTAMP=$2
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


echo "=========================================================="
echo "start query..."
echo "=========================================================="
# start query

total_time_spent=0
result_summary=$_RESULT_DIR/$_TIMESTAMP/result_$_SQL_TYPE
mkdir -p $_RESULT_DIR/$_TIMESTAMP
echo "result in:$result_summary"
echo $_SQL_TYPE >> $result_summary

files=$(ls $_WORKING_DIR/resource/queries-test)
if [ "$_SQL_TYPE" = "hive" ];then
    echo 'oh,use hive queries'
    files=$(ls $_WORKING_DIR/resource/queries)
fi
for filename in $files
do
    result_file=$_RESULT_DIR/$_TIMESTAMP/${filename/.sql/}
    echo "Executing $filename now, please wait a moment"
    $_SQL_TYPE -f $_WORKING_DIR/resource/queries/$filename -i $_WORKING_DIR/resource/$_SQL_TYPE'-prepare.sql' > $result_file 2>&1
    time_spent=$(cat $result_file | grep 'Time taken')
    if [ -n "$time_spent" ]; then
        time_spent=${time_spent% seconds*}
        time_spent=${time_spent##*taken: }
    fi
    echo "cost time:$time_spent"
    total_time_spent=$(awk 'BEGIN{printf "%.2f\n",('$total_time_spent'+'$time_spent')}')
    echo ${filename/.sql/}' '$time_spent >> $result_summary
done
echo "=========================================================="
echo "Finish query..."
echo "=========================================================="
echo "total time:$total_time_spent"
echo "total time:$total_time_spent" >> $result_summary
