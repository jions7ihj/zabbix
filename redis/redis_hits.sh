#!/bin/bash
REDISPATH="/usr/local/services/redisclient/redis-cli"
HOST="10.26.111.23"
PORT="6380"
REDIS_PA="$REDISPATH -h $HOST -p $PORT info"
hits=`$REDIS_PA|/bin/grep -w "keyspace_hits" | awk -F':' '{print $2}'`
misses=`$REDIS_PA|/bin/grep -w "keyspace_misses" | awk -F':' '{print $2}'`
a=$hits
#a=14414110
#b=3228654
b=$misses
c=`awk 'BEGIN{a=$a;b=$b;print '$a+$b'}'`
result=`awk 'BEGIN{c=$c;a=$a;print '$a/$c'}'`
echo $result
