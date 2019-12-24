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

You can also test all minions using "*" as MINION_ID.

## Deploy provider on Nexus

Once you got provider war file you need to deploy it over nexus maven repository. You have to chooes if you want deploy snapshot or relase version.
Be advise, if you deploy a release version you can't overwrite an existing version, so you have always to modify the VRM numbers. Otherwise, if you deploy a snapshot version, you can overwrite an existing version.

Release

mvn deploy:deploy-file -DgroupId=com.smeup -DartifactId=smeup-provider -Dversion=**V.R.M** -Dpackaging=war -Dfile=**/path/to/file/smeup-provider.war** -DrepositoryId=releases -DgeneratePom=true -Durl=http://mauer.smeup.com/nexus/content/repositories/releases

Snapshot

mvn deploy:deploy-file -DgroupId=com.smeup -DartifactId=smeup-provider -Dversion=**V.R.M-SNAPSHOT** -Dpackaging=war -Dfile=**/home/olimaest/Scaricati/smeup-provider.war** -DrepositoryId=snapshots -DgeneratePom=true -Durl=http://mauer.smeup.com/nexus/content/repositories/snapshots

