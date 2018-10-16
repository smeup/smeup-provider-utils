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

restart_container smeup-provider-fe

EOF

su --login $RUN_AS -c "chmod u+x \$HOME/bin/$RESTART_PROVIDER_FILE"

cat > "/etc/cron.daily/$RESTART_PROVIDER_FILE" << EOF
#!/bin/bash

logger "Restarting provider" \$(date)

/home/$RUN_AS/bin/$RESTART_PROVIDER_FILE

EOF

chmod u+x /etc/cron.daily/$RESTART_PROVIDER_FILE

