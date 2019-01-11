#!/bin/bash

if [ $(id -u) -ne 0 ]; then echo "Please run as root" ; exit 1 ; fi

function usage {
	echo "Usage: `basename "$0"` [MINION-ID] [USER] [PASSWORD]" >&2
}

rm /etc/salt/pki/minion/minion.pem
rm /etc/salt/pki/minion/minion.pub
cat /dev/null > /etc/salt/minion_id
/etc/salt/minion.d/id.conf

curl -L https://bootstrap.saltstack.com -o install_salt.sh
sh install_salt.sh -P

systemctl disable salt-minion
systemctl stop salt-minion

function usage {
	echo "Usage: `basename "$0"` [MINION-ID] [USER] [PASSWORD]" >&2
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	usage
	exit 0
fi

if [ $# -ne 3 ]
  then
    usage
    exit 0
fi

MASTER=rm.smeup.com

MINION=$1
USERNAME=$2
PASSWORD=$3

#mkdir -p /etc/salt/pki/minion
curl -sS https://${MASTER}/keys \
        -d mid=${MINION} \
        -d username=${USERNAME} \
        -d password=${PASSWORD} \
        -d eauth=pam \
    | tar --touch -C /etc/salt/pki/minion -xf -

mkdir -p /etc/salt/minion.d
printf "master: ${MASTER}\nid: ${MINION}" > /etc/salt/minion.d/id.conf

systemctl enable salt-minion
systemctl start salt-minion

