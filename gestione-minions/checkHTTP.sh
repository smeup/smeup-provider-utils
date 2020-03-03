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

LOGFILE=/home/ec2-user/gestione-minions/log/checkHTTP/$1.log

echo check http su minion $1 LOGFILE: $LOGFILE
echo check http su minion $1 eseguito il `date '+%d/%m/%Y %H:%M:%S'` > $LOGFILE

sudo salt $1 http.query http://127.0.0.1:8080/smeup-provider-fe/ProbesService/connectivity >> $LOGFILE.con
echo Check Connectivity : 
cat $LOGFILE.con | grep Status
sudo salt $1 http.query http://127.0.0.1:8080/smeup-provider-fe/ProbesService/appserver >> $LOGFILE.app
echo Check App : 
cat $LOGFILE.app | grep Status
sudo salt $1 http.query http://127.0.0.1:8080/smeup-provider-fe/ProbesService/folders >> $LOGFILE.fol
echo Check Folders : 
cat $LOGFILE.fol | grep Status
sudo salt $1 http.query http://127.0.0.1:8080/smeup-provider-fe/ProbesService/queues >> $LOGFILE.que
echo Check Queues : 
cat $LOGFILE.que | grep Status
sudo salt $1 http.query http://127.0.0.1:8080/smeup-provider-fe/ProbesService/version >> $LOGFILE.ver
echo Check Version : 
cat $LOGFILE.ver | grep Status

cat $LOGFILE.con $LOGFILE.app $LOGFILE.fol $LOGFILE.que $LOGFILE.ver >> $LOGFILE

rm $LOGFILE.con
rm $LOGFILE.app
rm $LOGFILE.fol
rm $LOGFILE.que
rm $LOGFILE.ver

