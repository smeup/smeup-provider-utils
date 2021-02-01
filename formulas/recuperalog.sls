comprimi_log:
  cmd.run:
    - order: 1
    - name: tar cvzf logs.tgz log
    - cwd: /home/smeup/container/smeup-provider-fe
copia_su_master:
  module.run:
    - order: 2
    - name: cp.push
    - path: /home/smeup/container/smeup-provider-fe/logs.tgz
