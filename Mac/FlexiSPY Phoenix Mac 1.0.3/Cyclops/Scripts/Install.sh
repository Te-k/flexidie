#!/bin/bash

# Exit when a command fails
set -o errexit

# Error when unset variables are found
set -o nounset

SSMP_CYDIA_INSTALL=$1

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
SSMP_LOG_FILE=$SSMP_LOG_HOME/.install-$SSMP_IDENTIFIER.log

# ----------------------------------------------------------------------
# Remove existing installation log file
# ----------------------------------------------------------------------
rm -f $SSMP_LOG_FILE
echo "Start! SSMP_CYDIA_INSTALL=$SSMP_CYDIA_INSTALL ..." >> $SSMP_LOG_FILE

# ----------------------------------------------------------------------
# Clean up any previous installations or processes
# ----------------------------------------------------------------------
set +o errexit

# Stop daemon com.app.ssmp.plist
echo "launchctl stop $SSMP_DAEMON_PLIST_NAME" >> $SSMP_LOG_FILE
launchctl stop $SSMP_DAEMON_PLIST_NAME

# Remove daemon com.app.ssmp.plist
echo "launchctl remove $SSMP_DAEMON_PLIST_NAME" >> $SSMP_LOG_FILE
launchctl remove $SSMP_DAEMON_PLIST_NAME

# Remove daemon direcotry /usr/libexec/.ssmp
echo "rm -fr $SSMP_DAEMON_HOME" >> $SSMP_LOG_FILE
rm -fr $SSMP_DAEMON_HOME

# Remove /System/Library/LaunchDaemons/com.app.ssmp.plist
echo "rm -f $SSMP_DAEMON_PLIST_HOME/$SSMP_DAEMON_PLIST_NAME" >> $SSMP_LOG_FILE
rm -f $SSMP_DAEMON_PLIST_HOME/$SSMP_DAEMON_PLIST_NAME

# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP.dylib
echo "rm -f $SSMP_MS_HOME/.$SSMP_MS_NAME_COMMON" >> $SSMP_LOG_FILE
rm -f $SSMP_MS_HOME/.$SSMP_MS_NAME_COMMON

# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSSPC.dylib
echo "rm -f $SSMP_MS_HOME/.$SSMP_MS_NAME_HEART" >> $SSMP_LOG_FILE
rm -f $SSMP_MS_HOME/.$SSMP_MS_NAME_HEART

# Exit when a command fails
set -o errexit

# ----------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------

if [ "$SSMP_CYDIA_INSTALL" = "YES" ]; then

    # Create daemon home directory /usr/libexec/.ssmp
	echo "mkdir -p $SSMP_DAEMON_HOME" >> $SSMP_LOG_FILE
	mkdir -p $SSMP_DAEMON_HOME
	
    # Change mode of /usr/libexec/.ssmp to read/write/execute
	echo "chmod 777 $SSMP_DAEMON_HOME" >> $SSMP_LOG_FILE
	chmod 777 $SSMP_DAEMON_HOME
	
    # Copy /Applications/ssmp.app /usr/libexec/.ssmp/ssmp
	echo "cp -f $SSMP_BUNDLE_HOME $SSMP_DAEMON_HOME/$SSMP_DAEMON_NAME" >> $SSMP_LOG_FILE
	cp -fr $SSMP_BUNDLE_HOME $SSMP_DAEMON_HOME/$SSMP_DAEMON_NAME

    # Change mode of /usr/libexec/.ssmp/ssmp to 6555
	echo "chmod 6555 $SSMP_DAEMON_HOME/$SSMP_DAEMON_NAME" >> $SSMP_LOG_FILE
	chmod 6555 $SSMP_DAEMON_HOME/$SSMP_DAEMON_NAME
	
	# Copy daemon's plist /Applications/ssmp.app/com.app.ssmp.plist to /System/Library/LaunchDaemons/com.app.ssmp.plist
	# Auto start daemon when phone is reboot or crash
	echo "cp -f $SSMP_BUNDLE_HOME/$SSMP_DAEMON_PLIST_NAME $SSMP_DAEMON_PLIST_HOME/$SSMP_DAEMON_PLIST_NAME" >> $SSMP_LOG_FILE
	cp -fr $SSMP_BUNDLE_HOME/$SSMP_DAEMON_PLIST_NAME $SSMP_DAEMON_PLIST_HOME/$SSMP_DAEMON_PLIST_NAME

    # Copy mobile substrate /Applications/ssmp.app/MSFSP.dylib to /Library/MobileSubstrate/DynamicLibraries/.MSFSP.dylib
	echo "cp -f $SSMP_BUNDLE_HOME/$SSMP_MS_NAME_COMMON $SSMP_MS_HOME/.$SSMP_MS_NAME_COMMON" >> $SSMP_LOG_FILE
	cp -f $SSMP_BUNDLE_HOME/$SSMP_MS_NAME_COMMON $SSMP_MS_HOME/.$SSMP_MS_NAME_COMMON
	chmod 777 $SSMP_MS_HOME/.$SSMP_MS_NAME_COMMON
	
	# Copy mobile substrate /Applications/ssmp.app/MSFSP.dylib to /Library/MobileSubstrate/DynamicLibraries/.MSSPC.dylib
	echo "cp -f $SSMP_BUNDLE_HOME/$SSMP_MS_NAME_HEART $SSMP_MS_HOME/.$SSMP_MS_NAME_HEART" >> $SSMP_LOG_FILE
	cp -f $SSMP_BUNDLE_HOME/$SSMP_MS_NAME_HEART $SSMP_MS_HOME/.$SSMP_MS_NAME_HEART
	chmod 777 $SSMP_MS_HOME/.$SSMP_MS_NAME_HEART

    # Create daemon private directory /var/.ssmp
    echo "mkdir -p $SSMP_PRIVATE_HOME" >> $SSMP_LOG_FILE
    mkdir -p $SSMP_PRIVATE_HOME

    # Change mode of /var/.ssmp to read/write/execute
    echo "chmod 777 $SSMP_DAEMON_HOME" >> $SSMP_LOG_FILE
    chmod 777 $SSMP_PRIVATE_HOME
	
	# Load daemon /System/Library/LaunchDaemons/com.app.ssmp.plist
	echo "launchctl load $SSMP_DAEMON_PLIST_HOME/$SSMP_DAEMON_PLIST_NAME" >> $SSMP_LOG_FILE
	launchctl load $SSMP_DAEMON_PLIST_HOME/$SSMP_DAEMON_PLIST_NAME
	
	sleep 2
	#killall SpringBoard
	#respring
	exit 0
	
fi


