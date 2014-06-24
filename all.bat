REM	--------------------------------------------------------------------------------------
REM Batch script to deploy MongoDB shard cluster. 
REM For more detail on MongoDB shard cluster, see : http://docs.mongodb.org/manual/tutorial/deploy-shard-cluster/
REM	--------------------------------------------------------------------------------------

@echo off 
echo Start
set mongo_home_path=C:\Program Files\MongoDB 2.6 Standard\bin
set root_path=D:\temp\mongodb
set data_path=%root_path%\data_sharded

REM --------------------------------------------------------------------------------------
echo Launch replicatSet #1 and #2
REM		Specifies the replica set name through the --replSet 
REM		By default, MongoDB overwrites the log file when the process restarts. To instead append to the log file, set the --logappend option.
REM		Sends all diagnostic logging information to a log file with --logpath
REM		Chose the directory where the mongod instance stores its data with --dbpath 
REM		Specifies the TCP port on which the MongoDB instance listens for client connections with --port
REM		Specifies a maximum size in megabytes for the replication operation log with --oplogSize
REM		Sets MongoDB to use a smaller default file size with --smallfiles
REM		Configures this mongod instance as a shard in a partitioned cluster with --shardsvr
echo Launch 3 mongod for replicatSet #1
start "" "%mongo_home_path%\mongod" --replSet s1 --logappend --logpath "%data_path%\s1\a\s1-a.log" --dbpath "%data_path%\s1\a" --port 37017 --oplogSize 200 --smallfiles --shardsvr
start "" "%mongo_home_path%\mongod" --replSet s1 --logappend --logpath "%data_path%\s1\b\s1-b.log" --dbpath "%data_path%\s1\b" --port 37018 --oplogSize 200 --smallfiles --shardsvr
start "" "%mongo_home_path%\mongod" --replSet s1 --logappend --logpath "%data_path%\s1\c\s1-c.log" --dbpath "%data_path%\s1\c" --port 37019 --oplogSize 200 --smallfiles --shardsvr

echo Launch 3 mongod for replicatSet #2
start "" "%mongo_home_path%\mongod" --replSet s2 --logappend --logpath "%data_path%\s2\a\s2-a.log" --dbpath "%data_path%\s2\a" --port 47017 --oplogSize 200 --smallfiles --shardsvr
start "" "%mongo_home_path%\mongod" --replSet s2 --logappend --logpath "%data_path%\s2\b\s2-b.log" --dbpath "%data_path%\s2\b" --port 47018 --oplogSize 200 --smallfiles --shardsvr
start "" "%mongo_home_path%\mongod" --replSet s2 --logappend --logpath "%data_path%\s2\c\s2-c.log" --dbpath "%data_path%\s2\c" --port 47019 --oplogSize 200 --smallfiles --shardsvr
REM --------------------------------------------------------------------------------------

REM --------------------------------------------------------------------------------------
echo Launch 3 config servers
REM		By default, MongoDB overwrites the log file when the process restarts. To instead append to the log file, set the --logappend option.
REM		Sends all diagnostic logging information to a log file with --logpath
REM		Chose the directory where the mongod instance stores its data with --dbpath 
REM		Specifies the TCP port on which the MongoDB instance listens for client connections with --port
REM		Declares that this mongod instance serves as the config database of a sharded cluster with --configsvr
start "" "%mongo_home_path%\mongod" --logappend --logpath "%data_path%\cfg-a\cfg-a.log" --dbpath "%data_path%\cfg-a" --port 57017 --configsvr
start "" "%mongo_home_path%\mongod" --logappend --logpath "%data_path%\cfg-b\cfg-b.log" --dbpath "%data_path%\cfg-b" --port 57018 --configsvr
start "" "%mongo_home_path%\mongod" --logappend --logpath "%data_path%\cfg-c\cfg-c.log" --dbpath "%data_path%\cfg-c" --port 57019 --configsvr
REM --------------------------------------------------------------------------------------

timeout /t 1

REM --------------------------------------------------------------------------------------
echo Configure shard #1
REM		Specifies the TCP port on which the MongoDB instance listens for client connections with --port
REM		Specifies a JavaScript file to run and then exit with <file.js> at the end of the commande line
start "" "%mongo_home_path%\mongo" --port 37017 configS1.js
REM --------------------------------------------------------------------------------------

timeout /t 1

REM --------------------------------------------------------------------------------------
echo Configure shard #2
REM		Specifies the TCP port on which the MongoDB instance listens for client connections with --port
REM		Specifies a JavaScript file to run and then exit with <file.js> at the end of the commande line
start "" "%mongo_home_path%\mongo" --port 47017 configS2.js
REM --------------------------------------------------------------------------------------

timeout /t 1

REM --------------------------------------------------------------------------------------
echo Launch mongos
REM		Specifies the TCP port on which the MongoDB instance listens for client connections with --port
REM		By default, MongoDB overwrites the log file when the process restarts. To instead append to the log file, set the --logappend option.
REM		Sends all diagnostic logging information to a log file with --logpath
REM		Specifies 3 configuration servers with --configdb
start "" "%mongo_home_path%\mongos" --port 61017 --logappend --logpath "%data_path%\mongos.log" --configdb localhost:57017,localhost:57018,localhost:57019
REM --------------------------------------------------------------------------------------

REM must wait before defining sharding configuration ...
timeout /t 20

REM --------------------------------------------------------------------------------------
echo define sharding configuration
REM		Specifies the TCP port on which the MongoDB instance listens for client connections with --port
REM		Provides the user with a shell prompt after the file finishes executing	with --shell
REM		Specifies a JavaScript file to run and then exit with <file.js> at the end of the commande line
start "" "%mongo_home_path%\mongo" --shell --port 61017 "%root_path%\configShard.js"
REM --------------------------------------------------------------------------------------

echo This is the End.
