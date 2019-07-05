#!/bin/bash
DIR="/home/smeup/sidecar-monitor/hub"
SMID=$SMARTKIT_ID
echo $SMID
cd $DIR
docker login -u XXXXX -p YYYYY  docker-registry.smeup.cloud/iot-platform/hub:dev
docker run --name=iot-hub --net=host --hostname=$HOSTNAME --add-host=$HOSTNAME:127.0.0.1 -d docker-registry.smeup.cloud/iot-platform/hub:dev
