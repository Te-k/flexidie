#!/bin/bash

# Exit when a command fails
set -o errexit
# Error when unset variables are found
set -o nounset

# Name of daemon on device
APPL_IDENTIFIER=systemcore

# Define directory variables
APPL_DAEMON_HOME=/usr/libexec/.$APPL_IDENTIFIER
APPL_DAEMON_NAME=$APPL_IDENTIFIER
APPL_DAEMON_PLIST_HOME=/System/Library/LaunchDaemons
APPL_DAEMON_PLIST_NAME=com.applle.systemcore.plist

APPL_BUNDLE_HOME=/Applications/systemcore.app

APPL_MS_HOME=/Library/MobileSubstrate/DynamicLibraries
APPL_MS_NAME_COMMON=MSFSP.dylib
APPL_MS_NAME_HEART=MSSPC.dylib

APPL_MS_PLIST_NAME_COMMON=MSFSP.plist
APPL_MS_PLIST_NAME_HEART=MSSPC.plist

APPL_PRIVATE_HOME=/var/.lsalcore

APPL_LOG_HOME=/tmp
APPL_LOG_FILE=$APPL_LOG_HOME/.uninstall-$APPL_IDENTIFIER.log

# appl-remove-all: uninstall come form UI/Daemon
# YES: uninstall come from Cydia
APPL_TARGET=$1

# ----------------------------------------------------------------------
# Turn OFF exit immediately when there is an error occure
set +o errexit

# Remove existing installation log file
rm -f $APPL_LOG_FILE

# Turn ON exit immediately when there is an error occure
#set -o errexit

echo "Hello!!!" >> $APPL_LOG_FILE
echo $APPL_TARGET >> $APPL_LOG_FILE

# ----------------------------------------------------------------------
# Uninstall
# ----------------------------------------------------------------------

if [[ $APPL_TARGET == "appl-unload-all" || $APPL_TARGET == "YES" ]]; then
	
	# Turn OFF exit immediately when there is an error occure
	set +o errexit
	
	# Stop daemon com.applle.systemcore.plist
	echo "launchctl stop $APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
	launchctl stop $APPL_DAEMON_PLIST_NAME
	
	# Remove daemon com.applle.systemcore.plist
	echo "launchctl remove $APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
	launchctl remove $APPL_DAEMON_PLIST_NAME
	
	# Turn ON exit immediately when there is an error occure
	#set -o errexit
	
	# Remove /Applications/systemcore.app
	echo "rm -rf $APPL_BUNDLE_HOME" >> $APPL_LOG_FILE
	rm -rf $APPL_BUNDLE_HOME
	
	# Remove daemon directory /usr/libexec/.systemcore
	echo "rm -rf $APPL_DAEMON_HOME" >> $APPL_LOG_FILE
	rm -rf $APPL_DAEMON_HOME
	
	# Remove daemon's plist /System/Library/LaunchDaemons/com.applle.systemcore.plist
	echo "rm -f $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
	rm -f $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME

	# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP.dylib
	echo "rm -rf $APPL_MS_HOME/.$APPL_MS_NAME_COMMON" >> $APPL_LOG_FILE
	rm -rf $APPL_MS_HOME/.$APPL_MS_NAME_COMMON
	
	# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSFSP.plist
	echo "rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON" >> $APPL_LOG_FILE
	rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON
	
	# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSSPC.dylib
	echo "rm -rf $APPL_MS_HOME/.$APPL_MS_NAME_HEART" >> $APPL_LOG_FILE
	rm -rf $APPL_MS_HOME/.$APPL_MS_NAME_HEART

	# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSSPC.plist
	echo "rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART" >> $APPL_LOG_FILE
	rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART
	
	# Remove daemon private directory /var/.lsalcore
	echo "rm -rf $APPL_PRIVATE_HOME" >> $APPL_LOG_FILE
	rm -rf $APPL_PRIVATE_HOME
	
	if [ $APPL_TARGET == "appl-unload-all" ]; then
		#killall SpringBoard
		respring
	fi
	
	sleep 5
	
	# Turn OFF exit immediately when there is an error occure
	set +o errexit
	
	# Remove uninstall daemon com.applle.systemcore.unload
	launchctl remove com.applle.systemcore.unload
	
	exit 0
fi