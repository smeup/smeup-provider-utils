/home/smeup/bin/update-provider-snapshot:
  file.managed:
    - order: 1
    - source: salt://scripts/update-provider-snapshot
    - makedirs: True
    - user: smeup
    - group: smeup
    - file_mode: keep
	- mode: 755
