terraform_destroy1:
  cmd.run:
    - name: (terraform destroy -auto-approve > /dev/null 2>&1) || (terraform destroy -auto-approve > /dev/null 2>&1)
    - cwd: /home/smeup/terraform/smeup-provider-fe
    - stateful: True

terraform_apply:
  cmd.run:
    - name: terraform apply -auto-approve > /dev/null 2>&1
    - cwd: /home/smeup/terraform/smeup-provider-fe
    - stateful: True

update_provider:
  cmd.run:
    - name: /home/smeup/bin/update-provider > /dev/null 2>&1
    - unless: ls -l /home/smeup/smeup-provider-1.2.4.war
    - env: 
      - HOME: '/home/smeup'
    - cwd: /home/smeup
    - stateful: True
