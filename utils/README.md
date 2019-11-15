# Minions smeupStats.py

This script was created to request the health status of the minions connected to a master.
This request can be made via the master (see command at bottom file) or via Rest-Cherrypy by anyone who can make an HTTP request (see the [Rest-Cherrypy] documentation).

# First Release v0.0.1

This is what is possible to ask:
  - Time system load
  - Average system load
  - Process
  - Used disk space (percentage)
  - User logged-in
  - RAM Memory used (percentage)
  - Swap memory used (percentage)
  - All interface IPv4
  - Is also possible ask all this information with one request.
 
### Installation

Before using this script, the first step is to have a SaltStack master with associated minions.
Then you have to modify the master configuration file and enable (uncommenting the lines) the "file_roots" (consult the documentation of [File_Server]).

```sh
$ /etc/salt/master
```
N.B. If is possible to leave a standard file_root and not change the default configuration.

Now you must put the smeupStats.py in the master-machine under this path (if the file_roots is leave as default, otherwise it will must put under the custom path choosed by user).

```sh
$ cd /srv/salt/_minions/
```

Run this command for send a script to all minions (and syncronize all).
(or change the '*' to a valid target minions, see a [Targeting] documentation)

```sh
$ salt '*' saltutil.sync_modules
```

If all the previous operation was succesfull do, try to run from the master terminal this command:
```sh
$ salt '*' smeupStats.get_stats
```
(or change the '*' to a valid target minions, see a [Targeting] documentation)

The other commands that we can ask are:
```sh
$ salt '*' smeupStats.get_uptime
$ salt '*' smeupStats.get_user_logged
$ salt '*' smeupStats.get_avg
$ salt '*' smeupStats.get_avg
$ salt '*' smeupStats.get_memory
$ salt '*' smeupStats.get_swap
$ salt '*' smeupStats.get_network_ip_addrs
$ salt '*' smeupStats.get_connection_check
```

[Rest-Cherrypy]: <https://docs.saltstack.com/en/latest/ref/netapi/all/salt.netapi.rest_cherrypy.html>
[File_Server]: <https://docs.saltstack.com/en/latest/ref/file_server/file_roots.html>
[Targeting]: <https://docs.saltstack.com/en/latest/topics/targeting/>
