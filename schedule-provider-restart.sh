#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

RUN_AS="smeup"

su --login $RUN_AS -c  'mkdir -p $HOME/bin'

#Create functions file
su --login $RUN_AS -c 'cat > "$HOME/bin/functions"' << 'EOF'
#!/bin/bash

function restart_container() {
        CONTAINER_ID=$(docker container ps -q --filter "name=$1")
        if [ -n "$CONTAINER_ID" ]; then
                docker restart $CONTAINER_ID
        fi
}

EOF

#Create restart-provider file
RESTART_PROVIDER_FILE=restart-provider
su --login $RUN_AS -c "cat > \$HOME/bin/$RESTART_PROVIDER_FILE" << 'EOF'
#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $DIR/functions

cd $DIR

logger "Restarting provider"
restart_container smeup-provider-fe

EOF
su --login $RUN_AS -c "chmod u+x \$HOME/bin/$RESTART_PROVIDER_FILE"

#Create set-restart-provider-time file
SET_RESTART_PROVIDER_TIME_FILE=set-restart-provider-time
su --login $RUN_AS -c "cat > \$HOME/bin/$SET_RESTART_PROVIDER_TIME_FILE" << EOF
#!/bin/bash

usage() {

        echo "Usage: \$0 HH:MM"
}

TIME=\$(date +"%H:%M" -d "\$1" 2> /dev/null)
DATE_PARSE_EXIT_STATUS=$?

if [ \$DATE_PARSE_EXIT_STATUS -ne 0  ]  
then
  usage 
  exit
fi

read HH MM <<< \${TIME//[-:]/ }

(echo "\$MM \$HH * * * \$HOME/bin/$RESTART_PROVIDER_FILE"; crontab -l 2> /dev/null) | uniq -f 5 - | crontab -

EOF
su --login $RUN_AS -c "chmod u+x \$HOME/bin/$SET_RESTART_PROVIDER_TIME_FILE"

su --login $RUN_AS -c "/home/$RUN_AS/bin/$SET_RESTART_PROVIDER_TIME_FILE 4:17"
