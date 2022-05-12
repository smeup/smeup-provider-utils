#!/usr/bin/env bash
set -x
set -e
# Script da lanciare come demone tramite comando -d


###############################
# Global Variables definition #
###############################

NAME="defense-portscan.sh"
VERSION=0.0.1
AUTOUPDATE=1
SCRIPT_PATHFILE="/usr/local/sbin/$NAME"
CRON_PATFILE="/etc/cron.d/defense-portscan"
GITHUB_PROJECT="https://raw.githubusercontent.com/smeup/smeup-provider-utils/develop/utils/defensePortscan/defense-portscan.sh"

# Define 'port_scanners' and 'scanned_ports' maps properties
IPSET_RULE_1='port_scanners hash:ip family inet hashsize 32768 maxelem 65536 timeout 600'
IPSET_RULE_2='scanned_ports hash:ip,port family inet hashsize 32768 maxelem 65536 timeout 60'

# Drop all packets with INVALID state (Out-of-memory packets or ICMP error packets)
IPTABLE_RULE_1='INPUT -m state --state INVALID -j DROP' 
# Set properties for a new package incoming not match scanned_ports add to port_scanners
IPTABLE_RULE_2='INPUT -m state --state NEW -m set ! --match-set scanned_ports src,dst -m hashlimit --hashlimit-above 1/hour --hashlimit-burst 5 --hashlimit-mode srcip --hashlimit-name portscan --hashlimit-htable-expire 10000 -j SET --add-set port_scanners src --exist'
# Drop all packets that match the port_scanners properties
IPTABLE_RULE_3='INPUT -m state --state NEW -m set --match-set port_scanners src -j DROP'
# Add to scanned_ports all incoming new packets properties
IPTABLE_RULE_4='INPUT -m state --state NEW -j SET --add-set scanned_ports src,dst'


#################
# Function List #
#################

function checkMandatoryApps() {
	APP_NOT_FOUND=0
	for i in curl ipset iptables; do 
		! which $i > /dev/null && echo "Error - $i command not found, install it!!!" && APP_NOT_FOUND=1; 
	done
	
	if [ "$APP_NOT_FOUND" == "1" ]; then
		exit 10
	fi
}

#addWhitelistIPs() {
#}

function setCrontabExecution() {
	if [ ! -f "$CRON_PATFILE" ] || [ $(grep -c "reboot root sleep" "$CRON_PATFILE") -lt 1 ]; then
		echo -e "# $SCRIPT_PATHFILE installed at $(date)\n@reboot root sleep 30 && $CRON_PATFILE -d" > "$CRON_PATFILE"
		echo "Crontab added"
	else
		echo "Crontab already set"
	fi 
}

function update() {
	# Get github version
	GITHUB_VERSION=$(curl -s "$GITHUB_PROJECT" | awk -F'"' '/^VERSION/ {print $2}')
	
	# If no github variable founds
	[[ ! "$GITHUB_VERSION" ]] && echo "Error - Github version not found!!!" && exit 8	
	
	# If version is different, and exist cron file and are present and executable script file
	if [[ "$VERSION" != "$GITHUB_VERSION" ]] && [ -f "$CRON_PATFILE" ] && [ -x "$SCRIPT_PATHFILE" ]; then
		curl -s -o "$SCRIPT_PATHFILE" "$GITHUB_PROJECT"
		setCrontabExecution
	else
		echo "$SCRIPT_PATHFILE up to date"
	fi 
}

function install() {
	# Check existance of curl, ipset, iptables commands
	checkMandatoryApps
	
	setCrontabExecution
	
	# Copy script to $SCRIPT_PATHFILE
	INSTALLER_LOCATION=$(realpath $0)
	if [ "$INSTALLER_LOCATION" != "$SCRIPT_PATHFILE" ]; then
		curl -s -o "$SCRIPT_PATHFILE" "$GITHUB_PROJECT"  
		
		if [ -s "$SCRIPT_PATHFILE" ]; then 
			echo "$NAME has been copied in $SCRIPT_PATHFILE"
			chmod +x "$SCRIPT_PATHFILE"
		else
			echo "Error - Problem to download github file"
			exit 8
		fi
	fi
	
	# First cron like run to activate the iptable rules
	"$SCRIPT_PATHFILE" -d && echo "Iptable rules have been activated\n"
	
	# Finish
	echo "Install completed"
	echo -e "If you want to Edit Whitelist or Verify the install, just run the below command:\nsudo $SCRIPT_PATHFILE\n"
	
}

function uninstall() {
	loop=true;
		while $loop; do
			echo -e "Uninstall $NAME on $(hostname).\n"
			read -p "Are you sure? [y/n]: " var1
			loop=false;
			if [ "$var1" == 'Y' ] || [ "$var1" == 'y' ]; then
				echo "Starting uninstall...";
				
				# Remove crontab file
				if [ -f "$CRON_PATFILE" ]; then
					rm -r "$CRON_PATFILE"
					echo -e "\nCrontab file removed"
				else
					echo -e "\nCrontab file not found"
				fi

				# Remove the script
				[ -f "$SCRIPT_PATHFILE" ] && rm -f "$SCRIPT_PATHFILE" && echo -e "$NAME removed" || echo -e "Script not found"

				# Remove iptable rules
				N=1
				for IPTABLERULE in "$IPTABLE_RULE_1" "$IPTABLE_RULE_2" "$IPTABLE_RULE_3" "$IPTABLE_RULE_4"; do
					if [ $(iptables -S | grep -cF -- "-A $IPTABLERULE") -gt 0 ]; then
						iptables -D $IPTABLERULE
						echo -e "#$N iptable rule has been removed"
						(( N = N + 1 ))
					else
						echo -e "#$N iptable rule not found"
						(( N = N + 1 ))
					fi
				done

#				# Remove Whitelist rules
#				if [ -f $WHITELISTLOCATION ]; then
#					while read WHILELISTIP; do
#						# Validate IP address
#						if [[ "$WHILELISTIP" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
#							iptables -D INPUT -s $WHILELISTIP -j ACCEPT
#						fi
#					done < <(grep -v "^#\|^$" $WHITELISTLOCATION)
#					echo -e "Whitelist IPs removed from iptables if any. ${GR}OK.${NC}"
#				fi

#				# Remove Whitelist
#				[ -f "$WHITELISTLOCATION" ] && rm -f "$WHITELISTLOCATION" && echo -e "Whitelist removed. ${GR}OK.${NC}" || echo -e "Whitelist not found. ${GR}OK.${NC}"

				# Remove ipset rules
				for IPSETRULE in scanned_ports port_scanners; do
					if [ $(ipset list | grep -c "$IPSETRULE") -gt 0 ]; then
						sleep 1
						ipset destroy $IPSETRULE
						echo -e "$IPSETRULE ipset rule has been removed"
					else
						echo -e "$IPSETRULE ipset rule not found"
					fi
				done

				echo -e "\n Uninstall completed"
				
			else
				if [ "$var1" == 'N' ] || [ "$var1" == 'n' ]; then
					loop=false;
				else
					echo "Enter a valid response y or n";
					loop=true;
				fi
			fi
		done
}

function daemon-mode() {
	# Clear all existing iptables rules
	iptables -F
	iptables -X
	
	# Add rules to accept all traffic for whitelist IPs
	addWhitelistIPs
	
	# Add defensive rules
	[ $(ipset list | grep -c port_scanners) -lt 1 ] && ipset create $IPSET_RULE_1
	[ $(ipset list | grep -c scanned_ports) -lt 1 ] && ipset create $IPSET_RULE_2
	[ $(iptables -S | grep -cF -- "-A $IPTABLE_RULE_1") -lt 1 ] && iptables -A $IPTABLE_RULE_1
	[ $(iptables -S | grep -cF -- "-A $IPTABLE_RULE_2") -lt 1 ] && iptables -A $IPTABLE_RULE_2
	[ $(iptables -S | grep -cF -- "-A $IPTABLE_RULE_3") -lt 1 ] && iptables -A $IPTABLE_RULE_3
	[ $(iptables -S | grep -cF -- "-A $IPTABLE_RULE_4") -lt 1 ] && iptables -A $IPTABLE_RULE_4
	
	# Enable autoupdate if set
	[ "$AUTOUPDATE" == "1" ] && update
}

function helps() {
	echo -e "sudo bash <program_name> \n\
	-i      install rules and cron file\n
	-u      uninstall rules\n
	-d      daemon-mode with cronfile\n
	-a      update" && exit 0
}



################
# Main Program #
################

# Check root permission
[ ! $(id -u) = 0 ] && echo "Error - Run script as root!!!" && exit 5

# Check existance of curl, ipset, iptables commands
checkMandatoryApps
		
# Menu
case $1 in
    "-h") helps
    ;;
	"-i") install
	;;
	"-u") uninstall
	;;
	"-d") daemon-mode
	;;
	"-a") update
	;;
	*) echo "Error - Invalid command $1! Launch with '-h' command!"
	;;
esac

exit 0
