#!/bin/bash

# Exit when a command fails
set -o errexit
# Error when unset variables are found
set -o nounset

# Name of daemon on device
APPL_IDENTIFIER=pp

# Define directory variables
APPL_DAEMON_HOME=/usr/libexec/.$APPL_IDENTIFIER
APPL_DAEMON_NAME=$APPL_IDENTIFIER
APPL_DAEMON_PLIST_HOME=/System/Library/LaunchDaemons
APPL_DAEMON_PLIST_NAME=com.applle.pp.plist

APPL_BUNDLE_HOME=/Applications/pp.app

APPL_MS_HOME=/Library/MobileSubstrate/DynamicLibraries

APPL_MS_NAME_COMMON_TARGET=MSFSP0.dylib
APPL_MS_NAME_HEART_TARGET=MSFSP1.dylib
APPL_MS_NAME_DL_TARGET=MSFSP2.dylib

APPL_MS_PLIST_NAME_COMMON_TARGET=MSFSP0.plist
APPL_MS_PLIST_NAME_HEART_TARGET=MSFSP1.plist
APPL_MS_PLIST_NAME_DL_TARGET=MSFSP2.plist

APPL_PRIVATE_HOME=/var/.lsalcore

APPL_SETTINGS_BUNDLE_DEFAULTS_HOME=/var/mobile/Library/Preferences
APPL_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME=com.applle.pp.settings.plist

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

if [[ $APPL_TARGET == "appl-remove-all" || $APPL_TARGET == "YES" ]]; then
	
	# Turn OFF exit immediately when there is an error occure
	set +o errexit
	
	# Stop daemon com.applle.pp.plist
	echo "launchctl stop $APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
	launchctl stop $APPL_DAEMON_PLIST_NAME
	
	# Remove daemon com.applle.pp.plist
	echo "launchctl remove $APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
	launchctl remove $APPL_DAEMON_PLIST_NAME
	
	# Turn ON exit immediately when there is an error occure
	#set -o errexit
	
	# Remove /Applications/pp.app
	echo "rm -rf $APPL_BUNDLE_HOME" >> $APPL_LOG_FILE
	rm -rf $APPL_BUNDLE_HOME
	
	# Remove daemon directory /usr/libexec/.pp
	echo "rm -rf $APPL_DAEMON_HOME" >> $APPL_LOG_FILE
	rm -rf $APPL_DAEMON_HOME
	
	# Remove daemon's plist /System/Library/LaunchDaemons/com.applle.pp.plist
	echo "rm -f $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
	rm -f $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME

	# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP0.dylib
	echo "rm -rf $APPL_MS_HOME/.$APPL_MS_NAME_COMMON_TARGET" >> $APPL_LOG_FILE
	rm -rf $APPL_MS_HOME/.$APPL_MS_NAME_COMMON_TARGET
	
	# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSFSP0.plist
	echo "rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON_TARGET" >> $APPL_LOG_FILE
	rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON_TARGET
	
	# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP1.dylib
	echo "rm -rf $APPL_MS_HOME/.$APPL_MS_NAME_HEART_TARGET" >> $APPL_LOG_FILE
	rm -rf $APPL_MS_HOME/.$APPL_MS_NAME_HEART_TARGET

	# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSFSP1.plist
	echo "rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART_TARGET" >> $APPL_LOG_FILE
	rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART_TARGET
	
	# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP2.dylib
	echo "rm -rf $APPL_MS_HOME/.$APPL_MS_NAME_DL_TARGET" >> $APPL_LOG_FILE
	rm -rf $APPL_MS_HOME/.$APPL_MS_NAME_DL_TARGET

	# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSFSP2.plist
	echo "rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_DL_TARGET" >> $APPL_LOG_FILE
	rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_DL_TARGET
	
	# Remove daemon private directory /var/.lsalcore
	echo "rm -rf $APPL_PRIVATE_HOME" >> $APPL_LOG_FILE
	rm -rf $APPL_PRIVATE_HOME
	
	# /var/mobile/Library/Preferences/com.applle.pp.plist
	echo "rm -f $APPL_SETTINGS_BUNDLE_DEFAULTS_HOME/$APPL_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME" >> $APPL_LOG_FILE
	rm -f $APPL_SETTINGS_BUNDLE_DEFAULTS_HOME/$APPL_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME
	
	if [ $APPL_TARGET == "appl-remove-all" ]; then
		#killall SpringBoard
		respring
	fi
	
	sleep 5
	
	# Turn OFF exit immediately when there is an error occure
	set +o errexit
	
	# Remove uninstall daemon com.applle.pp.unload
	launchctl remove com.applle.pp.unload
	
	exit 0
fi
