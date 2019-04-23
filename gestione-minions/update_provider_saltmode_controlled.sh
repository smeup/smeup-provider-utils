#!/bin/bash
MINION=$1
NOW=`date`
echo $NOW $SUDO_USER $MINION >> /home/ec2-user/gestione-minions/update_provider_saltmode.log
regex='s[0-9]{6}\.[0-9]{3}'
if [[ "$MINION" =~ $regex ]];
then
echo "Aggiorno provider su minion "$MINION
sudo salt $MINION state.apply update_provider_saltmode runas=smeup
#salt "$MINION" test.ping 
else
echo "Formato parametro non consentito. Supportato sNNNNNN.NNN"
fi
