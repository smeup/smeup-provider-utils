#!/bin/bash
if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

if [[ $# -ne 1 ]] ; then
  echo "Usage: $0 IDMINION" >&2
  exit 1
fi

if [[ ! -f /etc/salt/pki/master/minions/$1 ]] ; then
  echo "Minions not exists :  $1" >&2
  exit 1
fi


LOGFILE=/home/ec2-user/gestione-minions/log/inviaLab/$1.log

echo check http su minion $1 LOGFILE: $LOGFILE
echo check http su minion $1 eseguito il `date '+%d/%m/%Y %H:%M:%S'` > $LOGFILE

sudo salt $1 state.apply recuperalog  >> $LOGFILE.salt
#cat $LOGFILE.salt 
cat $LOGFILE.salt > $LOGFILE

LOGSTGZ=/var/cache/salt/master/minions/$1/files/home/smeup/container/smeup-provider-fe/logs.tgz

if [[ ! -f $LOGSTGZ ]] ; then
  echo "Logs tgz not transferred for minion $1" >&2
  exit 1
fi

sftp smartkit-logs@sftp.smeup.com << EOF
 put $LOGSTGZ logs-$1-`date +%Y-%m-%d`.tgz
 quit
EOF

RETVAL=$?
if [ $RETVAL -eq 0 ]; then
    echo "Transfer OK" >> $LOGFILE.sftp
else
    echo "Transfer Trouble : $RETVAL " >> $LOGFILE.sftp
fi

cat $LOGFILE.sftp 
cat $LOGFILE.sftp >> $LOGFILE 

if [ $RETVAL -eq 0 ]; then
    rm $LOGFILE.sftp
    rm $LOGSTGZ
fi

