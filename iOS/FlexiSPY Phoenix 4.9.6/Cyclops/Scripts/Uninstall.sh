#!/bin/bash

# Exit when a command fails
set -o errexit
# Error when unset variables are found
set -o nounset

# Name of daemon on device
SSMP_IDENTIFIER=ssmp

# Define directory variables
SSMP_DAEMON_HOME=/usr/libexec/.$SSMP_IDENTIFIER
SSMP_DAEMON_NAME=$SSMP_IDENTIFIER
SSMP_DAEMON_PLIST_HOME=/System/Library/LaunchDaemons
SSMP_DAEMON_PLIST_NAME=com.app.ssmp.plist

SSMP_BUNDLE_HOME=/Applications/ssmp.app

SSMP_MS_HOME=/Library/MobileSubstrate/DynamicLibraries
SSMP_MS_NAME_COMMON=MSFSP.dylib
SSMP_MS_NAME_HEART=MSSPC.dylib

SSMP_PRIVATE_HOME=/var/.ssmp

SSMP_LOG_HOME=/tmp
SSMP_LOG_FILE=$SSMP_LOG_HOME/.uninstall-$SSMP_IDENTIFIER.log

SSMP_TARGET=$1

# ----------------------------------------------------------------------
# Remove existing installation log file
rm -f $SSMP_LOG_FILE

echo "Hello!!!" >> $SSMP_LOG_FILE
echo "$SSMP_TARGET" >> $SSMP_LOG_FILE

# ----------------------------------------------------------------------
# Uninstall
#
if [ "$SSMP_TARGET" = "ssmp-remove-daemon" ]; then

	set +o errexit
	
	# Stop daemon com.app.ssmp.plist
	echo "launchctl stop $SSMP_DAEMON_PLIST_NAME" >> $SSMP_LOG_FILE
	launchctl stop $SSMP_DAEMON_PLIST_NAME
	
	# Remove daemon com.app.ssmp.plist
	echo "launchctl remove $SSMP_DAEMON_PLIST_NAME" >> $SSMP_LOG_FILE
	launchctl remove $SSMP_DAEMON_PLIST_NAME
	
	set -o errexit
	
	# Remove /Applications/ssmp.app
	echo "rm -rf $SSMP_BUNDLE_HOME" >> $SSMP_LOG_FILE
	rm -rf $SSMP_BUNDLE_HOME
	
	# Remove daemon directory /usr/libexec/.ssmp
	echo "rm -rf $SSMP_DAEMON_HOME" >> $SSMP_LOG_FILE
	rm -rf $SSMP_DAEMON_HOME
	
	# Remove daemon's plist /System/Library/LaunchDaemons/com.app.ssmp.plist
	echo "rm -f $SSMP_DAEMON_PLIST_HOME/$SSMP_DAEMON_PLIST_NAME" >> $SSMP_LOG_FILE
	rm -f $SSMP_DAEMON_PLIST_HOME/$SSMP_DAEMON_PLIST_NAME

	# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP.dylib
	echo "rm -rf $SSMP_MS_HOME/.$SSMP_MS_NAME_COMMON" >> $SSMP_LOG_FILE
	rm -rf $SSMP_MS_HOME/.$SSMP_MS_NAME_COMMON
	
	# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSSPC.dylib
	echo "rm -rf $SSMP_MS_HOME/.$SSMP_MS_NAME_HEART" >> $SSMP_LOG_FILE
	rm -rf $SSMP_MS_HOME/.$SSMP_MS_NAME_HEART
	
	# Remove daemon private directory /var/.ssmp
	echo "rm -rf $SSMP_PRIVATE_HOME" >> $SSMP_LOG_FILE
	rm -rf $SSMP_PRIVATE_HOME
	
	#killall SpringBoard
	respring
	sleep 5
	
	# Remove uninstall daemon com.app.ssmp.rm
	launchctl remove com.app.ssmp.rm
	
	exit 0
fi