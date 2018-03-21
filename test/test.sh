#!/bin/bash
set +e

docker build -t hsldevcom/digitransit-proxy:integrationtest .

PROXIED_HOSTS=`grep proxy_pass *.conf|cut -d'/' -f3|cut -d':' -f1|grep -v "\."|uniq`

TARGETHOST=`/sbin/ifconfig|grep inet|grep -v inet6|grep -v 127.0.0.1|grep -oE "([0-9.])+"|head -1`

echo $PROXIED_HOSTS

#construct --add-host parameters
for HOST in $PROXIED_HOSTS;do ADDHOSTS="--add-host $HOST:$TARGETHOST $ADDHOSTS";done;

echo $ADDHOSTS

cd test

npm install
npm install -g forever
forever start server.js

CONTAINER_ID=`docker run -d -p 9000:8080 $ADDHOSTS hsldevcom/digitransit-proxy:integrationtest`

curl -v http://127.0.0.1:9000

echo started proxy-container $CONTAINER_ID
echo starting echo server...
#node server.js&
#PID=$!

sleep 5
curl -v http://127.0.0.1:8080

npm test
STATUS=$?

#echo "stopping test server (pid:$PID)"
#kill -9 $PID
echo stopping proxy-container $CONTAINER_ID
docker stop $CONTAINER_ID

forever stopall

exit $STATUS
