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

## Register minion

```bash
wget -qO- https://raw.githubusercontent.com/smeup/smeup-provider-utils/master/saltminion.sh | sudo bash -s MINION_ID USERNMANE PASSWORD
```

## Test minion

```bash
curl -sS https://rm.smeup.com/run -H 'Accept: application/x-yaml' -H 'Content-type: application/json' -d '[{"client":"local","tgt":"MINION_ID","fun":"test.ping","username":"USERNMANE","password":"PASSWORD","eauth": "pam"}]'
```