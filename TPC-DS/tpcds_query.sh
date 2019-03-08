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
    *)
        echo "$1 is not an option"
        exit
        ;;
  esac
  shift
done

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
echo "start query..."
echo "=========================================================="
# start query
timestamp=$(date +%s)
echo "Timestamp:$timestamp"
total_time_spent=0
total_cpu_spent=0

files=$(ls $_WORKING_DIR/resource/queries-hive)
echo "result in:$_RESULT_DIR/$timestamp"
for filename in $files
do
#   echo $filename >> filename.txt
   result_file=$_RESULT_DIR/$timestamp'_'${filename/.sql/}
#   echo "result in:$result_file"
   echo "Executing $filename now, please wait a moment"
   hive -f $_WORKING_DIR/resource/queries/$filename > $result_file 2>&1
   time_spent=$(cat $result_file | grep 'Time taken' | tr -cd "[0-9]\.")
   cpu_spent=$(cat $result_file | grep 'MapReduce CPU Time Spent:')
   cpu_spent=$(echo ${cpu_spent/seconds/\.} | tr -cd "[0-9]\.")
   echo "cost time:$time_spent, cpu cost:$cpu_spent"
   total_time_spent=$(awk 'BEGIN{printf "%.2f\n",('$total_time_spent'+'$time_spent')}')
   total_cpu_spent=$(awk 'BEGIN{printf "%.2f\n",('$total_cpu_spent'+'$cpu_spent')}')
   echo ${filename/.sql/}' '$time_spent' '$cpu_spent >> $_RESULT_DIR/$timestamp
done
echo "=========================================================="
echo "Finish query..."
echo "=========================================================="
echo "total time:$total_time_spent"
echo "total cpu time:$total_cpu_spent"
echo "total time:$total_time_spent" >> $_RESULT_DIR/$timestamp
echo "total cpu time:$total_cpu_spent" >> $_RESULT_DIR/$timestamp
