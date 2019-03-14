# -*- coding: UTF-8 -*-
'''
Created on 2019/3/13
@author: duckzheng
'''
import json
import urllib2
import datetime
import hashlib
import urllib
import sys
import uuid
import re
import commands
import os


host = "https://yunyu.cloud.tencent.com/cloud_perf_db"
token = "Token %s" % sys.argv[1]

testcase_data = """
                {
                    "test_name": "%s",
                    "tool_name": "%s",
                    "benchmark_type": %s,
                    "description": "%s",
                    "env_configs": %s,
                    "tool_configs": %s
                }
                """

class Config(object):
    def __init__(self, name, version, configs, gcc_version, gcc_flags):
        if configs == 'default':
            configs = '{}'
        try:
            json.loads(configs)
        except Exception:
            raise RuntimeError('Cannot parse configs to a dict. It should be a json string.')
        self.name = name
        self.version = version
        self.configs = configs
        self.gcc_version = gcc_version
        self.gcc_flags = gcc_flags

    def toJsonStr(self):
        config_data = {
            "name": self.name,
            "version": self.version,
            "configs": self.configs,
            "configs2md5": self.configs2md5,
            "gcc_version": self.gcc_version,
            "gcc_flags": self.gcc_flags
        }
        return json.dumps(config_data)

    @property
    def configs2md5(self):
        m = hashlib.md5()
        m.update(self.configs)
        return m.hexdigest()

    def __str__(self):
        return self.toJsonStr()


def postVMTestResult(test_name, tool_name, vm_conf, host_conf, tool_conf, kvm_conf, qemu_conf, libvirt_conf,
                     cost, results_json, avg_time, min_time, max_time, median_time, std_time,
                     avg_through_put, min_through_put, max_through_put, median_through_put, std_through_put,
                     benchmark_type=0, description='待添加', task_id='0'
                     ):
    '''
    @:param test_name: 测试用例名字， 如fio-4k-random-test
    @:param tool_name: 使用工具名字， 如fio
    @:param vm_conf: 子机系统配置,Config对象
    @:param host_conf: 母机机型配置，Config对象
    @:param tool_conf: 测试工具配置，Config对象
    @:param kvm_conf: KVM配置，Config对象
    @:param qemu_conf: qemu配置，Config对象
    @:param libvirt_conf: libvirt配置，Config对象
    @:param cost: 运行时消耗. cost对象
    @:param results_json: json格式的测试结果数据
    @:param avg_time: 平均耗时
    @:param min_time: 最小耗时
    @:param max_time: 最大耗时
    @:param median_time: 中值耗时
    @:param std_time: 标准差耗时
    @:param avg_through_put: 平均吞吐量
    @:param min_through_put: 最小吞吐量
    @:param max_through_put: 最大吞吐量
    @:param median_through_put: 中值吞吐量
    @:param std_through_put: 标准差吞吐量
    @:param benchmark_type: 默认值0
    @:param description: 预留字段
    @:param task_id:任务id
    @:baseline_json:测试基准
    '''
    # get_env_configs
    env_configs = []

    vm_conf_id = __find_and_new_config(vm_conf)
    env_configs.append(vm_conf_id)

    host_conf_id = __find_and_new_config(host_conf)
    env_configs.append(host_conf_id)

    kvm_conf_id = __find_and_new_config(kvm_conf)
    env_configs.append(kvm_conf_id)

    qemu_conf_id = __find_and_new_config(qemu_conf)
    env_configs.append(qemu_conf_id)

    libvirt_conf_id = __find_and_new_config(libvirt_conf)
    env_configs.append(libvirt_conf_id)

    # get_tools_configs
    tools_configs = []
    tools_configs.append(__find_and_new_config(tool_conf))

    # get_testcase_id
    testcase_id = __find_and_new_testcase(test_name, tool_name, env_configs, tools_configs, benchmark_type, description)

    version = 2002
    status = 1
    test_baseline = '{}'
    is_cold_boot = 'True'

    testresult = {
        "timestamp": datetime.datetime.now().strftime('%Y-%m-%d'),
        "version": version,
        "costs_json": cost,
        "results_json": results_json,
        "avg_time": avg_time,
        "min_time": min_time,
        "max_time": max_time,
        "mean_time": median_time,
        "std_time": std_time,
        "min_through_put": min_through_put,
        "max_through_put": max_through_put,
        "avg_through_put": avg_through_put,
        "mean_through_put": median_through_put,
        "std_through_put": std_through_put,
        "testcase": testcase_id,
        "task_id": task_id,
        "baseline_json": test_baseline,
        "is_cold_boot": is_cold_boot,
        "original_version": -1,
        "status": status
    }

    print test_new_testresult(testresult)


def __find_and_new_testcase(test_name, tool_name, env_configs, tools_configs, benchmark_type, description):
    testcase_id = __find_testcase(test_name, tool_name, env_configs, tools_configs)
    if not testcase_id:
        result = __new_testcase(test_name, tool_name, benchmark_type, description, env_configs, tools_configs)
        if not result:
            return None
        testcase_id = result["id"]
    return testcase_id


def __find_testcase(test_name, tool_name, env_configs, tools_configs):
    """
    :return id
    """
    env_configs_query = ""
    if env_configs:
        env_configs_query = str(env_configs).replace(" ", "")
    tool_configs_query = ""
    if tools_configs:
        tool_configs_query = str(tools_configs).replace(" ", "")
    url = '%s/api/testcases/?test_name=%s&tool_name=%s&env_configs=%s&tools_configs=%s' % (
        host, test_name, tool_name, env_configs_query, tool_configs_query)
    url = urllib.quote(url, '?/:=&')
    print url
    req = urllib2.Request(url, headers={'Content-Type': 'application/json', 'Authorization': token})
    resp = urllib2.urlopen(req)
    if resp.code != 200:
        return None
    result = json.loads(resp.read())
    if not result:
        return None
    return result[0]["id"]


def __new_testcase(testname, toolname, benchmark_type, description, env_configs, tool_configs):
    assert type(env_configs) == list
    assert type(tool_configs) == list
    assert type(benchmark_type) == int

    req = urllib2.Request('%s/api/testcases/' % host, data=testcase_data % (
        testname, toolname, benchmark_type, description, str(env_configs), str(tool_configs)),
                          headers={'Content-Type': 'application/json', 'Authorization': token})
    resp = urllib2.urlopen(req)
    if resp.code != 200 and resp.code != 201:
        print resp.code, resp.read()
        return None
    return json.loads(resp.read())


def __find_and_new_config(config):
    config_id = __find_config(config)
    print "config_id:", config_id
    if not config_id:
        result = __new_config(config)
        if not result:
            return None
        config_id = result["id"]
    return config_id


def __find_config(config):
    """
    :return id
    """
    url = '%s/api/config/?name=%s&version=%s&gcc_version=%s&configs2md5=%s' % (
        host, config.name, config.version, config.gcc_version, config.configs2md5)
    url = urllib.quote(url, '?/:=&')
    print url
    req = urllib2.Request(url, headers={'Content-Type': 'application/json', 'Authorization': token})
    resp = urllib2.urlopen(req)
    if resp.code != 200:
        return None
    result = json.loads(resp.read())
    #     print result
    if not result:
        return None
    return result[0]["id"]


def __new_config(config):
    jsonstr = config.toJsonStr()
    print jsonstr
    req = urllib2.Request('%s/api/config/' % host, data=jsonstr,
                          headers={'Content-Type': 'application/json', 'Authorization': token})
    resp = urllib2.urlopen(req)
    if resp.code != 200 and resp.code != 201:
        print resp.code, resp.read()
        return None
    result = json.loads(resp.read())
    return result


def test_new_testresult(testresult):
    jsonres = json.dumps(testresult)
    req = urllib2.Request('%s/api/testresults/' % host, data=jsonres,
                          headers={'Content-Type': 'application/json', 'Authorization': token})
    resp = urllib2.urlopen(req)
    if resp.code != 200 and resp.code != 201:
        print resp.code, resp.read()
        return None
    result = json.loads(resp.read())
    return result


def get_cvm_config():
    configs = dict()
    cpu_pattern = r"CPU-Capacity\s:\s(?P<value>[0-9])"
    memory_pattern = r"Memory-Capacity\s:\s(?P<value>[0-9])"
    try:
        nodes_info = commands.getoutput(os.getenv("HADOOP_HOME") + "/bin/yarn node -list -states RUNNING | awk '{print $1}'")
        for node in nodes_info.split("\n"):
            if "Total" in node or "Node-Id" in node or "SLF4J: " in node:
                continue
            cpu = commands.getoutput(os.getenv("HADOOP_HOME") + "/bin/yarn node -status %s | grep CPU-Capacity" % node)
            memory = commands.getoutput(os.getenv("HADOOP_HOME") + "/bin/yarn node -status %s | grep Memory-Capacity" % node)
            match_cpu = re.search(cpu_pattern, cpu)
            match_memory = re.search(memory_pattern, memory)
            configs[node]["cpu"] = match_cpu.group("value")
            configs[node]["memory"] = match_memory.group("value")
        return configs
    except:
        return {}


def get_host_config():
    configs = dict()
    pattern = r"Total Nodes:(?P<value>[0-9])"
    try:
        hostname = commands.getoutput("hostname")
        configs[hostname]["cpu"] = commands.getoutput("cat /proc/cpuinfo| grep \"cpu cores\"| uniq | tr -cd 0-9")
        configs[hostname]["memory"] = commands.getoutput("cat /proc/meminfo | grep \"MemTotal:\"| uniq | tr -cd 0-9")

        running_nodes = commands.getoutput(os.getenv("HADOOP_HOME") + "/bin/yarn node -list -states RUNNING | grep \"Total Nodes\"")
        match = re.search(pattern, running_nodes)
        configs[hostname]["nodes"] = match.group("value")
        return configs
    except:
        return {}


def filter_version(version_str):
    pattern = r"(?P<version>\d{1,2}\.\d{1,2}\.\d{1,2})"
    match = re.search(pattern, version_str)
    try:
        if match and match.group("version"):
            return match.group("version")
        else:
            return '0.0'
    except:
        return '0.0'


def post_tpc_ds_result(sql_type, scale, result):
    if sql_type == 'hive':
        test_name = 'cvm_tpc_ds_73_queries'
    else:
        test_name = 'cvm_tpc_ds_99_queries'
    tool_name = 'TPC-DS'
    spark_version = filter_version(commands.getoutput(os.getenv("SPARK_HOME") + "/bin/spark-shell --version"))
    hadoop_version = filter_version(commands.getoutput(os.getenv("HADOOP_HOME") + "/bin/hadoop version"))
    hive_version = filter_version(commands.getoutput(os.getenv("HIVE_HOME") + "/bin/hive --version"))
    cost = '{}'
    vm_conf = Config("node", "default", json.dumps(get_cvm_config()), "default", "default")
    host_conf = Config("master", "default", json.dumps(get_host_config()), "default", "default")
    kvm_conf = Config("kvm", "default", "{}", "default", "default")
    qemu_conf = Config("qemu", "default", "{}", "default", "default")
    libvirt_conf = Config("libvirt", "default", "{}", "default", "default")
    tool_conf = Config("TPC-DS", "2.10.1rc3",
                       json.dumps({"scale": scale, "spark": spark_version, "hadoop": hadoop_version,
                                   "hive": hive_version}), "default", "default")
    cost = '{}'
    results_json = result
    avg_time = 0.0
    min_time = 0.0
    max_time = 0.0
    median_time = 0.0
    std_time = 0.0
    avg_through_put = 0.0
    min_through_put = 0.0
    max_through_put = 0.0
    median_through_put = 0.0
    std_through_put = 0.0
    benchmark_type = 0
    description = '待添加'
    # task_id = 'TPC-DS-' + str(timestamp)
    task_id = str(uuid.uuid1()).replace("-", "")

    postVMTestResult(test_name, tool_name, vm_conf, host_conf, tool_conf, kvm_conf, qemu_conf, libvirt_conf,
                     cost, results_json,
                     avg_time, min_time, max_time, median_time, std_time,
                     avg_through_put, min_through_put, max_through_put, median_through_put, std_through_put,
                     benchmark_type, description, task_id)


if __name__ == "__main__":
    print sys.argv[1]
    print sys.argv[2]
    print sys.argv[3]
    print sys.argv[4]
    print token
    post_tpc_ds_result(sys.argv[2], sys.argv[3], sys.argv[4])

