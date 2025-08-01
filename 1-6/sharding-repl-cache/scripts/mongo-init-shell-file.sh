#!/bin/bash

###
# Скрипты для выполнения в файле.
###

docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
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
EOF

docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
rs.initiate({_id: "rs1", members: [
  {_id: 0, host: "shard1-1:27018"},
  {_id: 1, host: "shard1-1-a:27031"},
  {_id: 2, host: "shard1-1-b:27032"}
]});
exit();
EOF

docker compose exec -T shard1-2 mongosh --port 27019 --quiet <<EOF
rs.initiate({_id: "rs2", members: [
  {_id: 0, host: "shard1-2:27019"},
  {_id: 1, host: "shard1-2-a:27041"},
  {_id: 2, host: "shard1-2-b:27042"}
]});
exit();
EOF

docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF

sh.addShard("rs1/shard1-1:27018");
sh.addShard("rs2/shard1-2:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );

use somedb;

for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i});

db.helloDoc.countDocuments();
exit();
EOF

docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF


docker compose exec -T shard1-2 mongosh --port 27019 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF
