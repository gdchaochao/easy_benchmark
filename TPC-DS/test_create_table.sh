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


echo "=========================================================="
echo "start create table..."
echo "=========================================================="

# create table
hive -f $_WORKING_DIR/resource/create_table.sql 

# load data to table
hive -e "load data local inpath "$_DATA_DIR/web_site.dat" overwrite into table web_site;"
hive -e "load data local inpath "$_DATA_DIR/web_page.dat" overwrite into table web_page;"
hive -e "load data local inpath "$_DATA_DIR/web_sales.dat" overwrite into table web_sales;"
hive -e "load data local inpath "$_DATA_DIR/date_dim.dat" overwrite into table date_dim;"
hive -e "load data local inpath "$_DATA_DIR/item.dat" overwrite into table item;"
hive -e "load data local inpath "$_DATA_DIR/warehouse.dat" overwrite into table warehouse;"
hive -e "load data local inpath "$_DATA_DIR/promotion.dat" overwrite into table promotion;"
hive -e "load data local inpath "$_DATA_DIR/time_dim.dat" overwrite into table time_dim;"
hive -e "load data local inpath "$_DATA_DIR/ship_mode.dat" overwrite into table ship_mode;"
hive -e "load data local inpath "$_DATA_DIR/customer_demographics.dat" overwrite into table customer_demographics;"
hive -e "load data local inpath "$_DATA_DIR/customer.dat" overwrite into table customer;"
hive -e "load data local inpath "$_DATA_DIR/customer_address.dat" overwrite into table customer_address;"
hive -e "load data local inpath "$_DATA_DIR/household_demographics.dat" overwrite into table household_demographics;"
hive -e "load data local inpath "$_DATA_DIR/income_band.dat" overwrite into table income_band;"
hive -e "load data local inpath "$_DATA_DIR/reason.dat" overwrite into table reason;"
hive -e "load data local inpath "$_DATA_DIR/web_returns.dat" overwrite into table web_returns;"
hive -e "load data local inpath "$_DATA_DIR/call_center.dat" overwrite into table call_center;"
hive -e "load data local inpath "$_DATA_DIR/catalog_page.dat" overwrite into table catalog_page;"
hive -e "load data local inpath "$_DATA_DIR/catalog_returns.dat" overwrite into table catalog_returns;"
hive -e "load data local inpath "$_DATA_DIR/catalog_sales.dat" overwrite into table catalog_sales;"
hive -e "load data local inpath "$_DATA_DIR/dbgen_version.dat" overwrite into table dbgen_version;"
hive -e "load data local inpath "$_DATA_DIR/inventory.dat" overwrite into table inventory;"
hive -e "load data local inpath "$_DATA_DIR/store.dat" overwrite into table store;"
hive -e "load data local inpath "$_DATA_DIR/store_returns.dat" overwrite into table store_returns;"
hive -e "load data local inpath "$_DATA_DIR/store_sales.dat" overwrite into table store_sales;"

echo "=========================================================="
echo "Finish create table..."
echo "=========================================================="
