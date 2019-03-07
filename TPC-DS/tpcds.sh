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
        --result   Directory for storing result"
        exit
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

# 利用TPC-DS产生数据
# unzip tpc-ds
echo "unzip tpc-ds"
_TPCDS_DIR=$_WORKING_DIR/tpcds
echo $_TPCDS_DIR
unzip -o ./resource/v2.10.1rc3.zip
mv $_WORKING_DIR/v2.10.1rc3 $_WORKING_DIR/tpcds
rm -rf $_WORKING_DIR/__MACOSX

# make tpc-ds
echo "make"
cd $_TPCDS_DIR/tools
make clean all

echo "dsdgen data"
chmod +x $_TPCDS_DIR/tools/dsdgen
$_TPCDS_DIR/tools/dsdgen -SCALE 1GB -DIR $_DATA_DIR


