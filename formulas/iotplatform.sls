/home/smeup/sidecar-monitor/hub:
  file.recurse:
    - order: 1
    - source: salt://files/sidecar-monitor/hub
    - makedirs: True
    - file_mode: keep
/home/smeup/sidecar-monitor/ahc-agent:
  file.recurse:
    - order: 2
    - source: salt://files/sidecar-monitor/ahc-agent
    - makedirs: True
    - file_mode: keep
/home/smeup/sidecar-monitor/ahc-agent/credas.yaml:
  file.append:
    - order: 3
    - text: "hubUrl: http://localhost:8888/api/messages/{{opts.id}}"
stop_container_hub:
  cmd.run:
    - order: 4
    - name: docker stop iot-hub
    - cwd: /home/smeup/sidecar-monitor/hub
rm_container_hub:
  cmd.run:
    - order: 5
    - name: docker rm iot-hub
    - cwd: /home/smeup/sidecar-monitor/hub
rm_image_hub:
  cmd.run:
    - order: 6
    - name: docker rmi $(docker images | grep docker-registry.smeup.cloud/iot-platform/hub* | awk '{ print $3 }') || true
    - cwd: /home/smeup/sidecar-monitor/hub
run_container_hub:
  cmd.run:
    - order: 7
    - name:  /home/smeup/sidecar-monitor/hub/dockerrun.sh > dockerrun.log
    - cwd: /home/smeup/sidecar-monitor/hub
stop_container_agent:
  cmd.run:
    - order: 8
    - name: docker stop iot-agent
    - cwd: /home/smeup/sidecar-monitor/ahc-agent
rm_container_agent:
  cmd.run:
    - order: 9
    - name: docker rm iot-agent
    - cwd: /home/smeup/sidecar-monitor/ahc-agent 
rm_image_agent:
  cmd.run:
    - order: 10
    - name: docker rmi $(docker images | grep docker-registry.smeup.cloud/iot-platform/ahc-agent* | awk '{ print $3 }')
    - cwd: /home/smeup/sidecar-monitor/ahc-agent
run_container_agent:
  cmd.run:
    - order: 11
    - name: /home/smeup/sidecar-monitor/ahc-agent/dockerrun.sh
    - cwd: /home/smeup/sidecar-monitor/ahc-agent
schedule_runagent:
  cron.present:
    - order: 12
    - name: /home/smeup/sidecar-monitor/ahc-agent/runagent.sh;
    - user: smeup
    - minute: '*/30'
    - hour: '*'
    - daymonth: '*'
    - month: '*'
    - dayweek: '*'
