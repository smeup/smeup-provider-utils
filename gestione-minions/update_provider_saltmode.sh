#!/bin/bash
MINION=$1
NOW=`date`
LOGFILE="/home/ec2-user/gestione-minions/update_provider_saltmode_saltlog.log"
# echo "Log su "$LOGFILE
echo "*******************************************************" >> "$LOGFILE"

echo $NOW $SUDO_USER "$MINION" >> "$LOGFILE"

echo "*******************************************************" >> "$LOGFILE"

# echo $NOW $SUDO_USER $MINION >> /home/ec2-user/gestione-minions/update_provider_saltmode.log
echo "Aggiorno provider su minion "$MINION
salt $MINION -b 20 state.apply update_provider_saltmode runas=smeup 2>&1 | tee -a "$LOGFILE"
