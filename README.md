# Usage

```bash
wget -qO- https://raw.githubusercontent.com/smeup/smeup-provider-utils/master/schedule-provider-restart.sh | bash
```

The default restart time is 4:17.

Use the command "set-restart-provider-time" to change it.

For example:

```bash
set-restart-provider-time 7:32
```

To check the crontab file:

```bash
crontab -l
```

To empty the crontab file:

```bash
crontab -r
```

In this case smeup-provider-fe will not be restarted.
