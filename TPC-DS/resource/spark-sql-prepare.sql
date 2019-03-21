set spark.sql.crossJoin.enabled=true;
set spark.sql.broadcastTimeout=36000;
set spark.memory.storageFraction=0.3;
set spark.shuffle.service.enabled=false;
set spark.dynamicAllocation.enabled=false;
set spark.io.compression.codec=snappy;
set spark.sql.shuttle.partition=2000;
set spark.default.parallelism=2000;
