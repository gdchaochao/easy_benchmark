# -*- coding: UTF-8 -*-
'''
Created on 2019/3/13
@author: duckzheng
'''
import re
import sys
import json
from collections import defaultdict


def get_load_data(r_file):
    total_time = 0
    r = dict()
    table_pattern = r"Loading data to table .*\.(?P<value>[a-zA-Z\_]*)"
    time_pattern = r"Time taken: (?P<value>\d*(\.\d+)*)"
    current_key = ""
    with open(r_file, 'r') as f:
        for line in f.readlines():
            if "Loading data to table" in line:
                match = re.search(table_pattern, line.strip())
                table = match.group("value")
                current_key = table
            if "Time taken" in line:
                match = re.search(time_pattern, line.strip())
                time = match.group("value")
                total_time = total_time + float(time)
                r[current_key] = time
        r["#tpcds_load_time"] = total_time
    # r = json.dumps(r)
    return r


if __name__ == "__main__":
    # print get_load_data("./load_data_log")
    print get_load_data(sys.argv[1])

