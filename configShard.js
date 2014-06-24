db.adminCommand({"addshard":"s1/localhost:37017"});

db.adminCommand({"addshard":"s2/localhost:47017"});

db.adminCommand({"enablesharding":"test"});

db.adminCommand({"shardcollection":"test.users","key":{"_id":1}});

sh.status();
