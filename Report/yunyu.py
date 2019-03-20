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
import traceback
from collections import defaultdict


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

master_config = {"os_kernel": {"kernel": "3.10.0-693.el7.x86_64", "os_name": "CentOS Linux release 7.4.1708 (Core)"}, "vendor": {"name": "qcloud"}, "bios": {"Vendor": "SeaBIOS", "Characteristics": "", "Runtime Size": "96 kB", "BIOS Revision": "0.0", "Version": "seabios-1.9.1-qemu-project.org", "ROM Size": "64 kB", "Address": "0xE8000", "Targeted content d": "istribution", "Release Date": "04/01/2014"}, "nic": {"firmware-version": "", "rfs": "0\\n0", "rps": "00", "supports-eeprom-access": "no", "supports-priv-flags": "no", "bus-info": ".0", "supports-register-dump": "no", "supports-test": "no", "expansion-rom-version": "", "version": "1.0.0", "xps": "00", "queue_num": "8", "supports-statistics": "no", "Ethernet controller": "Red Hat", "Inc Virtio network devicedriver": "virtio_net"}, "cpu_freq_info": {"available cpufreq governors": "Not Available", "consistency": "y"}, "sold_type": "D2", "gpu": {}, "xml_config": {"placement": "static", "name": "hypervisor", "cpuset": "2-1942-59'", "threads": "1", "policy": "require", "cores": "8", "fallback": "forbid", "sockets": "1"}, "disk": {}, "cuDNN": {}, "cuda": {"version": "default"}, "memory": {"Maximum Capacity": "32 GB", "Number Of Devices": "2", "Use": "System Memory", "Error Information Handle": "Not Provided", "Error Correction Type": "Multi-bit ECC", "Location": "Other"}, "nic_switch": {"tx-udp_tnl-csum-segmentation": "off fixed]", "vlan-challenged": "off fixed]", "rx-vlan-offload": "off fixed]", "tx-vlan-stag-hw-insert": "off fixed]", "rx-vlan-stag-filter": "off fixed]", "highdma": "on fixed]", "tx-tcp-segmentation": "off fixed]", "tx-nocache-copy": "off", "tx-gso-robust": "off fixed]", "tx-tcp6-segmentation": "off fixed]", "netns-local": "off fixed]", "tx-checksum-ipv4": "off fixed]", "Features for eth0": "", "tx-checksum-ip-generic": "off fixed]", "l2-fwd-offload": "off fixed]", "ntuple-filters": "off fixed]", "tx-checksum-ipv6": "off fixed]", "loopback": "off fixed]", "tx-mpls-segmentation": "off fixed]", "tx-ipip-segmentation": "off fixed]", "tx-udp_tnl-segmentation": "off fixed]", "tx-gre-segmentation": "off fixed]", "fcoe-mtu": "off fixed]", "tx-sctp-segmentation": "off fixed]", "rx-vlan-stag-hw-parse": "off fixed]", "tx-vlan-offload": "off fixed]", "tx-checksum-sctp": "off fixed]", "udp-fragmentation-offload": "off fixed]", "tx-scatter-gather-fraglist": "off fixed]", "tx-scatter-gather": "off fixed]", "tx-sit-segmentation": "off fixed]", "busy-poll": "off fixed]", "tx-checksum-fcoe-crc": "off fixed]", "generic-receive-offload": "on", "tx-tcp-mangleid-segmentation": "off fixed]", "rx-all": "off fixed]", "tcp-segmentation-offload": "off", "tx-tcp-ecn-segmentation": "off fixed]", "rx-checksumming": "on fixed]", "tx-lockless": "off fixed]", "generic-segmentation-offload": "off requested on]", "tx-fcoe-segmentation": "off fixed]", "tx-checksumming": "off", "large-receive-offload": "off fixed]", "rx-vlan-filter": "on fixed]", "tx-gre-csum-segmentation": "off fixed]", "tx-gso-partial": "off fixed]", "receive-hashing": "off fixed]", "rx-fcs": "off fixed]", "scatter-gather": "off", "hw-tc-offload": "off fixed]"}, "runtime_env": {"libc": "ldd (GNU libc) 2.17", "gcc": "gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-28)"}, "cpu": {"CPU(s)": "8", "L1d cache": "32K", "CPU op-mode(s)": "32-bit 64-bit", "NUMA node0 CPU(s)": "0-7", "Hypervisor vendor": "KVM", "L2 cache": "4096K", "L1i cache": "32K", "Model name": "Intel(R) Xeon(R) Gold 61xx CPU", "CPU MHz": "2399.998", "Core(s) per socket": "8", "Virtualization type": "full", "Thread(s) per core": "1", "model name": "Intel(R) Xeon(R) Gold 61xx CPU", "On-line CPU(s) list": "0-7", "Socket(s)": "1", "Flags": "fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl eagerfpu pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch fsgsbase bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx avx512f avx512dq rdseed adx smap avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 arat", "Architecture": "x86_64", "Model": "94", "Vendor ID": "GenuineIntel", "CPU family": "6", "flags": "fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl eagerfpu pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch fsgsbase bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx avx512f avx512dq rdseed adx smap avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 arat", "Stepping": "3", "Byte Order": "Little Endian", "NUMA node(s)": "1"}}


node_config = {"os_kernel": {"kernel": "3.10.0-693.el7.x86_64", "os_name": "CentOS Linux release 7.4.1708 (Core)"}, "vendor": {"name": "qcloud"}, "bios": {"Vendor": "SeaBIOS", "Characteristics": "", "Runtime Size": "96 kB", "BIOS Revision": "0.0", "Version": "seabios-1.9.1-qemu-project.org", "ROM Size": "64 kB", "Address": "0xE8000", "Targeted content d": "istribution", "Release Date": "04/01/2014"}, "nic": {"firmware-version": "", "rfs": "32768\\n4096", "rps": "ffffffff", "supports-eeprom-access": "no", "supports-priv-flags": "no", "bus-info": ".0", "supports-register-dump": "no", "supports-test": "no", "expansion-rom-version": "", "version": "1.0.0", "xps": "00000000", "queue_num": "8", "supports-statistics": "no", "Ethernet controller": "Red Hat", "Inc Virtio network devicedriver": "virtio_net"}, "cpu_freq_info": {"available cpufreq governors": "Not Available", "consistency": "y"}, "sold_type": "D2", "gpu": {}, "xml_config": {"placement": "static", "name": "hypervisor", "cpuset": "2-1942-59'", "threads": "1", "policy": "require", "cores": "32", "fallback": "forbid", "sockets": "1"}, "disk": {}, "cuDNN": {}, "cuda": {"version": "default"}, "memory": {"Maximum Capacity": "128 GB", "Number Of Devices": "8", "Use": "System Memory", "Error Information Handle": "Not Provided", "Error Correction Type": "Multi-bit ECC", "Location": "Other"}, "nic_switch": {"tx-udp_tnl-csum-segmentation": "off fixed]", "vlan-challenged": "off fixed]", "rx-vlan-offload": "off fixed]", "tx-vlan-stag-hw-insert": "off fixed]", "rx-vlan-stag-filter": "off fixed]", "highdma": "on fixed]", "tx-tcp-segmentation": "off fixed]", "tx-nocache-copy": "off", "tx-gso-robust": "off fixed]", "tx-tcp6-segmentation": "off fixed]", "netns-local": "off fixed]", "tx-checksum-ipv4": "off fixed]", "Features for eth0": "", "tx-checksum-ip-generic": "off fixed]", "l2-fwd-offload": "off fixed]", "ntuple-filters": "off fixed]", "tx-checksum-ipv6": "off fixed]", "loopback": "off fixed]", "tx-mpls-segmentation": "off fixed]", "tx-ipip-segmentation": "off fixed]", "tx-udp_tnl-segmentation": "off fixed]", "tx-gre-segmentation": "off fixed]", "fcoe-mtu": "off fixed]", "tx-sctp-segmentation": "off fixed]", "rx-vlan-stag-hw-parse": "off fixed]", "tx-vlan-offload": "off fixed]", "tx-checksum-sctp": "off fixed]", "udp-fragmentation-offload": "off fixed]", "tx-scatter-gather-fraglist": "off fixed]", "tx-scatter-gather": "off fixed]", "tx-sit-segmentation": "off fixed]", "busy-poll": "off fixed]", "tx-checksum-fcoe-crc": "off fixed]", "generic-receive-offload": "on", "tx-tcp-mangleid-segmentation": "off fixed]", "rx-all": "off fixed]", "tcp-segmentation-offload": "off", "tx-tcp-ecn-segmentation": "off fixed]", "rx-checksumming": "on fixed]", "tx-lockless": "off fixed]", "generic-segmentation-offload": "off requested on]", "tx-fcoe-segmentation": "off fixed]", "tx-checksumming": "off", "large-receive-offload": "off fixed]", "rx-vlan-filter": "on fixed]", "tx-gre-csum-segmentation": "off fixed]", "tx-gso-partial": "off fixed]", "receive-hashing": "off fixed]", "rx-fcs": "off fixed]", "scatter-gather": "off", "hw-tc-offload": "off fixed]"}, "runtime_env": {"libc": "ldd (GNU libc) 2.17", "gcc": "gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-28)"}, "cpu": {"CPU(s)": "32", "L1d cache": "32K", "CPU op-mode(s)": "32-bit 64-bit", "NUMA node0 CPU(s)": "0-31", "Hypervisor vendor": "KVM", "L2 cache": "4096K", "L1i cache": "32K", "Model name": "Intel(R) Xeon(R) Gold 61xx CPU", "CPU MHz": "2399.998", "Core(s) per socket": "32", "Virtualization type": "full", "Thread(s) per core": "1", "model name": "Intel(R) Xeon(R) Gold 61xx CPU", "On-line CPU(s) list": "0-31", "Socket(s)": "1", "Flags": "fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl eagerfpu pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch fsgsbase bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx avx512f avx512dq rdseed adx smap avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 arat", "Architecture": "x86_64", "Model": "94", "Vendor ID": "GenuineIntel", "CPU family": "6", "flags": "fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl eagerfpu pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch fsgsbase bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx avx512f avx512dq rdseed adx smap avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 arat", "Stepping": "3", "Byte Order": "Little Endian", "NUMA node(s)": "1"}}


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


def postVMTestResult(test_name, tool_name, tool_conf, cluster_conf,
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
    cluster_conf_id = __find_and_new_config(cluster_conf)
    env_configs.append(cluster_conf_id)

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
        "timestamp": datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
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
    configs = defaultdict(dict)
    cpu_pattern = r"CPU-Capacity\s:\s(?P<value>[0-9]*)"
    memory_pattern = r"Memory-Capacity\s:\s(?P<value>[0-9]*)"
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
        print traceback.format_exc()
        return {}


def get_host_config():
    configs = defaultdict(dict)
    pattern = r"Total Nodes:(?P<value>[0-9]*)"
    try:
        hostname = commands.getoutput("hostname")
        configs[hostname]["cpu"] = commands.getoutput("cat /proc/cpuinfo| grep \"cpu cores\"| uniq | tr -cd 0-9")
        configs[hostname]["memory"] = commands.getoutput("cat /proc/meminfo | grep \"MemTotal:\"| uniq | tr -cd 0-9")

        running_nodes = commands.getoutput(os.getenv("HADOOP_HOME") + "/bin/yarn node -list -states RUNNING | grep \"Total Nodes\"")
        match = re.search(pattern, running_nodes)
        configs[hostname]["nodes"] = match.group("value")
        return configs
    except:
        print traceback.format_exc()
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


def post_tpc_ds_result(sql_type, scale, result, master='', num_executors=-1, executor_cores=-1,
                       executor_memory=-1, driver_memory=-1):
    if sql_type == 'hive':
        test_name = 'cvm_tpc_ds_73_queries'
    elif sql_type == 'spark-sql':
        test_name = 'cvm_tpc_ds_99_queries'
    elif sql_type == 'load':
        test_name = 'cvm_tpc_ds_load'
    else:
        test_name = 'cvm_tpc_ds_99_queries'
    tool_name = 'TPC-DS'
    spark_version = filter_version(commands.getoutput(os.getenv("SPARK_HOME") + "/bin/spark-shell --version"))
    hadoop_version = filter_version(commands.getoutput(os.getenv("HADOOP_HOME") + "/bin/hadoop version"))
    hive_version = filter_version(commands.getoutput(os.getenv("HIVE_HOME") + "/bin/hive --version"))
    # spark_version = "2.2.2"
    # hadoop_version = "2.1"
    # hive_version = "2.3"
    cost = '{}'

    master_conf = Config("cvm", "default", json.dumps(master_config), "default", "default")
    node_conf = Config("cvm", "default", json.dumps(node_config), "default", "default")
    cluster_dir = {
        "master": {
                "config_id": __find_and_new_config(master_conf),
                "number": 1
        },
        "nodes": {
                "config_id": __find_and_new_config(node_conf),
                "number": 6
        }
    }
    cluster_conf = Config("cluster", "default", json.dumps(cluster_dir), "default", "default")
    tool_dir = {
        "scale": scale,
        "spark": spark_version,
        "hadoop": hadoop_version,
        "hive": hive_version,
        "master": master,
        "num_executors": num_executors,
        "executor_memory": executor_memory,
        "executor_cores": executor_cores,
        "driver_memory": driver_memory
    }
    tool_conf = Config("TPC-DS", "2.10.1rc3",
                       json.dumps(tool_dir), "default", "default")
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
    task_id = str(uuid.uuid1()).replace("-", "")

    postVMTestResult(test_name, tool_name, tool_conf, cluster_conf,
                     cost, results_json,
                     avg_time, min_time, max_time, median_time, std_time,
                     avg_through_put, min_through_put, max_through_put, median_through_put, std_through_put,
                     benchmark_type, description, task_id)


if __name__ == "__main__":
    print sys.argv[1]
    print sys.argv[2]
    print sys.argv[3]
    print sys.argv[4]
    print sys.argv[5]
    print sys.argv[6]
    print sys.argv[7]
    print sys.argv[8]
    print sys.argv[9]
    print token
    post_tpc_ds_result(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6], sys.argv[7],
                       sys.argv[8], sys.argv[8])


