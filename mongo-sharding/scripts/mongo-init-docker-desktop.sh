#!/bin/bash

###
# Скрипты для Docker Desktop
###

docker compose exec -it configSrv mongosh --port 27017
rs.initiate(
  {
    _id : "config_server",
    configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
exit();

docker compose exec -it shard1-1 mongosh --port 27018
rs.initiate(
    {
      _id : "shard1-1",
      members: [
        { _id : 0, host : "shard1-1:27018" },
      ]
    }
);
exit();


docker compose exec -it shard1-2 mongosh --port 27019
rs.initiate(
    {
      _id : "shard1-2",
      members: [
        { _id : 1, host : "shard1-2:27019" }
      ]
    }
  );
  exit();


docker compose exec -it mongos_router mongosh --port 27020

sh.addShard( "shard1-1/shard1-1:27018");
sh.addShard( "shard1-2/shard1-2:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );

use somedb;

for(var i = 0; i < 2000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i});

db.helloDoc.countDocuments();
exit();


docker compose exec -T shard1-1 mongosh --port 27018
use somedb;
db.helloDoc.countDocuments();
exit(); 


docker compose exec -T shadrd1-2 mongosh --port 27019
use somedb;
db.helloDoc.countDocuments();
exit();

