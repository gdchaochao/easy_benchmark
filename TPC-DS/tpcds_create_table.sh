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

# load data to table
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

echo "=========================================================="
echo "Finish create table..."
echo "=========================================================="
