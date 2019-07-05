#!/bin/bash
DIR="/home/smeup/sidecar-monitor/ahc-agent"

cd $DIR

docker login -u XXXXX -p YYYYYY  docker-registry.smeup.cloud/iot-platform/ahc-agent:dev

docker run --name="iot-agent" --volume=/home/smeup/sidecar-monitor/ahc-agent/:/app/smeup/conf --volume=/home/smeup/container/smeup-provider-fe/config/smeup-provider-fe/:/providerconfig --net=host -e SMARTKIT_ID=$SMARTKIT_ID -d docker-registry.smeup.cloud/iot-platform/ahc-agent:dev

