# -*- coding: UTF-8 -*-
'''
Created on 2019/3/13
@author: duckzheng
'''
import re
import sys


def get_load_data(r_file):
    total_time = 0
    r = "\"{"
    table_pattern = r"Loading data to table .*\.(?P<value>[a-zA-Z\_]*)"
    time_pattern = r"Time taken: (?P<value>\d*(\.\d+)*)"
    with open(r_file, 'r') as f:
        for line in f.readlines():
            if "Loading data to table" in line:
                # print line.strip()
                match = re.search(table_pattern, line.strip())
                table = match.group("value")
                r = r + "\"%s\":" % table
            if "Time taken" in line:
                # print line.strip()
                match = re.search(time_pattern, line.strip())
                time = match.group("value")
                total_time = total_time + float(time)
                r = r + "%s," % time
        r = r + "\"#tpcds_load_time\":%d}\"" % total_time
    return r


if __name__ == "__main__":
    # print get_load_data("./load_data_log")
    print get_load_data(sys.argv[1])

